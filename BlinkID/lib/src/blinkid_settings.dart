import 'types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blinkid_settings.g.dart';

/// Network timeouts used when the SDK downloads on-device processing resources.
///
/// Values are in milliseconds. Omit [ResourcesConfig.requestTimeout] or
/// [OtaResourcesConfig.requestTimeout] to keep the native SDK default (30 seconds
/// per timeout on current BlinkID native SDKs).
@JsonSerializable(includeIfNull: false)
class RequestTimeout {
  /// Timeout for establishing the TCP connection to the resource host.
  final int? connectionTimeoutMilliseconds;

  /// Timeout for individual write IO operations.
  final int? writeTimeoutMilliseconds;

  /// Timeout applied to the TCP socket and read IO operations.
  final int? readTimeoutMilliseconds;

  const RequestTimeout({
    this.connectionTimeoutMilliseconds,
    this.writeTimeoutMilliseconds,
    this.readTimeoutMilliseconds,
  });

  /// Applies the same duration to connection, write, and read timeouts.
  factory RequestTimeout.all(int timeoutMilliseconds) => RequestTimeout(
        connectionTimeoutMilliseconds: timeoutMilliseconds,
        writeTimeoutMilliseconds: timeoutMilliseconds,
        readTimeoutMilliseconds: timeoutMilliseconds,
      );

  factory RequestTimeout.fromJson(Map<String, dynamic> json) =>
      _$RequestTimeoutFromJson(json);
  Map<String, dynamic> toJson() => _$RequestTimeoutToJson(this);
}

@JsonSerializable()
class ResourcesConfig {
  /// Default: `true`.
  bool? download;

  /// Default host: `https://models.cdn.microblink.com/resources`
  /// Do not use the OTA host here.
  String? serviceUrl;

  /// Android default: `microblink/blinkid`. iOS default: `MLModels`.
  String? localFolder;

  /// Network timeouts for resource downloads. Values are in milliseconds.
  @JsonKey(includeIfNull: false)
  RequestTimeout? requestTimeout;

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

  /// Network timeouts for OTA resource downloads. Values are in milliseconds.
  @JsonKey(includeIfNull: false)
  RequestTimeout? requestTimeout;

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

/// Use case options for [SessionPreset.documentVideo].
@JsonSerializable()
class DocumentVideoUseCase {
  /// Module topology and mandatory presence rules for the scan.
  DocumentScenario scenario;

  /// Speed vs. accuracy tuning for frame selection and quality thresholds.
  VideoQualityProfile quality;

  /// Hand-held mobile capture vs. stationary capture.
  VideoCaptureEnvironment captureEnvironment;

  DocumentVideoUseCase({
    this.scenario = DocumentScenario.general,
    this.quality = VideoQualityProfile.balanced,
    this.captureEnvironment = VideoCaptureEnvironment.handHeld,
  });

  factory DocumentVideoUseCase.fromJson(Map<String, dynamic> json) =>
      _$DocumentVideoUseCaseFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentVideoUseCaseToJson(this);
}

/// Use case options for [SessionPreset.documentPhoto].
@JsonSerializable()
class DocumentPhotoUseCase {
  /// Module topology and mandatory presence rules for the scan.
  DocumentScenario scenario;

  /// Quality thresholds for single-image extraction.
  PhotoQualityProfile quality;

  DocumentPhotoUseCase({
    this.scenario = DocumentScenario.general,
    this.quality = PhotoQualityProfile.balanced,
  });

  factory DocumentPhotoUseCase.fromJson(Map<String, dynamic> json) =>
      _$DocumentPhotoUseCaseFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentPhotoUseCaseToJson(this);
}

/// Represents the configuration settings for a scanning session.
///
/// This class holds the settings related to the resources initialization,
/// scanning mode, and specific scanning configurations that define how the scanning
/// session should behave.
@JsonSerializable(includeIfNull: false)
class BlinkIdSessionSettings {
  /// Builds session settings from a native preset factory instead of manual module tuning.
  ///
  /// When set, [documentVideoUseCase] or [documentPhotoUseCase] apply to
  /// [SessionPreset.documentVideo] and [SessionPreset.documentPhoto] respectively.
  /// [scanningMode] overrides a preset only when set (non-null). [scanningSettings] merges
  /// onto a preset: only keys sent to the native bridge are applied; omit overrides to
  /// keep preset defaults.
  SessionPreset? sessionPreset;

  /// Use case options for [SessionPreset.documentVideo].
  DocumentVideoUseCase? documentVideoUseCase;

  /// Use case options for [SessionPreset.documentPhoto].
  DocumentPhotoUseCase? documentPhotoUseCase;

