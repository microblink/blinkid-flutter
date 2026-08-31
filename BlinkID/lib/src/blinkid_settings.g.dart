// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blinkid_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlinkIdSdkSettings _$BlinkIdSdkSettingsFromJson(Map<String, dynamic> json) =>
    BlinkIdSdkSettings(
      licenseKey: json['licenseKey'] as String,
      downloadResources: json['downloadResources'] as bool? ?? true,
      licensee: json['licensee'] as String?,
      resourceDownloadUrl: json['resourceDownloadUrl'] as String?,
      resourceLocalFolder: json['resourceLocalFolder'] as String?,
      bundleIdentifier: json['bundleIdentifier'] as String?,
      resourceRequestTimeout: (json['resourceRequestTimeout'] as num?)?.toInt(),
      microblinkProxyUrl: json['microblinkProxyUrl'] as String?,
    );

Map<String, dynamic> _$BlinkIdSdkSettingsToJson(BlinkIdSdkSettings instance) =>
    <String, dynamic>{
      'licenseKey': instance.licenseKey,
      'licensee': instance.licensee,
      'downloadResources': instance.downloadResources,
      'resourceDownloadUrl': instance.resourceDownloadUrl,
      'resourceLocalFolder': instance.resourceLocalFolder,
      'bundleIdentifier': instance.bundleIdentifier,
      'resourceRequestTimeout': instance.resourceRequestTimeout,
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
  'scanningSettings': instance.scanningSettings.toJson(),
  'stepTimeoutDuration': instance.stepTimeoutDuration,
  'inactivityTimeoutDuration': instance.inactivityTimeoutDuration,
};

const _$ScanningModeEnumMap = {
  ScanningMode.single: 'single',
  ScanningMode.automatic: 'automatic',
};

Map<String, dynamic> _$BlinkIdScanningSettingsToJson(
  BlinkIdScanningSettings instance,
) => <String, dynamic>{
  'documentCaptureModule': instance.documentCaptureModule?.toJson(),
  'mrzModule': instance.mrzModule?.toJson(),
  'barcodeModule': instance.barcodeModule?.toJson(),
  'vizModule': instance.vizModule?.toJson(),
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
