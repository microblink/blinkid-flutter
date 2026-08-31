import 'dart:async';
import 'dart:math' show pi;

import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomScannerScreen extends StatefulWidget {
  const CustomScannerScreen({required this.sdkSettings, required this.sessionSettings, super.key});

  final BlinkIdSdkSettings sdkSettings;
  final BlinkIdSessionSettings sessionSettings;

  @override
  State<CustomScannerScreen> createState() => _CustomScannerScreenState();
}

class _CustomScannerScreenState extends State<CustomScannerScreen> {
  late final BlinkIdScannerController _controller;
  StreamSubscription<BlinkIdGuidance>? _guidanceSub;
  bool _showingTimeoutDialog = false;
  BlinkIdScannerStatus _lastStatus = BlinkIdScannerStatus.uninitialized;
  BlinkIdScanPhase _lastPhase = BlinkIdScanPhase.front;
  Timer? _scanTimer;
  PreferredCamera _camera = PreferredCamera.back;
  bool _isPopping = false;
  bool _isSwitchingCamera = false;

  // Derived from the single guidanceStream subscription below (with
  // debounce/sticky/reset smoothing applied — see _onGuidance) and passed
  // down to _GuidanceOverlay as plain text; the overlay owns no controller
  // reference and needs none.
  late String _guidanceText;
  int _guidanceKey = 0;
  String? _pendingGuidanceText;
  Timer? _guidanceDebounce;
  Timer? _guidanceResetTimer;
  Timer? _guidanceStickyTimer;
  bool _guidanceSticky = false;

  static const _timeoutSeconds = 10;
  static const _guidanceDebounceDelay = Duration(milliseconds: 600);
  static const _guidanceStickyDuration = Duration(milliseconds: 1500);
  static const _guidanceResetDelay = Duration(seconds: 3);

  void _safePop([BlinkIdScanningResult? result]) {
    if (_isPopping || !mounted) return;
    _isPopping = true;
    _scanTimer?.cancel();
    Navigator.pop(context, result);
  }

  @override
  void initState() {
    super.initState();
    _controller = BlinkIdScannerController()
      ..setDebugLogging(true)
      ..addListener(_onScanStateChanged);
    _guidanceText = guidanceText(null, _controller.phase);
    // Single subscription drives both the scan-timeout timer and the
    // guidance overlay's text — previously two separate listeners on the
    // same stream, one of them duplicated inside _GuidanceOverlay itself.
    _guidanceSub = _controller.guidanceStream.listen(_onGuidance);
    unawaited(_startScanning());
  }

  void _onScanStateChanged() {
    final status = _controller.status;
    final phase = _controller.phase;

    if (status != _lastStatus) {
      _lastStatus = status;
      if (status == .scanning) _startScanTimer();
    }

    if (phase != _lastPhase) {
      _lastPhase = phase;
      switch (phase) {
        case .flip:
          _scanTimer?.cancel();
        case .back:
          _startScanTimer();
          // Same guidance value can mean something different on the new
          // side; refresh the displayed text immediately rather than waiting
          // for the next guidance event, and drop any smoothing state left
          // over from the front side.
          _guidanceDebounce?.cancel();
          _guidanceStickyTimer?.cancel();
          _guidanceResetTimer?.cancel();
          _guidanceSticky = false;
          _pendingGuidanceText = null;
          setState(() {
            _guidanceText = guidanceText(null, phase);
            _guidanceKey++;
          });
        case .front:
          break;
      }
    }
  }

  void _onGuidance(BlinkIdGuidance guidance) {
    if (guidance is! BlinkIdGuidanceSearching && guidance is! BlinkIdGuidanceWrongSide) {
      if (_controller.status == .scanning) _startScanTimer();
    }

    _guidanceResetTimer?.cancel();
    _guidanceResetTimer = Timer(_guidanceResetDelay, _resetGuidanceToDefault);

    final next = guidanceText(guidance, _controller.phase);
    if (next == _guidanceText || next == _pendingGuidanceText) return;

    _pendingGuidanceText = next;
    _guidanceDebounce?.cancel();
    final delay = _guidanceSticky ? _guidanceStickyDuration : _guidanceDebounceDelay;
    _guidanceDebounce = Timer(delay, _commitPendingGuidance);
  }

  void _commitPendingGuidance() {
    if (!mounted || _pendingGuidanceText == null) return;
    setState(() {
      _guidanceText = _pendingGuidanceText!;
      _pendingGuidanceText = null;
      _guidanceKey++;
    });
    _guidanceSticky = true;
    _guidanceStickyTimer?.cancel();
    _guidanceStickyTimer = Timer(_guidanceStickyDuration, () => _guidanceSticky = false);
  }

