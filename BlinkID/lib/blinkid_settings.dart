import 'package:json_annotation/json_annotation.dart';
part 'blinkid_settings.g.dart';

/// Network timeouts used when the SDK downloads on-device processing resources.
///
/// Values are in milliseconds. On Android BlinkID 7.7.x the native default is
/// 10000 ms for each timeout. Passing `null` from [BlinkIdSdkSettings] keeps
/// that native default.
@JsonSerializable()
class RequestTimeout {
  /// Timeout for establishing the TCP connection to the resource host.
  final int connectionTimeoutMilliseconds;

  /// Timeout for individual write IO operations.
  final int writeTimeoutMilliseconds;

  /// Timeout applied to the TCP socket and read IO operations.
  final int readTimeoutMilliseconds;

  const RequestTimeout({
    this.connectionTimeoutMilliseconds = 10000,
    this.writeTimeoutMilliseconds = 10000,
    this.readTimeoutMilliseconds = 10000,
  });

  /// Convenience constructor that applies the same duration to all timeouts.
  const RequestTimeout.all(int timeoutMilliseconds)
      : connectionTimeoutMilliseconds = timeoutMilliseconds,
        writeTimeoutMilliseconds = timeoutMilliseconds,
        readTimeoutMilliseconds = timeoutMilliseconds;

  /// Matches Android BlinkID 7.7.1 `RequestTimeout.DEFAULT` (10 seconds).
  static const RequestTimeout defaultTimeout = RequestTimeout();

  factory RequestTimeout.fromJson(Map<String, dynamic> json) =>
      _$RequestTimeoutFromJson(json);
  Map<String, dynamic> toJson() => _$RequestTimeoutToJson(this);
}

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
  bool? downloadResources;

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
  ///
  /// Serialized to the native Android `RequestTimeout` map
  /// (`connectionTimeoutMilliseconds`, `writeTimeoutMilliseconds`,
  /// `readTimeoutMilliseconds`). Leave `null` to use the native default
  /// (10 seconds on BlinkID Android 7.7.1).
  RequestTimeout? resourceRequestTimeout;

  /// Set a custom HTTPS URL to be used as a proxy for Ping and license checks.
  /// The proxy URL will be applied only if the license has the appropriate rights.
  /// The URL must use the HTTPS protocol. Example: https://your-proxy.com/
  ///
  /// If this value is defined, SDK initialization will not be successful in the following cases:
  ///   - if the URL does not use HTTPS or if the URL is invalid
  ///   - if the license does not allow proxy usage
  String? microblinkProxyURL;

  /// Settings for the initialization of the BlinkID SDK.
  BlinkIdSdkSettings(
    this.licenseKey, [
    licensee,
    downloadResources,
    resourceDownloadUrl,
    resourceLocalFolder,
    bundleURL,
    resourceRequestTimeout,
    microblinkProxyURL,
  ]);

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
  /// Defaults to 15.0
  int stepTimeoutDuration = 15000;

  /// Represents the configuration settings for a scanning session.
  ///
  /// This class holds the settings related to the resources initialization,
  /// scanning mode, and specific scanning configurations that define how the scanning
  /// session should behave.
  BlinkIdSessionSettings();

  factory BlinkIdSessionSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdSessionSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdSessionSettingsToJson(this);
}

/// Represents the configurable settings for scanning a document.
///
/// This class defines various parameters and policies related to the scanning
/// process, including image quality handling, data extraction and anonymization,
/// along with options for frame processing and image extraction.
@JsonSerializable()
class BlinkIdScanningSettings {
  /// The level of blur detection in the document image.
  ///
  /// Defines the severity of blur detected in the document image, as defined
  /// in [DetectionLevel]. Values range from `off` (detection NotAvailable) to higher
  /// levels of blur detection.
  ///
  /// `low` – less sensitive to blur; if something is detected as blur, it is almost certainly actual blur,
  ///  but some amount of blur may not be detected at all.
  /// `high` – highly sensitive to blur; it may detect as blur even something that only resembles blur.
  ///
  /// Default: [DetectionLevel.mid]
  DetectionLevel blurDetectionLevel = DetectionLevel.mid;

