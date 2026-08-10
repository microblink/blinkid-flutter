import 'types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blinkid_settings.g.dart';

@JsonSerializable()
class ResourcesConfig {
  /// Default: `true`.
  bool? download;

  /// Default host: `https://models.cdn.microblink.com/resources`
  /// Do not use the OTA host here.
  String? serviceUrl;

  /// Android default: `microblink/blinkid`. iOS default: `MLModels`.
  String? localFolder;

  /// Timeout in milliseconds (single value → connection/write/read).
  int? requestTimeout;  // TODO bug, should be set to RequestTimeout not int

  /// [iOS] Bundle id for prebundled resources when [download] is false.
  String? bundleIdentifier;

  ResourcesConfig({
    this.download,
    this.serviceUrl,
    this.localFolder,
    this.requestTimeout,
    this.bundleIdentifier,
  });
  factory ResourcesConfig.fromJson(Map<String, dynamic> json) =>
      _$ResourcesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ResourcesConfigToJson(this);
}
@JsonSerializable()
class OtaResourcesConfig {
  /// Default: `true`. Suppresses update checks only — first-run fetch still happens if missing.
  bool? checkForUpdates;

  /// Default: `false`. If `true` and updates enabled, init can fail on download errors.
  bool? strict;

  /// Default: `https://blinkid-ota.microblink.com`
  String? serviceUrl;

  /// Android default: `microblink/blinkid/ota`. iOS default: `OTAMLModels`.
  String? localFolder;

  int? requestTimeout;  // TODO bug, should be set to RequestTimeout not int
  
  /// [iOS] Bundle id for prebundled OTA resources.
  String? bundleIdentifier;
  OtaResourcesConfig({
    this.checkForUpdates,
    this.strict,
    this.serviceUrl,
    this.localFolder,
    this.requestTimeout,
    this.bundleIdentifier,
  });
  factory OtaResourcesConfig.fromJson(Map<String, dynamic> json) =>
      _$OtaResourcesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$OtaResourcesConfigToJson(this);
}

/// Settings for the initialization of the BlinkID SDK.
@JsonSerializable()
class BlinkIdSdkSettings {
  /// License key for the native SDK
  String licenseKey;

  /// Optional licensee string if the provided license key is not tied to the single application ID
  String? licensee;

  ResourcesConfig? resourcesConfig;

  OtaResourcesConfig? otaResourcesConfig;

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
    this.licensee,
    this.resourcesConfig,
    this.otaResourcesConfig,
    this.microblinkProxyUrl,
  });

  factory BlinkIdSdkSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdSdkSettingsFromJson(json);
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

  factory BlinkIdSessionSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdSessionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdSessionSettingsToJson(this);
}

/// Represents the configurable settings for scanning a document.
///
/// This class defines various parameters and policies related to the scanning
/// process, including image quality handling, data extraction and redaction,
/// along with options for frame processing and image extraction.
@JsonSerializable()
class BlinkIdScanningSettings {
  /// Settings for the document capture module.
  ///
  /// This module is responsible for the initial document detection, image extraction
  /// (such as face and document images), and image quality validation (blur, glare,
  /// and lighting checks).
  /// See [DocumentCaptureModuleSettings] for more information.
  DocumentCaptureModuleSettings? documentCaptureModule;

  /// Settings for the MRZ (Machine Readable Zone) extraction module.
  ///
  /// This module is dedicated to the detection and parsing of machine-readable
  /// zone typically found on passports, visas, and identity cards.
  ///
  /// See [MrzModuleSettings] for more information.
  MrzModuleSettings? mrzModule;

  /// Settings for the barcode extraction module.
  ///
  /// This module manages the detection and data extraction from various 1D and 2D
  /// barcode formats (such as PDF417, QR codes, and various retail codes).
  ///
  /// It can operate as a standalone module or in combination with document capture.
  ///
  /// See [BarcodeModuleSettings] for more information.
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
  VizModuleSettings? vizModule;

  /// The maximum allowed mismatches per field during data matching.
  ///
  /// Configures the maximum number of characters per field that can be inconsistent during data matching.
  ///
  /// By default, no mismatches are allowed.
  int maxAllowedMismatchesPerField;

  BlinkIdScanningSettings({
    this.documentCaptureModule,
    this.mrzModule,
    this.barcodeModule,
    this.vizModule,
    this.maxAllowedMismatchesPerField = 0,
  });

  factory BlinkIdScanningSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdScanningSettingsFromJson(json);
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

  factory BlinkIdScanningUxSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdScanningUxSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdScanningUxSettingsToJson(this);
}
