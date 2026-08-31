import AVFoundation
import BlinkID
import Flutter
import UIKit

private final class CameraContainerView: UIView {
  weak var previewLayer: AVCaptureVideoPreviewLayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    previewLayer?.frame = bounds
  }
}

public class BlinkIdScannerView: NSObject, FlutterPlatformView {
  private let containerView: CameraContainerView
  private let viewId: Int64
  private let creationParams: [String: Any]
  private let sdkProvider: () -> AnyObject?

  private let methodChannel: FlutterMethodChannel
  private let eventChannel: FlutterEventChannel
  private var guidanceEventSink: FlutterEventSink?

  private var captureSession: AVCaptureSession?
  private var previewLayer: AVCaptureVideoPreviewLayer?
  private var videoOutput: AVCaptureVideoDataOutput?
  private let _lock = NSLock()
  private var isScanning = false
  private var isProcessingResult = false
  private var isProcessingFrame = false
  private var currentFrameOrientation: CameraFrameVideoOrientation = .portrait
  private var debugLoggingEnabled = false
  private var blinkIdSession: BlinkIDSession?
  private var _startScanTask: Task<Void, Never>?
  private var cameraSetupFailed = false
  private var preferredCameraOverride: String?
  private var pendingCameraResult: FlutterResult?

  // Serializes AVCaptureSession.startRunning()/stopRunning() — both are
  // documented by Apple as blocking, so neither belongs on the main thread.
  // Being one serial queue, fed only from the main thread in call order,
  // also prevents a stale session's queued start from running after a later
  // switchCamera()/teardown() has already stopped and detached it.
  private let sessionQueue: DispatchQueue