  /// Indicates whether images with blur in the document image should be skipped.
  ///
  /// A value of `true` means images with detected blur will be excluded from further processing to prevent blurred images from being used
  ///     - If blurDetectionLevel = `off` - blurred images will be processed
  ///     - If blur is detected `ProcessingStatus` will be `ImagePreprocessingFailed` and blur will be reported in the `ProcessResult`
  /// A value of `false` means images with detected blur will not be excluded from further processing
  ///     - If blurDetectionLevel != `off` - even if blur is detected, the image will be processed and blur will be reported in the `ProcessResult`.
  ///
  /// Default: `true`
  bool skipImagesWithBlur = true;

  /// The level of glare detection in the document image.
  ///
  /// Defines the severity of glare detected in the document image, as defined in [DetectionLevel].
  /// Values range from `off` (detection NotAvailable) to higher levels of glare detection.
  /// `low` – less sensitive to glare; if something is detected as glare, it is almost certainly actual glare,
  ///     but some amount of glare may not be detected at all.
  /// `high` – highly sensitive to glare; it may detect as glare even something that only resembles glare.
  ///
  /// Default: [DetectionLevel.mid]
  DetectionLevel glareDetectionLevel = DetectionLevel.mid;

  /// Indicates whether images with glare in the document image should be skipped.
  ///
  /// A value of `true` means images with detected glare will be excluded from further processing to prevent glared images from being used
  ///     - If glareDetectionLevel = `off` - glared images will be processed
  ///     - If glare is detected `ProcessingStatus` will be `ImagePreprocessingFailed` and glare will be reported in the `ProcessResult`
  /// A value of `false` means images with detected glare will not be excluded from further processing
  ///     - If glareDetectionLevel != `off` - even if glare is detected, the image will be processed and glare will be reported in the `ProcessResult`
  ///
  /// Default: `true`
  bool skipImagesWithGlare = true;

  /// The level of allowed detected tilt of the document in the image.
  ///
  /// Defines the severity of allowed detected tilt of the document in the image, as defined in [DetectionLevel].
  /// Values range from `off` (detection NotAvailable) to higher levels of allowed tilt.
  /// `low` – less sensitive to tilt.
  /// `high` – highly sensitive to tilt.
  ///
  /// Default: [DetectionLevel.mid]
  DetectionLevel tiltDetectionLevel = DetectionLevel.mid;

  /// Indicates whether images with inadequate lighting conditions should be rejected.
  ///
  /// Inadequate lighting conditions are represented as either `TooBright` or `TooDark` document images,
  ///     as defined in the `ImageAnalysisLightingStatus` enum.
  /// A value of `true` means images with inadequate lighting conditions will be excluded from further processing to prevent images with
  /// inadequate lighting from being used
  ///     - If inadequate light conditions are detected `ProcessingStatus` will be `ImagePreprocessingFailed` and lighting status will be
  ///       reported in the `ProcessResult`.
  ///
  /// Default: `true`
  bool skipImagesWithInadequateLightingConditions = true;

  /// Indicates whether images occluded by hand should be rejected.
  ///
  /// A value of `true` means images occluded by hand will be excluded from further processing to prevent occluded images from being used
  ///     - If hand occlusion is detected `ProcessingStatus` will be `ImagePreprocessingFailed` and hand occlusion status will be reported
  ///       in the `ProcessResult`
  /// This setting is applicable only if `scanCroppedDocumentImage` = false.
  ///
  /// Default: `true`
  bool skipImagesOccludedByHand = true;

  /// Indicates whether the aggregation of data from multiple images is enabled.
  ///
  ///  Disabling this setting will yield higher-quality captured images, but it may slow down the scanning process due to the additional
  ///      effort required to find the optimal image.
  ///  Enabling this setting will simplify the extraction process, but the extracted data will be aggregated from multiple images instead
  ///      of being sourced from a single image.
  ///  This only applies to images from Video input image source - for images from Photo source, setting will be ignored.
  ///
  /// Default: `true`
  bool combineResultsFromMultipleInputImages = true;

