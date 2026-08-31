import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../blinkid_flutter_platform_interface.dart';
import '../blinkid_result.dart';
import '../blinkid_settings.dart';
import '../types.dart';
import 'blinkid_guidance.dart';

enum BlinkIdScannerStatus {
  uninitialized,

  /// SDK resources are downloading / license is being verified.
  loadingSdk,

  /// SDK loaded; platform view not yet attached.
  initializing,

  ready,
  scanning,

  /// [DocumentScanned] fired natively; awaiting result serialization and
  /// transfer. Transient — lasts milliseconds.
  processing,

  /// Result delivered. Transient — callers typically show a brief success UI
  /// then pop the screen.
  done,

  error,

  /// Camera permission has not been granted. Call
  /// [BlinkIdScannerController.retryAfterPermissionGrant] after the host app
  /// successfully grants the CAMERA permission.
  ///
  /// **Permission request responsibility:** this plugin detects the missing
  /// permission and reports it, but the host app owns the request flow.
  /// Use the `permission_handler` package (or platform-native APIs) to request
  /// `Permission.camera`, then call [BlinkIdScannerController.retryAfterPermissionGrant].
  ///
  /// The [BlinkIdCameraPermissionException] thrown by [BlinkIdScannerController.scan]
  /// carries a `permanentlyDenied` flag. When `true`, direct the user to open
  /// the system Settings instead of re-requesting. On Android, this flag may
  /// also be `true` on the very first launch before any prompt — use
  /// `permission_handler`'s `isPermanentlyDenied` for a definitive check.
  cameraPermissionRequired,
}

enum BlinkIdScanPhase {
  /// Scanning the front side.
  front,

  /// Front side complete. Show a flip animation, then call
  /// [BlinkIdScannerController.onFlipComplete] when the animation finishes so
  /// native scanning resumes. The phase remains [flip] until the camera
  /// produces its first frame after resuming — i.e. until the user has
  /// physically flipped the document. Failing to call [onFlipComplete] leaves
  /// the scanner paused indefinitely.
  ///
  /// Guidance events are suppressed during this phase; use [phase] instead.
  flip,

  /// User flipped the document; scanning the back side.
  back,
}

class BlinkIdScannerController extends ChangeNotifier {
  BlinkIdScannerStatus _status = BlinkIdScannerStatus.uninitialized;
  BlinkIdScannerStatus get status => _status;

  BlinkIdScanPhase _phase = BlinkIdScanPhase.front;
  BlinkIdScanPhase get phase => _phase;

  /// The last error set when [status] is [BlinkIdScannerStatus.error].
  /// Call [reset] to recover — the controller is reusable after an error.
  Exception? _lastError;
  Exception? get lastError => _lastError;

  // Stored so _awaitReady() can surface it when permission is denied before
  // the platform view reaches 'ready'.
  BlinkIdCameraPermissionException? _lastPermissionException;

  /// The last camera-permission exception set when [status] is
  /// [BlinkIdScannerStatus.cameraPermissionRequired].
  /// Use [permanentlyDenied] to decide between "open Settings" and
  /// "re-request permission + call [retryAfterPermissionGrant]".
  BlinkIdCameraPermissionException? get lastPermissionException => _lastPermissionException;

  final _guidanceController = StreamController<BlinkIdGuidance>.broadcast();
  BlinkIdGuidance? _lastEmittedGuidance;

  /// Guidance events emitted during scanning. Events are suppressed while
  /// [phase] is [BlinkIdScanPhase.flip]; use [phase] to drive flip UI instead.
  /// [BlinkIdGuidanceFlipDocument] is never emitted here — it drives the
  /// phase transition internally.
  ///
  /// Native emits one guidance value per analyzed frame (~30/s); only exact
  /// consecutive duplicates are collapsed here. Real detection is noisy
  /// frame-to-frame — e.g. `wrongSide` and `searching` alternating near a
  /// boundary — so consecutive *different* values are delivered as-is. Bind
  /// this directly to UI and it will flicker; debounce and impose a minimum
  /// hold time on the display side first (see `_GuidanceOverlay` /
  /// `_onGuidance` in `custom_scanner_screen.dart` for a working example).
  Stream<BlinkIdGuidance> get guidanceStream => _guidanceController.stream;

