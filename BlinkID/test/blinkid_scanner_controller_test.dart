// Unit tests for BlinkIdScannerController's pure-Dart state machine, driven
// entirely through mocked method/event channels — no device, camera, or
// license key required. These cover the bugs found in review: an in-flight
// startScan surviving cancel/switchCamera, switchCamera reporting `ready`
// before the native reply lands, and a native callback racing dispose().
import 'dart:async';

import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _codec = StandardMethodCodec();

/// Simulates a native -> Dart method call on [channel] and waits for the
/// registered handler (if any) to reply.
Future<void> _deliverPlatformCall(String channel, MethodCall call) async {
  final completer = Completer<void>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
    channel,
    _codec.encodeMethodCall(call),
    (_) => completer.complete(),
  );
  await completer.future;
}

/// Attaches a controller to a fake platform view: mocks the SDK-load channel,
/// the per-view method channel, and the guidance event channel, then drives
/// the controller through `initialize` + `onPlatformViewCreated` up to
/// [BlinkIdScannerStatus.ready]. Returns the view id used, so the caller can
/// mock further per-view method-call responses on
/// `com.microblink.blinkid.flutter/scanner/$viewId`.
Future<int> _attachReadyController(BlinkIdScannerController controller, {int viewId = 1}) async {
  const sdkChannel = MethodChannel('blinkid_flutter');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    sdkChannel,
    (call) async => call.method == 'loadBlinkIdSdk' ? true : null,
  );

  final viewChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    viewChannel,
    (call) async => null,
  );
  // EventChannel implements listen/cancel as method calls on its own name.
  final guidanceChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId/guidance');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    guidanceChannel,
    (call) async => null,
  );

  await controller.initialize(BlinkIdSdkSettings(licenseKey: 'test-license'), BlinkIdSessionSettings());
  // ignore: invalid_use_of_internal_member
  controller.onPlatformViewCreated(viewId);
  expect(controller.status, BlinkIdScannerStatus.ready);
  return viewId;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // Clear any per-test mock handlers so channel names don't leak state
    // across tests (they're plain strings, not tied to controller instances).
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'blinkid_flutter',
      'com.microblink.blinkid.flutter/scanner/1',
      'com.microblink.blinkid.flutter/scanner/1/guidance',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  group('cancel() during an in-flight startScan', () {
    test('scan() completes with BlinkIdScanCancelException, not a resurrected scan', () async {
      final controller = BlinkIdScannerController();
      addTearDown(controller.dispose);
      final viewId = await _attachReadyController(controller);

      // Replace the view channel's handler with one that lets us control
      // exactly when the native "startScan" reply lands, simulating a
      // session-creation call that's still in flight on the native side when
      // cancel() arrives — the race behind the worst bug in review.
      final startScanReply = Completer<void>();
      final viewChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(viewChannel, (
        call,
      ) async {
        if (call.method == 'startScan') {
          await startScanReply.future;
          return null; // native's result.success(null)
        }
        return null;
      });

      final scanFuture = controller.scan();
      expect(controller.status, BlinkIdScannerStatus.scanning);

      controller.cancel();
      expect(controller.status, BlinkIdScannerStatus.ready);

      // Now let the delayed native reply land — as if the in-flight session
      // creation had finished *after* the cancel reached native.
      startScanReply.complete();

      // scan() must resolve to the cancel — not hang, and not silently swap
      // in a later success as if scanning had resumed.
      await expectLater(scanFuture, throwsA(isA<BlinkIdScanCancelException>()));
      expect(controller.status, BlinkIdScannerStatus.ready);
    });
  });

  group('switchCamera()', () {
    test('does not report ready until the native reply lands, and returns the resolved lens', () async {
      final controller = BlinkIdScannerController();
      addTearDown(controller.dispose);
      final viewId = await _attachReadyController(controller);

      final switchReply = Completer<String?>();
      final viewChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(viewChannel, (
        call,
      ) async {
        if (call.method == 'switchCamera') return switchReply.future;
        return null;
      });

      final switchFuture = controller.switchCamera(PreferredCamera.front);
      // Synchronous portion of switchCamera() has already run by the time
      // the call above returns a Future — status must reflect "rebinding",
      // not "ready", even though the native call is deliberately unresolved.
      expect(controller.status, BlinkIdScannerStatus.initializing);

      // Device has no front camera: native resolves to "back" instead.
      switchReply.complete('back');
      final resolved = await switchFuture;

      expect(resolved, PreferredCamera.back);
      expect(controller.activeCamera, PreferredCamera.back);
      expect(controller.status, BlinkIdScannerStatus.ready);
    });

    test('a PlatformException from the native reply leaves status error, not ready', () async {
      final controller = BlinkIdScannerController();
      addTearDown(controller.dispose);
      final viewId = await _attachReadyController(controller);

      final viewChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(viewChannel, (
        call,
      ) async {
        if (call.method == 'switchCamera') {
          throw PlatformException(code: 'blinkid_error', message: 'Camera bind failed');
        }
        return null;
      });

      await expectLater(controller.switchCamera(PreferredCamera.front), throwsA(isA<PlatformException>()));
      expect(controller.status, BlinkIdScannerStatus.error);
    });
  });

  group('dispose()', () {
    test('a late native callback after dispose does not throw or resurrect status', () async {
      final controller = BlinkIdScannerController();
      final viewId = await _attachReadyController(controller);
      final viewChannel = 'com.microblink.blinkid.flutter/scanner/$viewId';

      // Sanity check the plumbing first: before dispose, a native callback
      // does reach the controller and update status.
      await _deliverPlatformCall(viewChannel, const MethodCall('onScanError', 'boom'));
      expect(controller.status, BlinkIdScannerStatus.error);

      controller.reset();
      expect(controller.status, BlinkIdScannerStatus.ready);

      controller.dispose();

      // The same callback arriving after dispose must not throw (no
      // notifyListeners on a disposed ChangeNotifier) and must not move
      // status away from whatever it was at dispose time.
      await _deliverPlatformCall(viewChannel, const MethodCall('onScanError', 'late error'));
    });

    test('an in-flight scan completes with BlinkIdScanDisposeException', () async {
      final controller = BlinkIdScannerController();
      final viewId = await _attachReadyController(controller);
      final viewChannel = MethodChannel('com.microblink.blinkid.flutter/scanner/$viewId');
      // Native replies to 'startScan' once the session is created, then
      // keeps scanning asynchronously — completeScan/failScan for *that*
      // arrive later via separate onScanResult/onScanError calls, not as
      // this reply. So this mock resolving is "session created", not "scan
      // finished"; the scan itself is still in flight when dispose() below runs.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        viewChannel,
        (call) async => null,
      );

      final scanFuture = controller.scan();
      expect(controller.status, BlinkIdScannerStatus.scanning);

      controller.dispose();

      await expectLater(scanFuture, throwsA(isA<BlinkIdScanDisposeException>()));
    });
  });
}
