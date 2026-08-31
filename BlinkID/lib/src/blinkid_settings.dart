import 'types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blinkid_settings.g.dart';

/// Settings for the initialization of the BlinkID SDK.
@JsonSerializable()
class BlinkIdSdkSettings {
  /// License key for the native SDK
  String licenseKey;

  /// Optional licensee string if the provided license key is not tied to the single application ID
  String? licensee;

  /// Whether resources required for on-device image processing should be downloaded and cached
  /// on first initialization of the SDK.
  /// If set to false, you need to package all the required
  /// resources in your application's assets.
  bool downloadResources;

  /// If resources are to be downloaded, the following is the URL where the resources are hosted.
  /// URL: `"https://models.cdn.microblink.com/resources"`
  String? resourceDownloadUrl;

  /// Local folder name where resources will be downloaded and cached.
  /// If resources are being downloaded, this defines the name of the folder within your
  /// application's cache folder where resources will be cached.
  String? resourceLocalFolder;

  /// [iOS-specific] If resources downloading is disabled for iOS, this defines the bundle identifier of your iOS app where the resources reside.
  String? bundleIdentifier;

  /// Timeout settings for resource downloads.
  int? resourceRequestTimeout; // TODO bug, should be set to RequestTimeout not int

  /// Set a custom HTTPS URL to be used as a proxy for Ping and license checks.
  /// The proxy URL will be applied only if the license has the appropriate rights.
  /// The URL must use the HTTPS protocol. Example: https://your-proxy.com/
  ///
  /// If this value is defined, SDK initialization will not be successful in the following cases:
  ///   - if the URL does not use HTTPS or if the URL is invalid
  ///   - if the license does not allow proxy usage
  String? microblinkProxyUrl;

  /// Settings for the initialization of the BlinkID SDK.
  BlinkIdSdkSettings({
    required this.licenseKey,
    this.downloadResources = true,
    this.licensee,
    this.resourceDownloadUrl,
    this.resourceLocalFolder,
    this.bundleIdentifier,
    this.resourceRequestTimeout,
    this.microblinkProxyUrl,
  });

  factory BlinkIdSdkSettings.fromJson(Map<String, dynamic> json) => _$BlinkIdSdkSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdSdkSettingsToJson(this);
}

/// Represents the configuration settings for a scanning session.
///
/// This class holds the settings related to the resources initialization,
/// scanning mode, and specific scanning configurations that define how the scanning
/// session should behave.
@JsonSerializable()
class BlinkIdSessionSettings {
  /// The scanning mode to be used during the scanning session.
  ///
  /// Specifies whether the scanning is for a single side of a document or multiple
  /// sides, as defined in [ScanningMode]. The default is set to `automatic`, which
  /// automatically determines the number of sides to scan.
  ScanningMode scanningMode = ScanningMode.automatic;

  /// The specific scanning settings for the scanning session.
  ///
  /// Defines various parameters that control the scanning process.
  BlinkIdScanningSettings scanningSettings = BlinkIdScanningSettings();

  /// Duration in seconds before scanning step times out and is cancelled.
  /// If less than zero, scanning will not time out.
  /// Defaults to 60000 (60 seconds)
  int stepTimeoutDuration = 60000;

  ///Duration in seconds of UI inactivity (no state change) before timeout.
  ///If less than or equal to zero, the inactivity timer will not fire.
  /// Defaults to 10000 (10 seconds)
  int inactivityTimeoutDuration = 10000;

  /// Represents the configuration settings for a scanning session.
  ///
  /// This class holds the settings related to the resources initialization,
  /// scanning mode, and specific scanning configurations that define how the scanning
  /// session should behave.
  BlinkIdSessionSettings({
    this.scanningMode = ScanningMode.automatic,
    BlinkIdScanningSettings? scanningSettings,
    this.stepTimeoutDuration = 60000,
    this.inactivityTimeoutDuration = 10000,
  }) : scanningSettings = scanningSettings ?? BlinkIdScanningSettings();

  factory BlinkIdSessionSettings.fromJson(Map<String, dynamic> json) => _$BlinkIdSessionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdSessionSettingsToJson(this);
}

/// Represents the configurable settings for scanning a document.
///
/// This class defines various parameters and policies related to the scanning
/// process, including image quality handling, data extraction and redaction,
/// along with options for frame processing and image extraction.
// createFactory: false — fromJson is hand-written below. The generated
// factory would always pass an explicit value for every module parameter
// (computed from the JSON, which is `null` for both "key absent" and "key
// present and null"), so it can't tell "leave the constructor's SDK-default
// in place" apart from "explicitly disabled" the way the constructor itself
// can (see the module fields' doc comments and the constructor below).
@JsonSerializable(createFactory: false)
class BlinkIdScanningSettings {
  /// Settings for the document capture module.
  ///
  /// This module is responsible for the initial document detection, image extraction
  /// (such as face and document images), and image quality validation (blur, glare,
  /// and lighting checks).
  /// See [DocumentCaptureModuleSettings] for more information.
  ///
  /// Leave unset for the SDK default (enabled). Pass `documentCaptureModule: null`
  /// explicitly to disable the module.
  DocumentCaptureModuleSettings? documentCaptureModule;