  MethodChannel? _methodChannel;
  StreamSubscription<dynamic>? _guidanceSub;
  Completer<BlinkIdScanningResult>? _scanCompleter;
  final List<Completer<void>> _pendingReady = [];
  bool _debugLoggingEnabled = false;
  bool _disposed = false;

  PreferredCamera? _activeCamera;

  /// The camera lens actually bound natively, once known. May differ from the
  /// last-requested [PreferredCamera] — e.g. a `front` request silently
  /// resolves to `back` on a device with no front lens. `null` until the
  /// platform view's first camera bind completes.
  PreferredCamera? get activeCamera => _activeCamera;

  // True between onFlipComplete() and the first guidance event after resume.
  bool _awaitingBackSide = false;

  Map<String, dynamic> _creationParams = {};

  /// Internal: creation params forwarded to the native platform view.
  @internal
  Map<String, dynamic> get creationParams => _creationParams;

  /// Loads the BlinkID SDK (model download + license check) then prepares
  /// the controller for view attachment. Transitions to
  /// [BlinkIdScannerStatus.loadingSdk] during init so callers can render a
  /// loading indicator, then to [BlinkIdScannerStatus.initializing] once the
  /// SDK is ready and the platform view can be mounted.
  ///
  /// No-op if called more than once.
  Future<void> initialize(
    BlinkIdSdkSettings sdkSettings,
    BlinkIdSessionSettings sessionSettings, {
    PreferredCamera preferredCamera = PreferredCamera.back,
  }) async {
    if (_status != BlinkIdScannerStatus.uninitialized) return;
    _setStatus(BlinkIdScannerStatus.loadingSdk);
    try {
      await BlinkIdFlutterPlatform.instance.loadBlinkIdSdk(sdkSettings);
    } on PlatformException catch (e) {
      _setStatus(BlinkIdScannerStatus.uninitialized);
      throw BlinkIdSdkInitException(e.message ?? 'SDK load failed');
    }
    _setStatus(BlinkIdScannerStatus.initializing);
    _creationParams = {
      'sdkSettings': sdkSettings.toJson(),
      'sessionSettings': sessionSettings.toJson(),
      'preferredCamera': preferredCamera.name,
    };
  }

  /// Called by [BlinkIdScannerView] once the platform view is attached.
  /// Do not call this directly.
  @internal
  void onPlatformViewCreated(int id) {
    _guidanceSub?.cancel().ignore();
    _guidanceSub = null;
    final methodChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$id');
    final eventChannel = EventChannel('com.microblink.blinkid.flutter/scanner/$id/guidance');

    methodChannel.setMethodCallHandler(_handleMethodCall);
    _methodChannel = methodChannel;
    _guidanceSub = eventChannel.receiveBroadcastStream().listen(
      _onGuidanceEvent,
      onError: (Object e) {
        _guidanceController.addError(e);
        _failScan('Camera stream error: $e');
      },
    );

    if (_debugLoggingEnabled) {
      methodChannel.invokeMethod<void>('setDebugLogging', true).ignore();
    }

    _setStatus(BlinkIdScannerStatus.ready);
  }

  void _onGuidanceEvent(dynamic event) {
    // Same rationale as _handleMethodCall's guard: a guidance frame can still
    // be in flight when dispose() closes _guidanceController.
    if (_disposed) return;
    if (event is! String) return;
    final guidance = BlinkIdGuidance.fromString(event);

    switch (guidance) {
      case BlinkIdGuidanceFlipDocument():
        if (_phase == BlinkIdScanPhase.front) {
          _phase = BlinkIdScanPhase.flip;
          notifyListeners();
        }
        // Never emitted to guidanceStream; callers use phase instead.
        return;
      default:
        break;
    }

    // First event after resumeAfterFlip — user has flipped; go to back phase.
    if (_awaitingBackSide) {
      _awaitingBackSide = false;
      _phase = BlinkIdScanPhase.back;
      notifyListeners();
      // The same guidance value can mean something different on the new side
      // (e.g. "searching" on front vs. back) — force it through even if it's
      // identical to the last front-side value.
      _lastEmittedGuidance = null;
    }

    if (_phase == BlinkIdScanPhase.flip) return;

    // Collapse consecutive duplicates — see guidanceStream's doc comment.
    if (guidance == _lastEmittedGuidance) return;
    _lastEmittedGuidance = guidance;
    _guidanceController.add(guidance);
  }

