// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'blinkid_flutter_platform_interface.dart';
import 'blinkid_result.dart';
import 'blinkid_settings.dart';
import 'types.dart';

/// An implementation of [BlinkidFlutterPlatform] that uses method channels.
///
/// MethodChannelCaptureFlutter exposes the appropriate native BlinkID module as a Flutter/Dart module,
/// based on the detected platform: Android or iOS.
///
/// The method channel contains the functions `performScan` and `performDirectApiScan` which enable the BlinkID scanning process, with the default UX properties, and with static images.
class MethodChannelBlinkIdFlutter extends BlinkIdFlutterPlatform {
  /// The method channel is used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('blinkid_flutter');
  static const String ARG_SCAN_METHOD = 'performScan';
  static const String ARG_SCAN_DIRECT_API_METHOD = 'performDirectApiScan';
  static const String ARG_LOAD_BLINKID_SDK = 'loadBlinkIdSdk';
  static const String ARG_UNLOAD_BLINKID_SDK = 'unloadBlinkIdSdk';
  static const String ARG_REFRESH_LICENSE_LEASE = 'refreshLicenseLease';
  static const String ARG_DELETE_CACHED_RESOURCES = 'deleteCachedResources';
  static const String ARG_BLINKID_SDK_SETTINGS = 'blinkIdSdkSettings';
  static const String ARG_SESSION_SETTINGS = 'blinkIdSessionSettings';
  static const String ARG_UX_SETTINGS = 'blinkIdScanningUxSettings';
  static const String ARG_CLASS_FILTER = 'blinkIdClassFilter';
  static const String ARG_REDACTION_SETTINGS_RESOLVER =
      'blinkIdRedactionSettingsResolver';
  static const String ARG_REDACTION_SETTINGS = 'directApiRedactionSettings';
  static const String ARG_FIRST_IMAGE = 'firstImage';
  static const String ARG_SECOND_IMAGE = 'secondImage';

  /// The `performScan` platform channel method launches the BlinkID scanning process with the default UX properties.
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
  @override
  Future<BlinkIdScanningResult?> performScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    BlinkIdScanningUxSettings? blinkIdScanningUxSettings,
    ClassFilter? classFilter,
    RedactionSettingsResolver? redactionSettingsResolver,
  }) async {
    final sessionPayload = jsonDecode(jsonEncode(blinkIdSessionSettings));
    debugPrint(
      '[BlinkIdFlutter] performScan sessionSettings: ${jsonEncode(sessionPayload)}',
    );
    final jsonBlinkIdResult = await methodChannel
        .invokeMethod(ARG_SCAN_METHOD, {
          ARG_BLINKID_SDK_SETTINGS: jsonDecode(jsonEncode(blinkIdSdkSettings)),
          ARG_SESSION_SETTINGS: sessionPayload,
          ARG_UX_SETTINGS: jsonDecode(jsonEncode(blinkIdScanningUxSettings)),
          ARG_CLASS_FILTER: jsonDecode(jsonEncode(classFilter)),
          ARG_REDACTION_SETTINGS_RESOLVER: jsonDecode(
            jsonEncode(redactionSettingsResolver),
          ),
        });

    final decodedMap = Map<String, dynamic>.from(jsonDecode(jsonBlinkIdResult));
    return BlinkIdScanningResult(decodedMap);
  }

  /// The `performDirectApiScan` platform channel method launches the BlinkID scanning process inteded for information extraction from static images.
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
  ///
  @override
  Future<BlinkIdScanningResult?> performDirectApiScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    RedactionSettings? redactionSettings,
    required String firstImage,
    String? secondImage,
  }) async {
    final sessionPayload = jsonDecode(jsonEncode(blinkIdSessionSettings));
    debugPrint(
      '[BlinkIdFlutter] performDirectApiScan sessionSettings: ${jsonEncode(sessionPayload)}',
    );
    final jsonBlinkIdDirectApiResult = await methodChannel
        .invokeMethod(ARG_SCAN_DIRECT_API_METHOD, {
          ARG_BLINKID_SDK_SETTINGS: jsonDecode(jsonEncode(blinkIdSdkSettings)),
          ARG_SESSION_SETTINGS: sessionPayload,
          ARG_REDACTION_SETTINGS: jsonDecode(jsonEncode(redactionSettings)),
          ARG_FIRST_IMAGE: jsonDecode(jsonEncode(firstImage)),
          ARG_SECOND_IMAGE: jsonDecode(jsonEncode(secondImage)),
        });

    final decodedMap = Map<String, dynamic>.from(
      jsonDecode(jsonBlinkIdDirectApiResult),
    );
    return BlinkIdScanningResult(decodedMap);
  }

  /// The `loadBlinkIdSdk` platform channel method creates or retrieves the instance of the BlinkID SDK.
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
  @override
  Future<void> loadBlinkIdSdk(BlinkIdSdkSettings blinkidSdkSettings) async {
    await methodChannel.invokeMethod(ARG_LOAD_BLINKID_SDK, {
      ARG_BLINKID_SDK_SETTINGS: jsonDecode(jsonEncode(blinkidSdkSettings)),
    });
  }

  /// The `unloadBlinkIdSdk` platform channel method terminates the BlinkID SDK and releases all associated resources.
  ///
  /// This method safely shuts down the SDK instance and frees any allocated memory.
  /// After calling this method, you must reinitialize the SDK (by calling [`loadBlinkIdSdk`]
  /// or any of the scanning methods) before using it again.
  ///
  /// The method accepts a single `bool` parameter, [deleteCachedResources].
  ///
  /// If set to `true` (`false` is default), the method performs a **complete cleanup**, including deletion of
  /// all downloaded and cached SDK resources from the device.
  ///
  /// This method is automatically called after each successful scan session.
  @override
  Future<void> unloadBlinkIdSdk({bool deleteCachedResources = false}) async {
    await methodChannel.invokeMethod(ARG_UNLOAD_BLINKID_SDK, {
      ARG_DELETE_CACHED_RESOURCES: jsonDecode(
        jsonEncode(deleteCachedResources),
      ),
    });
  }

  /// The `refreshLicenseLease` platform channel method refreshes the BlinkID SDK license lease.
  ///
  /// This method can be called periodically to maintain an active license status.
  /// The frequency of refresh calls depends on your license configuration.
  ///
  /// The BlinkID SDK must already be initialized (by calling [`loadBlinkIdSdk`]
  /// or any of the scanning methods) before calling this method.
  @override
  Future<void> refreshLicenseLease() async {
    await methodChannel.invokeMethod(ARG_REFRESH_LICENSE_LEASE);
  }
}