  /// Enables barcode recognition to proceed even if the initial VIZ extraction fails.
  ///
  /// If the barcode recognition is successful, recognition will still end in a valid state.
  /// This setting is applicable only to images from Photo source.
  /// For multi-side scanning, it is permitted only for the back side.
  ///
  /// Default: `false`
  bool enableBarcodeScanOnly = false;

  /// Defines custom rules for specific document class.
  ///
  /// When defining [DocumentRules], [DocumentFilter] is optionally set to specify the document to which the rule applies, and a `fields` with
  ///     the appropriate `alphabetType` should be specified as mandatory for that document.
  /// If a `fields` is set to a field that is optional for that document or does not exist on it, all fields on the document become optional.
  /// If a `fields` is set to a field with an incorrect alphabetType, all fields on the document become optional.
  /// If a `fields` is set to a field that doesn’t exist in the internal rules, that rule is ignored.
  /// When adding multiple `fields`, any field that does not match our rules is ignored. Only fields that comply with our rules are set as mandatory.
  /// If the documentFilter fields `country`, `region`, or `type` are set to `null`, all supported values for those fields will be considered.
  ///     For example, if `country = null`, the rule will apply to all supported countries in BlinkID.
  ///
  /// By default, document fields are validated using internal rules that define mandatory fields for the scanned document class. This setting allows
  ///     users to narrow down our internal rules on mandatory fields. All undefined fields will become optional. It is not possible to mark fields as
  ///     mandatory if they cannot theoretically appear on the document.
  /// The more detailed document filter will have priority over the other.
  ///
  /// See [DocumentRules] for more detailed information.
  List<DocumentRules>? customDocumentRules;

  /// The mode of anonymization applied to the document.
  ///
  /// Redact specific fields based on requirements or laws regarding a specific document.
  /// Data can be redacted from the image, the result or both.
  ///
  /// Default: [AnonymizationMode.fullResult]
  AnonymizationMode anonymizationMode = AnonymizationMode.fullResult;

  /// Redact fields for specific document class.
  ///
  /// Fields specified by requirements or laws for a specific document will be redacted regardless of this setting.
  /// Based on anonymizationMode setting, data will be redacted from the image, the result or both.
  ///
  /// See [DocumentAnonymizationSettings] for more information.
  List<DocumentAnonymizationSettings>? customDocumentAnonymizationSettings;

  /// Indicates whether input images should be returned.
  ///
  /// Save the input images at the moment of the data extraction or timeout.
  /// This significantly increases memory consumption. The scanning performance is not affected.
  ///
  /// Default: `false`
  bool returnInputImages = false;

  /// Process only cropped document images.
  /// Requires the input image to consist solely of the cropped document image with perspective correction applied.
  /// This only applies to images from Photo input image source - for images from Video input image source, setting will be ignored.
  ///
  /// Default: `false`
  bool scanCroppedDocumentImage = false;

  /// The filter for recognition modes.
  ///
  /// Specifies which recognition modes are enabled during the scanning process, with a default value of true to enable all modes.
  /// [RecognitionModeFilter] is used to enable/disable recognition of specific document groups.
  ///
  /// This setting is experimental and it will be removed in upcoming releases.
  ///
  /// By default all modes are enabled (set to `true`).
  RecognitionModeFilter recognitionModeFilter = RecognitionModeFilter();

  /// Indicates whether character validation is enabled.
  ///
  /// Allow only results containing expected characters for a given field.
  /// Each field is validated against a set of rules.
  /// All fields have to be successfully validated in order to successfully scan a document.
  /// Setting is used to improve scanning accuracy.
  /// If set to `true`, when an invalid character is detected `ProcessingStatus.InvalidCharactersFound` is returned.
  ///
  /// Default: `true`
  bool enableCharacterValidation = true;

  /// Defines the minimum required margin (in percentage) between the edge of the input image and the document.
  ///
  /// The setting is applicable only when using images from Video source.
  /// The setting is not applicable if `scanCroppedDocumentImage = true` (it will be ignored).
  /// This setting is implemented to comply with regulations in certain countries that mandate documents
  /// to be stored with adequate margins in the image.
  ///
  /// Default: `0.02` (also recommended value)
  double inputImageMargin = 0.02;