  /// Resumes back-side scanning after the flip animation completes.
  ///
  /// **You must call this** after showing your flip animation; failure to do so
  /// leaves the scanner paused indefinitely. [phase] transitions from [flip]
  /// to [back] automatically once the camera produces its first frame, i.e.
  /// once the user has physically flipped the document.
  void onFlipComplete() {
    if (_phase != BlinkIdScanPhase.flip) return;
    _awaitingBackSide = true;
    _resumeAfterFlip();
  }

  /// Enables or disables native debug log forwarding to [debugPrint].
  ///
  /// When enabled, key lifecycle events (scan start, side scanned, errors) are
  /// forwarded from native via the method channel and printed with `[BlinkID]`
  /// prefix. Disabled by default — no channel traffic is incurred unless opted in.
  /// Safe to call before or after the platform view is created.
  void setDebugLogging(bool enabled) {
    _debugLoggingEnabled = enabled;
    _setDebugLogging(enabled);
  }

  /// Starts a scan session and returns the [BlinkIdScanningResult] on success.
  ///
  /// If the controller is still initializing (status [BlinkIdScannerStatus.loadingSdk]
  /// or [BlinkIdScannerStatus.initializing]), this call suspends and resumes
  /// automatically once the platform view is ready — so calling immediately
  /// after [initialize] is safe without an explicit status check.
  ///
  /// Throws [BlinkIdScanCancelException] on cancel, [BlinkIdScanResetException]
  /// on [reset], or [StateError] if [initialize] was never called.
  Future<BlinkIdScanningResult> scan() async {
    switch (_status) {
      case BlinkIdScannerStatus.loadingSdk || BlinkIdScannerStatus.initializing:
        await _awaitReady();
      case BlinkIdScannerStatus.ready:
        break;
      default:
        throw StateError('Controller not ready (status: $_status)');
    }

    final channel = _methodChannel;
    if (channel == null) throw StateError('Platform view not yet created');
    if (_scanCompleter != null) throw StateError('A scan is already in progress');

    _phase = BlinkIdScanPhase.front;
    _setStatus(BlinkIdScannerStatus.scanning);
    _scanCompleter = Completer<BlinkIdScanningResult>();
    // Capture before the await — _handleMethodCall can null _scanCompleter
    // during the async gap (e.g. onPermissionRequired fires mid-startScan).
    final completer = _scanCompleter!;
    // Silence unhandled-future errors: if _handleMethodCall completes the
    // completer (e.g. onPermissionRequired) before we reach `return completer.future`,
    // Dart would report the error as unhandled. ignore() marks it as handled now;
    // the actual error still propagates when the caller awaits completer.future.
    completer.future.ignore();

    try {
      await channel.invokeMethod<void>('startScan');
    } on PlatformException catch (e) {
      if (completer.isCompleted) {
        // _handleMethodCall already resolved this completer (e.g. onPermissionRequired
        // fired, notifyListeners tore down BlinkIdScannerView, and the native
        // dispose() replied to the pending startScan with "Scanner disposed").
        // Fall through and return completer.future so the caller sees the real error.
      } else {
        _lastError = Exception(e.message ?? 'startScan failed');
        _setStatus(BlinkIdScannerStatus.error);
        _scanCompleter = null;
        rethrow;
      }
    }

    return completer.future;
  }

  /// Cancels the current scan and returns to [BlinkIdScannerStatus.ready].
  /// The [Future] from [scan] completes with [BlinkIdScanCancelException].
  void cancel() {
    _cancelScan();
    switch (_status) {
      case BlinkIdScannerStatus.scanning || BlinkIdScannerStatus.processing:
        _abortWithCancel();
      case BlinkIdScannerStatus.initializing:
        final pending = List<Completer<void>>.from(_pendingReady);
        _pendingReady.clear();
        for (final c in pending) {
          if (!c.isCompleted) c.completeError(const BlinkIdScanCancelException());
        }
      default:
        break;
    }
  }