  void _resetGuidanceToDefault() {
    _guidanceDebounce?.cancel();
    _guidanceStickyTimer?.cancel();
    _guidanceSticky = false;
    _pendingGuidanceText = null;
    final defaultText = guidanceText(null, _controller.phase);
    if (!mounted || _guidanceText == defaultText) return;
    setState(() {
      _guidanceText = defaultText;
      _guidanceKey++;
    });
  }

  void _startScanTimer() {
    _scanTimer?.cancel();
    _scanTimer = Timer(const .new(seconds: _timeoutSeconds), () => unawaited(_onScanTimeout()));
  }

  Future<void> _onScanTimeout() async {
    if (!mounted || _showingTimeoutDialog) return;
    _showingTimeoutDialog = true;

    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Couldn't read document"),
        content: const Text('Make sure the document is well-lit, fully visible, and not blurry.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Try Again')),
        ],
      ),
    );

    _showingTimeoutDialog = false;
    if (!mounted) return;

    if (retry == true) {
      _lastPhase = .front;
      _controller.reset();
    } else {
      _controller.cancel();
    }
  }

  Future<void> _switchCamera() async {
    if (_isSwitchingCamera) return;
    _isSwitchingCamera = true;
    try {
      _camera = _camera == .back ? .front : .back;
      await _controller.switchCamera(_camera);
    } finally {
      _isSwitchingCamera = false;
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      _controller.retryAfterPermissionGrant();
      unawaited(_startScanning());
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _startScanning() async {
    try {
      await _controller.initialize(widget.sdkSettings, widget.sessionSettings, preferredCamera: _camera);
    } on BlinkIdSdkInitException catch (e, st) {
      debugPrint('BlinkID init error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SDK error: $e')));
      }
      _safePop();
      return;
    }

    while (mounted) {
      try {
        final result = await _controller.scan();
        _scanTimer?.cancel();
        await Future.delayed(const Duration(milliseconds: 700));
        // _safePop() re-checks mounted internally, but the route may have
        // been popped by other means during the delay above — check
        // explicitly here too so that intent is obvious at the call site.
        if (!mounted) return;
        _safePop(result);
        return;
      } on BlinkIdScanCameraSwitchException {
        _scanTimer?.cancel();
        // Camera switch interrupted the scan — loop continues so scan()
        // waits for the new camera to become ready.
        continue;
      } on BlinkIdScanCancelException {
        _scanTimer?.cancel();
        _safePop();
        return;
      } on BlinkIdScanResetException {
        _scanTimer?.cancel();
      } on BlinkIdScanDisposeException {
        _scanTimer?.cancel();
        return;
      } on BlinkIdCameraPermissionException catch (e, st) {
        _scanTimer?.cancel();
        debugPrint('BlinkID camera permission: $e\n$st');
        return;
      } on BlinkIdSdkInitException catch (e, st) {
        _scanTimer?.cancel();
        debugPrint('BlinkID sdk error: $e\n$st');
        return;
      } catch (e, st) {
        _scanTimer?.cancel();
        debugPrint('BlinkID scan error: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan error: $e')));
        }
        _safePop();
        return;
      }
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _guidanceDebounce?.cancel();
    _guidanceResetTimer?.cancel();
    _guidanceStickyTimer?.cancel();
    _guidanceSub?.cancel();
    _controller.removeListener(_onScanStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final status = _controller.status;

        if (status == .uninitialized || status == .loadingSdk) {
          return const ColoredBox(
            color: Color(0xFF000000),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF))),
          );
        }

        if (status == .error) {
          return ColoredBox(
            color: const Color(0xFF000000),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${_controller.lastError}',
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _safePop,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final permRequired = status == .cameraPermissionRequired;
        final permException = _controller.lastPermissionException;
        final permanentlyDenied = permException?.permanentlyDenied ?? false;

        final canInteract = !permRequired && status != .processing && status != .done && status != .initializing;

        return Stack(
          fit: StackFit.expand,
          children: [
            BlinkIdScannerView(controller: _controller),
            if (status == .initializing)
              const ColoredBox(
                color: Color(0xFF000000),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF))),
              ),
            if (permRequired)
              ColoredBox(
                color: const Color(0xFF000000),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt, color: Color(0xFFFFFFFF), size: 48),
                        const SizedBox(height: 16),
                        Text(
                          permanentlyDenied
                              ? 'Camera access is blocked.\nPlease enable it in your device Settings.'
                              : 'Camera access is required to scan documents.',
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (!permanentlyDenied)
                          ElevatedButton(
                            onPressed: () => unawaited(_requestPermission()),
                            child: const Text('Request Permission'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (canInteract)
              switch (_controller.phase) {
                BlinkIdScanPhase.flip => _FlipOverlay(onFlipComplete: _controller.onFlipComplete),
                _ => _GuidanceOverlay(text: _guidanceText, switcherKey: _guidanceKey),
              },
            if (status == BlinkIdScannerStatus.done) const _ScanSuccessOverlay(message: 'Document scanned!'),
            // Close button — top-left
            if (permRequired)
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _safePop,
                  ),
                ),
              ),
            if (canInteract)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _controller.cancel,
                ),
              ),
            // Camera switch button — top-right
            if (canInteract)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () => unawaited(_switchCamera()),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _FlipOverlay extends StatefulWidget {
  const _FlipOverlay({required this.onFlipComplete});

  /// Called exactly once, when the flip animation finishes — or immediately
  /// on early disposal if it hasn't finished yet (see [_FlipOverlayState.dispose]).
  /// Callers pass [BlinkIdScannerController.onFlipComplete] directly; this
  /// widget holds no other reference to the controller, so it can't reach
  /// into state that isn't its concern.
  final VoidCallback onFlipComplete;

  @override
  State<_FlipOverlay> createState() => _FlipOverlayState();
}