  init(
    frame: CGRect,
    viewId: Int64,
    messenger: FlutterBinaryMessenger,
    creationParams: [String: Any],
    sdkProvider: @escaping () -> AnyObject?,
  ) {
    self.viewId = viewId
    self.creationParams = creationParams
    self.sdkProvider = sdkProvider
    self.containerView = CameraContainerView(frame: frame)

    methodChannel = FlutterMethodChannel(
      name: "com.microblink.blinkid.flutter/scanner/\(viewId)",
      binaryMessenger: messenger,
    )
    eventChannel = FlutterEventChannel(
      name: "com.microblink.blinkid.flutter/scanner/\(viewId)/guidance",
      binaryMessenger: messenger,
    )
    sessionQueue = DispatchQueue(label: "com.microblink.blinkid.scanner.session.\(viewId)")

    super.init()

    eventChannel.setStreamHandler(self)
    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleMethodCall(call, result: result)
    }

    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(deviceOrientationDidChange),
      name: UIDevice.orientationDidChangeNotification,
      object: nil,
    )

    setupCamera()
  }

  public func view() -> UIView { containerView }

  @objc private func deviceOrientationDidChange() {
    updateVideoOrientation()
  }

  private func updateVideoOrientation() {
    let deviceOrientation = UIDevice.current.orientation
    guard deviceOrientation.isValidInterfaceOrientation else { return }

    _lock.withLock { currentFrameOrientation = deviceOrientation.cameraFrameOrientation }

    let isFront = preferredCameraOverride == "front"

    if #available(iOS 17.0, *) {
      let angle = deviceOrientation.videoRotationAngle
      videoOutput?.connection(with: .video)?.videoRotationAngle = angle
      // The front camera sensor is mounted 180° rotated relative to the back
      // camera. In landscape this cancels out with the usual rotation, so we
      // use the opposite landscape angle for the preview layer only. Portrait
      // angles are the same for both cameras.
      let previewAngle = (isFront && deviceOrientation.isLandscape)
        ? deviceOrientation.frontCameraLandscapeRotationAngle : angle
      previewLayer?.connection?.videoRotationAngle = previewAngle
    } else {
      let avOrientation = deviceOrientation.avCaptureOrientation
      videoOutput?.connection(with: .video)?.videoOrientation = avOrientation
      let previewOrientation = (isFront && deviceOrientation.isLandscape)
        ? deviceOrientation.frontCameraLandscapeAvOrientation : avOrientation
      previewLayer?.connection?.videoOrientation = previewOrientation
    }

    if isFront {
      previewLayer?.connection?.isVideoMirrored = true
    }
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startScan":
      startScan(result: result)
    case "cancelScan":
      // Abort an in-flight startScan so a session created after this cancel
      // can never be installed — see startScan()'s checkCancellation().
      _startScanTask?.cancel()
      _startScanTask = nil
      _lock.withLock {
        isScanning = false
        isProcessingResult = false
        blinkIdSession = nil
      }
      result(nil)
    case "resumeAfterFlip":
      _lock.withLock { isScanning = true }
      result(nil)
    case "retryCamera":
      abortPendingCameraResult("Camera retry superseded")
      pendingCameraResult = result
      cameraSetupFailed = false
      // Only reachable today right after a permission denial, where no
      // session exists yet — but performCameraSetup() unconditionally builds
      // a new session/preview sublayer without detaching a prior one (unlike
      // Android's performCameraSetup, which self-protects via unbindAll()).
      // Stop first so this stays correct if retryCamera is ever reachable
      // with a running session.
      stopCaptureSession()
      setupCamera()
    case "switchCamera":
      _startScanTask?.cancel()
      _startScanTask = nil
      abortPendingCameraResult("Camera switch superseded")
      _lock.withLock {
        isScanning = false
        blinkIdSession = nil
      }
      preferredCameraOverride = call.arguments as? String
      cameraSetupFailed = false
      // Deferred until the camera has actually rebound (or definitively
      // failed) — see completeCameraResult(), called from performCameraSetup()
      // and handleCameraPermissionDenied().
      pendingCameraResult = result
      stopCaptureSession()
      setupCamera()
    case "setDebugLogging":
      _lock.withLock { debugLoggingEnabled = (call.arguments as? Bool) ?? false }
      result(nil)
    case "dispose":
      teardown()
      // Dart sends 'cancel' before 'dispose' on the same binary-messenger
      // queue, so onCancel has already fired and guidanceEventSink is nil.
      // Clearing the handler now releases the strong reference without risk
      // of MissingPluginException.
      eventChannel.setStreamHandler(nil)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startScan(result: @escaping FlutterResult) {
    if cameraSetupFailed {
      result(FlutterError(code: "blinkid_error", message: "Camera unavailable", details: nil))
      return
    }
    guard let sdk = sdkProvider() as? BlinkIDSdk else {
      result(FlutterError(code: "blinkid_error", message: "SDK not initialized", details: nil))
      return
    }
    guard let sessionSettingsDict = creationParams["sessionSettings"] as? [String: Any] else {
      result(FlutterError(code: "blinkid_error", message: "Missing sessionSettings", details: nil))
      return
    }
    _startScanTask?.cancel()
    _startScanTask = Task { @MainActor [weak self] in
      guard let self else { return }
      do {
        let sessionSettings = BlinkIdDeserializationUtils.deserializeBlinkIdSessionSettings(
          sessionSettingsDict,
          source: "customScanner"
        )
        let session = try await sdk.createScanningSession(sessionSettings: sessionSettings)
        try Task.checkCancellation()
        self._lock.withLock {
          self.blinkIdSession = session
          self.isScanning = true
        }
        self._startScanTask = nil
        result(nil)
      } catch is CancellationError {
        result(FlutterError(code: "blinkid_error", message: "Scanner disposed", details: nil))
      } catch {
        result(FlutterError(code: "blinkid_error", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func setupCamera() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      performCameraSetup()
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        DispatchQueue.main.async {
          if granted {
            self?.performCameraSetup()
          } else {
            // User denied the system prompt — not permanently denied yet
            // (they can still grant via Settings).
            self?.handleCameraPermissionDenied(permanentlyDenied: false)
          }
        }
      }
    case .denied:
      // User previously denied and must re-enable in Settings.
      handleCameraPermissionDenied(permanentlyDenied: true)
    case .restricted:
      // Device policy prevents camera access entirely.
      handleCameraPermissionDenied(permanentlyDenied: true)
    @unknown default:
      performCameraSetup()
    }
  }

  private func handleCameraPermissionDenied(permanentlyDenied: Bool) {
    cameraSetupFailed = true
    // No camera bind will happen on this pass — fail any deferred
    // switchCamera/retryCamera result rather than leaving it pending forever.
    completeCameraResult(
      resolvedLens: nil,
      error: permanentlyDenied ? "Camera permission permanently denied" : "Camera permission required",
    )
    methodChannel.invokeMethod(
      "onPermissionRequired",
      arguments: ["permanentlyDenied": permanentlyDenied],
    )
  }

  private func abortPendingCameraResult(_ message: String) {
    pendingCameraResult?(FlutterError(code: "blinkid_error", message: message, details: nil))
    pendingCameraResult = nil
  }

  // Completes the deferred switchCamera/retryCamera result once the camera has
  // actually bound (or definitively failed) — never on the calling turn.
  private func completeCameraResult(resolvedLens: String?, error: String?) {
    guard let pending = pendingCameraResult else { return }
    pendingCameraResult = nil
    if let error {
      pending(FlutterError(code: "blinkid_error", message: error, details: nil))
    } else {
      pending(resolvedLens)
    }
  }

  private func stopCaptureSession() {
    let session = captureSession
    captureSession = nil
    previewLayer?.removeFromSuperlayer()
    previewLayer = nil
    videoOutput = nil
    // stopRunning() is a blocking call (Apple's docs warn against calling it
    // on the main thread). All start/stop calls share sessionQueue, and it's
    // serial, so — since every enqueue below happens from the main thread in
    // call order — this stop is guaranteed to run after this same session's
    // own queued startRunning() and before any subsequent session's start.
    // That ordering alone is what prevents a stale session from being
    // resurrected after being detached here; no generation tracking needed.
    sessionQueue.async { session?.stopRunning() }
  }

  private func performCameraSetup() {
    let session = AVCaptureSession()
    session.sessionPreset = .high

    let position = resolvePosition(
      preferredCameraOverride ?? creationParams["preferredCamera"] as? String)
    let resolvedLens = position == .front ? "front" : "back"
    // Pin the lens actually resolved — not the request — so a subsequent
    // setupCamera() (permission grant, retry) doesn't re-attempt an
    // unavailable lens, and so callers can be told what's really live.
    preferredCameraOverride = resolvedLens

    guard
      let device = AVCaptureDevice.default(
        .builtInWideAngleCamera, for: .video, position: position),
      let input = try? AVCaptureDeviceInput(device: device)
    else {
      cameraSetupFailed = true
      completeCameraResult(resolvedLens: nil, error: "Camera device unavailable")
      methodChannel.invokeMethod("onScanError", arguments: "Camera device unavailable")
      return
    }

    let output = AVCaptureVideoDataOutput()
    output.alwaysDiscardsLateVideoFrames = true
    output.setSampleBufferDelegate(
      self,
      queue: DispatchQueue(label: "com.microblink.blinkid.scanner.\(viewId)"),
    )

    guard session.canAddInput(input), session.canAddOutput(output) else {
      cameraSetupFailed = true
      completeCameraResult(resolvedLens: nil, error: "Camera setup failed")
      methodChannel.invokeMethod("onScanError", arguments: "Camera setup failed")
      return
    }
    session.addInput(input)
    session.addOutput(output)
    self.videoOutput = output

    let preview = AVCaptureVideoPreviewLayer(session: session)
    preview.videoGravity = .resizeAspectFill
    preview.frame = containerView.bounds
    containerView.layer.addSublayer(preview)
    containerView.previewLayer = preview
    self.previewLayer = preview
    self.captureSession = session

    // Disable automatic mirroring before updateVideoOrientation() so our
    // manual isVideoMirrored call inside it isn't overridden by AVFoundation.
    if position == .front {
      preview.connection?.automaticallyAdjustsVideoMirroring = false
    }
    // Apply initial orientation (and front-camera mirroring) after connections exist.
    updateVideoOrientation()

    completeCameraResult(resolvedLens: resolvedLens, error: nil)
    // See stopCaptureSession()'s comment: sharing one serial queue for every
    // start/stop call, always enqueued in main-thread call order, is what
    // keeps this session's start from running after a later stop/start.
    sessionQueue.async { session.startRunning() }
  }

  // Returns the position that will actually be bound: .front only if
  // requested and available, .back otherwise (including any unrecognized
  // request).
  private func resolvePosition(_ preferred: String?) -> AVCaptureDevice.Position {
    if preferred == "front",
      AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
    {
      return .front
    }
    return .back
  }

  // Atomically claims the next frame for processing. Returns the active session
  // if scanning is active and no other frame or result is in flight; nil otherwise.
  private func _claimFrame() -> BlinkIDSession? {
    _lock.withLock {
      guard isScanning, !isProcessingResult, !isProcessingFrame,
            let s = blinkIdSession else { return nil }
      isProcessingFrame = true
      return s
    }
  }

  private func teardown() {
    _startScanTask?.cancel()
    _startScanTask = nil
    abortPendingCameraResult("Scanner disposed")
    NotificationCenter.default.removeObserver(
      self, name: UIDevice.orientationDidChangeNotification, object: nil)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
    _lock.withLock {
      isScanning = false
      blinkIdSession = nil
    }
    stopCaptureSession()
    methodChannel.setMethodCallHandler(nil)
    // Null the sink immediately so no events are emitted after teardown.
    // The StreamHandler is unregistered in the "dispose" method-channel
    // handler, which runs after Dart's 'cancel' has already arrived.
    guidanceEventSink = nil
  }
}

extension BlinkIdScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
  public func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection,
  ) {
    guard let session = _claimFrame() else { return }

    let frameOrientation = _lock.withLock { currentFrameOrientation }
    let inputImage = InputImage(
      cameraFrame: CameraFrame(buffer: sampleBuffer, orientation: frameOrientation),
    )

    Task { @ProcessingActor [weak self] in
      guard let self else { return }
      defer { _lock.withLock { isProcessingFrame = false } }
      do {
        let frameResult = try await session.process(inputImage: inputImage)

        let debugEnabled = _lock.withLock { debugLoggingEnabled }
        if let sessionErr = frameResult.sessionError {
          await MainActor.run {
            if debugEnabled {
              self.methodChannel.invokeMethod(
                "onDebugLog", arguments: "process sessionError: \(sessionErr)")
            }
          }
        }

        let processingStatus = frameResult.processResult?.inputImageAnalysisResult.processingStatus
        if processingStatus == .scanningWrongSide {
          await MainActor.run {
            guard self.blinkIdSession === session else { return }
            self.guidanceEventSink?("wrongSide")
          }
        } else if let ia = frameResult.processResult?.inputImageAnalysisResult {
          let guidance: String
          if ia.blurDetectionStatus == .detected {
            guidance = "blur"
          } else if ia.glareDetectionStatus == .detected {
            guidance = "glare"
          } else {
            guidance = ia.documentDetectionStatus.guidanceString
          }
          await MainActor.run {
            guard self.blinkIdSession === session else { return }
            self.guidanceEventSink?(guidance)
          }
        }

        let status = session.getScanningStatus()

        switch status {
        case .sideScanned:
          _lock.withLock { self.isScanning = false }
          await MainActor.run {
            guard self.blinkIdSession === session else { return }
            if debugEnabled {
              self.methodChannel.invokeMethod(
                "onDebugLog", arguments: "SideScanned — pausing for flip")
            }
            self.guidanceEventSink?("flipDocument")
          }

        case .documentScanned:
          let alreadyProcessing = _lock.withLock { () -> Bool in
            guard !self.isProcessingResult else { return true }
            self.isProcessingResult = true
            self.isScanning = false
            return false
          }
          guard !alreadyProcessing else { return }
          await MainActor.run {
            guard self.blinkIdSession === session else {
              self._lock.withLock { self.isProcessingResult = false }
              return
            }
            if debugEnabled {
              self.methodChannel.invokeMethod(
                "onDebugLog", arguments: "DocumentScanned — calling getResult()")
            }
            self.methodChannel.invokeMethod("onDocumentScanned", arguments: nil)
          }
          guard self.blinkIdSession === session else {
            _lock.withLock { isProcessingResult = false }
            return
          }
          let scanResult = session.getResult(redactionSettings: nil)
          let jsonString = BlinkIdSerializationUtils.serializeBlinkIdScanningResult(scanResult)
          await MainActor.run {
            guard self.blinkIdSession === session else {
              self._lock.withLock { self.isProcessingResult = false }
              return
            }
            self.methodChannel.invokeMethod("onScanResult", arguments: jsonString)
            self._lock.withLock {
              self.blinkIdSession = nil
              self.isProcessingResult = false
            }
          }

        default:
          break
        }
      } catch {
        let debugEnabled = _lock.withLock { debugLoggingEnabled }
        await MainActor.run {
          if debugEnabled {
            self.methodChannel.invokeMethod("onDebugLog", arguments: "process() threw: \(error)")
          }
        }
      }
    }
  }
}