  /// Call after the host app successfully grants the CAMERA permission.
  ///
  /// Dispatches a `retryCamera` command to the native view and transitions
  /// status to [BlinkIdScannerStatus.ready] optimistically — `ready` here means
  /// "retry dispatched", not "camera confirmed running". If the grant did not
  /// actually take effect the native side will re-fire `onPermissionRequired`
  /// and status will return to [BlinkIdScannerStatus.cameraPermissionRequired].
  ///
  /// No-op if [status] is not [BlinkIdScannerStatus.cameraPermissionRequired].
  void retryAfterPermissionGrant() {
    if (_status != BlinkIdScannerStatus.cameraPermissionRequired) return;
    _lastPermissionException = null;
    _retryCamera();
    _setStatus(BlinkIdScannerStatus.ready);
  }

  /// Switches the active camera without tearing down the scanner view.
  ///
  /// Cancels any in-flight scan and transitions to
  /// [BlinkIdScannerStatus.initializing] while the native camera rebinds, then
  /// back to [BlinkIdScannerStatus.ready] — which is only reached once the
  /// camera has actually bound (or definitively failed), not merely dispatched.
  /// Call [scan] again after this returns to start scanning with the new camera.
  ///
  /// Returns the lens actually bound, which **may differ from [camera]** — a
  /// `front` request silently resolves to `back` on a device with no front
  /// lens. Also available afterwards via [activeCamera].
  ///
  /// Any [Future] from an in-progress [scan] completes with
  /// [BlinkIdScanCameraSwitchException].
  ///
  /// Throws [StateError] if the platform view is not yet attached or if the
  /// controller is in a state that does not support camera switching (e.g.
  /// [BlinkIdScannerStatus.uninitialized], [BlinkIdScannerStatus.error]).
  Future<PreferredCamera> switchCamera(PreferredCamera camera) async {
    if (_methodChannel == null) throw StateError('Platform view not ready; cannot switch camera');
    switch (_status) {
      case BlinkIdScannerStatus.ready ||
          BlinkIdScannerStatus.scanning ||
          BlinkIdScannerStatus.processing ||
          BlinkIdScannerStatus.done:
        break;
      default:
        throw StateError('Cannot switch camera in state $_status');
    }

    _cancelScan();
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.completeError(const BlinkIdScanCameraSwitchException());

    _creationParams = {..._creationParams, 'preferredCamera': camera.name};
    _setStatus(BlinkIdScannerStatus.initializing);

    String? resolvedLens;
    try {
      resolvedLens = await _methodChannel!.invokeMethod<String>('switchCamera', camera.name);
    } on PlatformException catch (e) {
      _failScan(e.message ?? 'Camera switch failed');
      rethrow;
    }

    final resolved = _cameraFromLensString(resolvedLens) ?? camera;
    _activeCamera = resolved;
    _creationParams = {..._creationParams, 'preferredCamera': resolved.name};
    _setStatus(BlinkIdScannerStatus.ready);
    return resolved;
  }

  PreferredCamera? _cameraFromLensString(String? value) => switch (value) {
    'front' => PreferredCamera.front,
    'back' => PreferredCamera.back,
    _ => null,
  };

