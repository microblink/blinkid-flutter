import 'package:json_annotation/json_annotation.dart';
part 'types.g.dart';

/// Settings for the barcode extraction module.
///
/// This module manages the detection and data extraction from various 1D and 2D
/// barcode formats (such as PDF417, QR codes, and various retail codes).
///
/// It can operate as a standalone module or in combination with document capture.
///
@JsonSerializable()
class BarcodeModuleSettings {
  /// If set to true, barcode presence becomes mandatory for the scanned document.
  /// For [ScanningMode.single], the barcode must be present on the scanned side.
  /// For [ScanningMode.automatic], the barcode must be present on one of the scanned sides.
  ///
  /// In case of a timeout and advancement to the next step in the scanning flow,
  /// if a barcode is detected on the scanned side but cannot be extracted,
  /// the presence requirement is considered fulfilled. As a result, barcode extraction
  /// will no longer be a requirement to complete the scan on next side.
  final bool presenceMandatory;

  /// Indicates whether the barcode image should be returned in the result.
  ///
  /// The DPI setting and the extension factor do not affect returned barcode image.
  final bool barcodeImageReturnEnabled;

  /// Enables the scanning and processing of Pdf417 barcodes.
  ///
  /// The current analyzer model flags a barcode as "present" if either a `PDF417` or a `QR` code is detected.
  /// Because the model does not distinguish between the two types at this stage, a conflict can occur:
  /// if `PDF417` is enabled but `QR` is disabled, the analyzer may trigger for a `QR` code, causing the process to hang.
  /// To prevent this, `pdf417ScanningEnabled` and `qrScanningEnabled` must be enabled together.
  final bool pdf417ScanningEnabled;

  /// Enables the scanning and processing of QR barcodes.
  ///
  /// The current analyzer model flags a barcode as "present" if either a `PDF417` or a `QR` code is detected.
  /// Because the model does not distinguish between the two types at this stage, a conflict can occur:
  /// if `PDF417` is enabled but `QR` is disabled, the analyzer may trigger for a `QR` code, causing the process to hang.
  ///
  /// To prevent this, `qrScanningEnabled` and `pdf417ScanningEnabled` must be enabled together.
  final bool qrScanningEnabled;

  /// Enables the scanning and processing of UPC-E barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool upceScanningEnabled;

  /// Enables the scanning and processing of UPC-A barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool upcaScanningEnabled;

  /// Enables the scanning and processing of Code-128 barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool code128ScanningEnabled;

  /// Enables the scanning and processing of Code-39 barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool code39ScanningEnabled;

  /// Enables the scanning and processing of EAN-8 barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool ean8ScanningEnabled;

  /// Enables the scanning and processing of EAN-13 barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool ean13ScanningEnabled;

  /// Enables the scanning and processing of ITF barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool itfScanningEnabled;

  /// Enables the scanning and processing of DataMatrix barcodes.
  ///
  /// This setting can be enabled only if `documentCaptureEnabled` is disabled.
  final bool dataMatrixScanningEnabled;

  const BarcodeModuleSettings({
    this.presenceMandatory = false,
    this.barcodeImageReturnEnabled = false,
    this.pdf417ScanningEnabled = true,
    this.qrScanningEnabled = true,
    this.upceScanningEnabled = false,
    this.upcaScanningEnabled = false,
    this.code128ScanningEnabled = false,
    this.code39ScanningEnabled = false,
    this.ean8ScanningEnabled = false,
    this.ean13ScanningEnabled = false,
    this.itfScanningEnabled = false,
    this.dataMatrixScanningEnabled = false,
  });

  /// Returns a copy with the given fields replaced.
  BarcodeModuleSettings copyWith({
    bool? presenceMandatory,
    bool? barcodeImageReturnEnabled,
    bool? pdf417ScanningEnabled,
    bool? qrScanningEnabled,
    bool? upceScanningEnabled,
    bool? upcaScanningEnabled,
    bool? code128ScanningEnabled,
    bool? code39ScanningEnabled,
    bool? ean8ScanningEnabled,
    bool? ean13ScanningEnabled,
    bool? itfScanningEnabled,
    bool? dataMatrixScanningEnabled,
  }) => BarcodeModuleSettings(
    presenceMandatory: presenceMandatory ?? this.presenceMandatory,
    barcodeImageReturnEnabled: barcodeImageReturnEnabled ?? this.barcodeImageReturnEnabled,
    pdf417ScanningEnabled: pdf417ScanningEnabled ?? this.pdf417ScanningEnabled,
    qrScanningEnabled: qrScanningEnabled ?? this.qrScanningEnabled,
    upceScanningEnabled: upceScanningEnabled ?? this.upceScanningEnabled,
    upcaScanningEnabled: upcaScanningEnabled ?? this.upcaScanningEnabled,
    code128ScanningEnabled: code128ScanningEnabled ?? this.code128ScanningEnabled,
    code39ScanningEnabled: code39ScanningEnabled ?? this.code39ScanningEnabled,
    ean8ScanningEnabled: ean8ScanningEnabled ?? this.ean8ScanningEnabled,
    ean13ScanningEnabled: ean13ScanningEnabled ?? this.ean13ScanningEnabled,
    itfScanningEnabled: itfScanningEnabled ?? this.itfScanningEnabled,
    dataMatrixScanningEnabled: dataMatrixScanningEnabled ?? this.dataMatrixScanningEnabled,
  );

  factory BarcodeModuleSettings.fromJson(Map<String, dynamic> json) => _$BarcodeModuleSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BarcodeModuleSettingsToJson(this);
}

///
/// Settings for the document capture module.
///
/// This module is responsible for the initial document detection, image extraction
/// (such as face and document images), and image quality validation (blur, glare,
/// and lighting checks).
@JsonSerializable()
class DocumentCaptureModuleSettings {
  /// Indicates whether the input image is already cropped and perspective-corrected.
  ///
  /// Requires the input image to consist solely of the cropped document image with perspective correction applied.
  /// This only applies to images from the DirectAPI method of scanning — with images from the default scanning, the setting will be ignored.
  final bool inputImageCropped;

  /// Enables the scanning and processing of unsupported document types.
  ///
  /// A document is considered unsupported if its classification result is `OTHER`.
  final bool unsupportedDocumentsAllowed;

  /// Indicates whether the back side scan should be skipped if the document supports only image capture on that side.
  ///
  /// Some documents have a back side that is supported but contains no extractable data (no MRZ, Barcode, etc.).
  /// These sides will be "captured only".
  ///
  /// If set to `true` (default), the scanning process will stop after the front side for such documents.
  /// If set to `false`, the back side will be captured, even though no data extraction is performed.
  final bool secondSideWithNoExtractableDataSkipped;

  /// Indicates whether only the passport data page should be scanned.
  ///
  /// Scan only the data page (page containing `MRZ`) of the passport.
  ///
  /// If set to `false`, it will be required to scan the second page of certain passports.
  final bool passportDataPageScanOnly;

  /// Enables the extraction of the document's face image.
  ///
  /// If a face image is present on the document, extraction becomes mandatory if supported.
  ///
  /// For supported documents, the requirement for its presence is determined by document rules.
  /// For unsupported documents, presence is optional.
  final bool faceImageExtractionEnabled;

  /// If set to `true`, face image presence will be mandatory for the scanned document.
  ///
  /// For [ScanningMode.automatic], document side with the face image must be scanned first.
  ///
  /// In case of a timeout and advancement to the next step in the scanning flow,
  /// if a face image is detected on the scanned side but cannot be extracted,
  /// the presence requirement is considered fulfilled. As a result, face image extraction
  /// will no longer be required to complete the scan on the next side.
  final bool faceImagePresenceMandatory;

  /// Indicates whether input images should be returned in the result.
  ///
  /// Saves the input images at the moment of data extraction or timeout.
  /// This significantly increases memory consumption. Scanning performance is not affected.
  final bool inputImageReturnEnabled;

  /// Indicates whether the cropped document image should be returned in the result.
  ///
  final bool documentImageReturnEnabled;

  /// Defines the minimum required margin (in percentage) between the edge of the input image and the document.
  ///
  /// This setting is implemented to comply with regulations in certain countries that mandate documents
  /// to be stored with adequate margins in the image.
  ///
  /// Default value is `0.02`.
  /// The setting is applicable only when using images from `Video` source.
  /// The setting is ignored if `inputImageCropped == true`.
  ///
  /// Allowed minimal value is `0.0` and maximum value is `1.0`.
  final double? inputImageMargin;

  /// The DPI value for the cropped document, face and signature image.
  ///
  /// Allowed minimal value is `100` and maximum value is `400`.
  final int dotsPerInch;

  /// The extension factor for the cropped document image. Applicable only to document images.
  /// Allowed minimal value is `0.0` and maximum value is `1.0`.
  ///
  final double extensionFactor;

  /// The sensitivity of blur detection in the document image.
  ///
  /// Defines the severity of blur detected in the document image.
  ///
  /// Low – less sensitive to blur; if something is detected as blur, it is almost certainly actual blur,
  /// but some amount of blur may not be detected.
  ///
  /// High – highly sensitive to blur; it may detect blur even if it only resembles blur.
  ///
  /// See [SensitivityLevel] for more information
  final SensitivityLevel blurSensitivityLevel;

  /// Indicates whether images with detected blur should be rejected.
  ///
  /// If `true`, images with detected blur will be excluded from further processing.
  ///
  /// If `false`, images will still be processed and blur status will be reported in the result.
  final bool imageWithBlurRejected;

  /// The sensitivity of glare detection in the document image.
  ///
  /// Low – less sensitive to glare.
  /// High – highly sensitive to glare.
  /// See [SensitivityLevel] for more information
  final SensitivityLevel glareSensitivityLevel;

  /// Indicates whether images with detected glare should be rejected.
  ///
  /// If `true`, images with detected glare will be excluded from further processing.
  ///
  /// If `false`, images will still be processed and glare status will be reported in the result.
  final bool imageWithGlareRejected;

  /// The sensitivity of allowed detected tilt of the document in the image.
  ///
  /// Low – less sensitive to tilt.
  /// High – highly sensitive to tilt.
  /// See [SensitivityLevel] for more information
  final SensitivityLevel tiltSensitivityLevel;

  /// Indicates whether images with poor lighting conditions should be rejected.
  ///
  /// Poor lighting conditions are represented as either `tooBright` or `tooDark`.
  ///
  /// If `true`, such images will be excluded from further processing.
  final bool imageWithPoorLightingRejected;

  /// Indicates whether images occluded by a hand should be rejected.
  ///
  /// If `true`, occluded images will be excluded from further processing.
  ///
  /// This setting is applicable only if `inputImageCropped == false`.
  final bool imageWithHandOcclusionRejected;

  const DocumentCaptureModuleSettings({
    this.inputImageCropped = false,
    this.unsupportedDocumentsAllowed = false,
    this.secondSideWithNoExtractableDataSkipped = true,
    this.passportDataPageScanOnly = true,
    this.faceImageExtractionEnabled = false,
    this.faceImagePresenceMandatory = false,
    this.inputImageReturnEnabled = false,
    this.documentImageReturnEnabled = false,
    this.inputImageMargin = 0.02,
    this.dotsPerInch = 250,
    this.extensionFactor = 0.0,
    this.blurSensitivityLevel = SensitivityLevel.mid,
    this.imageWithBlurRejected = true,
    this.glareSensitivityLevel = SensitivityLevel.mid,
    this.imageWithGlareRejected = true,
    this.tiltSensitivityLevel = SensitivityLevel.mid,
    this.imageWithPoorLightingRejected = true,
    this.imageWithHandOcclusionRejected = true,
  });

  /// Returns a copy with the given fields replaced.
  ///
  /// [inputImageMargin] can only be replaced with a non-null value here —
  /// construct a new instance directly if you need to clear it back to null.
  DocumentCaptureModuleSettings copyWith({
    bool? inputImageCropped,
    bool? unsupportedDocumentsAllowed,
    bool? secondSideWithNoExtractableDataSkipped,
    bool? passportDataPageScanOnly,
    bool? faceImageExtractionEnabled,
    bool? faceImagePresenceMandatory,
    bool? inputImageReturnEnabled,
    bool? documentImageReturnEnabled,
    double? inputImageMargin,
    int? dotsPerInch,
    double? extensionFactor,
    SensitivityLevel? blurSensitivityLevel,
    bool? imageWithBlurRejected,
    SensitivityLevel? glareSensitivityLevel,
    bool? imageWithGlareRejected,
    SensitivityLevel? tiltSensitivityLevel,
    bool? imageWithPoorLightingRejected,
    bool? imageWithHandOcclusionRejected,
  }) => DocumentCaptureModuleSettings(
    inputImageCropped: inputImageCropped ?? this.inputImageCropped,
    unsupportedDocumentsAllowed: unsupportedDocumentsAllowed ?? this.unsupportedDocumentsAllowed,
    secondSideWithNoExtractableDataSkipped:
        secondSideWithNoExtractableDataSkipped ?? this.secondSideWithNoExtractableDataSkipped,
    passportDataPageScanOnly: passportDataPageScanOnly ?? this.passportDataPageScanOnly,
    faceImageExtractionEnabled: faceImageExtractionEnabled ?? this.faceImageExtractionEnabled,
    faceImagePresenceMandatory: faceImagePresenceMandatory ?? this.faceImagePresenceMandatory,
    inputImageReturnEnabled: inputImageReturnEnabled ?? this.inputImageReturnEnabled,
    documentImageReturnEnabled: documentImageReturnEnabled ?? this.documentImageReturnEnabled,
    inputImageMargin: inputImageMargin ?? this.inputImageMargin,
    dotsPerInch: dotsPerInch ?? this.dotsPerInch,
    extensionFactor: extensionFactor ?? this.extensionFactor,
    blurSensitivityLevel: blurSensitivityLevel ?? this.blurSensitivityLevel,
    imageWithBlurRejected: imageWithBlurRejected ?? this.imageWithBlurRejected,
    glareSensitivityLevel: glareSensitivityLevel ?? this.glareSensitivityLevel,
    imageWithGlareRejected: imageWithGlareRejected ?? this.imageWithGlareRejected,
    tiltSensitivityLevel: tiltSensitivityLevel ?? this.tiltSensitivityLevel,
    imageWithPoorLightingRejected: imageWithPoorLightingRejected ?? this.imageWithPoorLightingRejected,
    imageWithHandOcclusionRejected: imageWithHandOcclusionRejected ?? this.imageWithHandOcclusionRejected,
  );

  factory DocumentCaptureModuleSettings.fromJson(Map<String, dynamic> json) =>
      _$DocumentCaptureModuleSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentCaptureModuleSettingsToJson(this);
}

/// Settings for the MRZ (Machine Readable Zone) extraction module.
///
/// This module is dedicated to the detection and parsing of machine-readable
/// zone typically found on passports, visas, and identity cards.
@JsonSerializable()
class MrzModuleSettings {
  /// If set to `true`, MRZ presence becomes mandatory for the scanned document
  /// regardless of the document rules.
  ///
  /// For [ScanningMode.single], the MRZ must be present on the scanned side.
  /// For [ScanningMode.automatic], the MRZ must be present on one of the scanned sides.
  ///
  /// In case of a timeout and advancement to the next step in the scanning flow,
  /// if an MRZ is detected on the scanned side but cannot be extracted,
  /// the presence requirement is considered fulfilled. As a result, MRZ extraction
  /// will no longer be required to complete the scan on the next side.
  final bool presenceMandatory;

  const MrzModuleSettings({this.presenceMandatory = false});

  /// Returns a copy with the given fields replaced.
  MrzModuleSettings copyWith({bool? presenceMandatory}) =>
      MrzModuleSettings(presenceMandatory: presenceMandatory ?? this.presenceMandatory);

  factory MrzModuleSettings.fromJson(Map<String, dynamic> json) => _$MrzModuleSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$MrzModuleSettingsToJson(this);
}

/// Settings for the VIZ (Visual Inspection Zone) extraction module.
///
/// This module is responsible for extracting data from the document's
/// visual fields.
///
/// It supports features such as character validation for increased accuracy,
/// signature image extraction, and data aggregation across multiple video frames.
@JsonSerializable()
class VizModuleSettings {
  /// If set to true, Viz presence becomes mandatory for the scanned document.
  ///
  /// For [ScanningMode.single], the Viz must be present on the scanned side.
  /// Only the front side of supported documents can be scanned.
  ///
  /// For [ScanningMode.automatic], this setting won't affect the default behaviour;
  /// front side must be scanned first followed by the back side.
  ///
  /// In case of a timeout and advancement to the next step in the scanning flow,
  /// if a Viz was not extracted fully from a front side, we'll proceed to extract Viz
  /// from the back side, if present.
  final bool presenceMandatory;

  /// Enables the extraction of the document's signature image if supported.
  ///
  /// For supported documents, signature image extraction is determined by document rules.
  /// For unsupported documents, extraction won't be performed.
  final bool signatureImageExtractionEnabled;