extension BlinkIdScannerView: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    guidanceEventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    guidanceEventSink = nil
    return nil
  }
}

// MARK: - Orientation helpers

extension UIDeviceOrientation {
  fileprivate var cameraFrameOrientation: CameraFrameVideoOrientation {
    switch self {
    case .portraitUpsideDown: return .portraitUpsideDown
    case .landscapeLeft: return .landscapeLeft
    case .landscapeRight: return .landscapeRight
    default: return .portrait
    }
  }

  // AVCaptureVideoOrientation landscape axes are inverted vs UIDeviceOrientation.
  fileprivate var avCaptureOrientation: AVCaptureVideoOrientation {
    switch self {
    case .portraitUpsideDown: return .portraitUpsideDown
    case .landscapeLeft: return .landscapeRight
    case .landscapeRight: return .landscapeLeft
    default: return .portrait
    }
  }

  @available(iOS 17.0, *)
  fileprivate var videoRotationAngle: CGFloat {
    switch self {
    case .portraitUpsideDown: return 270
    case .landscapeLeft: return 0
    case .landscapeRight: return 180
    default: return 90
    }
  }

  // Front camera sensor is 180° rotated vs back in landscape, so swap the angles.
  @available(iOS 17.0, *)
  fileprivate var frontCameraLandscapeRotationAngle: CGFloat {
    switch self {
    case .landscapeLeft: return 180
    case .landscapeRight: return 0
    default: return videoRotationAngle
    }
  }

  // Pre-iOS 17 equivalent: back camera inverts the UIDevice landscape axes to get
  // AVCaptureVideoOrientation. Front camera skips the inversion (double-negative).
  fileprivate var frontCameraLandscapeAvOrientation: AVCaptureVideoOrientation {
    switch self {
    case .landscapeLeft: return .landscapeLeft
    case .landscapeRight: return .landscapeRight
    default: return avCaptureOrientation
    }
  }

}

extension DetectionStatus {
  fileprivate var guidanceString: String {
    switch self {
    case .cameraTooFar: return "tooFar"
    case .cameraTooClose: return "tooClose"
    case .documentTooCloseToCameraEdge: return "tooCloseToEdge"
    case .cameraAngleTooSteep: return "tilted"
    case .documentPartiallyVisible: return "notFullyVisible"
    default: return "searching"
    }
  }
}
