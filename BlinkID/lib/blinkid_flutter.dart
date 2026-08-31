import 'package:blinkid_flutter/src/types.dart';

import 'src/blinkid_flutter_platform_interface.dart';
import 'src/blinkid_result.dart';
import 'src/blinkid_settings.dart';

export 'src/blinkid_settings.dart';
export 'src/blinkid_result.dart';
export 'src/types.dart';
export 'src/scanner/blinkid_guidance.dart';
export 'src/scanner/blinkid_scanner_controller.dart';
export 'src/scanner/blinkid_scanner_view.dart';

/// BlinkidFlutter plugin exposes the appropriate native BlinkID module as a Flutter/Dart module,
/// based on the detected platform: Android or iOS.
///
/// The BlinkID plugin contains the methods `performScan` and `performDirectApiScan`
/// which enable the BlinkID scanning process, with the default UX properties, and with static images.
class BlinkIdFlutter {
  /// The `performScan` method launches the BlinkID scanning process with the default UX properties.
  /// It takes the following parameters: [BlinkIdSdkSettings], [BlinkIdSessionSettings] and the optional [ClassFilter] class.
  ///
  /// 1. BlinkID SDK Settings - [BlinkIdSdkSettings]: the class that contains all of the available SDK settings. It contains settings for the license key, and how the models, that the SDK
  /// needs for the scanning process, should be obtained.
  /// To obtain a valid license key, please visit https://developer.microblink.com/ or contact us directly at https://help.microblink.com
  ///
  /// 2. BlinkID Session Settings - [BlinkIdSessionSettings]: the class that contains various settings for the scanning session. It contains the settings for the [ScanningMode] and [BlinkIdScanningSettings], which define various parameters that control the scanning process.
  ///
  /// 3. The optional BlinkID scanning UX settings class - [BlinkIdScanningUxSettings] - the class that allows customization of various aspects of the UI & UX used during the scanning process.
  ///
  /// 4. The optional ClassFilter class - [ClassFilter]: the class which controls which documents will be accepted or reject for information extraction during the scanning session. See [ClassFilter] for more implementation information.
  ///
  /// 5. The optional Redaction settings - [RedactionSettings]: Represents the document redaction settings. Use this when need per-document redaction behavior is needed — for example,
  /// anonymizing different fields depending on the document's country or type.
  /// The resolver
  /// is invoked by the SDK immediately before the scanning result is finalized.
  ///
  /// Returns the `performScan` method from the [BlinkidFlutterPlatform].
  Future<BlinkIdScanningResult?> performScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    BlinkIdScanningUxSettings? blinkidScanningUxSettings,
    ClassFilter? classFilter,
    RedactionSettingsResolver? redactionSettingsResolver,
  }) {
    return BlinkIdFlutterPlatform.instance.performScan(
      blinkIdSdkSettings: blinkIdSdkSettings,
      blinkIdSessionSettings: blinkIdSessionSettings,
      blinkIdScanningUxSettings: blinkidScanningUxSettings,
      classFilter: classFilter,
      redactionSettingsResolver: redactionSettingsResolver,
    );
  }

  /// The `performDirectApiScan` method launches the BlinkID scanning process inteded for information extraction from static images.
  /// It takes the following parameters: [BlinkIdSdkSettings], [BlinkIdSessionSettings], `firstImage` [String] in the Base64 format and the optional `secondImage` [String] in the Base64 format.
  ///
  /// 1. BlinkID SDK Settings - [BlinkIdSdkSettings]: the class that contains all of the available SDK settings. It contains settings for the license key, and how the models, that the SDK
  /// needs for the scanning process, should be obtained.
  /// To obtain a valid license key, please visit https://developer.microblink.com/ or contact us directly at https://help.microblink.com
  ///
  /// 2. BlinkID Session Settings - [BlinkIdSessionSettings]: the class that contains various settings for the scanning session. It contains the settings for the [ScanningMode] and [BlinkIdScanningSettings], which define various parameters that control the scanning process.
  ///
  /// 3. The optional Redaction settings - [RedactionSettings]: Represents the document redaction settings. Use this when need per-document redaction behavior is needed — for example,
  /// anonymizing different fields depending on the document's country or type.
  /// 4. The `firstImage` Base64 string - [String]: image that represents one side of the document. If the document contains two sides and the [ScanningMode] is set to `automatic`,
  /// this should contain the image of the front side of the document. In case the [ScanningMode] is set to `single`, it can be either the front or the back side of the document.
  ///
  /// 5. The optional `secondImage` Base64 string - [String]: needed if the information from back side of the document is required and the [ScanningMode] is set to `automatic`.
  ///
  /// Returns the `performDirectApiScan` method from the [BlinkidFlutterPlatform].
  Future<BlinkIdScanningResult?> performDirectApiScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    RedactionSettings? redactionSettings,
    required String firstImage,
    String? secondImage,
  }) {
    return BlinkIdFlutterPlatform.instance.performDirectApiScan(
      blinkIdSdkSettings: blinkIdSdkSettings,
      blinkIdSessionSettings: blinkIdSessionSettings,
      redactionSettings: redactionSettings,
      firstImage: firstImage,
      secondImage: secondImage,
    );
  }

  /// The `loadBlinkIdSdk` method creates or retrieves the instance of the BlinkID SDK.
  ///
  /// Initializes and loads the BlinkID SDK if it is not already loaded.
  ///
  /// This method handles:
  /// - SDK initialization
  /// - Resource downloading
  /// - License verification
  ///
  /// It ensures that only one SDK instance exists at any time.
  ///
  /// You can call this method in advance to **preload** the SDK before starting a scanning session.
  /// Doing so reduces loading time for the [`performScan`] and [`performDirectApiScan`] methods,
  /// since all resources will already be available and the license verified.
  ///
  /// If you do not call this method beforehand, it will still be automatically invoked on the native platform channels
  /// when a scan starts. However, the initial scan may take longer due to resource loading and license checks.
  ///
  /// It takes the following parameter: [BlinkIdSdkSettings].
  ///
  /// BlinkID SDK Settings - [BlinkIdSdkSettings]: the class that contains all of the available SDK settings. It contains settings for the license key, and how the models, that the SDK
  /// needs for the scanning process, should be obtained.
  /// To obtain a valid license key, please visit https://developer.microblink.com/ or contact us directly at https://help.microblink.com
  Future<void> loadBlinkIdSdk({
    required BlinkIdSdkSettings blinkidSdkSettings,
  }) async {
    return BlinkIdFlutterPlatform.instance.loadBlinkIdSdk(blinkidSdkSettings);
  }

  /// The `unloadBlinkIdSdk` method terminates the BlinkID SDK and releases all associated resources.
  ///
  /// This method safely shuts down the SDK instance and frees any allocated memory.
  /// After calling this method, you must reinitialize the SDK (by calling [`loadBlinkIdSdk`]
  /// or any of the scanning methods) before using it again.
  ///
  /// The method accepts a single `bool` parameter, [deleteCachedResources].
  ///
  /// If set to `true` (`false` is default), the method performs a **complete cleanup**,
  /// including deletion of all downloaded and cached SDK resources from the device.
  ///
  /// This method is automatically called after each successful scan session.
  Future<void> unloadBlinkIdSdk({bool deleteCachedResources = false}) async {
    return BlinkIdFlutterPlatform.instance.unloadBlinkIdSdk(
      deleteCachedResources: deleteCachedResources,
    );
  }
}