  /// Indicates whether character validation is enabled.
  ///
  /// Allow only results containing expected characters for a given field.
  /// Each field is validated against a set of rules.
  /// All fields have to be successfully validated in order to successfully scan a document.
  /// Setting is used to improve scanning accuracy.
  ///
  final bool characterValidationEnabled;

  /// Indicates whether the aggregation of data from multiple input images is enabled.
  ///
  /// Disabling this setting will yield higher-quality captured images, but it may slow down the scanning process due to the additional
  /// effort required to find the optimal image.
  ///
  /// Enabling this setting will simplify the extraction process, but the extracted data will be aggregated from multiple images instead
  /// of being sourced from a single image.
  ///
  /// This only applies to images from `Video` input image source - for images from `Photo` source, setting will be ignored.
  final bool resultAggregationEnabled;

  const VizModuleSettings({
    this.presenceMandatory = false,
    this.signatureImageExtractionEnabled = false,
    this.characterValidationEnabled = true,
    this.resultAggregationEnabled = true,
  });

  /// Returns a copy with the given fields replaced.
  VizModuleSettings copyWith({
    bool? presenceMandatory,
    bool? signatureImageExtractionEnabled,
    bool? characterValidationEnabled,
    bool? resultAggregationEnabled,
  }) => VizModuleSettings(
    presenceMandatory: presenceMandatory ?? this.presenceMandatory,
    signatureImageExtractionEnabled: signatureImageExtractionEnabled ?? this.signatureImageExtractionEnabled,
    characterValidationEnabled: characterValidationEnabled ?? this.characterValidationEnabled,
    resultAggregationEnabled: resultAggregationEnabled ?? this.resultAggregationEnabled,
  );

  factory VizModuleSettings.fromJson(Map<String, dynamic> json) => _$VizModuleSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$VizModuleSettingsToJson(this);
}

/// ClassFilter represents the document filter used to determine which documents will be processed.
/// Document information (Country, Region, Type) is evaluated with the content set in the filter, and their inclusion or exclusion depends on the defined rules.
/// To set the document information, use [DocumentFilter].
/// The recognition results of the excluded documents will not be returned.
/// If using the standard BlinkID UX, an alert will be displayed that the document will not be scanned.
///
/// By default, the ClassFilter is turned off, and all documents will be included.
@JsonSerializable()
class ClassFilter {
  /// Document classes that will be explicitly accepted by this filter.
  /// Only documents belonging to the specified classes will be processed. All other documents will be rejected.
  ///
  /// If this list is empty, no restrictions are applied, and documents will be accepted unless explicitly excluded by `excludeDocuments`.
  ///
  /// Example usage:
  ///
  ///  ```
  ///   final classFilter = ClassFilter();
  ///    classFilter.includeDocuments = [
  ///      DocumentFilter.country(Country.usa),
  ///      DocumentFilter.countryType(Country.croatia, DocumentType.id),
  ///    ];
  ///
  ///    await blinkIdPlugin.performScan(sdkSettings, sessionSettings classFilter)
  ///  ```
  ///
  ///
  /// NOTE: from the example above, the class filter is set to only accept all documents from USA, and Croatian IDs.
  /// All other documents will be rejected.
  ///
  /// Rules can be combined, for example, to set all three properties (Country Region, Type), two (e.g., Country and Type) or just one (e.g, Region).
  ///
  /// See [DocumentFilter] for setting the combinations.
  List<DocumentFilter>? includeDocuments;

  /// Document classes that will be explicitly rejected by this filter.
  /// Documents belonging to the specified classes will not be processed. Other documents, not included with `excludeDocuments` will be accepted.
  ///
  /// If this array is empty, no restrictions are applied, and documents will be excluded only if not present in `includeDocuments`.
  ///
  /// Example usage:
  ///
  ///  ```
  ///   final classFilter = ClassFilter();
  ///    classFilter.excludeDocuments = [
  ///      DocumentFilter.country(Country.usa),
  ///      DocumentFilter.countryType(Country.croatia, DocumentType.id),
  ///    ];
  ///
  ///    await blinkIdPlugin.performScan(sdkSettings, sessionSettings classFilter)
  ///  ```
  ///
  /// NOTE: from the example above, the class filter is set to only exclude all documents from USA, and Croatian IDs.
  /// All other classes will be accepted.
  ///
  /// Rules can be combined, for example, to set all three properties (Country Region, Type), two (e.g., Country and Type) or just one (e.g, Region).
  ///
  /// See [DocumentFilter] for setting the combinations.
  List<DocumentFilter>? excludeDocuments;

  /// ClassFilter represents the document filter used to determine which documents will be processed.
  /// Document information (Country, Region, Type) is evaluated with the content set in the filter, and their inclusion or exclusion depends on the defined rules.
  /// To set the document information, use [DocumentFilter].
  /// The recognition results of the excluded documents will not be returned.
  /// If using the standard BlinkID UX, an alert will be displayed that the document will not be scanned.
  ///
  /// By default, the ClassFilter is turned off, and all documents will be included.
  ClassFilter();

  /// Constructor for only adding the document clasess that will be included for the scanning process.
  ClassFilter.withIncludedDocumentClasses(this.includeDocuments);

  /// Constructor for only adding the document clasess that will be excluded for the scanning process.
  ClassFilter.withExcludedDocumentClasses(this.excludeDocuments);

  factory ClassFilter.fromJson(Map<String, dynamic> json) => _$ClassFilterFromJson(json);
  Map<String, dynamic> toJson() => _$ClassFilterToJson(this);
}

/// Represents the document redaction settings.
@JsonSerializable()
class RedactionSettings {
  /// The mode of redaction applied to the document.
  RedactionMode mode;

  /// Fields to be redacted.
  List<FieldType> fields;

  /// Document number redaction settings.
  ///
  /// See [DocumentNumberRedactionSettings]
  DocumentNumberRedactionSettings? documentNumberRedactionSettings;

  /// If true, whole Mrz result will be redacted.
  ///
  /// Default: `false`
  bool redactMrzResult;

  /// If true, whole Barcode result will be redacted.
  ///
  /// Default: `false`
  bool redactBarcodeResult;

  /// Document classes that will be explicitly redacted.
  /// All other documents will not be redacted.
  List<DocumentFilter>? documentFilter;

  RedactionSettings({
    required this.fields,
    this.mode = RedactionMode.fullResult,
    this.documentNumberRedactionSettings,
    this.redactBarcodeResult = false,
    this.redactMrzResult = false,
    this.documentFilter,
  });

  factory RedactionSettings.fromJson(Map<String, dynamic> json) => _$RedactionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$RedactionSettingsToJson(this);
}

/// A resolver that provides custom [RedactionSettings] for a scanned document
/// based on its detected class information.
///
/// Add the resolver when you need per-document redaction behavior — for example,
/// anonymizing different fields depending on the document's country or type. The resolver
/// is invoked by the SDK immediately before the scanning result is finalized.
///
/// If not added, the SDK will use the default [RedactionSettings] for a given document class.
@JsonSerializable(explicitToJson: true)
class RedactionSettingsResolver {
  /// A list of redaction configurations evaluated by the SDK.
  ///
  /// Each [RedactionSettings] entry can target specific document classes
  /// using [RedactionSettings.documentFilter].
  ///
  /// During scanning, the SDK selects the first matching configuration
  /// for the detected document class and applies its redaction rules.
  ///
  /// If no matching configuration is found, the default SDK redaction
  /// behavior is used.
  List<RedactionSettings> documentRedactionList;

  RedactionSettingsResolver(this.documentRedactionList);

  factory RedactionSettingsResolver.fromJson(Map<String, dynamic> json) => _$RedactionSettingsResolverFromJson(json);
  Map<String, dynamic> toJson() => _$RedactionSettingsResolverToJson(this);
}

/// Represents the detailed field type.
@JsonSerializable()
class DetailedFieldType {
  /// The field type.
  ///
  /// See [FieldType] for more information.
  FieldType fieldType;

  /// The alphabet type.
  ///
  /// See [AlphabetType] for more information.
  AlphabetType alphabetType;

  /// Represents the detailed field type.
  /// Both the [FieldType] and [AlphabetType] are mandatory.
  DetailedFieldType(this.fieldType, this.alphabetType);

  factory DetailedFieldType.fromJson(Map<String, dynamic> json) => _$DetailedFieldTypeFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedFieldTypeToJson(this);
}

/// Represents the document filter.
/// Used with other classes like the [ClassFilter], [DocumentRules] and the [DocumentAnonymizationSettings].
@JsonSerializable()
class DocumentFilter {
  /// If set, only specified country will pass the filter criteria.
  /// Otherwise, issuing country will not be taken into account.
  Country? country;

  /// If set, only specified country will pass the filter criteria.
  /// Otherwise, issuing region will not be taken into account.
  Region? region;

  /// If set, only specified type will pass the filter criteria. Otherwise, issuing type will not be taken into
  /// account.
  DocumentType? documentType;

  /// Represents the document filter.
  /// Used with other classes like the [ClassFilter], [DocumentRules] and the [DocumentAnonymizationSettings].
  ///
  /// All parameters are optional, and do not need to be added.
  /// The filter can be set to be more generic (for example, to only accept document from USA):
  /// ```
  /// DocumentFilter(Country.usa);
  /// ```
  /// or, it can be set to be more specific (for example, to specifically accept USA drivers licenses from California):
  /// ```
  /// DocumentFilter(Country.usa, Region.california, DocumentType.dl);
  /// ```
  DocumentFilter({this.country, this.region, this.documentType});
  factory DocumentFilter.fromJson(Map<String, dynamic> json) => _$DocumentFilterFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentFilterToJson(this);
}

/// Represents the document number anonymization settings.
@JsonSerializable()
class DocumentNumberRedactionSettings {
  /// Defines how many digits at the beginning of the document number remain visible after anonymization.
  int? prefixDigitsVisible = 0;

  /// Defines how many digits at the end of the document number remain visible after anonymization.
  int? suffixDigitsVisible = 0;

  /// Represents the document number anonymization settings.
  ///
  /// Both settings, `prefixDigitsVisible` and `suffixDigitsVisible`, can be modified and set.
  ///
  /// By default, `prefixDigitsVisible` and `suffixDigitsVisible` are set to 0.
  /// This results that no digits within the document number will be visible.
  ///
  /// If any parameter is null, the value of the parameter will set to `0`.
  DocumentNumberRedactionSettings({int? prefixDigitsVisible, int? suffixDigitsVisible})
    : prefixDigitsVisible = prefixDigitsVisible ?? 0,
      suffixDigitsVisible = suffixDigitsVisible ?? 0;

  factory DocumentNumberRedactionSettings.fromJson(Map<String, dynamic> json) =>
      _$DocumentNumberRedactionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentNumberRedactionSettingsToJson(this);
}

/// BlinkID enums

/// Represents the mode of document scanning.
///
/// This enum class defines whether the scanning process is limited to a single
/// side of the document or includes multiple sides, automatically identifying how many sides need to be scanned.
enum ScanningMode {
  /// Specifies the scanning process to be for single side only.
  @JsonValue("single")
  single,

  /// The default [ScanningMode].
  ///
  ///  Automatically determines the number of sides to scan.
  @JsonValue("automatic")
  automatic,
}

/// Represents the different levels of detection sensitivity.
///
/// This enum class is used to configure detection thresholds and enable or
/// disable detection functionality. The levels range from turning detection
/// off completely to setting various levels of sensitivity (low, mid, high).
enum SensitivityLevel {
  /// Disables the [SensitivityLevel]
  @JsonValue("off")
  off,

  /// Sets the [SensitivityLevel] to be less sensitive.
  @JsonValue("low")
  low,

  /// The default [SensitivityLevel] sensitivity.
  @JsonValue("mid")
  mid,

  /// Sets the [SensitivityLevel] to be highly sensitive.
  @JsonValue("high")
  high,
}

/// Represents level of anonymization performed on the scanning result.
enum RedactionMode {
  /// Anonymization will not be performed.
  @JsonValue("none")
  none,

  /// Full document image is anonymized with black boxes covering sensitive data.
  @JsonValue("imageOnly")
  imageOnly,

  /// Result fields containing sensitive data are removed from result.
  @JsonValue("resultFieldsOnly")
  resultFieldsOnly,

  /// This mode is combination of `imageOnly` and `resultFieldsOnly` modes.
  @JsonValue("fullResult")
  fullResult,
}

/// Represents the type of the alphabet used in the document.
enum AlphabetType {
  /// The Latin alphabet type
  @JsonValue("latin")
  latin,

  /// The Arabic alphabet type
  @JsonValue("arabic")
  arabic,

  /// The Cyrillic alphabet type
  @JsonValue("cyrillic")
  cyrillic,

  /// The Greek alphabet type
  @JsonValue("greek")
  greek,
}