  /// Indicates whether backside of unsupported document should be scanned also.
  ///
  /// By default, back side of the document will not be scanned if only the front side is supported for a specific
  /// document.
  ///
  /// Default: `false`
  bool scanUnsupportedBack = false;

  /// Indicates whether scanning can continue to the next side despite an uncertain front-side scan.
  ///
  /// This only applies to images from Photo input image source - for images from Video source, setting will be
  /// ignored.
  ///
  /// Default: `false`
  bool allowUncertainFrontSideScan = false;

  /// The maximum allowed mismatches per field during data matching.
  ///
  /// Configures the maximum number of characters per field that can be inconsistent during data matching.
  /// By defualt, no mismatches are allowed.
  ///
  /// Default: `0`
  int maxAllowedMismatchesPerField = 0;

  /// Indicates whether only the passport data page should be scanned.
  ///
  /// Scan only the data page ( page containing MRZ ) of the passport.
  /// If set to `false`, it will be required to scan the second page of certain passports.
  ///
  /// Default: `true`
  bool scanPassportDataPageOnly = true;

  /// Configures the image processing settings during the scanning process.
  ///
  /// Allows customization of cropped image handling, such as dotsPerInch, extensions, and
  /// whether images should be returned for the document, face or signature regions.
  ///
  /// See [CroppedImageSettings] for more information.
  CroppedImageSettings croppedImageSettings = CroppedImageSettings();

  /// Represents the configurable settings for scanning a document.
  ///
  /// This class defines various parameters and policies related to the scanning
  /// process, including image quality handling, data extraction and anonymization,
  /// along with options for frame processing and image extraction.
  BlinkIdScanningSettings();

  factory BlinkIdScanningSettings.fromJson(Map<String, dynamic> json) =>
      _$BlinkIdScanningSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BlinkIdScanningSettingsToJson(this);
}

/// Represents the image cropping settings.
@JsonSerializable()
class CroppedImageSettings {
  /// The DPI value for the cropped image.
  ///
  /// Default: `250`
  int dotsPerInch = 250;

  /// The extension factor for the cropped image.
  ///
  /// Default: `0`
  double extensionFactor = 0;

  /// Indicates whether the document image should be returned.
  ///
  /// Default: `false`
  bool returnDocumentImage = false;

  /// Indicates whether the face image should be returned.
  ///
  /// Default: `false`
  bool returnFaceImage = false;

  /// Indicates whether the signature image should be returned.
  ///
  /// Default: `false`
  bool returnSignatureImage = false;

  /// Represents the image cropping settings.
  CroppedImageSettings();

  factory CroppedImageSettings.fromJson(Map<String, dynamic> json) =>
      _$CroppedImageSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$CroppedImageSettingsToJson(this);
}

/// Allows customization of various aspects of the UI/UX
/// used during the scanning process.
@JsonSerializable()
class BlinkIdScanningUxSettings {
  /// A boolean indicating whether to show a help button
  /// and enable help screens during the scanning session.
  ///
  /// Default: `true`
  bool showHelpButton = true;

  /// A boolean indicating whether to show an onboarding dialog
  /// at the beginning of the scanning session.
  ///
  /// Default: `true`
  bool showOnboardingDialog = true;

  /// Determines whether haptic feedback is played for scanning-related events.
  ///
  /// When enabled, haptic responses are generated during scanning activities,
  /// such as detection updates or user interactions (e.g., toggling the flashlight).
  /// When disabled, no haptic feedback is produced.
  ///
  /// Default: `true`
  bool allowHapticFeedback = true;

  /// The preferred camera position to use when capturing document.
  /// This value represents the user’s choice of front or back camera.
  ///
  /// The system determines the actual physical camera device.
  ///
  /// Default: [PrefferedCamera.back]
  PreferredCamera preferredCamera = PreferredCamera.back;

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

  factory ClassFilter.fromJson(Map<String, dynamic> json) =>
      _$ClassFilterFromJson(json);
  Map<String, dynamic> toJson() => _$ClassFilterToJson(this);
}