  /// The scanning mode to be used during the scanning session.
  ///
  /// When [sessionPreset] is set, leave null to keep the preset's scanning mode.
  /// For manual (non-preset) sessions, null is treated as [ScanningMode.automatic] on
  /// the native side.
  ScanningMode? scanningMode;

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
    this.sessionPreset,
    this.documentVideoUseCase,
    this.documentPhotoUseCase,
    this.scanningMode,
    BlinkIdScanningSettings? scanningSettings,
    this.stepTimeoutDuration = 60000,
    this.inactivityTimeoutDuration = 10000,
  }) : scanningSettings = scanningSettings ?? BlinkIdScanningSettings();

  factory BlinkIdSessionSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdSessionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdSessionSettingsToJson(this);

  /// Session settings map for the native method channel.
  ///
  /// Omits default [scanningSettings] and unset [scanningMode] when using a preset
  /// factory so native merge logic does not clear preset module defaults.
  Map<String, dynamic> toPlatformMap() {
    final map = <String, dynamic>{
      'stepTimeoutDuration': stepTimeoutDuration,
      'inactivityTimeoutDuration': inactivityTimeoutDuration,
    };

    if (sessionPreset != null) {
      map['sessionPreset'] = _$SessionPresetEnumMap[sessionPreset]!;
    }
    if (documentVideoUseCase != null) {
      map['documentVideoUseCase'] = documentVideoUseCase!.toJson();
    }
    if (documentPhotoUseCase != null) {
      map['documentPhotoUseCase'] = documentPhotoUseCase!.toJson();
    }

    if (_usesSessionPresetFactory(sessionPreset)) {
      if (scanningMode != null) {
        map['scanningMode'] = _$ScanningModeEnumMap[scanningMode]!;
      }
      final scanningPatch = scanningSettings.toPlatformMergePatch();
      if (scanningPatch != null) {
        map['scanningSettings'] = scanningPatch;
      }
    } else {
      map['scanningMode'] =
          _$ScanningModeEnumMap[scanningMode ?? ScanningMode.automatic]!;
      map['scanningSettings'] = scanningSettings.toPlatformMergePatch() ?? {};
    }

    return map;
  }

  static bool _usesSessionPresetFactory(SessionPreset? preset) {
    return preset == SessionPreset.documentVideo ||
        preset == SessionPreset.documentPhoto ||
        preset == SessionPreset.standaloneBarcode ||
        preset == SessionPreset.verifyCapture;
  }
}

/// Represents the configurable settings for scanning a document.
///
/// This class defines various parameters and policies related to the scanning
/// process, including image quality handling, data extraction and redaction,
/// along with options for frame processing and image extraction.
@JsonSerializable(includeIfNull: false)
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

  /// Non-null when at least one module override or non-default mismatch limit is set.
  Map<String, dynamic>? toPlatformMergePatch() {
    final map = <String, dynamic>{};
    if (documentCaptureModule != null) {
      map['documentCaptureModule'] = documentCaptureModule!.toJson();
    }
    if (mrzModule != null) {
      map['mrzModule'] = mrzModule!.toJson();
    }
    if (barcodeModule != null) {
      map['barcodeModule'] = barcodeModule!.toJson();
    }
    if (vizModule != null) {
      map['vizModule'] = vizModule!.toJson();
    }
    if (maxAllowedMismatchesPerField != 0) {
      map['maxAllowedMismatchesPerField'] = maxAllowedMismatchesPerField;
    }
    return map.isEmpty ? null : map;
  }
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

  /// Determines whether sound is played for scanning-success events.
  ///
  /// When enabled, scan sounds are generated during scanning-success events,
  /// such as when a document side is scanned.
  /// When disabled, no sound is produced.
  ///
  /// Default: `true`
  bool allowScanSound;

  /// The preferred camera position to use when capturing document.
  /// This value represents the user’s choice of front or back camera.
  ///
  /// The system determines the actual physical camera device.
  ///
  /// Default: [PreferredCamera.back]
  PreferredCamera preferredCamera;

  /// When `true`, accepts only passport booklets and guides the user to the data page.
  ///
  /// Default: `false`
  bool passportOnly;

  /// Delay in milliseconds before the help tooltip is shown automatically.
  /// Zero or negative disables automatic display.
  ///
  /// Default: `10000`
  int helpTooltipShowDelay;

  /// Delay in milliseconds before the help tooltip is hidden after being shown.
  ///
  /// Default: `5000`
  int helpTooltipHideDelay;

  BlinkIdScanningUxSettings({
    this.allowHapticFeedback = true,
    this.allowScanSound = true,
    this.showHelpButton = true,
    this.showOnboardingDialog = true,
    this.preferredCamera = PreferredCamera.back,
    this.passportOnly = false,
    this.helpTooltipShowDelay = 10000,
    this.helpTooltipHideDelay = 5000,
  });

  factory BlinkIdScanningUxSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdScanningUxSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdScanningUxSettingsToJson(this);
}