/// Document country.
enum Country {
  @JsonValue("none")
  none,
  @JsonValue("albania")
  albania,
  @JsonValue("algeria")
  algeria,
  @JsonValue("argentina")
  argentina,
  @JsonValue("australia")
  australia,
  @JsonValue("austria")
  austria,
  @JsonValue("azerbaijan")
  azerbaijan,
  @JsonValue("bahrain")
  bahrain,
  @JsonValue("bangladesh")
  bangladesh,
  @JsonValue("belgium")
  belgium,
  @JsonValue("bosniaAndHerzegovina")
  bosniaAndHerzegovina,
  @JsonValue("brunei")
  brunei,
  @JsonValue("bulgaria")
  bulgaria,
  @JsonValue("bambodia")
  bambodia,
  @JsonValue("canada")
  canada,
  @JsonValue("chile")
  chile,
  @JsonValue("colombia")
  colombia,
  @JsonValue("costaRica")
  costaRica,
  @JsonValue("croatia")
  croatia,
  @JsonValue("cyprus")
  cyprus,
  @JsonValue("czechia")
  czechia,
  @JsonValue("denmark")
  denmark,
  @JsonValue("dominicanRepublic")
  dominicanRepublic,
  @JsonValue("egypt")
  egypt,
  @JsonValue("estonia")
  estonia,
  @JsonValue("finland")
  finland,
  @JsonValue("france")
  france,
  @JsonValue("georgia")
  georgia,
  @JsonValue("germany")
  germany,
  @JsonValue("ghana")
  ghana,
  @JsonValue("greece")
  greece,
  @JsonValue("guatemala")
  guatemala,
  @JsonValue("hongKong")
  hongKong,
  @JsonValue("hungary")
  hungary,
  @JsonValue("india")
  india,
  @JsonValue("indonesia")
  indonesia,
  @JsonValue("ireland")
  ireland,
  @JsonValue("israel")
  israel,
  @JsonValue("italy")
  italy,
  @JsonValue("jordan")
  jordan,
  @JsonValue("kazakhstan")
  kazakhstan,
  @JsonValue("kenya")
  kenya,
  @JsonValue("kosovo")
  kosovo,
  @JsonValue("kuwait")
  kuwait,
  @JsonValue("latvia")
  latvia,
  @JsonValue("lithuania")
  lithuania,
  @JsonValue("malaysia")
  malaysia,
  @JsonValue("maldives")
  maldives,
  @JsonValue("malta")
  malta,
  @JsonValue("mauritius")
  mauritius,
  @JsonValue("mexico")
  mexico,
  @JsonValue("morocco")
  morocco,
  @JsonValue("netherlands")
  netherlands,
  @JsonValue("newZealand")
  newZealand,
  @JsonValue("nigeria")
  nigeria,
  @JsonValue("pakistan")
  pakistan,
  @JsonValue("panama")
  panama,
  @JsonValue("paraguay")
  paraguay,
  @JsonValue("philippines")
  philippines,
  @JsonValue("poland")
  poland,
  @JsonValue("portugal")
  portugal,
  @JsonValue("puertoRico")
  puertoRico,
  @JsonValue("qatar")
  qatar,
  @JsonValue("romania")
  romania,
  @JsonValue("russia")
  russia,
  @JsonValue("saudiArabia")
  saudiArabia,
  @JsonValue("serbia")
  serbia,
  @JsonValue("singapore")
  singapore,
  @JsonValue("slovakia")
  slovakia,
  @JsonValue("slovenia")
  slovenia,
  @JsonValue("southAfrica")
  southAfrica,
  @JsonValue("spain")
  spain,
  @JsonValue("sweden")
  sweden,
  @JsonValue("switzerland")
  switzerland,
  @JsonValue("taiwan")
  taiwan,
  @JsonValue("thailand")
  thailand,
  @JsonValue("tunisia")
  tunisia,
  @JsonValue("turkey")
  turkey,
  @JsonValue("uae")
  uae,
  @JsonValue("gganda")
  gganda,
  @JsonValue("uK")
  uK,
  @JsonValue("ukraine")
  ukraine,
  @JsonValue("usa")
  usa,
  @JsonValue("vietnam")
  vietnam,
  @JsonValue("brazil")
  brazil,
  @JsonValue("norway")
  norway,
  @JsonValue("oman")
  oman,
  @JsonValue("ecuador")
  ecuador,
  @JsonValue("elSalvador")
  elSalvador,
  @JsonValue("sriLanka")
  sriLanka,
  @JsonValue("peru")
  peru,
  @JsonValue("uruguay")
  uruguay,
  @JsonValue("bahamas")
  bahamas,
  @JsonValue("bermuda")
  bermuda,
  @JsonValue("bolivia")
  bolivia,
  @JsonValue("china")
  china,
  @JsonValue("europeanUnion")
  europeanUnion,
  @JsonValue("haiti")
  haiti,
  @JsonValue("honduras")
  honduras,
  @JsonValue("iceland")
  iceland,
  @JsonValue("japan")
  japan,
  @JsonValue("luxembourg")
  luxembourg,
  @JsonValue("montenegro")
  montenegro,
  @JsonValue("nicaragua")
  nicaragua,
  @JsonValue("southKorea")
  southKorea,
  @JsonValue("venezuela")
  venezuela,
  @JsonValue("afghanistan")
  afghanistan,
  @JsonValue("alandIslands")
  alandIslands,
  @JsonValue("americanSamoa")
  americanSamoa,
  @JsonValue("andorra")
  andorra,
  @JsonValue("angola")
  angola,
  @JsonValue("anguilla")
  anguilla,
  @JsonValue("antarctica")
  antarctica,
  @JsonValue("antiguaAndBarbuda")
  antiguaAndBarbuda,
  @JsonValue("armenia")
  armenia,
  @JsonValue("aruba")
  aruba,
  @JsonValue("bailiwickOfGuernsey")
  bailiwickOfGuernsey,
  @JsonValue("bailiwickOfJersey")
  bailiwickOfJersey,
  @JsonValue("barbados")
  barbados,
  @JsonValue("belarus")
  belarus,
  @JsonValue("belize")
  belize,
  @JsonValue("benin")
  benin,
  @JsonValue("bhutan")
  bhutan,
  @JsonValue("bonaireSaintEustatiusAndSaba")
  bonaireSaintEustatiusAndSaba,
  @JsonValue("botswana")
  botswana,
  @JsonValue("bouvetIsland")
  bouvetIsland,
  @JsonValue("britishIndianOceanTerritory")
  britishIndianOceanTerritory,
  @JsonValue("burkinaFaso")
  burkinaFaso,
  @JsonValue("burundi")
  burundi,
  @JsonValue("cameroon")
  cameroon,
  @JsonValue("capeVerde")
  capeVerde,
  @JsonValue("caribbeanNetherlands")
  caribbeanNetherlands,
  @JsonValue("caymanIslands")
  caymanIslands,
  @JsonValue("centralAfricanRepublic")
  centralAfricanRepublic,
  @JsonValue("chad")
  chad,
  @JsonValue("christmasIsland")
  christmasIsland,
  @JsonValue("cocosIslands")
  cocosIslands,
  @JsonValue("comoros")
  comoros,
  @JsonValue("congo")
  congo,
  @JsonValue("cookIslands")
  cookIslands,
  @JsonValue("cuba")
  cuba,
  @JsonValue("curacao")
  curacao,
  @JsonValue("democraticRepublicOfTheCongo")
  democraticRepublicOfTheCongo,
  @JsonValue("djibouti")
  djibouti,
  @JsonValue("dominica")
  dominica,
  @JsonValue("eastTimor")
  eastTimor,
  @JsonValue("equatorialGuinea")
  equatorialGuinea,
  @JsonValue("eritrea")
  eritrea,
  @JsonValue("ethiopia")
  ethiopia,
  @JsonValue("falklandIslands")
  falklandIslands,
  @JsonValue("faroeIslands")
  faroeIslands,
  @JsonValue("federatedStatesOfMicronesia")
  federatedStatesOfMicronesia,
  @JsonValue("fiji")
  fiji,
  @JsonValue("frenchGuiana")
  frenchGuiana,
  @JsonValue("frenchPolynesia")
  frenchPolynesia,
  @JsonValue("frenchSouthernTerritories")
  frenchSouthernTerritories,
  @JsonValue("gabon")
  gabon,
  @JsonValue("gambia")
  gambia,
  @JsonValue("gibraltar")
  gibraltar,
  @JsonValue("greenland")
  greenland,
  @JsonValue("grenada")
  grenada,
  @JsonValue("guadeloupe")
  guadeloupe,
  @JsonValue("guam")
  guam,
  @JsonValue("guinea")
  guinea,
  @JsonValue("guineaBissau")
  guineaBissau,
  @JsonValue("guyana")
  guyana,
  @JsonValue("heardIslandAndMcdonaldIslands")
  heardIslandAndMcdonaldIslands,
  @JsonValue("iran")
  iran,
  @JsonValue("iraq")
  iraq,
  @JsonValue("isleOfMan")
  isleOfMan,
  @JsonValue("ivoryCoast")
  ivoryCoast,
  @JsonValue("jamaica")
  jamaica,
  @JsonValue("kiribati")
  kiribati,
  @JsonValue("kyrgyzstan")
  kyrgyzstan,
  @JsonValue("laos")
  laos,
  @JsonValue("lebanon")
  lebanon,
  @JsonValue("lesotho")
  lesotho,
  @JsonValue("liberia")
  liberia,
  @JsonValue("libya")
  libya,
  @JsonValue("liechtenstein")
  liechtenstein,
  @JsonValue("macau")
  macau,
  @JsonValue("madagascar")
  madagascar,
  @JsonValue("malawi")
  malawi,
  @JsonValue("mali")
  mali,
  @JsonValue("marshallIslands")
  marshallIslands,
  @JsonValue("martinique")
  martinique,
  @JsonValue("mauritania")
  mauritania,
  @JsonValue("mayotte")
  mayotte,
  @JsonValue("moldova")
  moldova,
  @JsonValue("monaco")
  monaco,
  @JsonValue("mongolia")
  mongolia,
  @JsonValue("montserrat")
  montserrat,
  @JsonValue("mozambique")
  mozambique,
  @JsonValue("myanmar")
  myanmar,
  @JsonValue("namibia")
  namibia,
  @JsonValue("nauru")
  nauru,
  @JsonValue("nepal")
  nepal,
  @JsonValue("newCaledonia")
  newCaledonia,
  @JsonValue("niger")
  niger,
  @JsonValue("niue")
  niue,
  @JsonValue("norfolkIsland")
  norfolkIsland,
  @JsonValue("northernCyprus")
  northernCyprus,
  @JsonValue("northernMarianaIslands")
  northernMarianaIslands,
  @JsonValue("northKorea")
  northKorea,
  @JsonValue("northMacedonia")
  northMacedonia,
  @JsonValue("palau")
  palau,
  @JsonValue("palestine")
  palestine,
  @JsonValue("papuaNewGuinea")
  papuaNewGuinea,
  @JsonValue("pitcairn")
  pitcairn,
  @JsonValue("reunion")
  reunion,
  @JsonValue("rwanda")
  rwanda,
  @JsonValue("saintBarthelemy")
  saintBarthelemy,
  @JsonValue("saintHelenaAscensionAndTristianDaCunha")
  saintHelenaAscensionAndTristianDaCunha,
  @JsonValue("saintKittsAndNevis")
  saintKittsAndNevis,
  @JsonValue("saintLucia")
  saintLucia,
  @JsonValue("saintMartin")
  saintMartin,
  @JsonValue("saintPierreAndMiquelon")
  saintPierreAndMiquelon,
  @JsonValue("saintVincentAndTheGrenadines")
  saintVincentAndTheGrenadines,
  @JsonValue("samoa")
  samoa,
  @JsonValue("sanMarino")
  sanMarino,
  @JsonValue("saoTomeAndPrincipe")
  saoTomeAndPrincipe,
  @JsonValue("senegal")
  senegal,
  @JsonValue("seychelles")
  seychelles,
  @JsonValue("sierraLeone")
  sierraLeone,
  @JsonValue("sintMaarten")
  sintMaarten,
  @JsonValue("solomonIslands")
  solomonIslands,
  @JsonValue("somalia")
  somalia,
  @JsonValue("southGeorgiaAndTheSouthSandwichIslands")
  southGeorgiaAndTheSouthSandwichIslands,
  @JsonValue("southSudan")
  southSudan,
  @JsonValue("sudan")
  sudan,
  @JsonValue("suriname")
  suriname,
  @JsonValue("svalbardAndJanMayen")
  svalbardAndJanMayen,
  @JsonValue("eswatini")
  eswatini,
  @JsonValue("syria")
  syria,
  @JsonValue("tajikistan")
  tajikistan,
  @JsonValue("tanzania")
  tanzania,
  @JsonValue("togo")
  togo,
  @JsonValue("tokelau")
  tokelau,
  @JsonValue("tonga")
  tonga,
  @JsonValue("trinidadAndTobago")
  trinidadAndTobago,
  @JsonValue("turkmenistan")
  turkmenistan,
  @JsonValue("turksAndCaicosIslands")
  turksAndCaicosIslands,
  @JsonValue("tuvalu")
  tuvalu,
  @JsonValue("unitedStatesMinorOutlyingIslands")
  unitedStatesMinorOutlyingIslands,
  @JsonValue("uzbekistan")
  uzbekistan,
  @JsonValue("vanuatu")
  vanuatu,
  @JsonValue("vaticanCity")
  vaticanCity,
  @JsonValue("virginIslandsBritish")
  virginIslandsBritish,
  @JsonValue("virginIslandsOfTheUnitedStates")
  virginIslandsOfTheUnitedStates,
  @JsonValue("wallisAndFutuna")
  wallisAndFutuna,
  @JsonValue("westernSahara")
  westernSahara,
  @JsonValue("yemen")
  yemen,
  @JsonValue("yugoslavia")
  yugoslavia,
  @JsonValue("zambia")
  zambia,
  @JsonValue("zimbabwe")
  zimbabwe,
  @JsonValue("schengenArea")
  schengenArea,
  @JsonValue("saintThomasAndPrince")
  saintThomasAndPrince,
}

/// Document region.
enum Region {
  @JsonValue("none")
  none,
  @JsonValue("alabama")
  alabama,
  @JsonValue("alaska")
  alaska,
  @JsonValue("alberta")
  alberta,
  @JsonValue("arizona")
  arizona,
  @JsonValue("arkansas")
  arkansas,
  @JsonValue("australianCapitalTerritory")
  australianCapitalTerritory,
  @JsonValue("britishColumbia")
  britishColumbia,
  @JsonValue("california")
  california,
  @JsonValue("colorado")
  colorado,
  @JsonValue("connecticut")
  connecticut,
  @JsonValue("delaware")
  delaware,
  @JsonValue("districtOfColumbia")
  districtOfColumbia,
  @JsonValue("florida")
  florida,
  @JsonValue("georgia")
  georgia,
  @JsonValue("hawaii")
  hawaii,
  @JsonValue("idaho")
  idaho,
  @JsonValue("illinois")
  illinois,
  @JsonValue("indiana")
  indiana,
  @JsonValue("iowa")
  iowa,
  @JsonValue("kansas")
  kansas,
  @JsonValue("kentucky")
  kentucky,
  @JsonValue("louisiana")
  louisiana,
  @JsonValue("maine")
  maine,
  @JsonValue("manitoba")
  manitoba,
  @JsonValue("maryland")
  maryland,
  @JsonValue("massachusetts")
  massachusetts,
  @JsonValue("michigan")
  michigan,
  @JsonValue("minnesota")
  minnesota,
  @JsonValue("mississippi")
  mississippi,
  @JsonValue("missouri")
  missouri,
  @JsonValue("montana")
  montana,
  @JsonValue("nebraska")
  nebraska,
  @JsonValue("nevada")
  nevada,
  @JsonValue("newBrunswick")
  newBrunswick,
  @JsonValue("newHampshire")
  newHampshire,
  @JsonValue("newJersey")
  newJersey,
  @JsonValue("newMexico")
  newMexico,
  @JsonValue("newSouthWales")
  newSouthWales,
  @JsonValue("newYork")
  newYork,
  @JsonValue("northernTerritory")
  northernTerritory,
  @JsonValue("northCarolina")
  northCarolina,
  @JsonValue("northDakota")
  northDakota,
  @JsonValue("novaScotia")
  novaScotia,
  @JsonValue("ohio")
  ohio,
  @JsonValue("oklahoma")
  oklahoma,
  @JsonValue("ontario")
  ontario,
  @JsonValue("oregon")
  oregon,
  @JsonValue("pennsylvania")
  pennsylvania,
  @JsonValue("quebec")
  quebec,
  @JsonValue("queensland")
  queensland,
  @JsonValue("rhodeIsland")
  rhodeIsland,
  @JsonValue("saskatchewan")
  saskatchewan,
  @JsonValue("southAustralia")
  southAustralia,
  @JsonValue("southCarolina")
  southCarolina,
  @JsonValue("southDakota")
  southDakota,
  @JsonValue("tasmania")
  tasmania,
  @JsonValue("tennessee")
  tennessee,
  @JsonValue("texas")
  texas,
  @JsonValue("utah")
  utah,
  @JsonValue("vermont")
  vermont,
  @JsonValue("victoria")
  victoria,
  @JsonValue("virginia")
  virginia,
  @JsonValue("washington")
  washington,
  @JsonValue("westernAustralia")
  westernAustralia,
  @JsonValue("westVirginia")
  westVirginia,
  @JsonValue("wisconsin")
  wisconsin,
  @JsonValue("wyoming")
  wyoming,
  @JsonValue("yukon")
  yukon,
  @JsonValue("ciudadDeMexico")
  ciudadDeMexico,
  @JsonValue("jalisco")
  jalisco,
  @JsonValue("newfoundlandAndLabrador")
  newfoundlandAndLabrador,
  @JsonValue("nuevoLeon")
  nuevoLeon,
  @JsonValue("bajaCalifornia")
  bajaCalifornia,
  @JsonValue("chihuahua")
  chihuahua,
  @JsonValue("guanajuato")
  guanajuato,
  @JsonValue("guerrero")
  guerrero,
  @JsonValue("mexico")
  mexico,
  @JsonValue("michoacan")
  michoacan,
  @JsonValue("newYorkCity")
  newYorkCity,
  @JsonValue("tamaulipas")
  tamaulipas,
  @JsonValue("veracruz")
  veracruz,
  @JsonValue("chiapas")
  chiapas,
  @JsonValue("coahuila")
  coahuila,
  @JsonValue("durango")
  durango,
  @JsonValue("guerreroCocula")
  guerreroCocula,
  @JsonValue("guerreroJuchitan")
  guerreroJuchitan,
  @JsonValue("guerreroTepecoacuilco")
  guerreroTepecoacuilco,
  @JsonValue("guerreroTlacoapa")
  guerreroTlacoapa,
  @JsonValue("gujarat")
  gujarat,
  @JsonValue("hidalgo")
  hidalgo,
  @JsonValue("karnataka")
  karnataka,
  @JsonValue("kerala")
  kerala,
  @JsonValue("khyberPakhtunkhwa")
  khyberPakhtunkhwa,
  @JsonValue("madhyaPradesh")
  madhyaPradesh,
  @JsonValue("maharashtra")
  maharashtra,
  @JsonValue("morelos")
  morelos,
  @JsonValue("nayarit")
  nayarit,
  @JsonValue("oaxaca")
  oaxaca,
  @JsonValue("puebla")
  puebla,
  @JsonValue("punjab")
  punjab,
  @JsonValue("queretaro")
  queretaro,
  @JsonValue("sanLuisPotosi")
  sanLuisPotosi,
  @JsonValue("sinaloa")
  sinaloa,
  @JsonValue("sonora")
  sonora,
  @JsonValue("tabasco")
  tabasco,
  @JsonValue("tamilNadu")
  tamilNadu,
  @JsonValue("yucatan")
  yucatan,
  @JsonValue("zacatecas")
  zacatecas,
  @JsonValue("aguascalientes")
  aguascalientes,
  @JsonValue("bajaCaliforniaSur")
  bajaCaliforniaSur,
  @JsonValue("campeche")
  campeche,
  @JsonValue("colima")
  colima,
  @JsonValue("quintanaRooBenitoJuarez")
  quintanaRooBenitoJuarez,
  @JsonValue("quintanaRoo")
  quintanaRoo,
  @JsonValue("quintanaRooSolidaridad")
  quintanaRooSolidaridad,
  @JsonValue("tlaxcala")
  tlaxcala,
  @JsonValue("quintanaRooCozumel")
  quintanaRooCozumel,
  @JsonValue("saoPaolo")
  saoPaolo,
  @JsonValue("rioDeJaneiro")
  rioDeJaneiro,
  @JsonValue("rioGrandeDoSul")
  rioGrandeDoSul,
  @JsonValue("northWestTerritories")
  northWestTerritories,
  @JsonValue("nunavut")
  nunavut,
  @JsonValue("princeEdwardIsland")
  princeEdwardIsland,
  @JsonValue("distritoFederal")
  distritoFederal,
  @JsonValue("maranhao")
  maranhao,
  @JsonValue("matoGrosso")
  matoGrosso,
  @JsonValue("minasGerais")
  minasGerais,
  @JsonValue("para")
  para,
  @JsonValue("parana")
  parana,
  @JsonValue("pernambuco")
  pernambuco,
  @JsonValue("santaCatarina")
  santaCatarina,
  @JsonValue("andhraPradesh")
  andhraPradesh,
  @JsonValue("ceara")
  ceara,
  @JsonValue("goias")
  goias,
  @JsonValue("guerreroAcapulcoDeJuarez")
  guerreroAcapulcoDeJuarez,
  @JsonValue("haryana")
  haryana,
  @JsonValue("sergipe")
  sergipe,
  @JsonValue("alagos")
  alagos,
  @JsonValue("bangsamoro")
  bangsamoro,
  @JsonValue("telangana")
  telangana,
  @JsonValue("acre")
  acre,
  @JsonValue("espiritoSanto")
  espiritoSanto,
  @JsonValue("matoGrossoDoSul")
  matoGrossoDoSul,
  @JsonValue("paraiba")
  paraiba,
  @JsonValue("piaui")
  piaui,
  @JsonValue("rioGrandeDoNorte")
  rioGrandeDoNorte,
  @JsonValue("tocantins")
  tocantins,
  @JsonValue("odisha")
  odisha,
  @JsonValue("uttarakhand")
  uttarakhand,
}