/// Represents the custom document rules.
///
/// This setting allows users to narrow down our internal rules on mandatory fields. All undefined fields will become optional.
/// It is not possible to mark fields as mandatory if they cannot theoretically appear on the document.
/// The more detailed document filter will have priority over the other.
///
/// Document fields are validated using internal rules that define mandatory fields for the scanned document class.
@JsonSerializable()
class DocumentRules {
  /// Specified fields will overrule our document class field rules if filter conditions are met.
  ///
  /// See [DocumentFilter] for more information.
  DocumentFilter? documentFilter;

  /// Fields to overrule our class field rules.
  ///
  /// [DetailedFieldType] for more information.
  List<DetailedFieldType> fields;

  /// Represents the custom document rules.
  ///
  /// This setting allows users to narrow down our internal rules on mandatory fields. All undefined fields will become optional.
  /// It is not possible to mark fields as mandatory if they cannot theoretically appear on the document.
  /// The more detailed document filter will have priority over the other.
  ///
  /// Document fields are validated using internal rules that define mandatory fields for the scanned document class.
  /// Defines custom rules for specific document class.
  ///
  /// When defining [DocumentRules], [DocumentFilter] is optionally set to specify the document to which the rule applies, and a `fields` with
  ///     the appropriate `alphabetType` should be specified as mandatory for that document.
  /// If a `fields` is set to a field that is optional for that document or does not exist on it, all fields on the document become optional.
  /// If a `fields` is set to a field with an incorrect alphabetType, all fields on the document become optional.
  /// If a `fields` is set to a field that doesn’t exist in the internal rules, that rule is ignored.
  /// When adding multiple `fields`, any field that does not match our rules is ignored. Only fields that comply with our rules are set as mandatory.
  /// If the documentFilter fields `country`, `region`, or `type` are set to `null`, all supported values for those fields will be considered.
  ///     For example, if `country = null`, the rule will apply to all supported countries in BlinkID.
  DocumentRules(this.fields, [this.documentFilter]);

  factory DocumentRules.fromJson(Map<String, dynamic> json) =>
      _$DocumentRulesFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentRulesToJson(this);
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

  factory DetailedFieldType.fromJson(Map<String, dynamic> json) =>
      _$DetailedFieldTypeFromJson(json);
  Map<String, dynamic> toJson() => _$DetailedFieldTypeToJson(this);
}

/// Represents the document anonymization settings.
@JsonSerializable()
class DocumentAnonymizationSettings {
  /// Document fields that will be anonymized.
  List<FieldType> fields = [];

  /// Specified fields will be anonymized if filter conditions are met.
  DocumentFilter? documentFilter;

  /// Document number anonymization settings.
  DocumentNumberAnonymizationSettings? documentNumberAnonymizationSettings;

  /// Represents the document anonymization settings.
  ///
  /// **fields** parameter represents the document fields that will be anonymized.
  /// This parameter is mandatory.
  ///
  /// **documentFilter** specifies the document filter.
  /// If the conditions of the filter are met, fields of those documents will be anonymized.
  /// This parameter is optional.
  ///
  /// **documentNumberAnonymizationSettings** specifies the document number anonymization settings.
  /// If this parameter is set, it will anonymize the document number, even if the document number is not set in the `fields` parameter.
  /// If the default constructor for [DocumentNumberAnonymizationSettings] is used, all of the digits within the document number will be anonymized.
  /// This parameter is optional.
  DocumentAnonymizationSettings(
    this.fields, [
    this.documentFilter,
    this.documentNumberAnonymizationSettings,
  ]);

  factory DocumentAnonymizationSettings.fromJson(Map<String, dynamic> json) =>
      _$DocumentAnonymizationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentAnonymizationSettingsToJson(this);
}

/// Represents the document filter.
/// Used with other classes like the [ClassFilter], [DocumentRules] and the [DocumentAnonymizationSettings].
@JsonSerializable()
class DocumentFilter {
  /// If set, only specified country will pass the filter criteria.
  /// Otherwise, issuing country will not betaken into account.
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
  DocumentFilter([this.country, this.region, this.documentType]);
  factory DocumentFilter.fromJson(Map<String, dynamic> json) =>
      _$DocumentFilterFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentFilterToJson(this);
}

