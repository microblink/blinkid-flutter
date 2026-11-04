import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'sample_filter_options.dart';

/// Default OTA service URL used by the native BlinkID SDK when omitted.
const defaultOtaServiceUrl = 'https://blinkid-ota.microblink.com';

/// Manual module tuning, or a native session preset factory.
enum SampleSessionPresetMode {
  manual,
  documentVideo,
  documentPhoto,
  standaloneBarcode,
  verifyCapture,
}

const sampleSessionPresetModes = SampleSessionPresetMode.values;

const documentScenarios = DocumentScenario.values;

const videoQualityProfiles = VideoQualityProfile.values;

const photoQualityProfiles = PhotoQualityProfile.values;

const videoCaptureEnvironments = VideoCaptureEnvironment.values;

/// Holds UI-driven scanning configuration for the BlinkID sample app.
class ScanningModulesConfig {
  SampleSessionPresetMode sessionPresetMode = SampleSessionPresetMode.manual;

  DocumentScenario documentScenario = DocumentScenario.general;

  VideoQualityProfile videoQuality = VideoQualityProfile.balanced;

  PhotoQualityProfile photoQuality = PhotoQualityProfile.balanced;

  VideoCaptureEnvironment videoCaptureEnvironment =
      VideoCaptureEnvironment.handHeld;

  ScanningMode scanningMode = ScanningMode.automatic;

  /// Milliseconds before a scanning step times out. `0` disables the timeout.
  int stepTimeoutDuration = 60000;

  /// Milliseconds of UI inactivity before timeout. `0` disables the timeout.
  int inactivityTimeoutDuration = 10000;

  /// Shown at the start of the camera scanning flow (performScan only).
  bool showOnboardingDialog = true;

  bool allowScanSound = true;

  bool passportOnly = false;

  bool barcodeEnabled = true;
  BarcodeModuleSettings barcode = ScanningModulesConfig.defaultBarcodeModule;

  bool documentCaptureEnabled = true;
  DocumentCaptureModuleSettings documentCapture =
      ScanningModulesConfig.defaultDocumentCaptureModule;

  bool mrzEnabled = true;
  MrzModuleSettings mrz = ScanningModulesConfig.defaultMrzModule;

  bool vizEnabled = true;
  VizModuleSettings viz = ScanningModulesConfig.defaultVizModule;

  bool classFilterEnabled = false;
  List<UiDocumentFilter> classFilterInclude = [];
  List<UiDocumentFilter> classFilterExclude = [];

  bool redactionResolverEnabled = false;
  List<RedactionSettings> redactionResolverEntries = [
    ScanningModulesConfig.defaultRedactionSettings(),
  ];

  bool otaResourcesDownload = true;
  bool otaResourcesStrict = false;
  String otaResourcesServiceUrl = defaultOtaServiceUrl;

  /// SDK defaults from [BarcodeModuleSettings] constructor in `types.dart`.
  static BarcodeModuleSettings get defaultBarcodeModule =>
      BarcodeModuleSettings();

  /// SDK defaults from [DocumentCaptureModuleSettings] constructor in `types.dart`.
  static DocumentCaptureModuleSettings get defaultDocumentCaptureModule =>
      DocumentCaptureModuleSettings();

  /// SDK defaults from [MrzModuleSettings] constructor in `types.dart`.
  static MrzModuleSettings get defaultMrzModule => MrzModuleSettings();

  /// SDK defaults from [VizModuleSettings] constructor in `types.dart`.
  static VizModuleSettings get defaultVizModule => VizModuleSettings();

  static RedactionSettings defaultRedactionSettings() {
    return RedactionSettings(
      mode: RedactionMode.fullResult,
      documentNumberRedactionSettings: DocumentNumberRedactionSettings(
        prefixDigitsVisible: 0,
        suffixDigitsVisible: 1,
      ),
      fields: [FieldType.firstName, FieldType.lastName],
      documentFilter: [
        DocumentFilter(
          country: CountryID.croatia,
          documentType: DocumentTypeID.id,
        ),
      ],
    );
  }

  ClassFilter? toClassFilter() {
    if (!classFilterEnabled) {
      return null;
    }

    final includeDocuments = classFilterInclude
        .where(hasDocumentFilterCriteria)
        .map(uiToDocumentFilter)
        .toList();
    final excludeDocuments = classFilterExclude
        .where(hasDocumentFilterCriteria)
        .map(uiToDocumentFilter)
        .toList();

    if (includeDocuments.isEmpty && excludeDocuments.isEmpty) {
      return null;
    }

    final filter = ClassFilter();
    if (includeDocuments.isNotEmpty) {
      filter.includeDocuments = includeDocuments;
    }
    if (excludeDocuments.isNotEmpty) {
      filter.excludeDocuments = excludeDocuments;
    }
    return filter;
  }

  RedactionSettingsResolver? toRedactionSettingsResolver() {
    if (!redactionResolverEnabled || redactionResolverEntries.isEmpty) {
      return null;
    }
    return RedactionSettingsResolver(redactionResolverEntries);
  }

