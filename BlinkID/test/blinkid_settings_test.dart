// Verifies the tri-state module contract on BlinkIdScanningSettings: leaving
// a module unset serializes as the SDK-default enabled settings, explicitly
// passing null serializes as an explicit JSON null (disables the module
// natively — see BlinkIdDeserializationUtils on both platforms), and passing
// settings serializes those settings. Also verifies the round trip back
// through fromJson, which is hand-written specifically to preserve this
// contract (see blinkid_settings.dart).
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlinkIdScanningSettings module contract', () {
    test('unset module serializes as the SDK-default enabled settings, not omitted', () {
      final json = BlinkIdScanningSettings().toJson();

      expect(json.containsKey('barcodeModule'), isTrue);
      expect(json['barcodeModule'], isNotNull);
      expect(json['documentCaptureModule'], isNotNull);
      expect(json['mrzModule'], isNotNull);
      expect(json['vizModule'], isNotNull);
    });

    test('explicit null disables the module: key present, value null', () {
      final json = BlinkIdScanningSettings(barcodeModule: null).toJson();

      expect(json.containsKey('barcodeModule'), isTrue);
      expect(json['barcodeModule'], isNull);
      // Unrelated modules stay on the SDK default.
      expect(json['documentCaptureModule'], isNotNull);
    });

    test('an explicit settings object round-trips through toJson', () {
      final settings = BlinkIdScanningSettings(barcodeModule: BarcodeModuleSettings(presenceMandatory: true));
      final json = settings.toJson();

      expect(json['barcodeModule'], isA<Map<String, dynamic>>());
      expect((json['barcodeModule'] as Map)['presenceMandatory'], isTrue);
    });

    test('fromJson preserves unset vs. explicit-null vs. present on the way back in', () {
      // Unset: key genuinely absent from the JSON map.
      final unset = BlinkIdScanningSettings.fromJson(const {});
      expect(unset.documentCaptureModule, isNotNull);
      expect(unset.barcodeModule, isNotNull);

      // Explicit null: key present, value null.
      final disabled = BlinkIdScanningSettings.fromJson(const {'barcodeModule': null});
      expect(disabled.barcodeModule, isNull);
      // Everything else the caller didn't mention stays SDK-default enabled.
      expect(disabled.documentCaptureModule, isNotNull);

      // Present map: deserialized into real settings.
      final withMap = BlinkIdScanningSettings.fromJson({
        'barcodeModule': {'presenceMandatory': true},
      });
      expect(withMap.barcodeModule, isNotNull);
      expect(withMap.barcodeModule!.presenceMandatory, isTrue);
    });

    test('toJson -> fromJson round trip is stable for a disabled module', () {
      final original = BlinkIdScanningSettings(vizModule: null);
      final roundTripped = BlinkIdScanningSettings.fromJson(original.toJson());

      expect(roundTripped.vizModule, isNull);
      expect(roundTripped.barcodeModule, isNotNull);
    });
  });
}