/// Document type.
enum DocumentType {
  @JsonValue("none")
  none,
  @JsonValue("consularId")
  consularId,
  @JsonValue("dl")
  dl,
  @JsonValue("dlPublicServicesCard")
  dlPublicServicesCard,
  @JsonValue("employmentPass")
  employmentPass,
  @JsonValue("finCard")
  finCard,
  @JsonValue("id")
  id,
  @JsonValue("multipurposeId")
  multipurposeId,
  @JsonValue("myKad")
  myKad,
  @JsonValue("myKid")
  myKid,
  @JsonValue("myPR")
  myPR,
  @JsonValue("myTentera")
  myTentera,
  @JsonValue("panCard")
  panCard,
  @JsonValue("professionalId")
  professionalId,
  @JsonValue("publicServicesCard")
  publicServicesCard,
  @JsonValue("residencePermit")
  residencePermit,
  @JsonValue("residentId")
  residentId,
  @JsonValue("temporaryResidencePermit")
  temporaryResidencePermit,
  @JsonValue("voterId")
  voterId,
  @JsonValue("workPermit")
  workPermit,
  @JsonValue("iKad")
  iKad,
  @JsonValue("militaryId")
  militaryId,
  @JsonValue("myKas")
  myKas,
  @JsonValue("docialSecurityCard")
  docialSecurityCard,
  @JsonValue("healthInsuranceCard")
  healthInsuranceCard,
  @JsonValue("passport")
  passport,
  @JsonValue("sPass")
  sPass,
  @JsonValue("addressCard")
  addressCard,
  @JsonValue("alienId")
  alienId,
  @JsonValue("alienPassport")
  alienPassport,
  @JsonValue("greenCard")
  greenCard,
  @JsonValue("minorsId")
  minorsId,
  @JsonValue("postalId")
  postalId,
  @JsonValue("professionalDl")
  professionalDl,
  @JsonValue("taxId")
  taxId,
  @JsonValue("weaponPermit")
  weaponPermit,
  @JsonValue("visa")
  visa,
  @JsonValue("borderCrossingCard")
  borderCrossingCard,
  @JsonValue("driverCard")
  driverCard,
  @JsonValue("globalEntryCard")
  globalEntryCard,
  @JsonValue("mypolis")
  mypolis,
  @JsonValue("nexusCard")
  nexusCard,
  @JsonValue("passportCard")
  passportCard,
  @JsonValue("proofOfAgeCard")
  proofOfAgeCard,
  @JsonValue("refugeeId")
  refugeeId,
  @JsonValue("tribalId")
  tribalId,
  @JsonValue("veteranId")
  veteranId,
  @JsonValue("citizenshipCertificate")
  citizenshipCertificate,
  @JsonValue("myNumberCard")
  myNumberCard,
  @JsonValue("consularPassport")
  consularPassport,
  @JsonValue("minorsPassport")
  minorsPassport,
  @JsonValue("minorsPublicServicesCard")
  minorsPublicServicesCard,
  @JsonValue("drivingPriviligeCard")
  drivingPriviligeCard,
  @JsonValue("asylumRequest")
  asylumRequest,
  @JsonValue("driverQualificationCard")
  driverQualificationCard,
  @JsonValue("provisionalDl")
  provisionalDl,
  @JsonValue("refugeePassport")
  refugeePassport,
  @JsonValue("specialId")
  specialId,
  @JsonValue("uniformedServicesId")
  uniformedServicesId,
  @JsonValue("immigrantVisa")
  immigrantVisa,
  @JsonValue("consularVoterId")
  consularVoterId,
  @JsonValue("twicCard")
  twicCard,
  @JsonValue("exitEntryPermit")
  exitEntryPermit,
  @JsonValue("mainlandTravelPermitTaiwan")
  mainlandTravelPermitTaiwan,
  @JsonValue("nbiClearance")
  nbiClearance,
  @JsonValue("proofOfRegistration")
  proofOfRegistration,
  @JsonValue("temporaryProtectionPermit")
  temporaryProtectionPermit,
  @JsonValue("afghanCitizenCard")
  afghanCitizenCard,
  @JsonValue("eId")
  eId,
  @JsonValue("pass")
  pass,
  @JsonValue("sisId")
  sisId,
  @JsonValue("asicCard")
  asicCard,
  @JsonValue("bidoonCard")
  bidoonCard,
  @JsonValue("interimHealthInsuranceCard")
  interimHealthInsuranceCard,
  @JsonValue("nonVoterId")
  nonVoterId,
  @JsonValue("reciprocalHealthInsuranceCard")
  reciprocalHealthInsuranceCard,
  @JsonValue("vehicleRegistration")
  vehicleRegistration,
  @JsonValue("esaadCard")
  esaadCard,
  @JsonValue("registrationCertificate")
  registrationCertificate,
  @JsonValue("medicalMarijuanaId")
  medicalMarijuanaId,
  @JsonValue("nonCardTribalId")
  nonCardTribalId,
  @JsonValue("diplomaticId")
  diplomaticId,
  @JsonValue("emergencyPassport")
  emergencyPassport,
  @JsonValue("temporaryPassport")
  temporaryPassport,
  @JsonValue("metisFederationCard")
  metisFederationCard,
  @JsonValue("socialSecurityCard")
  socialSecurityCard,
  @JsonValue("adrCertificate")
  adrCertificate,
  @JsonValue("ninCard")
  ninCard,
  @JsonValue("mysssCard")
  mysssCard,
  @JsonValue("gendarmerieId")
  gendarmerieId,
  @JsonValue("policeId")
  policeId,
  @JsonValue("originCard")
  originCard,
}

/// Represents all possible field types that can be extracted from the document.
enum FieldType {
  @JsonValue("additionalAddressInformation")
  additionalAddressInformation,
  @JsonValue("additionalNameInformation")
  additionalNameInformation,
  @JsonValue("additionalOptionalAddressInformation")
  additionalOptionalAddressInformation,
  @JsonValue("additionalPersonalIdNumber")
  additionalPersonalIdNumber,
  @JsonValue("address")
  address,
  @JsonValue("classEffectiveDate")
  classEffectiveDate,
  @JsonValue("classExpiryDate")
  classExpiryDate,
  @JsonValue("conditions")
  conditions,
  @JsonValue("dateOfBirth")
  dateOfBirth,
  @JsonValue("dateOfExpiry")
  dateOfExpiry,
  @JsonValue("dateOfIssue")
  dateOfIssue,
  @JsonValue("documentAdditionalNumber")
  documentAdditionalNumber,
  @JsonValue("documentOptionalAdditionalNumber")
  documentOptionalAdditionalNumber,
  @JsonValue("documentNumber")
  documentNumber,
  @JsonValue("employer")
  employer,
  @JsonValue("endorsements")
  endorsements,
  @JsonValue("fathersName")
  fathersName,
  @JsonValue("firstName")
  firstName,
  @JsonValue("fullName")
  fullName,
  @JsonValue("issuingAuthority")
  issuingAuthority,
  @JsonValue("lastName")
  lastName,
  @JsonValue("licenceType")
  licenceType,
  @JsonValue("localizedName")
  localizedName,
  @JsonValue("maritalStatus")
  maritalStatus,
  @JsonValue("mothersName")
  mothersName,
  @JsonValue("mrz")
  mrz,
  @JsonValue("nationality")
  nationality,
  @JsonValue("personalIdNumber")
  personalIdNumber,
  @JsonValue("placeOfBirth")
  placeOfBirth,
  @JsonValue("profession")
  profession,
  @JsonValue("race")
  race,
  @JsonValue("religion")
  religion,
  @JsonValue("residentialStatus")
  residentialStatus,
  @JsonValue("restrictions")
  restrictions,
  @JsonValue("sex")
  sex,
  @JsonValue("vehicleClass")
  vehicleClass,
  @JsonValue("bloodType")
  bloodType,
  @JsonValue("sponsor")
  sponsor,
  @JsonValue("visaType")
  visaType,
  @JsonValue("documentSubtype")
  documentSubtype,
  @JsonValue("remarks")
  remarks,
  @JsonValue("residencePermitType")
  residencePermitType,
  @JsonValue("manufacturingYear")
  manufacturingYear,
  @JsonValue("vehicleType")
  vehicleType,
  @JsonValue("dependentDateOfBirth")
  dependentDateOfBirth,
  @JsonValue("dependentSex")
  dependentSex,
  @JsonValue("dependentDocumentNumber")
  dependentDocumentNumber,
  @JsonValue("dependentFullName")
  dependentFullName,
  @JsonValue("eligibilityCategory")
  eligibilityCategory,
  @JsonValue("specificDocumentValidity")
  specificDocumentValidity,
  @JsonValue("vehicleOwner")
  vehicleOwner,
  @JsonValue("nationalInsuranceNumber")
  nationalInsuranceNumber,
  @JsonValue("countryCode")
  countryCode,
  @JsonValue("certificateNumber")
  certificateNumber,
  @JsonValue("municipalityOfRegistration")
  municipalityOfRegistration,
  @JsonValue("localityCode")
  localityCode,
  @JsonValue("maidenName")
  maidenName,
  @JsonValue("stateCode")
  stateCode,
  @JsonValue("dateOfEntry")
  dateOfEntry,
  @JsonValue("municipalityCode")
  municipalityCode,
  @JsonValue("pollingStationCode")
  pollingStationCode,
  @JsonValue("sectionCode")
  sectionCode,
  @JsonValue("registrationCenterCode")
  registrationCenterCode,
  @JsonValue("stateName")
  stateName,
  @JsonValue("effectiveDate")
  effectiveDate,
  @JsonValue("parentsLastName")
  parentsLastName,
  @JsonValue("parentsFirstName")
  parentsFirstName,
  @JsonValue("workRestriction")
  workRestriction,
  @JsonValue("socialSecurityStatus")
  socialSecurityStatus,
  @JsonValue("legalStatus")
  legalStatus,
  @JsonValue("husbandName")
  husbandName,
  @JsonValue("cardAccessNumber")
  cardAccessNumber,
}

/// An enum indicating preffered camera position for document capturing.
enum PreferredCamera {
  /// Use the back-facing camera
  ///
  /// This is the default value
  @JsonValue("back")
  back,

  /// Use the front-facing camera
  @JsonValue("front")
  front,
}

/// Represents the document class information.
class DocumentClassInfo {
  /// The document country.
  ///
  /// See [Country] for more information.
  Country? country;

  /// The document region.
  ///
  /// See [Region] for more information.
  Region? region;

  /// The type of the scanned document.
  ///
  /// See [DocumentType] for more information.
  DocumentType? documentType;

  /// Flag that indicates if the document class information is empty
  ///
  bool? empty;

  /// The name of the country that issued the scanned document.
  String? countryName;

  /// The ISO numeric code of the country that issued the scanned document.
  String? isoNumericCountryCode;

  /// The 2 letter ISO code of the country that issued the scanned document.
  String? isoAlpha2CountryCode;

  /// The 3 letter ISO code of the country that issued the scanned document.
  String? isoAlpha3CountryCode;

  /// Represents the document class information.
  DocumentClassInfo(Map<String, dynamic> nativeClassInfo) {
    country = enumFromValue(Country.values.toList(), nativeClassInfo['country']);
    region = enumFromValue(Region.values.toList(), nativeClassInfo['region']);
    documentType = enumFromValue(DocumentType.values.toList(), nativeClassInfo['documentType']);
    empty = nativeClassInfo['empty'];
    countryName = nativeClassInfo['countryName'];
    isoNumericCountryCode = nativeClassInfo['isoNumericCountryCode'];
    isoAlpha2CountryCode = nativeClassInfo['isoAlpha2CountryCode'];
    isoAlpha3CountryCode = nativeClassInfo['isoAlpha3CountryCode'];
  }
}

/// Represents the result of the data match.
class DataMatchResult {
  ///  The state of the data match on the whole document.
  ///
  /// See [DataMatchState] for more information.
  DataMatchState? overallState;

  /// The data match state of each field.
  ///
  /// See [DataMatchResultField] for more information.
  List<DataMatchResultField>? states;

  /// Represents the result of the data match.
  DataMatchResult(Map<String, dynamic> nativeDataMatchResult) {
    overallState = enumFromValue(DataMatchState.values, nativeDataMatchResult["overallState"]);
    states = nativeDataMatchResult["states"] != null
        ? (nativeDataMatchResult["states"] as List<dynamic>)
              .map((item) => DataMatchResultField(Map<String, dynamic>.from(item)))
              .toList()
        : null;
  }
}

/// Represents the state of the field in the data match.
class DataMatchResultField {
  /// The type of the field.
  ///
  /// See [DataMatchField] for more information.
  DataMatchField? field;

  /// The state of the field.
  ///
  /// See [DataMatchState] for more information.
  DataMatchState? state;

  /// Represents the state of the field in the data match.
  DataMatchResultField(Map<String, dynamic> nativeDataMatchResultField) {
    field = enumFromValue(DataMatchField.values, nativeDataMatchResultField["field"]);
    state = enumFromValue(DataMatchState.values, nativeDataMatchResultField["state"]);
  }
}

/// Represents the type of the field used in data match.
enum DataMatchField {
  /// The date of birth field.
  @JsonValue("dateOfBirth")
  dateOfBirth,

  /// The date of expiry field.
  @JsonValue("dateOfExpiry")
  dateOfExpiry,

  /// The document number field.
  @JsonValue("documentNumber")
  documentNumber,

  /// The document additional number field.
  @JsonValue("documentAdditionalNumber")
  documentAdditionalNumber,

  /// The document optional additional number field.
  @JsonValue("documentOptionalAdditionalNumber")
  documentOptionalAdditionalNumber,

  /// The personal ID number field.
  @JsonValue("personalIdNumber")
  personalIdNumber,
}

/// Represents the state of the data match.
enum DataMatchState {
  /// Data matching has not been performed.
  @JsonValue("notPerformed")
  notPerformed,

  /// Data does not match.
  @JsonValue("failed")
  failed,

  /// Data does match.
  @JsonValue("success")
  success,
}

/// Represents the multi-alphabet string result extracted from the OCR.
/// The result contains the extracted strings, their locations, and the sides of the extracted strings.
class StringResult {
  ///  All strings separated by new line
  String? value;

  /// String for field in latin alphabet
  String? latin;

  /// String for field in arabic alphabet
  String? arabic;

  /// String for field in cyrillic alphabet
  String? cyrillic;

  /// String for field in greek alphabet
  String? greek;

  /// Document field location
  ///
  /// See [Location] for more information.
  Location? location;

  /// The document side where the field is located.
  ///
  /// See [Side] for more information.
  Side? side;

  /// Represents the multi-alphabet string result extracted from the OCR.
  /// The result contains the extracted strings, their locations, and the sides of the extracted strings.
  StringResult(Map<String, dynamic> nativeStringResult) {
    value = nativeStringResult['value'];
    latin = nativeStringResult['latin'];
    arabic = nativeStringResult['arabic'];
    cyrillic = nativeStringResult['cyrillic'];
    greek = nativeStringResult['greek'];
    location = nativeStringResult['location'] != null
        ? Location(Map<String, dynamic>.from(nativeStringResult['location']))
        : null;
    side = nativeStringResult['side'] != null ? Side(Map<String, dynamic>.from(nativeStringResult['side'])) : null;
  }
}

/// Represents the rectangle location of each document field
class Rectangle {
  /// X location
  double? x;

  /// Y location
  double? y;

  /// Rectangle width
  double? width;

  /// Rectangle height
  double? height;

  /// Represents rectangle location of each document field
  Rectangle(Map<String, dynamic> nativeRect) {
    x = nativeRect['x'] != null ? nativeRect['x'] * 1.0 : null;
    y = nativeRect['y'] != null ? nativeRect['y'] * 1.0 : null;
    width = nativeRect['width'] != null ? nativeRect['width'] * 1.0 : null;
    height = nativeRect['height'] != null ? nativeRect['height'] * 1.0 : null;
  }
}

