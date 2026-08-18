## v8001.0.0

Updated to BlinkID native SDKs **v8001.0.0** (Android & iOS). See also the [platform release notes](https://docs.microblink.com/blinkid/release-notes) and the repository [Release notes](https://github.com/microblink/blinkid-flutter/blob/master/Release%20notes.md).

### What's new
- Accelerated support for newly issued documents
    - Optimized document support and extraction pipeline to reduce time-to-production for newly issued identity documents, and to apply document-rule / knowledge improvements without a full SDK upgrade when possible.
    - Zero-day readiness: depending on design availability and when a new document begins circulating, BlinkID can deliver 0-day support—and at a maximum, within 4 weeks of the document's release.
    - Future-proof compliance: workflows can adapt to global document updates faster than before.
- Enhanced frame selection & image quality
    - Smart quality selection: analyzes multiple frames and selects a crisp, stable image before extraction.
    - Higher first-pass success by filtering blurry or unstable frames early.
    - Flexible speed vs. quality tuning via `documentCaptureModule.inputImageSelectionStrategy` (camera / video flow).
- Enhanced DirectAPI / photo-mode intelligence
    - `documentCaptureModule.cropType` replaces the former boolean cropped-image flag (`InputImageCropType.notCropped` | `unknown` | `cropped`).
    - `cropped` and `unknown` apply to **DirectAPI (photo)** flows only; camera UX (`performScan`) requires `notCropped`.
- Expanded & improved barcode capabilities
    - Aztec barcode support via `barcodeModule.aztecScanningEnabled`.
    - Improved speed and accuracy for QR, DataMatrix, and selected 1D formats.
- Parsing & extraction improvements
    - Improved Persian digit recognition for regional documents.
- Mandatory data redaction: Netherlands DL QR code added to the redacted list.
- OTA (over-the-air) resources: configure separately from base ML resources via `BlinkIdSdkSettings.otaResourcesConfig`.

### Bug fixes
- Document swap data caching: fixed an issue in continuous-video mode where data from a previously scanned document could persist after a new document was introduced. The SDK now detects document swaps and clears cached images (cropped faces, signatures, barcodes, etc.) to prevent cross-contamination.
- Fixed `resourcesConfig.requestTimeout` and `otaResourcesConfig.requestTimeout`: custom timeout values are now applied on Android and iOS (previously ignored or dropped on the bridge).

### New documents support
- Bailiwick Of Jersey - Driver's License
- Bailiwick Of Jersey - Paper Passport
- Bailiwick Of Jersey - Polycarbonate Passport
- Botswana - Driver's License
- Brunei - Polycarbonate Passport
- Democratic Republic Of The Congo - Polycarbonate Passport
- Dominican Republic - Polycarbonate Passport
- Eswatini - Driver's License
- Gambia - Driver's License
- Georgia - Residence Permit
- Iceland - Identity Card
- Iceland - Residence Permit
- Japan - Specified Residence Card
- Liechtenstein - Residence Permit
- Liechtenstein - Resident ID
- Mali - Polycarbonate Passport
- Mauritania - Resident ID
- Monaco - Identity Card
- Monaco - Residence Permit
- Nepal - Identity Card
- Palestine - Identity Card
- San Marino - Identity Card
- Sudan - Driver's License
- UK, Northern Ireland - Voter ID
- USA, Arkansas - Medical Marijuana ID
- USA, Massachusetts - Medical Marijuana ID
- USA, Michigan - Medical Marijuana ID
- USA, New Jersey - Medical Marijuana ID
- Zambia - Residence Permit

#### New document versions for supported documents
- Bolivia - Driver's License
- Burkina Faso - Identity Card
- Central African Republic - Paper Passport
- Estonia - Identity Card
- Dominican Republic - Identity Card
- Guyana - Identity Card
- Israel - Identity Card
- Luxembourg - Polycarbonate Passport
- Mexico, Baja California - Driver's License
- Mexico, Hidalgo - Driver's License
- Oman - Identity Card
- Oman - Resident ID
- Uruguay - Identity Card
- USA, Mississippi - Identity Card
- USA, Nebraska - Driver's License
- USA, Nebraska - Identity Card
- USA, North Carolina - Identity Card
- USA, Oklahoma - Driver's License
- USA, Oklahoma - Identity Card
- USA, Texas - Weapon Permit

#### New extracted fields from documents
- Brazil national identity card and regional (22 regions) identity cards now extract parent names (`parentsInfo`).
- Croatia identity card: added support for cyrillic values in `sex`, `address`, `issuingAuthority`, `lastName` and `firstName`, and latin `sex`.
- Virgin Islands of the United States identity card and driver's license: added `documentSubtype` and `specificDocumentValidity`.
- Tunisia identity card: added arab values for `lastName`, `firstName`, `placeOfBirth`; added `dateOfBirth`.
- Argentina identity card and alien identity card: use `cardAccessNumber` instead of `documentAdditionalNumber`.

### Requirements
- Flutter **3.44.1** or newer
- Dart **3.12.1** or newer
- iOS **16.0** or newer; Swift Package Manager must be enabled (`flutter config --enable-swift-package-manager`)
- Android API level **24** or newer; **compileSdk 36**; **AGP 9.1.0**; **Kotlin 2.2.21**
- Integrator apps do **not** need Jetpack Compose setup; Compose is used internally by BlinkID UX

### Breaking changes
- **Document class info:** `DocumentClassInfo.country`, `region`, and `documentType` are nested objects (`Country` / `Region` / `DocumentType` with `id?` and `rawValue`) instead of flat enum/string values. `ClassFilter` / `DocumentFilter` stay flat (`CountryID` / `RegionID` / `DocumentTypeID`).
- **SDK settings:** flat resource fields on `BlinkIdSdkSettings` move into `resourcesConfig` and optional `otaResourcesConfig` (`downloadResources` → `resourcesConfig.download`, `resourceDownloadUrl` → `resourcesConfig.serviceUrl`, etc.).
- **Resource download timeouts:** `resourcesConfig.requestTimeout` and `otaResourcesConfig.requestTimeout` are `RequestTimeout?` (three millisecond fields: `connectionTimeoutMilliseconds`, `writeTimeoutMilliseconds`, `readTimeoutMilliseconds`), not `int?`. Use `RequestTimeout.all(milliseconds)` or per-field configuration. Omit `requestTimeout` to keep native defaults (30 seconds per timeout).
- **Document capture:** `documentCaptureModule.inputImageCropped` (boolean) → `documentCaptureModule.cropType` (`InputImageCropType.notCropped` | `unknown` | `cropped`).
- **Document capture:** added `documentCaptureModule.inputImageSelectionStrategy` (`singleImage` | `optimizeForSpeed` | `balanced` | `optimizeForQuality`).
- **Barcode:** added `barcodeModule.aztecScanningEnabled` (default `false`).

For step-by-step migration examples, see [What's new in v8001](https://github.com/microblink/blinkid-flutter/tree/master?tab=readme-ov-file#whats-new-in-v8001) in the README and [API changes in Release notes](https://github.com/microblink/blinkid-flutter/blob/master/Release%20notes.md#api-changes-v8001).

### Minor API changes
- Added `ethnicity` on `BlinkIdScanningResult` and `VizResult`.
- Added `fullName` on `ParentInfo`.
- Added `FieldType.parentFullName` and `FieldType.ethnicity` for redaction.
- Native intermediate analysis APIs added in v8001 (e.g. process/analysis crop signals, `AwaitingMoreStableInputImages`, `vizExtractionType`) are **not** part of the Flutter public API.

## v8000.0.0

### What's new
- The list of all supported documents and result fields is now available [here](https://docs.microblink.com/blinkid/supported-documents).
- SDK modularization & enhanced flexibility: We’ve transformed our core architecture. Features previously known as "fallback modes" are now independent SDK modules.
    - Tailored implementation: Users can now toggle specific modules such as Capture, Barcode, MRZ, or VIZ scanners to build a workflow that fits their exact needs.
    - Total control: This modular approach offers more flexibility, allowing you to use BlinkID as a comprehensive recognition tool or a specialized scanner, all while leveraging our latest feature updates.
- Expanded barcode support: When operating in Barcode Mode, BlinkID is no longer limited to PDF417.
    - Universal scanning: We've added support for QR codes, Code 128, Code 39, ITF, EAN, UPC, and DataMatrix.
    - Versatility: This expansion allows the SDK to be used across a wider variety of document types beyond standard IDs.
- Streamlined extraction & data redaction (anonymization): We are putting more power in the hands of our integrators by removing restrictive custom rules.
    - Document rules: Custom document rules have been removed. Customers can now implement their own logic based on result completeness to determine how a document is processed.
    - Data redaction (Anonymization): We’ve transitioned away from fixed data redaction (anonymization) rules. You can now programmatically decide which fields to mask and how to handle them based on the specific data returned.
    - We are transitioning our terminology from 'anonymization' to 'data redaction' to more accurately reflect the nature of this feature.
- Intelligent timeout mechanism: To balance performance with accuracy, we've introduced a new timeout feature
    - Non-Blocking scans: Ensures a smooth user experience by preventing "stuck" scan states.
    - Step-by-Step decisions: After each extraction step, you can decide whether the current data is sufficient or if the SDK should continue processing to gather more information.
- Document-specific improvements
    - EU residence permits: For documents with redundant fields on both the front and back, BlinkID now intelligently merges these into the top-level results for better data consistency.
    - Egypt driver’s license: Enhanced data extraction to now include Date of Birth (DOB) as an additional field.
    - Zimbabwe ID: Improved data extraction to support and return both alphabetic and numeric characters within the document number field.
    - We have added extraction of date of birth from document numbers on Egypt DL.
    - If a residence permit has a "remarks" field on both the front and back side, values of these fields will be combined in the top level result.

### Bug fixes
- Date conversion accuracy: Resolved an issue where Islamic-to-Gregorian date conversions could occasionally differ by +/- 1 day. These conversions are now precise and consistent.
- We have fixed MRZ parsing rules for Zimbabwe ID and the new version of Brunei ID; these are now successfully extracted.

### New documents support
- Argentina - Polycarbonate Passport
- Bhutan - Identity Card
- Georgia - Polycarbonate Passport
- Jamaica - Identity Card
- Maldives - Driver's License
- Mongolia - Identity Card
- New Zealand - Proof Of Age Card
- Pakistan - Origin Card
- Saint Kitts And Nevis - Polycarbonate Passport
- South Sudan - Identity Card
- Virgin Islands Of The United States - Driver's License
- Virgin Islands Of The United States - Identity Card

#### New document versions for supported documents
- Argentina - Alien ID
- Argentina - Identity Card
- Armenia - Identity Card
- Australia, Australian Capital Territory - Driver's License
- Australia, Australian Capital Territory - Identity Card
- Brunei - Identity Card
- Bulgaria - Residence Permit
- Denmark - Driver's License
- Georgia - Identity Card
- Greece - Residence Permit
- Guatemala - Alien ID
- Guatemala - Identity Card
- Guyana - Paper Passport
- Kosovo - Driver's License
- Kyrgyzstan - Polycarbonate Passport
- Liechtenstein - Identity Card
- Mauritius - Identity Card
- Nigeria - Identity Card
- Puerto Rico - Driver's License
- Puerto Rico - Identity Card
- Uganda - Identity Card
- USA - Paper Passport
- USA - Polycarbonate Passport
- USA, Montana - Driver's License
- USA, Montana - Identity Card
- USA, New York City - Identity Card
- Venezuela - Driver's License

#### New segments supported on documents
- Pakistan, proof of registration: renamed fathersName to additionalNameInformation
- Mauritania, ID: renamed documentNumber to personalIdNumber

### Requirements
- Flutter **3.44.1** or newer
- Dart **3.12.1** or newer
- iOS **16.0** or newer; Swift Package Manager must be enabled (`flutter config --enable-swift-package-manager`)
- Android API level **24** or newer; **compileSdk 36**; **AGP 9.1.0**; **Kotlin 2.2.21**
- Integrator apps do **not** need Jetpack Compose setup; Compose is used internally by BlinkID UX

### Breaking changes
- **Module-based scanning settings:** flat fields on `BlinkIdScanningSettings` (e.g. `glareDetectionLevel`, `CroppedImageSettings`) are replaced by optional module configs: `DocumentCaptureModuleSettings`, `MrzModuleSettings`, `BarcodeModuleSettings`, `VizModuleSettings`
- **UX settings:** use `BlinkIdScanningUxSettings` (already renamed from `BlinkIdUiSettings` in v7.6; v8000 builds on the module model)
- **Method signatures:** `performScan` and `performDirectApiScan` use **named parameters** instead of positional arguments
- **SDK settings constructor:** `BlinkIdSdkSettings(licenseKey: ...)` — the v7 positional `sdkLicenseKey` parameter name is gone
- **Class filter:** prefer `ClassFilter()..includeDocuments = [...]` / `..excludeDocuments = [...]` instead of `ClassFilter.withIncludedDocumentClasses(...)`
- **Anonymization → redaction:** `AnonymizationSettings` / fixed rules removed; use `RedactionSettings` (DirectAPI) or `RedactionSettingsResolver` (camera scan)
- **Custom document rules removed:** `customDocumentRules` on `BlinkIdScanningSettings` is no longer supported — implement completeness logic in your app
- **Session timeouts:** `BlinkIdSessionSettings` adds `stepTimeoutDuration` and `inactivityTimeoutDuration` (milliseconds)
- **Enum/result changes:** see Minor API changes below (`VIRGIN_ISLANDS_US` → `VIRGIN_ISLANDS_OF_THE_UNITED_STATES`, removed `FieldType` values, new `cardAccessNumber`, etc.)

For step-by-step migration examples, see the [Migrating from v7.x](https://github.com/microblink/blinkid-flutter/tree/master?tab=readme-ov-file#migrating-from-v7x) section in the README and the [native v8000 migration guide](https://docs.microblink.com/blinkid/migration-v8000).

### Minor API changes
- Added new items to enums:
    - new `FieldType` enum values: `CardAccessNumber`
    - new `Type` enum values: `ORIGIN_CARD`
    - new `Country` enum value: `VIRGIN_ISLANDS_OF_THE_UNITED_STATES`
- Added member results to `ScanningResult` and `VizResult`:
    -  'cardAccessNumber'
- Removed items from enums:
    -  removed `FieldType` enum values: Removed `ParentsLastName2`, `ParentsFirstName2`, `ChinPermanentExpiry`
    -  removed `Country` enum value: `VIRGIN_ISLANDS_US`


## v7.7.0
- Updated to [Android SDK v7.7.1](https://github.com/microblink/blinkid-android/releases/tag/v7.7.1) and [iOS SDK v7.7.0](https://github.com/microblink/blinkid-ios/releases/tag/v7.7.0)

### What's New
- Barcode extraction is marked as optional on documents where barcode detecton has bad performance (Cuba ID and Passport, Philippines DL, Haiti ID, Sudan ID, Egypt ID, Ecuador Passport, Ghana Passport, Iraq Passport, Nicaragua Passport, Pakistan Passport)

## Bug fixes
- In situations where some fields on different sides of a document have values in multiple alphabets it could happen that while merging results we overwrite them and keep only one alphabet. With this version this is fixed and both alphabets are returned.
- Fixed issue with incorrect retrieval of properties `primaryID` and `secondaryID` from the `MrzResult`.

### New documents support
- Angola - Identity Card
- Antigua And Barbuda - Paper Passport
- Barbados - Paper Passport
- Belize - Paper Passport
- Benin - Driver's License
- Benin - Polycarbonate Passport
- Bermuda - Paper Passport
- Bermuda - Polycarbonate Passport
- Bhutan - Paper Passport
- Botswana - Paper Passport
- Brazil, Acre - Identity Card
- Brazil, Espirito Santo - Identity Card
- Brazil, Mato Grosso Do Sul - Identity Card
- Brazil, Paraiba - Identity Card
- Brazil, Piaui - Identity Card
- Brazil, Rio Grande Do Norte - Identity Card
- Brazil, Tocantins - Identity Card
- Central African Republic - Paper Passport
- Chad - Paper Passport
- Chad - Polycarbonate Passport
- Congo - Paper Passport
- Democratic Republic Of The Congo - Paper Passport
- Djibouti - Paper Passport
- Djibouti - Polycarbonate Passport
- Equatorial Guinea - Paper Passport
- Equatorial Guinea - Polycarbonate Passport
- Eswatini - Identity Card
- Ethiopia - Paper Passport
- Federated States Of Micronesia - Paper Passport
- Gabon - Paper Passport
- Gabon - Polycarbonate Passport
- Ghana - Polycarbonate Passport
- Ghana - Social Security Card
- Guinea - Driver's License
- Guinea Bissau - Paper Passport
- Guinea Bissau - Polycarbonate Passport
- India, Odisha - Driver's License
- India, Uttarakhand - Driver's License
- Ireland - Proof Of Age Card
- Laos - Paper Passport
- Lesotho - Paper Passport
- Liberia - Driver's License
- Liberia - Social Security Card
- Madagascar - Paper Passport
- Malawi - Driver's License
- Mauritania - Identity Card
- Mauritania - Polycarbonate Passport
- Mexico - Social Security Card
- Mongolia - Paper Passport
- Mongolia - Polycarbonate Passport
- Namibia - Paper Passport
- Niger - Paper Passport
- Nigeria - Nin Card
- Papua New Guinea - Paper Passport
- Philippines - eID
- Philippines - MySSS Card
- Puerto Rico - Identity Card
- Saint Thomas And Prince - Paper Passport
- Saint Vincent And The Grenadines - Paper Passport
- Seychelles - Paper Passport
- Seychelles - Polycarbonate Passport
- South Sudan - Polycarbonate Passport
- Taiwan - Paper Passport
- Togo - Gendarmerie ID
- Togo - Military ID
- Togo - Police ID
- Togo - Residence Permit
- Togo - Voter ID
- Tonga - Paper Passport
- Yemen - Paper Passport
- Ghana - Health Insurance Card

#### New document versions for supported documents
- Afghanistan - Identity Card
- Cameroon - Identity Card
- Chile - Driver's License
- Colombia - Alien ID
- Costa Rica - Identity Card
- Malaysia - Driver's License
- Moldova - Identity Card
- Netherlands - Driver's License
- Panama - Driver's License
- South Korea - Driver's License
- South Korea - Identity Card
- Sweden - Driver's License
- UK - Polycarbonate Passport
- USA - Veteran ID
- USA, Alaska - Identity Card
- USA, California - Driver's License
- USA, California - Identity Card
- USA, North Carolina - Driver's License
- USA, Texas - Driver's License
- USA, Texas - Identity Card
- USA, Texas - Weapon Permit
- Vietnam - Driver's License
- Zimbabwe - Identity Card

#### New segments supported on documents
- Greece, Estonia, Finland, Hungary, Ireland, Latvia, Lithuania, Norway, Romania, Slovenia, Croatia, Slovakia, Poland, Malta, Austria, Luxembourg, Netherlands, Bulgaria, Portugal, Cyprus, Sweden, Czechia, Belgium, Germany, Italy, Spain, Switzerland, Denmark - Residence Permit: remarks, residencePermitType
- Belgium, Minors ID: added parentsInfo vector
- Nicaragua, Passport: barcode
- USA, Social Security Card: workRestriction
- China, Identity Card: permanentExpiry (Chinese)

### Minor API changes
- Added new items to enums:
  - new `FieldType` enum values: `effectiveDate`, `parentsLastName`, `parentsLastName2`, `parentsFirstName2`, `workRestriction`, `parentsFirstName`, `socialSecurityStatus`, `legalStatus`, `husbandName`, `chinPermanentExpiry`
  - new `DocumentType` enum values: `ninCard`, `mysssCard`, `gendarmerieId`, `policeId`
  - new `Country` enum value:`saintThomasAndPrince`
  - new `Region` enum values:`acre`,`espiritoSanto`,`matoGrossoDoSul`,`paraiba`,`piaui`,`rioGrandeDoNorte`,`tocantins`,`odisha`,`uttarakhand`

- Added member results to `ScanningResult` and `VizResult`
  - `effectiveDate`
  - `husbandName`
  - `legalStatus`
  - `socialSecurityStatus`
  - `workRestriction`
  - `parentsInfo` (new class)

## v7.6.1
- Updated to [Android SDK v7.6.1](https://github.com/microblink/blinkid-android/releases/tag/v7.6.1) and [iOS SDK v7.6.2](https://github.com/microblink/blinkid-ios/releases/tag/v7.6.2)

### What's New
- For some documents document type was returned as None, which was causing confusion. To prevent this, we are filling in document type from the barcode in case customers are using BarcodeId mode.
- The fix is applied to all the AAMVA types, plus some others (Argentina, Canada, Colombia, Nigeria, Panama, Paraguay, SouthAfrica)

## v7.6.0

- Updated to [Android SDK v7.6.0](https://github.com/microblink/blinkid-android/releases/tag/v7.6.0) and [iOS SDK v7.6.0](https://github.com/microblink/blinkid-ios/releases/tag/v7.6.0)

### What's New
- Added two new methods in `BlinkidFlutter`: `loadBlinkIdSdk` & `unloadBlinkIdSdk`
    - `loadBlinkIdSdk` - Initializes and loads the BlinkID SDK if it is not already loaded. This method can be called in advance to **preload** the SDK before starting a scanning session. Doing so reduces loading time for the `performScan` and `performDirectApiScan` methods since all resources will already be available and the license verified.
    - `unloadBlinkIdSdk` - Terminates the BlinkID SDK and releases all associated resources. This method safely shuts down the SDK instance and frees any allocated memory. If the parameter `deleteCachedResources` is set to `true`, the method performs a complete cleanup, including deletion of all downloaded and cached SDK resources from the device.
- You can now configure the SDK to load resources locally instead of downloading them. Set `downloadResources` to false, and provide the local resource path using `resourceLocalFolder` (Android) and `bundleIdentifier` (iOS).
- Added support for capturing the back of US and India passports that feature a barcode
- Prevent parsing of two-line MRZ in TD1 format unless it's explicitly allowed. This will prevent false positive MRZ extraction on documents where the last line of the MRZ is covered or not fully visible

### New Documents Support
- Angola - Paper Passport
- Bahrain - Polycarbonate Passport
- Burkina Faso - Polycarbonate Passport
- Cameroon - Driver's License
- Canada, Manitoba - Metis Federation Card
- East Timor - Polycarbonate Passport
- El Salvador - Paper Passport
- Eritrea - Paper Passport
- France - Adr Certificate
- Germany - Adr Certificate
- Ghana - Voter ID
- India, Telangana - Driver's License
- Ivory Coast - Paper Passport
- Japan - Polycarbonate Passport
- Liberia - Paper Passport
- Liberia - Voter ID
- Malawi - Identity Card
- Malawi - Paper Passport
- Maldives - Polycarbonate Passport
- Mali - Paper Passport
- Mauritius - Paper Passport
- Oman - Vehicle Registration
- Paraguay - Polycarbonate Passport
- Rwanda - Driver's License
- Senegal - Driver's License
- Sierra Leone - Paper Passport
- Somalia - Paper Passport
- Switzerland - Adr Certificate
- Togo - Driver's License
- Togo - Paper Passport
- USA, Maryland - Medical Marijuana ID
- Vietnam - Paper Passport

#### New Document Versions for Supported Documents
- Chile - Polycarbonate Passport
- India - Paper Passport
- Moldova - Identity Card
- Pakistan - Identity Card
- Peru - Identity Card
- Romania - Identity Card
- Slovakia - Identity Card
- USA, California - Driver's License
- USA, California - Identity Card
- USA, New Hampshire - Identity Card
- USA, Georgia - Medical Marijuana ID
- USA, Pennsylvania - Medical Marijuana ID
- USA, South Carolina - Driver's License
- USA, South Carolina - Identity Card
- USA, Texas - Driver's License
- USA, Texas - Identity Card

##### New Segments Supported on Documents
- Switzerland, Residence Permit - `dateOfEntry`
- Hungary, Identity Card - `maidenName`, `nationality`, `sexOrGender`, `documentNumber`, `dateOfBirth`
- Greece, Identity Card - `fathersName` (Latin and Greek), `mothersName` (Latin and Greek), `personalIdNumber`, `issuingAuthority` (Greek), `municipalityOfRegistration` (Greek)
- Mexico, Voter ID - `sectionCode`, `stateCode`, `municipalityCode`, `localityCode`
- Mexico, Consular Voter ID - `stateCode`, `stateName`

##### Renamed segments
- Hungary - Identity Card - `additionalNameInformation` -> `mothersName`

### New languages
- Added 33 new languages (see full list [here](https://github.com/microblink/blinkid-android?tab=readme-ov-file#-new-languages-v76))

### Breaking changes
- Renamed the `bundleURL` to `bundleIdentifier` in `BlinkIdSdkSettings`.
- Renamed `BlinkIdUiSettings` to `BlinkIdScanningUxSettings`.

### Native platform changes
**iOS**
- The SDK was built with Xcode 26

**Android**
- Updated Kotlin to `v2.0.21` in the `blinkid-core` library. The `blinkid-ux` and `microblink-ux` libraries already used Kotlin `v2.1.20`.
- Target SDK updated to API Level 36

### Bugfixes
- Users are no longer forced to scan back sides of Alien and Refugee passports
- Fixed the issue with Togo ID where document number from VIZ was overriden by a wrong value from MRZ

### Other changes
- Changed default `tiltDetectionLevel` from `Off` to `Mid`

## v7.5.0

- Updated to [Android SDK v7.5.0](https://github.com/microblink/blinkid-android/releases/tag/v7.5.0) and [iOS SDK v7.5.0](https://github.com/microblink/blinkid-ios/releases/tag/v7.5.0)

### What's New
- We introduced event tracking across the SDK lifecycle, giving you deeper insights into user journeys, success rates, and drop-off points during scanning sessions. These enhanced analytics make it easier to identify optimization opportunities and ensure the best possible user experience.
- Updated detection analysis logic in case of photo mode
- Added new `parsed` result member to the BarcodeResult which indicates whether the raw barcode data was successfully parsed
- Barcode recognition is now allowed on all document classes; unparsable barcodes will be returned as raw data

### Bugfixes
- Fixed crash when the optional `BlinkIdUiSettings` parameter was not being passed to the `performScan` method.

## v7.4.0
- Updated to [Android SDK v7.4.0](https://github.com/microblink/blinkid-android/releases/tag/v7.4.0) and [iOS SDK v7.4.0](https://github.com/microblink/blinkid-ios/releases/tag/v7.4.0)

#### New Documents Support
- Canada, Newfoundland And Labrador - Identity Card
- Canada, Northwest Territories - Driver's License
- Canada, Northwest Territories - Identity Card
- Canada, Prince Edward Island - Identity Card
- Canada, Yukon - Identity Card

#### New Document Versions for Supported Documents
- Canada, Yukon - Driver's License

**Bug fixes**
- Fixed issue with incorrect `DriverLicenseDetailedInfo` serialization

## 7.3.0
- Updated to [Android SDK v7.3.0](https://github.com/microblink/blinkid-android/releases/tag/v7.3.0) and [iOS SDK v7.3.1](https://github.com/microblink/blinkid-ios/releases/tag/v7.3.1)

### What's new
- Improved extraction for Canada/Nunavut ID and DL by introducing error correction for "1" and "I" characters which look the same in the font used on a document
- Added `BlinkIdUiSettings` for customizing various aspects of the UI used during the scanning process

#### New Documents Support
- Canada, Nunavut - Driver's License
- Canada, Nunavut - Identity Card
- Liberia - Identity Card
- Mali - Identity Card
- UK - Military ID

#### New Document Versions for Supported Documents
- Bahrain - Identity Card
- Canada - Weapon Permit
- Chile - Alien ID
- Chile - Identity Card
- Finland - Driver's License
- Indonesia - Driver's License
- Kosovo - Identity Card
- Latvia - Polycarbonate Passport
- Mexico, Chiapas - Driver's License
- Mexico, Ciudad de Mexico - Driver's License
- Mexico, Durango - Driver's License
- Mexico, Jalisco - Driver's License
- Sri Lanka - Driver's License
- USA, Alaska - Driver's License
- USA, New Hampshire - Driver's License
- European Union - Health Insurance Card

#### New Beta Documents Support
- Canada - Non Card Tribal ID
- Dominica - Paper Passport
- Dominica - Polycarbonate Passport
- UAE - Diplomatic ID
- USA, Georgia - Medical Marijuana ID

#### New Document Versions for Beta-Supported Documents
- Egypt - Driver's License
- Mexico, Quintana Roo - Driver's License
- Philippines - Postal ID
- Vietnam - Identity Card

#### New Segments Supported on Documents
- European Union, Health Insurance Card - `countryCode`
- Italy, Identity Card - `documentOptionalAdditionalNumber`
- France, Identity Card - `additionalNameInformation`
- UK, Asylum Request - `residencePermitType`, `remarks`
- UK, Residence Permit - `residencePermitType`, `remarks`, `certificateNumber`, `nationalInsuranceNumber`

#### Renamed segments
- Bahrain - Identity Card - `documentNumber` -> `personalIdNumber`

### Bugs and fixes
- Fixed document number extraction from Canada/Nunavut barcodes
- Fix for ARGENTINA ID and ALIEN_ID documents - made separate barcode scanning step optional for these documents; they have a barcode on the front side, and requiring barcode extraction was causing the scanning process to get stuck on the front
- Fixed issue with `DateResult` where `day`, `month` and `year` were not properly returned

#### iOS-specific
- Fixed issue with adding `customDocumentRules` in `BlinkIdScanningSettings`

## 7.2.0

The version 7 release of the BlinkID SDK.
- Updated to [Android SDK v7.2.0](https://github.com/microblink/blinkid-android/releases/tag/v7.2.0) and [iOS SDK v7.2.0](https://github.com/microblink/blinkid-ios/releases/tag/v7.2.0)
- For more information about the inital version 7 release, see the release notes for the native SDKs for [Android](https://github.com/microblink/blinkid-android/releases/tag/v7.0.0) and [iOS](https://github.com/microblink/blinkid-ios/releases/tag/v7.0.0).

## Breaking changes
- The plugin now requires:
    - iOS version 16.0 and above.
    - Android API version 24 and above.
    - Flutter version 3.29 and above.

- Class `MicroblinkScanner` has been renamed to `BlinkidFlutter`.
- Method `scanWithCamera` has been renamed to `performScan`.
- Method `scanWithDirectApi` has been renamed to `performDirectApiScan`.
- Many of the older settings have been renamed to be more intuitive, for more information see the [blinkid_settings.dart](https://github.com/microblink/blinkid-flutter/blob/master/BlinkID/lib/blinkid_settings.dart) file, and the native documentation for [Android](https://blinkid.github.io/blinkid-android/blinkid-core/com.microblink.blinkid.core/index.html) and [iOS](https://blinkid.github.io/blinkid-swift-package/documentation/blinkid/).
- See section **Version 7 plugin usage** for more details about how to use each method, and how to handle the scanned results.

## Version 7 plugin usage
**The `performScan` method**

The `performScan` method launches the BlinkID scanning process with the default UX properties.\
It takes the following parameters: 
1. BlinkID SDK settings
2. BlinkID session settings
3. The optional ClassFilter object for filtering documents.

**BlinkID SDK Settings** - `BlinkIdSdkSettings`: the class that contains all of the available SDK settings. It contains settings for the license key, and how the models, that the SDK needs for the scanning process, should be obtained.

**BlinkID Session Settings** - `BlinkIdSessionSettings`: the class that contains various settings for the scanning session. It contains the settings for the `ScanningMode` and `BlinkIdScanningSettings`, which define various parameters that control the scanning process.

The optional **ClassFilter** class - `ClassFilter`: the class which controls which documents will be accepted or reject for information extraction during the scanning session.

- The implementation of the `performScan` method can be viewed here in the [blinkid_flutter_method_channel.dart](https://github.com/microblink/blinkid-flutter/blob/master/BlinkID/lib/blinkid_flutter_method_channel.dart) file.

**The `performDirectApiScanning` method**

The `performDirectApiScan` method launches the BlinkID scanning process inteded for information extraction from static images.\
It takes the following parameters: 
1. BlinkID SDK settings
2. BlinkID session settings
3. First image string in the Base64 format
4. The optional second image string in the Base64 format

**BlinkID SDK Settings** - `BlinkIdSdkSettings`: the class that contains all of the available SDK settings. It contains settings for the license key, and how the models, that the SDK needs for the scanning process, should be obtained.

**BlinkID Session Settings** - `BlinkIdSessionSettings`: the class that contains various settings for the scanning session. It contains the settings for the [ScanningMode] and [BlinkIdScanningSettings], which define various parameters that control the scanning process.

The first image Base64 string - `String`: image that represents one side of the document. If the document contains two sides and the `ScanningMode` is set to `automatic`, this should contain the image of the front side of the document. In case the `ScanningMode` is set to `single`, it can be either the front or the back side of the document. If the document contains only one side (for example, various passports), the SDK will automatically detect it, and will not look for the other side.

The optional second image Base64 string - `String`: needed if the information from back side of the document is required and the `ScanningMode` is set to `automatic`.

- The implementation of the `performDirectApiScan` method can be viewed here in the [blinkid_flutter_method_channel.dart](https://github.com/microblink/blinkid-flutter/blob/master/BlinkID/lib/blinkid_flutter_method_channel.dart) file.
- All of the mentioned settings can be found in the [blinkid_settings.dart](https://github.com/microblink/blinkid-flutter/blob/master/BlinkID/lib/blinkid_settings.dart) file.

**BlinkID result**

- Both methods return the `BlinkIdScanningResult` object, which contains the results of scanning a document, including the extracted data and images from the document.

- All of the available results can be viewed [here](https://github.com/microblink/blinkid-flutter/blob/master/BlinkID/lib/blinkid_result.dart).

**Implementation guide**
- A detailed guide about the integration and usage of the plugin can be viewed [here](https://github.com/microblink/blinkid-flutter/tree/master?tab=readme-ov-file#plugin-integration).
- The sample application which demonstrates the usage of the SDK can be found in the [main.dart](https://github.com/microblink/blinkid-flutter/blob/master/sample_files/main.dart) file.

## 6.1.2
- Fixed date and `documentDataMatch` errors

## 6.1.1
- Updated to [Android SDK v6.1.1](https://github.com/microblink/blinkid-android/releases/tag/v6.1.1) and [iOS SDK v6.1.2](https://github.com/microblink/blinkid-ios/releases/tag/v6.1.2)

## 6.1.0
- Updated to [Android SDK v6.1.0](https://github.com/microblink/blinkid-android/releases/tag/v6.1.0) and [iOS SDK v6.1.1](https://github.com/microblink/blinkid-ios/releases/tag/v6.1.1)

## 5.8.1
- Fixed `documentDataMatch` serialization.

## 5.8.0
- Updated to [Android SDK v5.8.0](https://github.com/microblink/blinkid-android/releases/tag/v5.8.0) and [iOS SDK v5.8.0](https://github.com/microblink/blinkid-ios/releases/tag/v5.8.0)

## 5.7.1

### Major bug fix:

- This version fixes bug introduced in v5.7.0 which could cause SDK crash on `applicationDidBecomeActive` event.

## 5.7.0

### Plugin changes
- We changed the way BlinkID plugin is registered in Android so it no longer requires changing MainActivity. This fixes [Issue #2](https://github.com/microblink/blinkid-flutter/issues/2) and [Issue #5](https://github.com/microblink/blinkid-flutter/issues/5).

### New features
- We translated complete SDK to the following additional languages: **Malay**, **Dutch**, **Hungarian**, **Slovenian**, **Indonesian**, **Arabic(UAE)**, **Romanian**, **Chinese traditional**, **Chinese simplified**, **Thai**, **Hebrew**, **Vietnamese**, **Filipino**.

### Improvements to existing features:

- We have improved parsing of **MRZ** formats deviating from the ISO/IEC 7501 standard:
    - Document discriminator was in place of the document number on driver licenses and IDs from:
        - **New York**
        - **Michigan**
        - **Canada**
    - Different check digit calculation for **Mexico** (Consular) ID
    - Recognition of the unofficial `XCT` country code for Northern **Cyprus** ID
    - Recognition of different country codes and check digit calculation on **China** Mainland Travel Permit for Hong Kong and Macao Residents
- We added **anonymization** support for:
    - MRZ on the Mainland Travel Permit for Hong Kong and Macao Residents
- We have made some changes to the **BlinkID(Combined)Recognizer**
    - You can now see `ProcessingStatus` in the results to inspect potential processing errors, such as when barcode detection fails, a mandatory field is missing, etc.
    - You can now also see a more detailed `ImageAnalysisResult` showing you when:
        - Face image is detected
        - MRZ is detected
        - Barcode is detected
    - We added a `RecognitionModeFilter` settings group. You can toggle flags on this object to control the recognition mode of the recognizer:
        - `enableMrzId` lets you scan MRZ on all identity documents except visas and passports.
        - `enableMrzVisa` lets you scan MRZ on visa documents.
        - `enableMrzPassport` lets you scan MRZ on passports.
        - `enablePhotoId` lets you scan photo IDs. Use it to enable or disable document and face image extraction on unsupported documents.
        - `enableFullRecognition` lets you scan all data from our [supported](https://github.com/microblink/blinkid-android/blob/master/documentation/BlinkIDRecognizer.md) documents.
        - Your license key still controls which of the above recognition modes are allowed.
    - We have added a `RecognitionMode` result member describing which recognition mode was used to produce the results.
    -  We are now retrieving sex and nationality fields from the MRZ in cases where those two fields cannot be found in the document’s VIZ. Previously, we only used to do this for dates, name fields and document numbers.
    - We are now preserving the original string (raw data) of the dates we couldn’t parse.
- We have improved the thresholds for card detection feedback messages ("move closer" and "move farther"). This will improve the UX when scanning in landscape mode as the document can now be closer to the camera.

### Minor API Changes
- We have made some changes to the `BlinkIDRecognizer` and `BlinkIDCombinedRecognizer`:
    - We renamed `DocumentImageMoireStatus` to `ImageAnalysisDetectionStatus`
    - We grouped the `conditions` member from the results with the `DriverLicenseDetailedInfo` structure
- We renamed `RecogitionMode` to `RecognitionDebugMode` in `RecognizerBundle`.

### Bug fixes:
- We fixed an issue in default UI that was causing reticle to reappear while card flip animation was showing.

## 5.6.0

### New features:

- We have translated complete SDK to following languages: **Croatian**, **Czech**, **English**, **French**, **German**, **Italian**, **Portuguese**, **Slovak**, and **Spanish**.

- In `BlinkIdCombinedRecognizer` and `BlinkIdRecognizer` we added:
    - Support for US documents with **vertical** orientations:
        - Alabama DL
        - Arizona DL
        - California DL
        - Colorado DL
        - Connecticut DL
        - Georgia DL
        - Illinois DL
        - Iowa DL
        - Kansas DL
        - Kentucky DL
        - Maryland DL
        - Massachusetts DL
        - Minnesota DL
        - Missouri DL
        - New Jersey DL
        - Ohio DL
        - Pennsylvania DL
        - South Carolina DL
        - Tennessee DL
        - Texas DL
        - Utah DL
        - Washington DL
        - Wisconsin DL
    - Support for **new document types**:
        - Croatia Health Insurance Card / front side / BETA
        - Ecuador ID / front side
        - El Salvador ID / BETA
        - Sri Lanka ID / BETA
    - No longer BETA:
        - Canada Nova Scotia DL
        - Canada Yukon DL
        - Norway DL
    - Back side support:
        - Kenya ID
    - **Result anonymization** - with this option enabled, results are not returned for protected fields on certain documents. The full document image will also have this data blacked out.
        - Protected fields are:
         - Document number on Hong Kong ID
         - MRZ on Hong Kong passports
         - Personal ID number on Netherlands DL
         - Personal ID number and MRZ on Netherlands ID
         - MRZ on Netherlands passports
         - Document number on Singapore DL, ID, Fin Card, Resident ID
         - Personal ID number on Singapore Employment Pass
         - Document number and personal ID number on Singapore Work Permit
         - MRZ on Singapore passports
           - By using `anonymizationMode` property, you can choose the `AnonymizationMode`: `ImageOnly`, `ResultFieldsOnly`, `FullResult` or `None`.
        - `FullResult` anonymization (both images and data) is set by default.

- We added support for new **MRZ** formats:
    - Guatemala ID
    - Kenya ID

### Improvements to existing features:

- We updated `UsdlRecognizerResult` and `IdBarcodeRecognizer.Result` with additional address fields:
    - `street`, `postalCode`, `city` and `jurisdiction` 
- We added `expired` (in Swift `isExpired`) property to `BlinkIdRecognizerResult`, `BlinkIdCombinedRecognizerResult` and `IdBarcodeRecognizerResult`.
    - It compares the current time on the device with the date of expiry and checks whether the document has expired or not. 
- We made changes to the result structure of `BlinkIdCombinedRecognizer` and `BlinkIdRecognizer`:
    - Barcode data is now encapsulated in its own result structure: `BarcodeResult`.
    - Data from all OCR-ed fields, without MRZ data, is now encapsulated in a `VizResult` structure, representing the "Visual Inspection Zone" data. In `BlinkIdCombinedRecognizer`, front side data is available in its own structure (`frontVizResult`), back side data in its own (`backVizResult`), so you can now **access data from each side separately**.
    - The main part of the result, outside these structures, is filled according to these rules:
        - Document number is filled with data from the MRZ, if present.
        - Remaining data is then filled with barcode data.
        - Remaining data is filled from the back side's visual inspection zone (OCR data outside of MRZ).
        - Remaining data is filled from the front side's visual inspection zone.
        - Remaining data is filled with data from the MRZ.

### Minor API changes:

- We moved `BlinkIdRecognizerResult` members `colorStatus` and `moireStatus` to the result's `imageAnalysisResult` (`frontImageAnalysisResult` and `backImageAnalysisResult` in `BlinkIDCombinedRecognizerResult`).

### Bug fixes:

- We fixed US driver's license address extraction (Oregon, Mississippi, Rhode Island).
- We removed OpenGL entirely which was causing unexpected crashes.

## 5.5.0+1

Updated README for 5.5.0

## 5.5.0

### New features:

- In `BlinkIdCombinedRecognizer` and `BlinkIdRecognizer` we added:
    - Support for obtaining full document image for IDs with barcodes. Now you can capture document image and extract barcode data with a single scan.
    - Scanning & data extraction for  travel visas and passports.
    - Field validation - we validate if the results from certain fields match predefined character sets.
            - If validation fails, the recognizer's state is `RecognizerResultStateUncertain`.
            - Use `validateResultCharacters`to enable or disable validation.
    - Field anonymization for sensitive data.
            - Enable or disable whether certain sensitive data should be anonymized in full document image result.
            - Use `anonymizeImage` to enable or disable image anonymization.
    
    - Support for new document types:
        - Australia New South Wales - ID Card / Front only / BETA
        - Brazil - Driver License / BETA
        - Brunei - Military ID / BETA
        - Brunei - Residence Permit / BETA
        - Brunei - Temporary Residence Permit / BETA
        - Ghana - Driver License / Front only
        - Latvia - ID Card
        - Norway - Driving Licence / Front only / BETA
        - Oman - ID Card
        - Saudi Arabia - ID Card / BETA
        - Sweden - Social Security Card / Front only
        - USA - Social Security Card / BETA
        - Back side supported:
            - Malaysia - MyTentera

    - No longer BETA:
        - Australia Tasmania - Driving Licence
        - Canada British Columbia - ID Card
        - Germany - Residence Permit
        - Morocco - ID Card
        - Nigeria - Voter ID
        - Singapore - Work Permit
        - USA Alaska - ID Card
        - USA District Of Columbia - Driver License
        - USA Indiana - ID Card
        - USA Kentucky - ID Card
    
    - Barcode scanning on the following documents:
        - Argentina ID
        - Colombia ID
        - Nigeria Voter ID
        - South Africa ID

### Improvements for existing features:

- Improvements in `BlinkIdCombinedRecognizer` and `BlinkIdRecognizer`:
    - Documents discarded with the class filter are now reported as not supported
        -  `onDocumentSupportStatus` will be called if a documents is filtered out by the `classInfoFilter`.
    - For Malaysian MyKad we are now returning if a Moire pattern is present on the scanned document (detected or not detected).
        - use `documentImageMoireStatus` in `BlinkIdRecognizer`.
        - use `documentFrontImageMoireStatus` and `documentBackImageMoireStatus` in `BlinkIdCombinedRecognizer`.
- We added digital signature support to `PassportRecognizer`. 
- We updated `IdBarcodeRecognizerResult` with specific driving license info.
    - Use `restrictions`, `endorsements` and `vehicleClass`