enum _FlipStage { success, animating, persistent }

class _FlipOverlayState extends State<_FlipOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  _FlipStage _stage = _FlipStage.success;
  bool _completedFlip = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _stage = _FlipStage.animating);
      _anim.forward().then((_) {
        if (!mounted) return;
        _completeFlip();
        setState(() => _stage = _FlipStage.persistent);
      });
    });
  }

  void _completeFlip() {
    if (_completedFlip) return;
    _completedFlip = true;
    widget.onFlipComplete();
  }

  @override
  void dispose() {
    // Guarantee native scanning resumes even if this overlay is torn down
    // before the flip animation finishes (e.g. canInteract flips false, or
    // the route is popped) — otherwise the scanner is left paused forever,
    // since nothing else calls onFlipComplete for this flip.
    _completeFlip();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (_stage) {
    .success => const _ScanSuccessOverlay(message: 'Front side scanned!'),
    .animating => AnimatedBuilder(animation: _anim, builder: (context, _) => _flipFrame(_anim.value)),
    .persistent => _flipFrame(0),
  };

  Widget _flipFrame(double t) => Container(
    color: Colors.black54,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(t * pi),
            child: const Icon(Icons.credit_card, color: Colors.white, size: 80),
          ),
          const SizedBox(height: 24),
          const Text(
            'Flip to the back side',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _ScanSuccessOverlay extends StatelessWidget {
  const _ScanSuccessOverlay({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black54,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 72),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

// Purely presentational — the parent owns the single guidanceStream
// subscription and derives [text]/[switcherKey] from it (see
// _CustomScannerScreenState._onGuidance) — including the debounce/sticky/
// reset smoothing, since native emits per-frame (~30/s) and consecutive
// *different* noisy values still need it, not just exact duplicates.
// [switcherKey] must be a monotonically increasing counter, not the text
// itself: a quick A->B->A oscillation would otherwise leave two children
// keyed identically mid-transition and crash AnimatedSwitcher's Stack.
class _GuidanceOverlay extends StatelessWidget {
  const _GuidanceOverlay({required this.text, required this.switcherKey});
  final String text;
  final int switcherKey;

  @override
  Widget build(BuildContext context) => Align(
    alignment: .bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 48),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Container(
          key: ValueKey(switcherKey),
          padding: const .symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: .center,
          ),
        ),
      ),
    ),
  );
}

String guidanceText(BlinkIdGuidance? guidance, BlinkIdScanPhase phase) {
  final prefix = phase == .back ? 'Back side: ' : '';
  return prefix +
      switch (guidance) {
        null || BlinkIdGuidanceSearching() =>
          phase == .back ? 'Scan the back side of a document' : 'Scan the front side of a document',
        BlinkIdGuidanceTooFar() => 'Move closer',
        BlinkIdGuidanceTooClose() => 'Move further away',
        BlinkIdGuidanceTooCloseToEdge() => 'Move the document from the edge',
        BlinkIdGuidanceTilted() => 'Keep document parallel to phone',
        BlinkIdGuidanceHoldStill() => 'Hold still…',
        BlinkIdGuidanceFlipDocument() => 'Flip to the back side',
        BlinkIdGuidanceWrongSide() => 'Flip the document',
        BlinkIdGuidanceBlur() => 'Keep document and phone still',
        BlinkIdGuidanceGlare() => 'Tilt or move document to remove reflection',
        BlinkIdGuidanceNotFullyVisible() => 'Keep the document fully visible',
        BlinkIdGuidanceLowLight() => 'Move to a brighter spot',
        BlinkIdGuidanceTooMuchLight() => 'Move to a spot with less lighting',
      };
}
