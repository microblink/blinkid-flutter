// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blinkid_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourcesConfig _$ResourcesConfigFromJson(Map<String, dynamic> json) =>
    ResourcesConfig(
      download: json['download'] as bool?,
      serviceUrl: json['serviceUrl'] as String?,
      localFolder: json['localFolder'] as String?,
      requestTimeout: (json['requestTimeout'] as num?)?.toInt(),
      bundleIdentifier: json['bundleIdentifier'] as String?,
    );

Map<String, dynamic> _$ResourcesConfigToJson(ResourcesConfig instance) =>
    <String, dynamic>{
      'download': instance.download,
      'serviceUrl': instance.serviceUrl,
      'localFolder': instance.localFolder,
      'requestTimeout': instance.requestTimeout,
      'bundleIdentifier': instance.bundleIdentifier,
    };

OtaResourcesConfig _$OtaResourcesConfigFromJson(Map<String, dynamic> json) =>
    OtaResourcesConfig(
      checkForUpdates: json['checkForUpdates'] as bool?,
      strict: json['strict'] as bool?,
      serviceUrl: json['serviceUrl'] as String?,
      localFolder: json['localFolder'] as String?,
      requestTimeout: (json['requestTimeout'] as num?)?.toInt(),
      bundleIdentifier: json['bundleIdentifier'] as String?,
    );

Map<String, dynamic> _$OtaResourcesConfigToJson(OtaResourcesConfig instance) =>
    <String, dynamic>{
      'checkForUpdates': instance.checkForUpdates,
      'strict': instance.strict,
      'serviceUrl': instance.serviceUrl,
      'localFolder': instance.localFolder,
      'requestTimeout': instance.requestTimeout,
      'bundleIdentifier': instance.bundleIdentifier,
    };

BlinkIdSdkSettings _$BlinkIdSdkSettingsFromJson(Map<String, dynamic> json) =>
    BlinkIdSdkSettings(
      licenseKey: json['licenseKey'] as String,
      licensee: json['licensee'] as String?,
      resourcesConfig: json['resourcesConfig'] == null
          ? null
          : ResourcesConfig.fromJson(
              json['resourcesConfig'] as Map<String, dynamic>,
            ),
      otaResourcesConfig: json['otaResourcesConfig'] == null
          ? null
          : OtaResourcesConfig.fromJson(
              json['otaResourcesConfig'] as Map<String, dynamic>,
            ),
      microblinkProxyUrl: json['microblinkProxyUrl'] as String?,
    );

Map<String, dynamic> _$BlinkIdSdkSettingsToJson(BlinkIdSdkSettings instance) =>
    <String, dynamic>{
      'licenseKey': instance.licenseKey,
      'licensee': instance.licensee,
      'resourcesConfig': instance.resourcesConfig,
      'otaResourcesConfig': instance.otaResourcesConfig,
      'microblinkProxyUrl': instance.microblinkProxyUrl,
    };

BlinkIdSessionSettings _$BlinkIdSessionSettingsFromJson(
  Map<String, dynamic> json,
) => BlinkIdSessionSettings(
  scanningMode:
      $enumDecodeNullable(_$ScanningModeEnumMap, json['scanningMode']) ??
      ScanningMode.automatic,
  scanningSettings: json['scanningSettings'] == null
      ? null
      : BlinkIdScanningSettings.fromJson(
          json['scanningSettings'] as Map<String, dynamic>,
        ),
  stepTimeoutDuration: (json['stepTimeoutDuration'] as num?)?.toInt() ?? 60000,
  inactivityTimeoutDuration:
      (json['inactivityTimeoutDuration'] as num?)?.toInt() ?? 10000,
);

Map<String, dynamic> _$BlinkIdSessionSettingsToJson(
  BlinkIdSessionSettings instance,
) => <String, dynamic>{
  'scanningMode': _$ScanningModeEnumMap[instance.scanningMode]!,
  'scanningSettings': instance.scanningSettings,
  'stepTimeoutDuration': instance.stepTimeoutDuration,
  'inactivityTimeoutDuration': instance.inactivityTimeoutDuration,
};

const _$ScanningModeEnumMap = {
  ScanningMode.single: 'single',
  ScanningMode.automatic: 'automatic',
};

BlinkIdScanningSettings _$BlinkIdScanningSettingsFromJson(
  Map<String, dynamic> json,
) => BlinkIdScanningSettings(
  documentCaptureModule: json['documentCaptureModule'] == null
      ? null
      : DocumentCaptureModuleSettings.fromJson(
          json['documentCaptureModule'] as Map<String, dynamic>,
        ),
  mrzModule: json['mrzModule'] == null
      ? null
      : MrzModuleSettings.fromJson(json['mrzModule'] as Map<String, dynamic>),
  barcodeModule: json['barcodeModule'] == null
      ? null
      : BarcodeModuleSettings.fromJson(
          json['barcodeModule'] as Map<String, dynamic>,
        ),
  vizModule: json['vizModule'] == null
      ? null
      : VizModuleSettings.fromJson(json['vizModule'] as Map<String, dynamic>),
  maxAllowedMismatchesPerField:
      (json['maxAllowedMismatchesPerField'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BlinkIdScanningSettingsToJson(
  BlinkIdScanningSettings instance,
) => <String, dynamic>{
  'documentCaptureModule': instance.documentCaptureModule,
  'mrzModule': instance.mrzModule,
  'barcodeModule': instance.barcodeModule,
  'vizModule': instance.vizModule,
  'maxAllowedMismatchesPerField': instance.maxAllowedMismatchesPerField,
};

BlinkIdScanningUxSettings _$BlinkIdScanningUxSettingsFromJson(
  Map<String, dynamic> json,
) => BlinkIdScanningUxSettings(
  allowHapticFeedback: json['allowHapticFeedback'] as bool? ?? true,
  showHelpButton: json['showHelpButton'] as bool? ?? true,
  showOnboardingDialog: json['showOnboardingDialog'] as bool? ?? true,
  preferredCamera:
      $enumDecodeNullable(_$PreferredCameraEnumMap, json['preferredCamera']) ??
      PreferredCamera.back,
);

Map<String, dynamic> _$BlinkIdScanningUxSettingsToJson(
  BlinkIdScanningUxSettings instance,
) => <String, dynamic>{
  'showHelpButton': instance.showHelpButton,
  'showOnboardingDialog': instance.showOnboardingDialog,
  'allowHapticFeedback': instance.allowHapticFeedback,
  'preferredCamera': _$PreferredCameraEnumMap[instance.preferredCamera]!,
};

const _$PreferredCameraEnumMap = {
  PreferredCamera.back: 'back',
  PreferredCamera.front: 'front',
};