/// Represents the information about the location of an element within a document or image.
class Location {
  /// Rectangle location of the result extracted from the OCR in the latin alphabet.
  Rectangle? latin;

  /// Rectangle location of the result extracted from the OCR in the arabic alphabet.
  Rectangle? arabic;

  /// Rectangle location of the result extracted from the OCR in the cyrillic alphabet.
  Rectangle? cyrillic;

  /// Rectangle location of the result extracted from the OCR in the greek alphabet.
  Rectangle? greek;

  /// Represents the information about the location of an element within a document or image.
  Location(Map<String, dynamic> nativeLocation) {
    latin = nativeLocation['latin'] != null ? Rectangle(Map<String, dynamic>.from(nativeLocation['latin'])) : null;
    arabic = nativeLocation['arabic'] != null ? Rectangle(Map<String, dynamic>.from(nativeLocation['arabic'])) : null;
    cyrillic = nativeLocation['cyrillic'] != null
        ? Rectangle(Map<String, dynamic>.from(nativeLocation['cyrillic']))
        : null;
    greek = nativeLocation['greek'] != null ? Rectangle(Map<String, dynamic>.from(nativeLocation['greek'])) : null;
  }
}

/// Side of the document on which the specific result is located.
class Side {
  /// Document side of the result extracted from the OCR in the latin alphabet.
  DocumentSide? latin;

  /// Document side of the result extracted from the OCR in the arabic alphabet.
  DocumentSide? arabic;

  /// Document side of the result extracted from the OCR in the cyrillic alphabet.
  DocumentSide? cyrillic;

  /// Document side of the result extracted from the OCR in the cyrillic alphabet.
  DocumentSide? greek;

  /// Side of the document on which the specific result is located.
  Side(Map<String, dynamic> nativeSide) {
    latin = enumFromValue(DocumentSide.values, nativeSide['latin']);
    arabic = enumFromValue(DocumentSide.values, nativeSide['arabic']);
    cyrillic = enumFromValue(DocumentSide.values, nativeSide['cyrillic']);
    greek = enumFromValue(DocumentSide.values, nativeSide['greek']);
  }
}

/// Define document side where the document field is located
enum DocumentSide {
  ///The field was not detected
  none,

  ///The field is located on the front side of the document
  front,

  ///The field is located on the back side of the document
  back,
}

/// Represents the result of the date extraction.
/// Contains the extracted date, along with additional date information.
class DateResult<T> {
  /// The extracted date information.
  ///
  /// See [Date] for more information.
  Date? date;

  /// Original string representation of the date which has been extracted.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? originalString;

  /// Indicates that date does not appear on the document but is filled by our internal domain knowledge.
  bool? isFilledByDomainKnowledge;

  /// Indicates whether date was successfully parsed.
  bool? successfullyParsed;

  /// Represents the result of the date extraction.
  /// Contains the extracted date, along with additional date information.
  DateResult(Map<String, dynamic> nativeDateResult) {
    date = Date(nativeDateResult);
    originalString = handleStringType(nativeDateResult, "originalString");
    isFilledByDomainKnowledge = nativeDateResult["isFilledByDomainKnowledge"];
    successfullyParsed = nativeDateResult["successfullyParsed"];
  }
}

/// Represents the extracted date.
class Date {
  /// Day of the month.
  /// The first day of the month has value 1.
  int? day;

  /// Month of the year.
  /// The first month of the year has value 1.
  int? month;

  /// Full year.
  int? year;

  /// Represents the extracted date.
  Date(Map<String, dynamic> nativeDate) {
    day = nativeDate['date']['day'];
    month = nativeDate['date']['month'];
    year = nativeDate['date']['year'];
  }
}

StringResult? createStringResult(Map<String, dynamic> result, String propertyName) {
  return result[propertyName] != null ? StringResult(Map<String, dynamic>.from(result[propertyName])) : null;
}

///  Represents detailed extracted information about the driver license.
class DriverLicenseDetailedInfo<T> {
  ///  The restrictions to driving privileges for the United States driver license owner.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? restrictions;

  ///  The additional privileges granted to the US driver license owner.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? endorsements;

  /// The type of vehicle the driver license owner has privilege to drive.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? vehicleClass;

  /// The driver license conditions.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? conditions;

  /// The additional information on vehicle class.
  ///
  /// See [VehicleClassInfo] for more information.
  List<VehicleClassInfo>? vehicleClassesInfo;

  ///  Represents detailed extracted information about the driver license.
  DriverLicenseDetailedInfo(Map<String, dynamic> nativeDriverLicenseDetailedInfo) {
    restrictions = handleStringType(nativeDriverLicenseDetailedInfo, 'restrictions');
    endorsements = handleStringType(nativeDriverLicenseDetailedInfo, 'endorsements');
    vehicleClass = handleStringType(nativeDriverLicenseDetailedInfo, 'vehicleClass');
    conditions = handleStringType(nativeDriverLicenseDetailedInfo, 'conditions');
    vehicleClassesInfo = nativeDriverLicenseDetailedInfo['vehicleClassesInfo'] != null
        ? List<VehicleClassInfo<T>>.from(
            nativeDriverLicenseDetailedInfo['vehicleClassesInfo'].map((v) => VehicleClassInfo<T>(v)),
          )
        : null;
  }
}

/// Represents the information about the vehicle class extraction.
class VehicleClassInfo<T> {
  /// The type of driver licence.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? licenceType;

  /// The type of vehicle the driver license owner has privilege to drive.
  ///
  /// Depending of the information source, it can either be of type [StringResult] or [String].
  T? vehicleClass;

  /// The date since licence is effective.
  /// See [DateResult] for more information.
  DateResult<T>? effectiveDate;

  /// The date of expiry of licence.
  DateResult<T>? expiryDate;

  /// Represents the information about the vehicle class extraction.
  VehicleClassInfo(Map<String, dynamic> nativeVehicleClassInfo) {
    licenceType = handleStringType(nativeVehicleClassInfo, 'licenceType');
    vehicleClass = handleStringType(nativeVehicleClassInfo, 'vehicleClass');
    effectiveDate = nativeVehicleClassInfo['effectiveDate'] != null
        ? DateResult<T>(Map<String, dynamic>.from(nativeVehicleClassInfo['effectiveDate']))
        : null;
    expiryDate = nativeVehicleClassInfo['expiryDate'] != null
        ? DateResult<T>(Map<String, dynamic>.from(nativeVehicleClassInfo['expiryDate']))
        : null;
  }
}

/// Information about the dependent.
class DependentInfo {
  /// The date of birth of the dependent.
  DateResult<StringResult>? dateOfBirth;

  /// The sex or gender of the dependent.
  StringResult? sex;

  /// The document number of the dependent.
  StringResult? documentNumber;

  /// The full name of the dependent.
  StringResult? fullName;

  /// Checks if the dependent's information is empty.
  bool? empty;

  /// Information about the dependent.
  DependentInfo(Map<String, dynamic> nativeDependentInfo) {
    dateOfBirth = nativeDependentInfo['dateOfBirth'] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeDependentInfo['dateOfBirth']))
        : null;
    sex = createStringResult(nativeDependentInfo, 'sex');
    documentNumber = createStringResult(nativeDependentInfo, 'documentNumber');
    fullName = createStringResult(nativeDependentInfo, 'fullName');
    empty = nativeDependentInfo['empty'];
  }
}

///Represents the result of scanning a single side of the document.
///
/// Contains the data extracted from the Visual Inspection Zone, Machine Readable Zone,
/// barcode, the input image, and the cropped document, face, and signature images.
class SingleSideScanningResult {
  /// The data extracted from the Visual Inspection Zone.
  VizResult? viz;

  /// The data extracted from the Machine Readable Zone.
  MrzResult? mrz;

  /// The data extracted from the barcode.
  BarcodeResult? barcode;

  /// The input image in the Base64 format.
  String? inputImage;

  /// The input image containing parsable barcode in the Base64 format.
  String? barcodeInputImage;

  /// The cropped document image in the Base64 format.
  String? documentImage;

  /// The cropped face image with additional info.
  DetailedCroppedImageResult? faceImage;

  /// The cropped signature image with additional info.
  DetailedCroppedImageResult? signatureImage;

  ///Represents the result of scanning a single side of the document.
  ///
  /// Contains the data extracted from the Visual Inspection Zone, Machine Readable Zone,
  /// barcode, the input image, and the cropped document, face, and signature images.
  SingleSideScanningResult(Map<String, dynamic> nativeSingleSideScanningResult) {
    viz = nativeSingleSideScanningResult["viz"] != null
        ? VizResult(Map<String, dynamic>.from(nativeSingleSideScanningResult['viz']))
        : null;
    mrz = nativeSingleSideScanningResult["mrz"] != null
        ? MrzResult(Map<String, dynamic>.from(nativeSingleSideScanningResult['mrz']))
        : null;
    barcode = nativeSingleSideScanningResult["barcode"] != null
        ? BarcodeResult(Map<String, dynamic>.from(nativeSingleSideScanningResult['barcode']))
        : null;
    inputImage = nativeSingleSideScanningResult["inputImage"];
    barcodeInputImage = nativeSingleSideScanningResult["barcodeInputImage"];
    documentImage = nativeSingleSideScanningResult["documentImage"];
    faceImage = nativeSingleSideScanningResult["faceImage"] != null
        ? DetailedCroppedImageResult(Map<String, dynamic>.from(nativeSingleSideScanningResult["faceImage"]))
        : null;
    signatureImage = nativeSingleSideScanningResult["signatureImage"] != null
        ? DetailedCroppedImageResult(Map<String, dynamic>.from(nativeSingleSideScanningResult["signatureImage"]))
        : null;
  }
}

/// Represents the result of the Visual Inspection Zone of a document.
class VizResult {
  /// The first name of the document owner.
  StringResult? firstName;

  /// The last name of the document owner.
  StringResult? lastName;

  /// The full name of the document owner.
  StringResult? fullName;

  /// The additional name information of the document owner.
  StringResult? additionalNameInformation;

  /// The localized name of the document owner.
  StringResult? localizedName;

  /// The fathers name of the document owner.
  StringResult? fathersName;

  /// The mothers name of the document owner.
  StringResult? mothersName;

  /// The address of the document owner.
  StringResult? address;

  /// THe additional address information of the document owner.
  StringResult? additionalAddressInformation;

  /// The one more additional address information of the document own
  StringResult? additionalOptionalAddressInformation;

  /// The place of birth of the document owner.
  StringResult? placeOfBirth;

  /// The nationality of the document owner.
  StringResult? nationality;

  /// The race of the document owner.
  StringResult? race;

  /// The religion of the document owner.
  StringResult? religion;

  /// The profession of the document owner.
  StringResult? profession;

  /// The marital status of the document owner.
  StringResult? maritalStatus;

  /// The residential status of the document owner.
  StringResult? residentialStatus;

  /// The employer of the document owner.
  StringResult? employer;

  /// The sex of the document owner.
  StringResult? sex;

  /// The sponsor of the document owner.
  StringResult? sponsor;

  /// The blood type of the document owner.
  StringResult? bloodType;

  /// The date of birth of the document owner.
  DateResult<StringResult>? dateOfBirth;

  /// The date of issue of the document.
  DateResult<StringResult>? dateOfIssue;

  /// The date of expiry of the document.
  DateResult<StringResult>? dateOfExpiry;

  /// The date of entry of the document owner.
  DateResult<StringResult>? dateOfEntry;

  /// The locality code of the document owner.
  StringResult? localityCode;

  /// The maiden name of the document owner.
  StringResult? maidenName;

  /// The municipality code of the document owner.
  StringResult? municipalityCode;

  /// The municipality of registration of the document owner.
  StringResult? municipalityOfRegistration;

  /// The polling station code of the document owner.
  StringResult? pollingStationCode;

  /// The registration center code of the document owner.
  StringResult? registrationCenterCode;

  /// The section code of the document owner.
  StringResult? sectionCode;

  /// The state code of the document owner.
  StringResult? stateCode;

  /// The state of the document owner.
  StringResult? stateName;

  /// Determines if date of expiry is permanent.
  bool? dateOfExpiryPermanent;

  /// The document number.
  StringResult? documentNumber;

  /// The card access number.
  StringResult? cardAccessNumber;

  /// The personal identification number.
  StringResult? personalIdNumber;

  /// The additional number of the document.
  StringResult? documentAdditionalNumber;

  /// The one more additional number of the document.
  StringResult? documentOptionalAdditionalNumber;

  /// The additional personal identification number.
  StringResult? additionalPersonalIdNumber;

  /// The issuing authority of the document.
  StringResult? issuingAuthority;

  /// The visa type of the document.
  StringResult? visaType;

  /// The driver license detailed info.
  DriverLicenseDetailedInfo<StringResult>? driverLicenseDetailedInfo;

  /// The transcription of the document subtype.
  StringResult? documentSubtype;

  /// The remarks on the residence permit.
  StringResult? remarks;

  /// The residence permit type.
  StringResult? residencePermitType;

  /// The manufacturing year.
  StringResult? manufacturingYear;

  /// The vehicle type.
  StringResult? vehicleType;

  /// The eligibility category.
  StringResult? eligibilityCategory;

  /// The specific document validity.
  StringResult? specificDocumentValidity;

  /// The dependents info.
  List<DependentInfo>? dependentsInfo;

  /// The vehicle owner.
  StringResult? vehicleOwner;

  /// The country code of the document owner.
  StringResult? countryCode;

  /// The certificate number of the document owner.
  StringResult? certificateNumber;

  /// The national insurance number of the document owner.
  StringResult? nationalInsuranceNumber;

  ///  The effective date of the document.
  DateResult<StringResult>? effectiveDate;

  /// The parents info.
  ///
  /// See [ParentInfo] for more information.
  List<ParentInfo>? parentsInfo;

  /// The husband name of the document owner.
  StringResult? husbandName;

  /// The legal status of the document owner.
  StringResult? legalStatus;

  /// The social security status of the document owner.
  StringResult? socialSecurityStatus;

  /// The work restriction of the document owner.
  StringResult? workRestriction;

  /// Represents the result of the Visual Inspection Zone of a document.
  VizResult(Map<String, dynamic> nativeVizResult) {
    firstName = createStringResult(nativeVizResult, 'firstName');
    lastName = createStringResult(nativeVizResult, 'lastName');
    fullName = createStringResult(nativeVizResult, 'fullName');
    additionalNameInformation = createStringResult(nativeVizResult, 'additionalNameInformation');
    localizedName = createStringResult(nativeVizResult, 'localizedName');
    fathersName = createStringResult(nativeVizResult, 'fathersName');
    mothersName = createStringResult(nativeVizResult, 'mothersName');
    address = createStringResult(nativeVizResult, 'address');
    additionalAddressInformation = createStringResult(nativeVizResult, 'additionalAddressInformation');
    additionalOptionalAddressInformation = createStringResult(nativeVizResult, 'additionalOptionalAddressInformation');
    placeOfBirth = createStringResult(nativeVizResult, 'placeOfBirth');
    nationality = createStringResult(nativeVizResult, 'nationality');
    race = createStringResult(nativeVizResult, 'race');
    religion = createStringResult(nativeVizResult, 'religion');
    profession = createStringResult(nativeVizResult, 'profession');
    maritalStatus = createStringResult(nativeVizResult, 'maritalStatus');
    residentialStatus = createStringResult(nativeVizResult, 'residentialStatus');
    employer = createStringResult(nativeVizResult, 'employer');
    sex = createStringResult(nativeVizResult, 'sex');
    sponsor = createStringResult(nativeVizResult, 'sponsor');
    bloodType = createStringResult(nativeVizResult, 'bloodType');
    dateOfBirth = nativeVizResult["dateOfBirth"] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeVizResult["dateOfBirth"]))
        : null;
    dateOfIssue = nativeVizResult["dateOfIssue"] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeVizResult["dateOfIssue"]))
        : null;
    dateOfExpiry = nativeVizResult["dateOfExpiry"] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeVizResult["dateOfExpiry"]))
        : null;
    dateOfEntry = nativeVizResult["dateOfEntry"] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeVizResult["dateOfEntry"]))
        : null;
    localityCode = createStringResult(nativeVizResult, "localityCode");
    maidenName = createStringResult(nativeVizResult, "maidenName");
    municipalityCode = createStringResult(nativeVizResult, "municipalityCode");
    municipalityOfRegistration = createStringResult(nativeVizResult, "municipalityOfRegistration");
    pollingStationCode = createStringResult(nativeVizResult, "pollingStationCode");
    registrationCenterCode = createStringResult(nativeVizResult, "registrationCenterCode");
    sectionCode = createStringResult(nativeVizResult, "sectionCode");
    stateCode = createStringResult(nativeVizResult, "stateCode");
    stateName = createStringResult(nativeVizResult, "stateName");
    dateOfExpiryPermanent = nativeVizResult["dateOfExpiryPermanent"];
    documentNumber = createStringResult(nativeVizResult, 'documentNumber');
    cardAccessNumber = createStringResult(nativeVizResult, "cardAccessNumber");
    personalIdNumber = createStringResult(nativeVizResult, 'personalIdNumber');
    documentAdditionalNumber = createStringResult(nativeVizResult, 'documentAdditionalNumber');
    documentOptionalAdditionalNumber = createStringResult(nativeVizResult, 'documentOptionalAdditionalNumber');
    additionalPersonalIdNumber = createStringResult(nativeVizResult, 'additionalPersonalIdNumber');
    issuingAuthority = createStringResult(nativeVizResult, 'issuingAuthority');
    visaType = createStringResult(nativeVizResult, 'visaType');
    driverLicenseDetailedInfo = nativeVizResult["driverLicenseDetailedInfo"] != null
        ? DriverLicenseDetailedInfo(Map<String, dynamic>.from(nativeVizResult["driverLicenseDetailedInfo"]))
        : null;

    documentSubtype = createStringResult(nativeVizResult, 'documentSubtype');
    remarks = createStringResult(nativeVizResult, 'remarks');
    residencePermitType = createStringResult(nativeVizResult, 'residencePermitType');
    manufacturingYear = createStringResult(nativeVizResult, 'manufacturingYear');
    vehicleType = createStringResult(nativeVizResult, 'vehicleType');
    eligibilityCategory = createStringResult(nativeVizResult, 'eligibilityCategory');
    specificDocumentValidity = createStringResult(nativeVizResult, 'specificDocumentValidity');
    dependentsInfo = nativeVizResult["dependentsInfo"] != null
        ? (nativeVizResult["dependentsInfo"] as List<dynamic>)
              .map((item) => DependentInfo(Map<String, dynamic>.from(item)))
              .toList()
        : null;
    vehicleOwner = createStringResult(nativeVizResult, 'vehicleOwner');
    countryCode = createStringResult(nativeVizResult, 'countryCode');
    certificateNumber = createStringResult(nativeVizResult, 'certificateNumber');
    nationalInsuranceNumber = createStringResult(nativeVizResult, 'nationalInsuranceNumber');
    effectiveDate = nativeVizResult["effectiveDate"] != null
        ? DateResult<StringResult>(Map<String, dynamic>.from(nativeVizResult["effectiveDate"]))
        : null;
    parentsInfo = nativeVizResult["parentsInfo"] != null
        ? (nativeVizResult["parentsInfo"] as List<dynamic>)
              .map((item) => ParentInfo(Map<String, dynamic>.from(item)))
              .toList()
        : null;
    husbandName = createStringResult(nativeVizResult, 'husbandName');
    legalStatus = createStringResult(nativeVizResult, 'legalStatus');
    socialSecurityStatus = createStringResult(nativeVizResult, 'socialSecurityStatus');
    workRestriction = createStringResult(nativeVizResult, 'workRestriction');
  }
}

