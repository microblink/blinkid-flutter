import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'sample_filter_options.dart';

/// Holds UI-driven scanning configuration for the BlinkID sample app.
class ScanningModulesConfig {
  ScanningMode scanningMode = ScanningMode.automatic;

  /// Milliseconds before a scanning step times out. `0` disables the timeout.
  int stepTimeoutDuration = 60000;

  /// Milliseconds of UI inactivity before timeout. `0` disables the timeout.
  int inactivityTimeoutDuration = 10000;

  /// Shown at the start of the camera scanning flow (performScan only).
  bool showOnboardingDialog = true;

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

  BlinkIdScanningSettings toScanningSettings() {
    return BlinkIdScanningSettings(
      barcodeModule: barcodeEnabled ? barcode : null,
      documentCaptureModule:
          documentCaptureEnabled ? documentCapture : null,
      mrzModule: mrzEnabled ? mrz : null,
      vizModule: vizEnabled ? viz : null,
    );
  }

  BlinkIdSessionSettings toSessionSettings() {
    return BlinkIdSessionSettings(
      scanningMode: scanningMode,
      scanningSettings: toScanningSettings(),
      stepTimeoutDuration: stepTimeoutDuration,
      inactivityTimeoutDuration: inactivityTimeoutDuration,
    );
  }

  BlinkIdScanningUxSettings toUxSettings() {
    return BlinkIdScanningUxSettings(
      showHelpButton: true,
      showOnboardingDialog: showOnboardingDialog,
      allowHapticFeedback: true,
      preferredCamera: PreferredCamera.back,
    );
  }

  void resetToDefaults() {
    scanningMode = ScanningMode.automatic;
    stepTimeoutDuration = 60000;
    inactivityTimeoutDuration = 10000;
    showOnboardingDialog = true;
    barcodeEnabled = true;
    barcode = defaultBarcodeModule;

    documentCaptureEnabled = true;
    documentCapture = defaultDocumentCaptureModule;

    mrzEnabled = true;
    mrz = defaultMrzModule;

    vizEnabled = true;
    viz = defaultVizModule;

    classFilterEnabled = false;
    classFilterInclude = [];
    classFilterExclude = [];
    redactionResolverEnabled = false;
    redactionResolverEntries = [defaultRedactionSettings()];
  }
}