  OtaResourcesConfig? toOtaResourcesConfig() {
    if (!otaResourcesDownload) {
      return OtaResourcesConfig(checkForUpdates: false);
    }

    final serviceUrl = otaResourcesServiceUrl.trim();

    return OtaResourcesConfig(
      checkForUpdates: true,
      strict: otaResourcesStrict,
      serviceUrl: serviceUrl.isNotEmpty ? serviceUrl : null,
    );
  }

  BlinkIdScanningSettings toScanningSettings({
    bool forDirectApi = false,
  }) {
    final documentCaptureSettings = documentCaptureEnabled
        ? DocumentCaptureModuleSettings.fromJson(documentCapture.toJson())
        : null;

    if (!forDirectApi) {
      documentCaptureSettings?.cropType = InputImageCropType.notCropped;
    }

    return BlinkIdScanningSettings(
      barcodeModule: barcodeEnabled ? barcode : null,
      documentCaptureModule: documentCaptureSettings,
      mrzModule: mrzEnabled ? mrz : null,
      vizModule: vizEnabled ? viz : null,
    );
  }

  BlinkIdSessionSettings toSessionSettings({
    bool forDirectApi = false,
  }) {
    final usesPreset = sessionPresetMode != SampleSessionPresetMode.manual;

    final sessionSettings = BlinkIdSessionSettings(
      scanningMode: usesPreset ? null : scanningMode,
      scanningSettings: toScanningSettings(forDirectApi: forDirectApi),
      stepTimeoutDuration: stepTimeoutDuration,
      inactivityTimeoutDuration: inactivityTimeoutDuration,
    );

    if (!usesPreset) {
      return sessionSettings;
    }

    sessionSettings.sessionPreset = _toSessionPreset(sessionPresetMode);
    switch (sessionPresetMode) {
      case SampleSessionPresetMode.documentVideo:
        sessionSettings.documentVideoUseCase = DocumentVideoUseCase(
          scenario: documentScenario,
          quality: videoQuality,
          captureEnvironment: videoCaptureEnvironment,
        );
      case SampleSessionPresetMode.documentPhoto:
        sessionSettings.documentPhotoUseCase = DocumentPhotoUseCase(
          scenario: documentScenario,
          quality: photoQuality,
        );
      case SampleSessionPresetMode.standaloneBarcode:
      case SampleSessionPresetMode.verifyCapture:
      case SampleSessionPresetMode.manual:
        break;
    }

    return sessionSettings;
  }

  /// Manual turns the four modules on with constructor defaults.
  /// Any other preset turns them off and clears stored edits, so the scan
  /// sends only the preset until a module is turned back on.
  void applySessionPresetMode(SampleSessionPresetMode mode) {
    sessionPresetMode = mode;
    resetScanningModules(enabled: mode == SampleSessionPresetMode.manual);
  }

  void resetScanningModules({required bool enabled}) {
    barcodeEnabled = enabled;
    barcode = defaultBarcodeModule;
    documentCaptureEnabled = enabled;
    documentCapture = defaultDocumentCaptureModule;
    mrzEnabled = enabled;
    mrz = defaultMrzModule;
    vizEnabled = enabled;
    viz = defaultVizModule;
  }

  String moduleToggleSubtitle(bool enabled) {
    if (enabled) {
      return 'Enabled';
    }
    if (sessionPresetMode == SampleSessionPresetMode.manual) {
      return 'Disabled (null)';
    }
    return 'Not sent; the preset applies';
  }

  SessionPreset _toSessionPreset(SampleSessionPresetMode mode) {
    switch (mode) {
      case SampleSessionPresetMode.documentVideo:
        return SessionPreset.documentVideo;
      case SampleSessionPresetMode.documentPhoto:
        return SessionPreset.documentPhoto;
      case SampleSessionPresetMode.standaloneBarcode:
        return SessionPreset.standaloneBarcode;
      case SampleSessionPresetMode.verifyCapture:
        return SessionPreset.verifyCapture;
      case SampleSessionPresetMode.manual:
        throw StateError('manual preset mode has no SessionPreset');
    }
  }

  BlinkIdScanningUxSettings toUxSettings() {
    return BlinkIdScanningUxSettings(
      showHelpButton: true,
      showOnboardingDialog: showOnboardingDialog,
      allowHapticFeedback: true,
      allowScanSound: allowScanSound,
      preferredCamera: PreferredCamera.back,
      passportOnly: passportOnly,
    );
  }

  void resetToDefaults() {
    sessionPresetMode = SampleSessionPresetMode.manual;
    documentScenario = DocumentScenario.general;
    videoQuality = VideoQualityProfile.balanced;
    photoQuality = PhotoQualityProfile.balanced;
    videoCaptureEnvironment = VideoCaptureEnvironment.handHeld;
    scanningMode = ScanningMode.automatic;
    stepTimeoutDuration = 60000;
    inactivityTimeoutDuration = 10000;
    showOnboardingDialog = true;
    allowScanSound = true;
    passportOnly = false;
    resetScanningModules(enabled: true);

    classFilterEnabled = false;
    classFilterInclude = [];
    classFilterExclude = [];
    redactionResolverEnabled = false;
    redactionResolverEntries = [defaultRedactionSettings()];
    otaResourcesDownload = true;
    otaResourcesStrict = false;
    otaResourcesServiceUrl = defaultOtaServiceUrl;
  }
}