/// Represents the result of the MRZ recognition.
class MrzResult {
  /// The entire Machine Readable Zone text from ID.
  String? rawMRZString;

  /// The document code. Document code contains two characters.
  /// For MRTD the first character shall be A, C or I.
  /// The second character shall be discretion of the issuing State or organization except
  /// that V shall not be used, and `C` shall not be used after `A` except in the crew member certificate.
  ///
  /// On machine-readable passports (MRP) first character shall be `P` to designate an MRP. One additional
  /// letter may be used, at the discretion of the issuing State or organization, to designate a particular
  ///  MRP.
  /// If the second character position is not used for this purpose, it shall be filled by the filter character.
  String? documentCode;

  /// three-letter or two-letter code which indicate the issuing State. Three-letter codes are based
  /// on Aplha-3 codes for entities specified in ISO 3166-1, with extensions for certain States. Two-letter
  /// codes are based on Aplha-2 codes for entities specified in ISO 3166-1, with extensions for certain States.
  String? issuer;

  /// The document number.
  String? documentNumber;

  /// The first optional data. Empty string if not available.
  String? opt1;

  /// The second optional data. Empty string if not available.
  String? opt2;

  /// The gender of the document holder.
  /// Gender is specified by use of the single initial.
  String? gender;

  ///  The nationality of the document holder represented by a three-letter or two-letter code.
  /// Three-letter codes are based on Alpha-3 codes for entities specified in ISO 3166-1, with extensions for certain
  /// States.
  /// Two-letter codes are based on Aplha-2 codes for entities specified in ISO 3166-1, with extensions for certain States.
  String? nationality;

  /// The primary indentifier. If there is more than one component, they are separated with space.
  String? primaryID;

  /// The secondary identifier. If there is more than one component, they are separated with space.
  String? secondaryID;

  /// The full issuer name that is expanded from the three-letter or two-letter code which indicate
  /// the issuing State.
  String? issuerName;

  /// The full nationality of the document holder, which is expanded from the three-letter or two-letter
  /// nationality code.
  String? nationalityName;

  /// Whether the MRZ is verified.
  /// If the MRZ is verified, it means that all check digits are correct.
  bool? verified;

  /// The date of birth of the document holder.
  DateResult<String>? dateOfBirth;

  /// The date of expiry of the document.
  DateResult<String>? dateOfExpiry;

  /// The type of the document.
  MRZDocumentType? documentType;

  /// The sanitized first optional data. Result without additional '<' characters if they exist.
  String? sanitizedOpt1;

  /// The sanitized second optional data. Result without additional '<' characters if they exist.
  String? sanitizedOpt2;

  /// The sanitized nationality. Result without additional '<' characters if they exist.
  String? sanitizedNationality;

  /// The sanitized issuer. Result without additional '<' characters if they exist.
  String? sanitizedIssuer;

  /// The sanitized document code. Result without additional '<' characters if they exist.
  String? sanitizedDocumentCode;

  /// The sanitized document number. Result without additional '<' characters if they exist.
  String? sanitizedDocumentNumber;

  /// Represents the result of the MRZ recognition.
  MrzResult(Map<String, dynamic> nativeMRZResult) {
    documentType = enumFromValue(MRZDocumentType.values, nativeMRZResult["documentType"]);
    primaryID = nativeMRZResult['primaryID'];
    secondaryID = nativeMRZResult['secondaryID'];
    issuer = nativeMRZResult['issuer'];
    dateOfBirth = nativeMRZResult['dateOfBirth'] != null
        ? DateResult(Map<String, dynamic>.from(nativeMRZResult['dateOfBirth']))
        : null;
    documentNumber = nativeMRZResult['documentNumber'];
    nationality = nativeMRZResult['nationality'];
    gender = nativeMRZResult['gender'];
    documentCode = nativeMRZResult['documentCode'];
    dateOfExpiry = nativeMRZResult['dateOfExpiry'] != null
        ? DateResult(Map<String, dynamic>.from(nativeMRZResult['dateOfExpiry']))
        : null;
    opt1 = nativeMRZResult['opt1'];
    opt2 = nativeMRZResult['opt2'];
    rawMRZString = nativeMRZResult['rawMRZString'];
    verified = nativeMRZResult['mrzVerified'];
    sanitizedOpt1 = nativeMRZResult['sanitizedOpt1'];
    sanitizedOpt2 = nativeMRZResult['sanitizedOpt2'];
    sanitizedNationality = nativeMRZResult['sanitizedNationality'];
    sanitizedIssuer = nativeMRZResult['sanitizedIssuer'];
    sanitizedDocumentCode = nativeMRZResult['sanitizedDocumentCode'];
    sanitizedDocumentNumber = nativeMRZResult['sanitizedDocumentNumber'];
  }
}

///  Represents the data extracted from the barcode.
class BarcodeResult {
  /// The raw, unparsed barcode data.
  BarcodeData? barcodeData;

  /// The first name of the document owner.
  String? firstName;

  /// The middle name of the document owner.
  String? middleName;

  /// The last name of the document owner.
  String? lastName;

  /// The full name of the document owner.
  String? fullName;

  /// The additional name information of the document owner.
  String? additionalNameInformation;

  /// The address of the document owner.
  String? address;

  /// The place of birth of the document owner.
  String? placeOfBirth;

  /// The nationality of the document owner.
  String? nationality;

  /// The race of the document owner.
  String? race;

  /// The religion of the document owner.
  String? religion;

  /// The profession of the document owner.
  String? profession;

  /// The marital status of the document owner.
  String? maritalStatus;

  /// The residential status of the document owner.
  String? residentialStatus;

  /// The employer of the document owner.
  String? employer;

  /// The sex of the document owner.
  String? sex;

  /// The date of birth of the document owner.
  DateResult<String>? dateOfBirth;

  /// The date of issue of the document.
  DateResult<String>? dateOfIssue;

  /// The date of expiry of the document.
  DateResult<String>? dateOfExpiry;

  /// The document number.
  String? documentNumber;

  /// The personal identification number.
  String? personalIdNumber;

  /// The additional number of the document.
  String? documentAdditionalNumber;

  /// The issuing authority of the document.
  String? issuingAuthority;

  /// The details about the address of the document owner.
  AddressDetailedInfo? addressDetailedInfo;

  /// The driver license detailed info.
  DriverLicenseDetailedInfo<String>? driverLicenseDetailedInfo;

  /// Document specific extended elements that contain all barcode fields in their original form.
  ///
  /// Currently this is only filled for AAMVACompliant documents.
  BarcodeExtendedElements? extendedElements;

  /// Indicates whether the barcode was successfully parsed.
  bool? parsed;

  ///  Represents the data extracted from the barcode.
  BarcodeResult(Map<String, dynamic> nativeBarcodeResult) {
    barcodeData = nativeBarcodeResult['barcodeData'] != null
        ? BarcodeData(Map<String, dynamic>.from(nativeBarcodeResult['barcodeData']))
        : null;
    firstName = nativeBarcodeResult['firstName'];
    middleName = nativeBarcodeResult['middleName'];
    lastName = nativeBarcodeResult['lastName'];
    fullName = nativeBarcodeResult['fullName'];
    additionalNameInformation = nativeBarcodeResult['additionalNameInformation'];
    address = nativeBarcodeResult['address'];
    placeOfBirth = nativeBarcodeResult['placeOfBirth'];
    nationality = nativeBarcodeResult['nationality'];
    race = nativeBarcodeResult['race'];
    religion = nativeBarcodeResult['religion'];
    profession = nativeBarcodeResult['profession'];
    maritalStatus = nativeBarcodeResult['maritalStatus'];
    residentialStatus = nativeBarcodeResult['residentialStatus'];
    employer = nativeBarcodeResult['employer'];
    sex = nativeBarcodeResult['sex'];
    dateOfBirth = nativeBarcodeResult['dateOfBirth'] != null
        ? DateResult<String>(Map<String, dynamic>.from(nativeBarcodeResult['dateOfBirth']))
        : null;
    dateOfBirth = nativeBarcodeResult['dateOfIssue'] != null
        ? DateResult<String>(Map<String, dynamic>.from(nativeBarcodeResult['dateOfIssue']))
        : null;
    dateOfBirth = nativeBarcodeResult['dateOfExpiry'] != null
        ? DateResult<String>(Map<String, dynamic>.from(nativeBarcodeResult['dateOfExpiry']))
        : null;
    documentNumber = nativeBarcodeResult['documentNumber'];
    personalIdNumber = nativeBarcodeResult['personalIdNumber'];
    documentAdditionalNumber = nativeBarcodeResult['documentAdditionalNumber'];
    issuingAuthority = nativeBarcodeResult['issuingAuthority'];
    addressDetailedInfo = nativeBarcodeResult['addressDetailedInfo'] != null
        ? AddressDetailedInfo(Map<String, dynamic>.from(nativeBarcodeResult['addressDetailedInfo']))
        : null;
    driverLicenseDetailedInfo = nativeBarcodeResult['driverLicenseDetailedInfo'] != null
        ? DriverLicenseDetailedInfo<String>(Map<String, dynamic>.from(nativeBarcodeResult['driverLicenseDetailedInfo']))
        : null;
    extendedElements = nativeBarcodeResult['extendedElements'] != null
        ? BarcodeExtendedElements(Map<String, dynamic>.from(nativeBarcodeResult['extendedElements']))
        : null;
    parsed = nativeBarcodeResult['parsed'];
  }
}

/// Represents the raw, unparsed data extracted from a scanned barcode.
class BarcodeData {
  /// Type of the scanned barcode.
  BarcodeType? barcodeType;

  /// Raw bytes of the barcode content.
  String? rawData;

  /// String representation of the barcode content.
  String? stringData;

  /// Whether the barcode data is uncertain, i.e. if scanned barcode was incomplete or has parts of it missing.
  bool? uncertain;

  /// Represents the raw, unparsed data extracted from a scanned barcode.
  BarcodeData(Map<String, dynamic> nativeBarcodeData) {
    barcodeType = enumFromValue(BarcodeType.values, nativeBarcodeData["barcodeType"]);
    rawData = nativeBarcodeData["rawData"];
    stringData = nativeBarcodeData["stringData"];
    uncertain = nativeBarcodeData["uncertain"];
  }
}

/// Represents the type of scanned barcode
enum BarcodeType {
  /// No barcode was scanned
  none,

  /// QR code was scanned
  qrCode,

  /// Data Matrix 2D barcode was scanned
  dataMatrix,

  /// UPC E barcode was scanned
  upce,

  /// UPC A barcode was scanned
  upca,

  /// EAN 8 barcode was scanned
  ean8,

  /// EAN 13 barcode was scanned
  ean13,

  /// Code 128 barcode was scanned
  code128,

  /// Code 39 barcode was scanned
  code39,

  /// ITF barcode was scanned
  itf,

  /// Aztec 2D barcode was scanned
  aztec,

  /// PDF417 2D barcode was scanned
  pdf417,
}

/// Detailed information about the address.
class AddressDetailedInfo {
  /// The address street portion of the document owner.
  String? street;

  /// The address postal code portion of the document owner.
  String? postalCode;

  /// The address city portion of the document owner.
  String? city;

  /// The address jurisdiction code portion of the document owner.
  String? jurisdiction;

  /// Detailed information about the address.
  AddressDetailedInfo(Map<String, dynamic> nativeAddressDetailedInfo) {
    street = nativeAddressDetailedInfo["street"];
    postalCode = nativeAddressDetailedInfo["postalCode"];
    city = nativeAddressDetailedInfo["city"];
    jurisdiction = nativeAddressDetailedInfo["jurisdiction"];
  }
}

/// Represents the fields present in the barcode.
/// Currently this is only used for AAMVACompliant documents.
class BarcodeExtendedElements {
  /// Mandatory on all AAMVA and Magnetic barcodes.
  /// On compact barcodes, use kFullAddress.
  ///
  /// City portion of the cardholder address.
  String? addressCity;

  /// Mandatory on all AAMVA and Magnetic barcodes.
  /// On compact barcodes, use kFullAddress.
  ///
  /// State portion of the cardholder address.
  String? addressJurisdictionCode;

  /// Mandatory on all AAMVA and Magnetic barcodes.
  /// On compact barcodes, use kFullAddress.
  ///
  /// Postal code portion of the cardholder address in the U.S. and Canada.
  /// If the trailing portion of the postal code in the U.S. is not known, zeros can be used
  /// to fill the trailing set of numbers up to nine (9) digits.
  String? addressPostalCode;

  /// Mandatory on all AAMVA and Magnetic barcodes.
  /// On compact barcodes, use kFullAddress.
  ///
  /// Street portion of the cardholder address.
  /// The place where the registered driver of a vehicle (individual or corporation)
  /// may be contacted such as a house number, street address, etc.
  String? addressStreet;

  /// Optional on all AAMVA barcodes.
  /// On Compact barcodes, use kFullAddress.
  ///
  /// Second line of street portion of the cardholder address.
  String? addressStreet2;

  /// Optional on AAMVA 01. (MMDDCCYY format)
  ///
  /// ALTERNATIVE DATES(S) given as date of birth.
  String? akaDateOfBirth;

  /// Optional on all AAMVA and Compact barcodes.
  /// Other family name by which the cardholder is known.
  String? akaFamilyName;

  /// Optional on all AAMVA and Compact barcodes.
  ///
  /// Other name by which the cardholder is known. ALTERNATIVE NAME(S) of the individual
  /// holding the Driver License or ID.
  ///
  /// The Name field contains up to four portions, separated with the "," delimiter:
  /// AKA Last Name (required)
  /// , (required)
  /// AKA First Name (required)
  /// , (required if other name portions follow, otherwise optional)
  /// AKA Middle Name(s) (optional)
  /// , (required if other name portions follow, otherwise optional)
  /// AKA Suffix (optional)
  /// , (optional)
  ///
  /// If the individual has more than one AKA middle name they are separated with space.
  String? akaFullName;

  /// Optional on all AAMVA and Compact barcodes.
  ///
  /// Other given name by which the cardholder is known
  String? akaGivenName;

  /// Optional on AAMVA 01 barcodes.
  ///
  /// ALTERNATIVE MIDDLE NAME(s) or INITIALS of the individual holding the Driver License or ID.
  /// Hyphenated names acceptable, spaces between names acceptable, but no other
  /// use of special symbols.
  String? akaMiddleName;