  /// Cancels any in-flight scan and returns the controller to
  /// [BlinkIdScannerStatus.ready], ready for a new [scan] call. Use this to
  /// implement retry flows (e.g. after a timeout).
  ///
  /// The [Future] from [scan] completes with [BlinkIdScanResetException].
  ///
  /// Can also be called when [status] is [BlinkIdScannerStatus.error] to
  /// recover and allow a new scan.
  void reset() {
    _cancelScan();
    _phase = BlinkIdScanPhase.front;
    _awaitingBackSide = false;
    _lastError = null;
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.completeError(const BlinkIdScanResetException());
    switch (_status) {
      case BlinkIdScannerStatus.uninitialized ||
          BlinkIdScannerStatus.loadingSdk ||
          BlinkIdScannerStatus.initializing ||
          // Permission denial can't be reset away — the host must grant the
          // permission and call retryAfterPermissionGrant() instead.
          BlinkIdScannerStatus.cameraPermissionRequired:
        break;
      default:
        _setStatus(BlinkIdScannerStatus.ready);
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    // A native callback can still be in flight when dispose() runs (e.g. a
    // frame processed just before teardown). Without this guard it would
    // reach _setStatus/notifyListeners on an already-disposed ChangeNotifier.
    if (_disposed) return;
    try {
      switch (call.method) {
        case 'onDebugLog':
          if (_debugLoggingEnabled) debugPrint('[BlinkID] ${call.arguments}');
        case 'onDocumentScanned':
          _setStatus(BlinkIdScannerStatus.processing);
        case 'onScanResult':
          _completeScan(_parseResult(call.arguments));
        case 'onScanError':
          _failScan(call.arguments as String? ?? 'Scan error');
        case 'onScanCanceled':
          _abortWithCancel();
        case 'onPermissionRequired':
          final args = call.arguments as Map?;
          final permanentlyDenied = args?['permanentlyDenied'] as bool? ?? false;
          final permissionException = BlinkIdCameraPermissionException(permanentlyDenied: permanentlyDenied);
          _lastPermissionException = permissionException;
          _setStatus(BlinkIdScannerStatus.cameraPermissionRequired);
          _cancelScan();
          final completer = _scanCompleter;
          _scanCompleter = null;
          completer?.completeError(permissionException);
      }
    } catch (e, st) {
      if (_debugLoggingEnabled) debugPrint('BlinkID _handleMethodCall error (${call.method}): $e\n$st');
      _failScan('Handler error: $e');
    }
  }

  void _cancelScan() => _methodChannel?.invokeMethod<void>('cancelScan').ignore();

  void _resumeAfterFlip() => _methodChannel?.invokeMethod<void>('resumeAfterFlip').ignore();

  void _retryCamera() {
    _methodChannel?.invokeMethod<String>('retryCamera').then((lens) {
      final resolved = _cameraFromLensString(lens);
      if (resolved != null) _activeCamera = resolved;
    }).ignore();
  }

  void _setDebugLogging(bool enabled) => _methodChannel?.invokeMethod<void>('setDebugLogging', enabled).ignore();

  BlinkIdScanningResult _parseResult(dynamic rawArgs) {
    // Native sends a JSON string. jsonDecode produces Map<String, dynamic> at
    // every nesting level, avoiding the Map<Object?, Object?> that
    // StandardMessageCodec would produce for a method-channel map argument.
    final Map<String, dynamic> json = switch (rawArgs) {
      final String s => jsonDecode(s) as Map<String, dynamic>,
      final Map m => Map<String, dynamic>.fromEntries(m.entries.map((e) => MapEntry(e.key as String, e.value))),
      _ => throw ArgumentError('Unexpected scan result type: ${rawArgs?.runtimeType}'),
    };
    return BlinkIdScanningResult(json);
  }

  Future<void> _awaitReady() {
    if (_status == BlinkIdScannerStatus.ready) return Future.value();
    final completer = Completer<void>();
    _pendingReady.add(completer);
    void listener() {
      switch (_status) {
        case BlinkIdScannerStatus.ready:
          removeListener(listener);
          _pendingReady.remove(completer);
          if (!completer.isCompleted) completer.complete();
        case BlinkIdScannerStatus.error:
          removeListener(listener);
          _pendingReady.remove(completer);
          if (!completer.isCompleted) {
            completer.completeError(_lastError ?? Exception('Controller initialization failed'));
          }
        case BlinkIdScannerStatus.cameraPermissionRequired:
          // Permission was denied before the platform view reached 'ready'.
          removeListener(listener);
          _pendingReady.remove(completer);
          if (!completer.isCompleted) {
            completer.completeError(_lastPermissionException ?? const BlinkIdCameraPermissionException());
          }
        default:
          break;
      }
    }

    addListener(listener);
    return completer.future;
  }

  void _completeScan(BlinkIdScanningResult result) {
    _setStatus(BlinkIdScannerStatus.done);
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.complete(result);
  }

  void _abortWithCancel() {
    _setStatus(BlinkIdScannerStatus.ready);
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.completeError(const BlinkIdScanCancelException());
  }

  void _failScan(String message) {
    final error = Exception(message);
    _lastError = error;
    _setStatus(BlinkIdScannerStatus.error);
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.completeError(error);
  }

  void _setStatus(BlinkIdScannerStatus s) {
    _status = s;
    // Guards against notifyListeners() on an already-disposed ChangeNotifier
    // when a native callback races dispose() — see _handleMethodCall's guard.
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    // Set first: every guard above (_handleMethodCall, _onGuidanceEvent,
    // _setStatus) checks this before touching notifyListeners or the
    // (about to be closed) guidance controller.
    _disposed = true;
    _guidanceSub?.cancel().ignore();
    // Stop dispatching to _handleMethodCall before the underlying platform
    // view is asked to tear down, so no late native callback reaches a
    // disposed ChangeNotifier via the method channel.
    _methodChannel?.setMethodCallHandler(null);
    _methodChannel?.invokeMethod<void>('dispose').ignore();
    _guidanceController.close();
    // Drain in-flight scan without corrupting status — widget tree tearing down.
    final completer = _scanCompleter;
    _scanCompleter = null;
    completer?.completeError(const BlinkIdScanDisposeException());
    for (final c in _pendingReady) {
      if (!c.isCompleted) c.completeError(const BlinkIdScanDisposeException());
    }
    _pendingReady.clear();
    super.dispose();
  }
}

/// Thrown when the user explicitly cancels scanning via
/// [BlinkIdScannerController.cancel].
class BlinkIdScanCancelException implements Exception {
  const BlinkIdScanCancelException();
  @override
  String toString() => 'Scan canceled';
}

/// Thrown when [BlinkIdScannerController.switchCamera] interrupts an in-flight
/// scan. Distinct from [BlinkIdScanCancelException] so callers can continue
/// the scan loop rather than treating it as a user-initiated cancel.
class BlinkIdScanCameraSwitchException implements Exception {
  const BlinkIdScanCameraSwitchException();
  @override
  String toString() => 'Scan interrupted by camera switch';
}

/// Thrown when [BlinkIdScannerController.reset] is called while a scan is in
/// progress. Distinct from a user-initiated cancel so callers can branch on
/// retry vs. dismiss.
class BlinkIdScanResetException implements Exception {
  const BlinkIdScanResetException();
  @override
  String toString() => 'Scan reset';
}

/// Thrown when the controller is [dispose]d while a scan is in progress.
class BlinkIdScanDisposeException implements Exception {
  const BlinkIdScanDisposeException();
  @override
  String toString() => 'Scanner disposed';
}

/// Thrown by [BlinkIdScannerController.initialize] when the BlinkID SDK fails
/// to load (network error, license check failure, etc.).
class BlinkIdSdkInitException implements Exception {
  const BlinkIdSdkInitException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when camera permission has not been granted.
///
/// Check [permanentlyDenied] to decide whether to show a "Go to Settings"
/// prompt or to request the permission again:
///
/// ```dart
/// } catch (e) {
///   if (e is BlinkIdCameraPermissionException) {
///     if (e.permanentlyDenied) {
///       // open app settings
///     } else {
///       // request permission, then call controller.retryAfterPermissionGrant()
///     }
///   }
/// }
/// ```
///
/// **Note:** On Android, [permanentlyDenied] may be `true` on the very first
/// launch before any permission prompt has been shown.  Use
/// `permission_handler`'s `Permission.camera.isPermanentlyDenied` for a
/// definitive check on Android.
class BlinkIdCameraPermissionException implements Exception {
  const BlinkIdCameraPermissionException({this.permanentlyDenied = false});

  final bool permanentlyDenied;

  @override
  String toString() => permanentlyDenied
      ? 'Camera permission permanently denied; direct user to app Settings'
      : 'Camera permission required';
}