  /// Settings for the MRZ (Machine Readable Zone) extraction module.
  ///
  /// This module is dedicated to the detection and parsing of machine-readable
  /// zone typically found on passports, visas, and identity cards.
  ///
  /// See [MrzModuleSettings] for more information.
  ///
  /// Leave unset for the SDK default (enabled). Pass `mrzModule: null`
  /// explicitly to disable the module.
  MrzModuleSettings? mrzModule;

  /// Settings for the barcode extraction module.
  ///
  /// This module manages the detection and data extraction from various 1D and 2D
  /// barcode formats (such as PDF417, QR codes, and various retail codes).
  ///
  /// It can operate as a standalone module or in combination with document capture.
  ///
  /// See [BarcodeModuleSettings] for more information.
  ///
  /// Leave unset for the SDK default (enabled). Pass `barcodeModule: null`
  /// explicitly to disable the module.
  BarcodeModuleSettings? barcodeModule;

  /// Settings for the VIZ (Visual Inspection Zone) extraction module.
  ///
  /// This module is responsible for extracting data from the document's
  /// visual fields.
  ///
  /// It supports features such as character validation for increased accuracy,
  /// signature image extraction, and data aggregation across multiple video frames.
  ///
  /// See [VizModuleSettings] for more information.
  ///
  /// Leave unset for the SDK default (enabled). Pass `vizModule: null`
  /// explicitly to disable the module.
  VizModuleSettings? vizModule;

  /// The maximum allowed mismatches per field during data matching.
  ///
  /// Configures the maximum number of characters per field that can be inconsistent during data matching.
  ///
  /// By default, no mismatches are allowed.
  int maxAllowedMismatchesPerField;

  BlinkIdScanningSettings({
    this.documentCaptureModule = const DocumentCaptureModuleSettings(),
    this.mrzModule = const MrzModuleSettings(),
    this.barcodeModule = const BarcodeModuleSettings(),
    this.vizModule = const VizModuleSettings(),
    this.maxAllowedMismatchesPerField = 0,
  });

  // Hand-written to preserve the tri-state contract on the way back in:
  // key absent -> leave the constructor's SDK-default instance in place; key
  // present and null -> disabled; key present with a map -> deserialize.
  factory BlinkIdScanningSettings.fromJson(Map<String, dynamic> json) {
    final settings = BlinkIdScanningSettings(
      maxAllowedMismatchesPerField: (json['maxAllowedMismatchesPerField'] as num?)?.toInt() ?? 0,
    );
    if (json.containsKey('documentCaptureModule')) {
      final value = json['documentCaptureModule'];
      settings.documentCaptureModule = value == null
          ? null
          : DocumentCaptureModuleSettings.fromJson(value as Map<String, dynamic>);
    }
    if (json.containsKey('mrzModule')) {
      final value = json['mrzModule'];
      settings.mrzModule = value == null ? null : MrzModuleSettings.fromJson(value as Map<String, dynamic>);
    }
    if (json.containsKey('barcodeModule')) {
      final value = json['barcodeModule'];
      settings.barcodeModule = value == null ? null : BarcodeModuleSettings.fromJson(value as Map<String, dynamic>);
    }
    if (json.containsKey('vizModule')) {
      final value = json['vizModule'];
      settings.vizModule = value == null ? null : VizModuleSettings.fromJson(value as Map<String, dynamic>);
    }
    return settings;
  }

  Map<String, dynamic> toJson() => _$BlinkIdScanningSettingsToJson(this);
}

/// Allows customization of various aspects of the UI/UX
/// used during the scanning process.
@JsonSerializable()
class BlinkIdScanningUxSettings {
  /// A boolean indicating whether to show a help button
  /// and enable help screens during the scanning session.
  ///
  /// Default: `true`
  bool showHelpButton;

  /// A boolean indicating whether to show an onboarding dialog
  /// at the beginning of the scanning session.
  ///
  /// Default: `true`
  bool showOnboardingDialog;

  /// Determines whether haptic feedback is played for scanning-related events.
  ///
  /// When enabled, haptic responses are generated during scanning activities,
  /// such as detection updates or user interactions (e.g., toggling the flashlight).
  /// When disabled, no haptic feedback is produced.
  ///
  /// Default: `true`
  bool allowHapticFeedback;

  /// The preferred camera position to use when capturing document.
  /// This value represents the user’s choice of front or back camera.
  ///
  /// The system determines the actual physical camera device.
  ///
  /// Default: [PreferredCamera.back]
  PreferredCamera preferredCamera;

  BlinkIdScanningUxSettings({
    this.allowHapticFeedback = true,
    this.showHelpButton = true,
    this.showOnboardingDialog = true,
    this.preferredCamera = PreferredCamera.back,
  });

  factory BlinkIdScanningUxSettings.fromJson(Map<String, dynamic> json) => _$BlinkIdScanningUxSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdScanningUxSettingsToJson(this);
}