/// Represents the document number anonymization settings.
@JsonSerializable()
class DocumentNumberAnonymizationSettings {
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
  DocumentNumberAnonymizationSettings([
    int? prefixDigitsVisible,
    int? suffixDigitsVisible,
  ]) : prefixDigitsVisible = prefixDigitsVisible ?? 0,
       suffixDigitsVisible = suffixDigitsVisible ?? 0;

  factory DocumentNumberAnonymizationSettings.fromJson(
    Map<String, dynamic> json,
  ) => _$DocumentNumberAnonymizationSettingsFromJson(json);
  Map<String, dynamic> toJson() =>
      _$DocumentNumberAnonymizationSettingsToJson(this);
}

/// Represents the configuration used to enable/disable recognition of specific
/// document groups.
///
/// By default all modes are enabled.
@JsonSerializable()
class RecognitionModeFilter {
  /// Enable scanning of MRZ IDs.
  bool enableMrzId = true;

  /// Enable scanning of visa MRZ.
  bool enableMrzVisa = true;

  /// Enable scanning of Passport MRZ.
  bool enableMrzPassport = true;

  /// Enable scanning of Photo ID.
  bool enablePhotoId = true;

  /// Enable scanning of barcode IDs.
  bool enableBarcodeId = true;

  /// Enable full document recognition.
  bool enableFullDocumentRecognition = true;

  /// Represents the configuration used to enable/disable recognition of specific
  /// document groups.
  ///
  /// By default all modes are enabled.
  RecognitionModeFilter();

  factory RecognitionModeFilter.fromJson(Map<String, dynamic> json) =>
      _$RecognitionModeFilterFromJson(json);
  Map<String, dynamic> toJson() => _$RecognitionModeFilterToJson(this);
}

/// BlinkID enums

/// Represents the mode of document scanning.
///
/// This enum class defines whether the scanning process is limited to a single
/// side of the document or includes multiple sides, automatically identifying how many sides need to be scanned.
enum ScanningMode {
  /// Specifies the scanning process to be for single side only.
  @JsonValue(0)
  single,

  /// The default [ScanningMode].
  ///
  ///  Automatically determines the number of sides to scan.
  @JsonValue(1)
  automatic,
}

/// Represents the different levels of detection sensitivity.
///
/// This enum class is used to configure detection thresholds and enable or
/// disable detection functionality. The levels range from turning detection
/// off completely to setting various levels of sensitivity (low, mid, high).
enum DetectionLevel {
  /// Disables the [DetectionLevel]
  @JsonValue(0)
  off,

  /// Sets the [DetectionLevel] to be less sensitive.
  @JsonValue(1)
  low,

  /// The default [DetectionLevel] sensitivity.
  @JsonValue(2)
  mid,

  /// Sets the [DetectionLevel] to be highly sensitive.
  @JsonValue(3)
  high,
}

/// Represents level of anonymization performed on the scanning result.
enum AnonymizationMode {
  /// Anonymization will not be performed.
  @JsonValue(0)
  none,

  /// Full document image is anonymized with black boxes covering sensitive data.
  @JsonValue(1)
  imageOnly,

  /// Result fields containing sensitive data are removed from result.
  @JsonValue(2)
  resultFieldsOnly,

  /// This mode is combination of `imageOnly` and `resultFieldsOnly` modes.
  @JsonValue(3)
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
  @JsonValue("virginIslandsUs")
  virginIslandsUs,
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
  @JsonValue("parentsLastName2")
  parentsLastName2,
  @JsonValue("parentsFirstName")
  parentsFirstName,
  @JsonValue("parentsFirstName2")
  parentsFirstName2,
  @JsonValue("workRestriction")
  workRestriction,
  @JsonValue("socialSecurityStatus")
  socialSecurityStatus,
  @JsonValue("legalStatus")
  legalStatus,
  @JsonValue("husbandName")
  husbandName,
  @JsonValue("chinPermanentExpiry")
  chinPermanentExpiry,
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