  /// Optional on AAMVA 01 barcodes.
  ///
  /// ALTERNATIVE PREFIX to Driver Name. Freeform as defined by issuing jurisdiction.
  String? akaPrefixName;

  /// Optional on AAMVA version 01.
  ///
  /// Driver "AKA" Social Security Number. FORMAT SAME AS DRIVER SOC SEC NUM. ALTERNATIVE NUMBERS(S) used as SS NUM.
  String? akaSocialSecurityNumber;

  ///  Optional on all AAMVA and Compact barcodes.
  ///
  /// Other suffix by which the cardholder is known.

  /// The Suffix Code Portion, if submitted, can contain only the Suffix Codes
  /// shown in the following table (e.g., Andrew Johnson, III = JOHNSON@ANDREW@@3RD):
  ///
  /// Suffix     Meaning or Synonym
  /// JR         Junior
  /// SR         Senior or Esquire 1ST First
  /// 2ND        Second
  /// 3RD        Third
  /// 4TH        Fourth
  /// 5TH        Fifth
  /// 6TH        Sixth
  /// 7TH        Seventh
  /// 8TH        Eighth
  /// 9TH        Ninth
  String? akaSuffixName;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// A string of letters and/or numbers that identifies when, where, and by whom a driver's
  /// license/ID card was made. If audit information is not used on the card or the MRT, it
  /// must be included in the driver record.
  String? auditInformation;

  /// Optional on AAMVA 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// DHS required field that indicates date of the most recent version change or
  ///  modification to the visible format of the DL/ID. (MMDDCCYY format)
  String? cardRevisionDate;

  /// Optional on AAMVA 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// DHS required field that indicates compliance: "M" = materially compliant,
  /// "F" = fully compliant, and, "N" = non-compliant.
  String? complianceType;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Country in which DL/ID is issued. U.S. = USA, Canada = CAN.
  String? countryIdentification;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// Family name of the cardholder. (Family name is sometimes also called "last name" or "surname.")
  /// Collect full name for record, print as many characters as possible on portrait side of DL/ID.
  String? customerFamilyName;

  /// Mandatory on all AAMVA and Compact barcodes.
  ///
  /// The number assigned or calculated by the issuing authority.
  String? customerIdNumber;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// First name of the cardholder.
  String? customerFirstName;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// Full name of the individual holding the Driver's License or ID.
  ///
  /// The Name field contains up to four portions, separated with the "," delimiter:
  /// Last Name (required)
  /// , (required)
  /// First Name (required)
  /// , (required if other name portions follow, otherwise optional)
  /// Middle Name(s) (optional)
  /// , (required if other name portions follow, otherwise optional)
  /// Suffix (optional)
  /// , (optional)
  ///
  /// If the individual has more than one middle name they are separated with space.
  String? customerFullName;

  /// Mandatory on AAMVA 04, 05, 06, 07, 08 barcodes.
  /// Optional on AAMVA 01, 02, 03, Magnetic and Compcat barcodes.
  ///
  /// Middle name(s) of the cardholder. In the case of multiple middle names they
  /// shall be separated by space " ".
  String? customerMiddleName;

  /// Optional on compact barcodes.
  ///
  /// Document discriminator.
  String? dataDiscriminator;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// Date on which the cardholder was born. (MMDDCCYY format)
  String? dateOfBirth;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 and Magnetic barcodes.
  /// Optional on Compact barcodes.
  ///
  /// Number must uniquely identify a particular document issued to that customer
  /// from others that may have been issued in the past. This number may serve
  /// multiple purposes of document discrimination, audit info, and/or inventory control.
  String? documentDiscriminator;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// Date on which the document expires. (MMDDCCYY format)
  /// If the document is non expiring then "Non expiring" is written in this field.
  String? documentExpirationDate;

  /// Optional on Magnetic barcodes.
  ///
  /// Month on which the driving and identification privileges granted by the document are no longer valid.
  String? documentExpirationMonth;

  /// Mandatory on all AAMVA and Compact barcodes.
  ///
  /// Date on which the document was issued. (MMDDCCYY format)
  String? documentIssueDate;

  /// Optional on Magnetic barcodes.
  ///
  /// Field that indicates that the driving and identification privileges granted by the
  /// document are nonexpiring = "1".
  String? documentNonexpiring;

  /// Mandatory on all driver's licenses.
  /// All barcodes which are using 3-track magnetic stripe encoding used in the interest of smoothing a transition from legacy documents
  /// shall be designated as "Magnetic". All barcodes which are using compact encoding
  /// compliant with ISO/IEC 18013-2 shall be designated as "Compact". All barcodes (majority)
  /// compliant with Mandatory PDF417 Bar Code of the American Association of Motor Vehicle
  /// Administrators (AAMVA) Card Design Standard from AAMVA DL/ID-2000 standard to DL/ID-2013
  /// shall be designated as "AAMVA".
  String? documentType;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 barcodes.
  /// Optional on AAMVA 01, Magnetic and Compact barcodes.
  ///
  /// Color of cardholder's eyes. (ANSI D-20 codes)
  /// Code   Description
  /// BLK    Black
  /// BLU    Blue
  /// BRO    Brown
  /// GRY    Gray
  /// GRN    Green
  /// HAZ    Hazel
  /// MAR    Maroon
  /// PNK    Pink
  /// DIC    Dichromatic
  /// UNK    Unknown
  String? eyeColor;

  /// Mandatory on AAMVA 04, 05, 06, 07, 08 barcodes.
  /// Optional on Compact barcodes.
  /// A code that indicates whether a field has been truncated (T), has not been
  /// truncated (N), or – unknown whether truncated (U).
  String? familyNameTruncation;

  /// Mandatory on AAMVA versions 02 and 03.
  ///
  /// Federally established codes for vehicle categories, endorsements, and restrictions
  /// that are generally applicable to commercial motor vehicles. If the vehicle is not a
  /// commercial vehicle, "NONE" is to be entered.
  String? federalCommercialVehicleCodes;

  /// Mandatory on AAMVA 04, 05, 06, 07, 08 barcodes.
  /// Optional on Compact barcodes.
  ///
  /// A code that indicates whether a field has been truncated (T), has not been
  /// truncated (N), or – unknown whether truncated (U).
  String? firstNameTruncation;

  /// Mandatory on all AAMVA and Magnetic barcodes.
  /// Optional on Compact barcodes.
  ///
  /// Full address of the individual holding the Driver's License or ID.
  ///
  /// The full address field contains up to four portions, separated with the "," delimiter:
  /// Street Address (required)
  /// , (required if other address portions follow, otherwise optional)
  /// City (optional)
  /// , (required if other address portions follow, otherwise optional)
  /// Jurisdiction Code (optional)
  /// , (required if other address portions follow, otherwise optional)
  /// ZIP - Postal Code (optional)
  String? fullAddress;

  /// Optional on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// Bald, black, blonde, brown, gray, red/auburn, sandy, white, unknown. If the issuing
  /// jurisdiction wishes to abbreviate colors, the three-character codes provided in ANSI D20 must be
  /// used.
  ///
  /// Code   Description
  /// BAL    Bald
  /// BLK    Black
  /// BLN    Blond
  /// BRO    Brown
  /// GRY    Grey
  /// RED    Red/Auburn
  /// SDY    Sandy
  /// WHI    White
  /// UNK    Unknown
  String? hairColor;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  /// Optional on AAMVA 01 and Magnetic barcodes.
  ///
  /// Height of cardholder, either in Inches or in Centimeters.
  ///
  /// Inches (in): number of inches followed by " in"
  /// example: 6'1'' = "73 in"
  ///
  /// Centimeters (cm): number of centimeters followed by " cm"
  /// example: 181 centimeters = "181 cm"
  String? height;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  /// Optional on AAMVA 01 and Magnetic barcodes.
  ///
  /// Height of cardholder in Inches.
  /// Example: 5'9'' = "69".
  String? heightIn;

  /// Mandatory on AAMVA 02, 03, 04, 05, 06, 07, 08 Compact barcodes.
  /// Optional on AAMVA 01 and Magnetic barcodes.
  ///
  /// Height of cardholder in Centimeters.
  /// Example: 180 Centimeters = "180".
  String? heightCm;

  /// Mandatory on all AAMVA, Magnetic and Compact barcodes.
  ///
  /// This number uniquely identifies the issuing jurisdiction and can
  /// be obtained by contacting the ISO Issuing Authority (AAMVA)
  String? issuerIdentificationNumber;

  /// Optional on all AAMVA barcodes.
  /// Mandatory on Compact barcodes.
  ///
  /// Jurisdictions may define a subfile to contain jurisdiction-specific information.
  /// These subfiles are designated with the first character of “Z” and the second
  /// character is the first letter of the jurisdiction's name. For example, "ZC" would
  /// be the designator for a California or Colorado jurisdiction-defined subfile, "ZQ"
  /// would be the designator for a Quebec jurisdiction-defined subfile. In the case of
  /// a jurisdiction-defined subfile that has a first letter that could be more than
  /// one jurisdiction (e.g. California, Colorado, Connecticut) then other data, like
  /// the IIN or address, must be examined to determine the jurisdiction.
  ///
  String? issuingJurisdiction;

  /// Optional on all AAMVA and Magnetic barcodes.
  ///
  /// Name of issuing jurisdiction, for example: Alabama, Alaska ...
  String? issuingJurisdictionName;

  /// Mandatory on all AAMVA barcodes.
  /// Optional on Magnetic barcodes.
  ///
  /// Jurisdiction-specific codes that represent additional privileges
  /// granted to the cardholder beyond the vehicle class (such as transportation of
  /// passengers, hazardous materials, operation of motorcycles, etc.).
  String? jurisdictionEndorsementCodes;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Text that explains the jurisdiction-specific code(s) that indicates additional
  /// driving privileges granted to the cardholder beyond the vehicle class.
  String? jurisdictionEndorsmentCodeDescription;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Text describing the jurisdiction-specific restriction code(s) that curtail driving privileges.
  String? jurisdictionRestrictionCodeDescription;

  /// Mandatory on all AAMVA barcodes.
  /// Optional on Magnetic barcodes.
  ///
  /// Jurisdiction-specific codes that represent additional privileges
  /// granted to the cardholder beyond the vehicle class (such as transportation of
  /// passengers, hazardous materials, operation of motorcycles, etc.).
  String? jurisdictionRestrictionCodes;

  /// Mandatory on all AAMVA and Magnetic barcodes.
  ///
  /// Jurisdiction-specific vehicle class / group code, designating the type
  /// of vehicle the cardholder has privilege to drive.
  String? jurisdictionVehicleClass;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Text that explains the jurisdiction-specific code(s) for classifications
  /// of vehicles cardholder is authorized to drive.
  String? jurisdictionVehicleClassificationDescription;

  /// Mandatory on all AAMVA and Compact barcodes.
  /// Optional on Magnetic barcodes.
  ///
  /// Jurisdiction Version Number: This is a decimal value between 0 and 99 that
  /// specifies the jurisdiction version level of the PDF417 barcode format.
  /// Notwithstanding iterations of this standard, jurisdictions implement incremental
  /// changes to their barcodes, including new jurisdiction-specific data, compression
  /// algorithms for digitized images, digital signatures, or new truncation
  /// conventions used for names and addresses. Each change to the barcode format
  /// within each AAMVA version (above) must be noted, beginning with Jurisdiction
  /// Version 00.
  String? jurisdictionVersionNumber;

  /// Optional on AAMVA 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// DHS required field that indicates that the cardholder has temporary lawful status = "1".
  String? limitedDurationDocument;

  /// Optional on AAMVA version 01.
  ///
  /// Medical Indicator/Codes.
  /// STATE SPECIFIC. Freeform, Standard "TBD"
  String? medicalIndicator;

  /// Mandatory on AAMVA 04, 05, 06, 07, 08 barcodes.
  ///
  /// A code that indicates whether a field has been truncated (T), has not been
  /// truncated (N), or – unknown whether truncated (U).
  String? middleNameTruncation;

  /// Optional on AAMVA 01 barcodes.
  ///
  /// PREFIX to Driver Name. Freeform as defined by issuing jurisdiction.
  String? namePrefix;

  /// Mandatory on AAMVA 02 barcodes.
  /// Optional on AAMVA 01, 03, 04, 05, 06, 07, 08, Magnetic and Compact barcodes.
  ///
  /// Name Suffix (If jurisdiction participates in systems requiring name suffix (PDPS, CDLIS, etc.),
  /// the suffix must be collected and displayed on the DL/ID and in the MRT).
  /// - JR (Junior)
  /// - SR (Senior)
  /// - 1ST or I (First)
  /// - 2ND or II (Second)
  /// - 3RD or III (Third)
  /// - 4TH or IV (Fourth)
  /// - 5TH or V (Fifth)
  /// - 6TH or VI (Sixth)
  /// - 7TH or VII (Seventh)
  /// - 8TH or VIII (Eighth)
  /// - 9TH or IX (Ninth)
  String? nameSuffix;

  /// Optional on AAMVA version 01.
  ///
  /// Non-Resident Indicator. "Y". Used by some jurisdictions to indicate holder of the document is a non-resident.
  String? nonResident;

  /// Optional on AAMVA version 01.
  ///
  /// Number of duplicate cards issued for a license or ID if any.
  String? numberOfDuplicates;

  /// Optional on AAMVA 01, 06, 07, 08 barcodes.
  ///
  /// Field that indicates that the cardholder is an organ donor = "1".
  String? organDonor;

  /// Optional on AAMVA version 01 barcodes.
  ///
  /// Driver Permit Expiration Date. MMDDCCYY format. Date permit expires.
  String? permitExpirationDate;

  /// Optional on AAMVA version 01 barcodes..
  ///
  /// Type of permit.
  String? permitIdentifier;

  /// Optional on AAMVA version 01 barcodes..
  ///
  /// Driver Permit Issue Date. MMDDCCYY format. Date permit was issued.
  String? permitIssueDate;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Country and municipality and/or state/province.
  String? placeOfBirth;

  /// Optional on AAMVA 02, 03, 04, 05, 06, 07, 08 and Compact barcodes.
  ///
  /// Codes for race or ethnicity of the cardholder, as defined in ANSI D20.
  ///
  /// Race:
  /// Code   Description
  /// AI     Alaskan or American Indian (Having Origins in Any of The Original Peoples of
  /// North America, and Maintaining Cultural Identification Through Tribal
  /// Affiliation of Community Recognition)
  /// AP     Asian or Pacific Islander (Having Origins in Any of the Original Peoples of
  /// the Far East, Southeast Asia, or Pacific Islands. This Includes China, India,
  /// Japan, Korea, the Philippines Islands, and Samoa)
  /// BK     Black (Having Origins in Any of the Black Racial Groups of Africa)
  /// W      White (Having Origins in Any of The Original Peoples of Europe, North Africa,
  /// or the Middle East)
  ///
  /// Ethnicity:
  /// Code   Description
  /// H      Hispanic Origin (A Person of Mexican, Puerto Rican, Cuban, Central or South
  /// American or Other Spanish Culture or Origin, Regardless of Race)
  /// O      Not of Hispanic Origin (Any Person Other Than Hispanic)
  /// U      Unknown
  String? raceEthnicity;

  /// Optional on AAMVA version 01.
  ///
  /// Driver Residence City
  String? residenceCity;

  /// Optional on AAMVA 01 barcodes.
  ///
  /// Full residence address of the individual holding the Driver's License or ID.
  /// The full address field contains up to four portions, separated with the "," delimiter:
  /// Residence Street Address (required)
  /// , (required if other address portions follow, otherwise optional)
  /// Residence City (optional)
  /// , (required if other address portions follow, otherwise optional)
  /// Residence Jurisdiction Code (optional)
  /// , (required if other address portions follow, otherwise optional)
  /// Residence ZIP - Residence Postal Code (optional)
  String? residenceFullAddress;

  /// Optional on AAMVA version 01.
  ///
  /// Driver Residence Jurisdiction Code.
  String? residenceJurisdictionCode;

  /// Optional on AAMVA 01 barcodes.
  ///
  /// Driver Residence Postal Code.
  String? residencePostalCode;

  /// Optional on AAMVA version 01.
  ///
  /// Driver Residence Street Address 1.
  String? residenceStreetAddress;

  /// Optional on AAMVA version 01.
  ///
  /// Driver Residence Street Address 2.
  String? residenceStreetAddress2;

  /// Optional on Magnetic barcodes.
  ///
  /// Security version being used.
  String? securityVersion;

  /// Mandatory on all AAMVA, Magnetic barcodes.
  /// Optional on Compact barcodes.
  ///
  /// Gender of the cardholder. 1 = male, 2 = female.
  String? sex;

  /// Optional on AAMVA version 01.
  ///
  /// The number assigned to the individual by the Social Security Administration.
  String? socialSecurityNumber;

  /// Optional on all AAMVA barcodes.
  ///
  /// Standard endorsement code(s) for cardholder. See codes in D20. This data element is a
  /// placeholder for future efforts to standardize endorsement codes.
  ///
  /// Code   Description
  /// H      Hazardous Material - This endorsement is required for the operation of any vehicle
  /// transporting hazardous materials requiring placarding, as defined by U.S.
  /// Department of Transportation regulations.
  /// L      Motorcycles – Including Mopeds/Motorized Bicycles.
  ///
  /// N      Tank - This endorsement is required for the operation of any vehicle transporting,
  /// as its primary cargo, any liquid or gaseous material within a tank attached to the vehicle.
  ///
  /// O      Other Jurisdiction Specific Endorsement(s) - This code indicates one or more
  /// additional jurisdiction assigned endorsements.
  ///
  /// P      Passenger - This endorsement is required for the operation of any vehicle used for
  /// transportation of sixteen or more occupants, including the driver.
  ///
  /// S      School Bus - This endorsement is required for the operation of a school bus. School bus means a
  /// CMV used to transport pre-primary, primary, or secondary school students from home to school,
  /// from school to home, or to and from school sponsored events. School bus does not include a
  /// bus used as common carrier (49 CRF 383.5).
  ///
  /// T      Doubles/Triples - This endorsement is required for the operation of any vehicle that would be
  /// referred to as a double or triple.
  ///
  /// X      Combined Tank/HAZ-MAT - This endorsement may be issued to any driver who qualifies for
  /// both the N and H endorsements.
  String? standardEndorsementCode;

  /// Optional on all AAMVA barcodes.
  ///
  /// Standard restriction code(s) for cardholder. See codes in D20. This data element is a placeholder
  /// for future efforts to standardize restriction codes.
  ///
  /// Code   Description
  /// B      Corrective Lenses
  /// C      Mechanical Devices (Special Brakes, Hand Controls, or Other Adaptive Devices)
  /// D      Prosthetic Aid
  /// E      Automatic Transmission
  /// F      Outside Mirror
  /// G      Limit to Daylight Only
  /// H      Limit to Employment
  /// I      Limited Other
  /// J      Other
  /// K      CDL Intrastate Only
  /// L      Vehicles without air brakes
  /// M      Except Class A bus
  /// N      Except Class A and Class B bus
  /// O      Except Tractor-Trailer
  /// V      Medical Variance Documentation Required
  /// W      Farm Waiver
  String? standardRestrictionCode;

  /// Optional on all AAMVA barcodes.
  /// Mandatory on Compact barcodes.
  ///
  /// Standard vehicle classification code(s) for cardholder. This data element is a
  /// placeholder for future efforts to standardize vehicle classifications.
  String? standardVehicleClassification;

  /// Mandatory on all driver's licenses.
  ///
  /// AAMVA Version Number: This is a decimal value between 0 and 99 that
  /// specifies the version level of the PDF417 bar code format. Version "0" and "00"
  /// is reserved for bar codes printed to the specification of the American Association
  /// of Motor Vehicle Administrators (AAMVA) prior to the adoption of the AAMVA DL/ID-2000
  /// standard.
  ///
  /// - All barcodes compliant with AAMVA DL/ID-2000 standard shall be designated Version "01."
  /// - All barcodes compliant with AAMVA Card Design Specification version 1.0, dated 09-2003
  /// shall be designated Version "02."
  /// - All barcodes compliant with AAMVA Card Design Specification version 2.0, dated 03-2005
  /// shall be designated Version "03."
  /// - All barcodes compliant with AAMVA Card Design Standard version 1.0, dated 07-2009
  /// shall be designated Version "04."
  /// - All barcodes compliant with AAMVA Card Design Standard version 1.0, dated 07-2010
  /// shall be designated Version "05."
  /// - All barcodes compliant with AAMVA Card Design Standard version 1.0, dated 07-2011
  /// shall be designated Version "06".
  /// - All barcodes compliant with AAMVA Card Design Standard version 1.0, dated 06-2012
  /// shall be designated Version "07".
  /// - All barcodes compliant with this current AAMVA standard shall be designated "08".
  ///
  /// Should a need arise requiring major revision to the format, this field provides the
  /// means to accommodate additional revision.
  ///
  /// If the document type is not "AAMVA", this field defines the version number of the
  /// given document type's standard.
  String? standardVersionNumber;

  /// Optional on AAMVA 05, 06, 07, 08 barcodes.
  /// Date on which the cardholder turns 18 years old. (MMDDCCYY format)
  String? under18;

  /// Optional on AAMVA 05, 06, 07, 08 barcodes.
  ///
  /// Date on which the cardholder turns 19 years old. (MMDDCCYY format)
  String? under19;

  /// Optional on AAMVA 05, 06, 07, 08 barcodes.
  ///
  /// Date on which the cardholder turns 21 years old. (MMDDCCYY format)
  String? under21;

  /// Optional on AAMVA version 01.
  ///
  ///  A number or alphanumeric string used by some jurisdictions to identify a "customer" across multiple data bases.
  String? uniqueCustomerId;

  /// Optional on AAMVA 07, 08 barcodes.
  ///
  /// Field that indicates that the cardholder is a veteran = "1"
  String? veteran;

  /// Mandatory on AAMVA 02 barcodes.
  /// Optional on AAMVA 01, 03, 04, 05, 06, 07, 08, Magnetic and Compact barcodes.
  ///
  /// Cardholder weight in kilograms Example: 84 kg = "084"
  String? weightKilograms;

  /// Mandatory on AAMVA 02 barcodes.
  /// Optional on AAMVA 01, 03, 04, 05, 06, 07, 08, Magnetic and Compact barcodes.
  ///
  /// Cardholder weight in pounds Example: 185 lb = "185"
  String? weightPounds;

  /// Mandatory on AAMVA 02 barcodes.
  /// Optional on AAMVA 01, 03, 04, 05, 06, 07, 08, Magnetic and Compact barcodes.
  ///
  /// Indicates the approximate weight range of the cardholder:
  /// 0 = up to 31 kg (up to 70 lbs)
  /// 1 = 32 – 45 kg (71 – 100 lbs)
  /// 2 = 46 - 59 kg (101 – 130 lbs)
  /// 3 = 60 - 70 kg (131 – 160 lbs)
  /// 4 = 71 - 86 kg (161 – 190 lbs)
  /// 5 = 87 - 100 kg (191 – 220 lbs)
  /// 6 = 101 - 113 kg (221 – 250 lbs)
  /// 7 = 114 - 127 kg (251 – 280 lbs)
  /// 8 = 128 – 145 kg (281 – 320 lbs)
  /// 9 = 146+ kg (321+ lbs)
  String? weightRange;

  /// SubField Designator extracted from barcode, to support proper document classification based on the standard.
  ///
  /// Subfield designator is a 2-character code that specifies the type of document, typically DL or ID.
  /// It is located immediately after the IIN and the variable metadata structure in the PDF417 barcode data structure.
  ///
  /// For example: ANSI 636010090002DL00410267ZF03080067DLDAQS1234567812300000000000000 ^^ |           | |           +-- SubField Designator (DL, ID, EN, etc.) +----- IIN (636010)
  String? subFieldDesignator;

  /// Represents the fields present in the barcode.
  /// Currently this is only used for AAMVACompliant documents.
  BarcodeExtendedElements(Map<String, dynamic> nativeBarcodeExtendedElements)
    : addressCity = nativeBarcodeExtendedElements['addressCity'],
      addressJurisdictionCode = nativeBarcodeExtendedElements['addressJurisdictionCode'],
      addressPostalCode = nativeBarcodeExtendedElements['addressPostalCode'],
      addressStreet = nativeBarcodeExtendedElements['addressStreet'],
      addressStreet2 = nativeBarcodeExtendedElements['addressStreet2'],
      akaDateOfBirth = nativeBarcodeExtendedElements['akaDateOfBirth'],
      akaFamilyName = nativeBarcodeExtendedElements['akaFamilyName'],
      akaFullName = nativeBarcodeExtendedElements['akaFullName'],
      akaGivenName = nativeBarcodeExtendedElements['akaGivenName'],
      akaMiddleName = nativeBarcodeExtendedElements['akaMiddleName'],
      akaPrefixName = nativeBarcodeExtendedElements['akaPrefixName'],
      akaSocialSecurityNumber = nativeBarcodeExtendedElements['akaSocialSecurityNumber'],
      akaSuffixName = nativeBarcodeExtendedElements['akaSuffixName'],
      auditInformation = nativeBarcodeExtendedElements['auditInformation'],
      cardRevisionDate = nativeBarcodeExtendedElements['cardRevisionDate'],
      complianceType = nativeBarcodeExtendedElements['complianceType'],
      countryIdentification = nativeBarcodeExtendedElements['countryIdentification'],
      customerFamilyName = nativeBarcodeExtendedElements['customerFamilyName'],
      customerIdNumber = nativeBarcodeExtendedElements['customerIdNumber'],
      customerFirstName = nativeBarcodeExtendedElements['customerFirstName'],
      customerFullName = nativeBarcodeExtendedElements['customerFullName'],
      customerMiddleName = nativeBarcodeExtendedElements['customerMiddleName'],
      dataDiscriminator = nativeBarcodeExtendedElements['dataDiscriminator'],
      dateOfBirth = nativeBarcodeExtendedElements['dateOfBirth'],
      documentDiscriminator = nativeBarcodeExtendedElements['documentDiscriminator'],
      documentExpirationDate = nativeBarcodeExtendedElements['documentExpirationDate'],
      documentExpirationMonth = nativeBarcodeExtendedElements['documentExpirationMonth'],
      documentIssueDate = nativeBarcodeExtendedElements['documentIssueDate'],
      documentNonexpiring = nativeBarcodeExtendedElements['documentNonexpiring'],
      documentType = nativeBarcodeExtendedElements['documentType'],
      eyeColor = nativeBarcodeExtendedElements['eyeColor'],
      familyNameTruncation = nativeBarcodeExtendedElements['familyNameTruncation'],
      federalCommercialVehicleCodes = nativeBarcodeExtendedElements['federalCommercialVehicleCodes'],
      firstNameTruncation = nativeBarcodeExtendedElements['firstNameTruncation'],
      fullAddress = nativeBarcodeExtendedElements['fullAddress'],
      hairColor = nativeBarcodeExtendedElements['hairColor'],
      height = nativeBarcodeExtendedElements['height'],
      heightIn = nativeBarcodeExtendedElements['heightIn'],
      heightCm = nativeBarcodeExtendedElements['heightCm'],
      issuerIdentificationNumber = nativeBarcodeExtendedElements['issuerIdentificationNumber'],
      issuingJurisdiction = nativeBarcodeExtendedElements['issuingJurisdiction'],
      issuingJurisdictionName = nativeBarcodeExtendedElements['issuingJurisdictionName'],
      jurisdictionEndorsementCodes = nativeBarcodeExtendedElements['jurisdictionEndorsementCodes'],
      jurisdictionEndorsmentCodeDescription = nativeBarcodeExtendedElements['jurisdictionEndorsmentCodeDescription'],
      jurisdictionRestrictionCodeDescription = nativeBarcodeExtendedElements['jurisdictionRestrictionCodeDescription'],
      jurisdictionRestrictionCodes = nativeBarcodeExtendedElements['jurisdictionRestrictionCodes'],
      jurisdictionVehicleClass = nativeBarcodeExtendedElements['jurisdictionVehicleClass'],
      jurisdictionVehicleClassificationDescription =
          nativeBarcodeExtendedElements['jurisdictionVehicleClassificationDescription'],
      jurisdictionVersionNumber = nativeBarcodeExtendedElements['jurisdictionVersionNumber'],
      limitedDurationDocument = nativeBarcodeExtendedElements['limitedDurationDocument'],
      medicalIndicator = nativeBarcodeExtendedElements['medicalIndicator'],
      middleNameTruncation = nativeBarcodeExtendedElements['middleNameTruncation'],
      namePrefix = nativeBarcodeExtendedElements['namePrefix'],
      nameSuffix = nativeBarcodeExtendedElements['nameSuffix'],
      nonResident = nativeBarcodeExtendedElements['nonResident'],
      numberOfDuplicates = nativeBarcodeExtendedElements['numberOfDuplicates'],
      organDonor = nativeBarcodeExtendedElements['organDonor'],
      permitExpirationDate = nativeBarcodeExtendedElements['permitExpirationDate'],
      permitIdentifier = nativeBarcodeExtendedElements['permitIdentifier'],
      permitIssueDate = nativeBarcodeExtendedElements['permitIssueDate'],
      placeOfBirth = nativeBarcodeExtendedElements['placeOfBirth'],
      raceEthnicity = nativeBarcodeExtendedElements['raceEthnicity'],
      residenceCity = nativeBarcodeExtendedElements['residenceCity'],
      residenceFullAddress = nativeBarcodeExtendedElements['residenceFullAddress'],
      residenceJurisdictionCode = nativeBarcodeExtendedElements['residenceJurisdictionCode'],
      residencePostalCode = nativeBarcodeExtendedElements['residencePostalCode'],
      residenceStreetAddress = nativeBarcodeExtendedElements['residenceStreetAddress'],
      residenceStreetAddress2 = nativeBarcodeExtendedElements['residenceStreetAddress2'],
      securityVersion = nativeBarcodeExtendedElements['securityVersion'],
      sex = nativeBarcodeExtendedElements['sex'],
      socialSecurityNumber = nativeBarcodeExtendedElements['socialSecurityNumber'],
      standardEndorsementCode = nativeBarcodeExtendedElements['standardEndorsementCode'],
      standardRestrictionCode = nativeBarcodeExtendedElements['standardRestrictionCode'],
      standardVehicleClassification = nativeBarcodeExtendedElements['standardVehicleClassification'],
      standardVersionNumber = nativeBarcodeExtendedElements['standardVersionNumber'],
      under18 = nativeBarcodeExtendedElements['under18'],
      under19 = nativeBarcodeExtendedElements['under19'],
      under21 = nativeBarcodeExtendedElements['under21'],
      uniqueCustomerId = nativeBarcodeExtendedElements['uniqueCustomerId'],
      veteran = nativeBarcodeExtendedElements['veteran'],
      weightKilograms = nativeBarcodeExtendedElements['weightKilograms'],
      weightPounds = nativeBarcodeExtendedElements['weightPounds'],
      weightRange = nativeBarcodeExtendedElements['weightRange'],
      subFieldDesignator = nativeBarcodeExtendedElements['subFieldDesignator'];
}

/// Represents the document type found on the Machine Readable Zone
enum MRZDocumentType {
  /// Document type was not identified.
  unknown,

  /// Identity card
  identityCard,

  /// Passport
  passport,

  /// VISA
  visa,

  /// Green card
  greenCard,

  /// IIM13P Pass
  mysPassIMM13P,

  /// Driver license
  driverLicense,

  /// Internal travel document
  internalTravelDocument,

  /// Border crossing card
  borderCrossingCard,
}

/// Represents the result of the image crop transformation with additional details.
class DetailedCroppedImageResult {
  /// The cropped image in the Base64 format
  String? image;

  /// The document side that was cropped.
  ScanningSide? side;

  /// The location of the cropped image in the transformed image of the document.
  Rectangle? location;

  /// Represents the result of the image crop transformation with additional details.
  DetailedCroppedImageResult(Map<String, dynamic> nativeDetailedCroppedImageResult) {
    image = nativeDetailedCroppedImageResult["image"];
    side = enumFromValue(ScanningSide.values, nativeDetailedCroppedImageResult["side"]);
    location = nativeDetailedCroppedImageResult['location'] != null
        ? Rectangle(Map<String, dynamic>.from(nativeDetailedCroppedImageResult['location']))
        : null;
  }
}

/// Represents the side of the document being scanned.
enum ScanningSide {
  /// The first side of the scanned document
  first,

  /// The second side of the scanned document
  second,
}

/// The results of parents info.
class ParentInfo {
  /// The first name of one of the document owner's parents.
  StringResult? firstName;

  /// The last name of one of the document owner's parents.
  StringResult? lastName;

  ParentInfo(Map<String, dynamic> nativeParentInfo) {
    firstName = createStringResult(nativeParentInfo, 'firstName');
    lastName = createStringResult(nativeParentInfo, 'lastName');
  }
}

/// Helper method for serializing enums from the native Android and iOS platforms.
T? enumFromValue<T>(List<T> values, dynamic input) {
  if (input == null) return null;
  if (input is T) return input;

  if (input is int) {
    if (input >= 0 && input < values.length) return values[input];
  }

  final inputStr = input.toString().split('.').last.toLowerCase();
  for (var value in values) {
    final enumStr = value.toString().split('.').last.toLowerCase();
    if (enumStr == inputStr) return value;
  }

  return null;
}

/// Helper method for handling different string types, based on the document information source.
T? handleStringType<T>(dynamic result, String propertyName) {
  if (result == null) return null;

  if (T == String) {
    if (result is Map && result[propertyName] is String) {
      return result[propertyName] as T;
    }
    return null;
  }

  if (T == StringResult) {
    final value = result[propertyName];
    if (value is Map<String, dynamic>) {
      return StringResult(value) as T;
    }
    return null;
  }

  return null;
}
