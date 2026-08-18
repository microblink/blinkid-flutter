<p align="center" >
  <img src="https://raw.githubusercontent.com/wiki/blinkid/blinkid-android/images/logo-microblink.png" alt="Microblink" title="Microblink">
</p>

# _BlinkID_ Flutter plugin

The BlinkID SDK is a comprehensive solution for implementing secure document scanning on the Flutter cross-platform.
It offers powerful capabilities for capturing and analyzing a wide range of identification documents. The Flutter plugin consists of BlinkID, which serves as the core module, and the BlinkIDUX package that provides a complete, ready-to-use solution with a user-friendly interface.

**Please note that, for maximum performance and full access to all features, it’s best to go with one of our native SDKs (for [iOS](https://github.com/microblink/blinkid-ios) or [Android](https://github.com/microblink/blinkid-android)).**

However, since the wrapper is open source, you can add the features you need on your own.

> **Current version:** `blinkid_flutter` **8001.0.0** (BlinkID SDK v8001).  
> If you are upgrading from v8000, see [What's new in v8001](#whats-new-in-v8001).  
> If you are upgrading from v7.x, see [Migrating from v7.x](#migrating-from-v7x) (then apply the v8001 notes).

# Table of contents
- [Licensing](#licensing)
- [Requirements](#requirements)
- [Quickstart with the sample application](#quickstart-with-the-sample-application)
- [Plugin integration](#plugin-integration)
- [Plugin usage](#plugin-usage)
- [Scanning modules](#scanning-modules)
- [Plugin specifics](#plugin-specifics)
  - [Scanning methods](#scanning-methods)
  - [SDK loading & unloading](#sdk-loading--unloading)
  - [BlinkID settings](#blinkid-settings)
  - [BlinkID results](#blinkid-results)
  - [Class filter & redaction](#class-filter--redaction)
- [What's new in v8001](#whats-new-in-v8001)
- [Migrating from v7.x](#migrating-from-v7x)
- [Additional information](#additional-information)

## <a name="licensing"></a> Licensing
A valid license key is required to initialize the BlinkID plugin. A free trial license key can be requested after registering at the [Microblink Developer Hub](https://developer.microblink.com/).

## <a name="requirements"></a> Requirements

|     Requirement     |        Flutter         |          iOS           |        Android         |
|:-------------------:|:----------------------:|:----------------------:|:----------------------:|
|   OS/API version    | Flutter 3.44 and newer |   iOS 16.0 and newer   | API level 24 and newer |
| Compile SDK version |           —            |           —            |      36 and newer      |
|   Kotlin version    |           —            |           —            |    2.2.21 and newer    |
|     AGP version     |           —            |           —            |    9.1.0 and newer     |
|   Camera quality    |—                       |At least 1080p          |     At least 1080p     | 

See [Plugin integration](#plugin-integration) for more details.

For additional help with the Flutter setup, view the official [documentation](https://flutter.dev/docs).

For more detailed information about the BlinkID Android and iOS requirements, view the native SDK documentation here ([Android](https://github.com/microblink/blinkid-android?tab=readme-ov-file#-device-requirements) & [iOS](https://github.com/microblink/blinkid-ios?tab=readme-ov-file#requirements)).

## <a name="quickstart-with-the-sample-application"></a> Quickstart with the sample application
The sample application demonstrates how the BlinkID plugin is implemented and how to obtain scanned results. It contains the implementation for:

1. **Camera scanning (`performScan`)** — default BlinkID UX with configurable scanning modules.
2. **DirectAPI MultiSide scanning** — extract document information from two static images (gallery).
3. **DirectAPI SingleSide scanning** — extract document information from a single static image (gallery).

The sample UI lets you toggle and configure each scanning module (Document Capture, Barcode, MRZ, VIZ), session timeouts, UX options, class filter, and redaction — the same settings you would configure in your own app.

To obtain and run the sample application, follow the steps below:

1. Git clone the repository:
```bash
git clone https://github.com/microblink/blinkid-flutter.git
```
2. Position to the obtained BlinkID folder and run the `initBlinkIdFlutterSample.sh` script:
```bash
cd blinkid-flutter && ./initBlinkIdFlutterSample.sh
```
3. After the script finishes running, position to the `sample` folder and run the `flutter run` command:
```bash
cd sample && flutter run
```
4. Pick the platform to run the BlinkID plugin on.

Note: the plugin can be run directly via Xcode (iOS) and Android Studio (Android):
1. Open the `Runner.xcodeproj` in the path: `sample/ios/Runner.xcodeproj` to run the iOS sample application.
2. Open the `android` folder via Android Studio in the `sample` folder to run the Android sample application.

**Sample app on iOS additional instructions**
- Error: `Module 'blinkid-flutter' not found`

If you are getting the error above when running the sample application, this usually means that support for Swift Package Manager was not enabled in the Flutter configuration. Simply run the following command to enable it:
```bash
flutter config --enable-swift-package-manager
```
After this, try to run the sample application again.

- Error: `FlutterGeneratedPluginSwiftPackage has a lower minimum deployment target`

To resolve the issue with the minimum deployment target for the `FlutterGeneratedPluginSwiftPackage` package, do the following:
1. Exit Xcode
2. Run the following command:
```bash
flutter build ios --config-only
```
3. Run the sample application

This should properly configure the minimum deployment target of the package.

## <a name="plugin-integration"></a> Plugin integration

### 1. Create or open your Flutter project
```bash
flutter create project_name
```

### 2. Enable Swift Package Manager (iOS)
The native BlinkID iOS SDK is distributed via Swift Package Manager. Enable Flutter SPM support:
```bash
flutter config --enable-swift-package-manager
```

### 3. Add the dependency
Add `blinkid_flutter` to your `pubspec.yaml`:
```yaml
dependencies:
  ...
  blinkid_flutter: ^8001.0.0
```

Then install:
```bash
flutter pub get
```

### 4. Android — minimum SDK and Kotlin version
The BlinkID SDK requires API level **24** or newer. In `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdk = 24
    }
}
```

In `android/settings.gradle.kts`, update the Android Gradle Plugin (AGP) and Kotlin versions to match BlinkID requirements:

```kotlin
id("com.android.application") version "9.1.0" apply false
id("org.jetbrains.kotlin.android") version "2.2.21" apply false
```

No Jetpack Compose setup is required in your app. The plugin uses BlinkID's Activity-based scanning flow (`MbBlinkIdScan`); Compose runtime libraries are resolved transitively through the plugin. If your app already uses Compose for its own UI, you can keep your existing Compose configuration — the plugin does not declare a Compose BOM.

### 5. iOS — permissions and deployment target
Set the minimum iOS deployment target to **16.0** in your Xcode project (or `ios/Podfile` / `IPHONEOS_DEPLOYMENT_TARGET` in xcconfig files).

Add the following keys to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for BlinkID document scanning</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required for BlinkID DirectAPI scanning</string>
```

After changing the deployment target, run:
```bash
flutter build ios --config-only
```

## <a name="plugin-usage"></a> Plugin usage

### 1. Import the plugin
```dart
import 'package:blinkid_flutter/blinkid_flutter.dart';
```

### 2. Create a plugin instance
```dart
final blinkIdPlugin = BlinkIdFlutter();
```

### 3. Configure SDK, session, and module settings
```dart
import 'dart:io';

// Platform-specific license key
var sdkLicenseKey = "";
if (Platform.isAndroid) {
  sdkLicenseKey = "android-license-key";
} else if (Platform.isIOS) {
  sdkLicenseKey = "ios-license-key";
}

// SDK initialization settings
final sdkSettings = BlinkIdSdkSettings(
  licenseKey: sdkLicenseKey,
  resourcesConfig: ResourcesConfig(download: true),
);

// Scanning modules — enable only what your use case needs, for example
final scanningSettings = BlinkIdScanningSettings(
  documentCaptureModule: DocumentCaptureModuleSettings(
    documentImageReturnEnabled: true,
    faceImageExtractionEnabled: true,
    inputImageReturnEnabled: false,
  ),
  mrzModule: MrzModuleSettings(),
  barcodeModule: BarcodeModuleSettings(),
  vizModule: VizModuleSettings(
    signatureImageExtractionEnabled: true,
  ),
);

// Session settings
final sessionSettings = BlinkIdSessionSettings(
  scanningMode: ScanningMode.automatic,
  scanningSettings: scanningSettings,
  stepTimeoutDuration: 60000,       // ms per scanning step (0 = no timeout)
  inactivityTimeoutDuration: 10000, // ms of UI inactivity (0 = disabled)
);

// Optional UX customization (camera scanning only)
final uxSettings = BlinkIdScanningUxSettings(
  showHelpButton: true,
  showOnboardingDialog: true,
  allowHapticFeedback: true,
  preferredCamera: PreferredCamera.back,
);

// Optional document class filter
final classFilter = ClassFilter()
  ..includeDocuments = [
    DocumentFilter(country: CountryID.usa),
    DocumentFilter(
      country: CountryID.usa,
      region: RegionID.california,
      documentType: DocumentTypeID.id,
    ),
  ];
```

> **Tip:** Set a module to `null` (or omit it) to disable that module entirely. For example, an MRZ-only passport flow can use `BlinkIdScanningSettings(mrzModule: MrzModuleSettings())` with all other modules omitted.

### 4. Scan and handle results
```dart
try {
  final result = await blinkIdPlugin.performScan(
    blinkIdSdkSettings: sdkSettings,
    blinkIdSessionSettings: sessionSettings,
    blinkidScanningUxSettings: uxSettings,
    classFilter: classFilter,
    redactionSettingsResolver: redactionSettingsResolver
  );

  if (result != null) {
    print(result.firstName?.value);
    print(result.firstDocumentImage); // Base64, if document capture returned images
  }
} on PlatformException catch (e) {
  print("BlinkID scanning error: ${e.message}");
}
```

### DirectAPI (static images)
```dart
final result = await blinkIdPlugin.performDirectApiScan(
  blinkIdSdkSettings: sdkSettings,
  blinkIdSessionSettings: sessionSettings,
  firstImage: frontImageBase64,
  secondImage: backImageBase64, // optional; required for automatic two-sided scan
);
```

- The full integration example is in [`sample_files/main.dart`](sample_files/main.dart).
- Module configuration patterns are in [`sample_files/scanning_modules_config.dart`](sample_files/scanning_modules_config.dart).
- Result parsing examples are in [`sample_files/blinkid_result_builder.dart`](sample_files/blinkid_result_builder.dart).

## <a name="scanning-modules"></a> Scanning modules

In v8000, scanning behavior is controlled through four independent modules configured on `BlinkIdScanningSettings`:

| Module | Class | Purpose |
|:-------|:------|:--------|
| **Document Capture** | `DocumentCaptureModuleSettings` | Document detection, cropping, image quality checks (blur, glare, tilt, lighting, hand occlusion), face image extraction, and document image return. |
| **MRZ** | `MrzModuleSettings` | Machine Readable Zone detection and parsing (passports, visas, ID cards). |
| **Barcode** | `BarcodeModuleSettings` | 1D/2D barcode detection and parsing (PDF417, QR, retail codes, etc.). Can run standalone or alongside document capture. |
| **VIZ** | `VizModuleSettings` | Visual Inspection Zone field extraction, character validation, signature image extraction, and multi-frame result aggregation. |

### Common module combinations

**Full ID scan (default-like behavior)** — enable all four modules:
```dart
BlinkIdScanningSettings(
  documentCaptureModule: DocumentCaptureModuleSettings(),
  mrzModule: MrzModuleSettings(),
  barcodeModule: BarcodeModuleSettings(),
  vizModule: VizModuleSettings(),
)
```

**Passport MRZ only:**
```dart
BlinkIdScanningSettings(
  documentCaptureModule: DocumentCaptureModuleSettings(
    passportDataPageScanOnly: true,
  ),
  mrzModule: MrzModuleSettings(),
)
```

**Standalone barcode scanning** — disable document capture; enable only barcode formats you need:
```dart
BlinkIdScanningSettings(
  barcodeModule: BarcodeModuleSettings(
    pdf417ScanningEnabled: true,
    qrScanningEnabled: true,
  ),
)
```

> **Note:** Retail barcode formats (UPC, EAN, Code128, etc.) can only be enabled when document capture is disabled. PDF417 and QR must be enabled together — the analyzer treats them as a single detection stage.

### Image and quality settings
Image return, DPI, blur/glare rejection, and related options now live on `DocumentCaptureModuleSettings` and `VizModuleSettings` instead of the removed `CroppedImageSettings` class from v7.

Key document capture settings:
- `documentImageReturnEnabled` / `inputImageReturnEnabled` — return cropped or raw input images in the result.
- `faceImageExtractionEnabled` / `faceImagePresenceMandatory` — control face photo extraction.
- `blurSensitivityLevel`, `glareSensitivityLevel`, `tiltSensitivityLevel` — use `SensitivityLevel` (`off`, `low`, `mid`, `high`).
- `imageWithBlurRejected`, `imageWithGlareRejected`, etc. — reject or accept frames with quality issues.
- `cropType` — `InputImageCropType.notCropped` (default; camera + DirectAPI), `unknown`, or `cropped`. `cropped` / `unknown` are **DirectAPI only**; camera `performScan` requires `notCropped`.
- `inputImageSelectionStrategy` — camera / video frame selection (`balanced` default).

Key barcode settings:
- `aztecScanningEnabled` — enable Aztec barcodes (default `false`).

Key VIZ settings:
- `signatureImageExtractionEnabled` — extract signature images when supported.
- `characterValidationEnabled` — validate extracted characters against expected field rules.
- `resultAggregationEnabled` — aggregate data across video frames (camera scanning only).

## <a name="plugin-specifics"></a> Plugin specifics
The BlinkID plugin implementation is located in the `BlinkID/lib` folder, while platform-specific implementation is located in the `BlinkID/android` and `BlinkID/ios` folders.

### <a name="scanning-methods"></a> Scanning methods
The BlinkID plugin exposes two scanning methods and two lifecycle methods.

#### `performScan`
Launches camera scanning with the BlinkID UX.

| Parameter | Type | Required | Description |
|:----------|:-----|:--------:|:------------|
| `blinkIdSdkSettings` | `BlinkIdSdkSettings` | Yes | License key, nested `resourcesConfig` / optional `otaResourcesConfig`, proxy URL. |
| `blinkIdSessionSettings` | `BlinkIdSessionSettings` | Yes | Scanning mode, module settings, and timeouts. |
| `blinkidScanningUxSettings` | `BlinkIdScanningUxSettings` | No | Help button, onboarding, haptics, preferred camera. |
| `classFilter` | `ClassFilter` | No | Accept or reject specific document classes. |
| `redactionSettingsResolver` | `RedactionSettingsResolver` | No | Per-document redaction rules applied before the result is finalized. |

Returns `Future<BlinkIdScanningResult?>`.

Implementation: [`BlinkID/lib/src/blinkid_flutter_method_channel.dart`](BlinkID/lib/src/blinkid_flutter_method_channel.dart)

#### `performDirectApiScan`
Extracts data from one or two Base64-encoded static images.

| Parameter | Type | Required | Description |
|:----------|:-----|:--------:|:------------|
| `blinkIdSdkSettings` | `BlinkIdSdkSettings` | Yes | License key, nested `resourcesConfig` / optional `otaResourcesConfig`, proxy URL. |
| `blinkIdSessionSettings` | `BlinkIdSessionSettings` | Yes | Scanning mode and module settings. |
| `firstImage` | `String` | Yes | Base64 image of the first document side. |
| `secondImage` | `String` | No | Base64 image of the second side (for `ScanningMode.automatic`). |
| `redactionSettings` | `RedactionSettings` | No | Static redaction settings for this scan. |

Returns `Future<BlinkIdScanningResult?>`.

For `ScanningMode.automatic`, `firstImage` should be the front side and `secondImage` the back side. For `ScanningMode.single`, `firstImage` can be either side. Single-sided documents (e.g. passports) are detected automatically.

### <a name="sdk-loading--unloading"></a> SDK loading & unloading

#### `loadBlinkIdSdk`
Initializes and loads the BlinkID SDK if not already loaded (resource download, license verification). Call before scanning to reduce first-scan latency:
```dart
await blinkIdPlugin.loadBlinkIdSdk(blinkidSdkSettings: sdkSettings);
```

If not called explicitly, loading happens automatically when a scan starts.

#### `unloadBlinkIdSdk`
Terminates the SDK and releases resources. Must call `loadBlinkIdSdk` (or start a new scan) before scanning again:
```dart
await blinkIdPlugin.unloadBlinkIdSdk(deleteCachedResources: false);
```

Set `deleteCachedResources: true` to also delete downloaded SDK models from device storage.

This method is automatically called after each successful scan session.

### <a name="blinkid-settings"></a> BlinkID Settings

| Setting class | Description |
|:--------------|:------------|
| [`BlinkIdSdkSettings`](BlinkID/lib/src/blinkid_settings.dart) | License key, nested `resourcesConfig` / optional `otaResourcesConfig`, proxy URL. |
| [`BlinkIdSessionSettings`](BlinkID/lib/src/blinkid_settings.dart) | `ScanningMode`, `BlinkIdScanningSettings`, step and inactivity timeouts. |
| [`BlinkIdScanningSettings`](BlinkID/lib/src/blinkid_settings.dart) | Module settings and `maxAllowedMismatchesPerField`. |
| [`DocumentCaptureModuleSettings`](BlinkID/lib/src/types.dart) | Document detection, image quality, face/document image return. |
| [`MrzModuleSettings`](BlinkID/lib/src/types.dart) | MRZ presence requirement. |
| [`BarcodeModuleSettings`](BlinkID/lib/src/types.dart) | Barcode format toggles and image return. |
| [`VizModuleSettings`](BlinkID/lib/src/types.dart) | VIZ extraction, validation, signature return. |
| [`BlinkIdScanningUxSettings`](BlinkID/lib/src/blinkid_settings.dart) | UX customization for camera scanning. |

Each Dart file documents available properties in detail. Native equivalents:
- [Android SDK documentation](https://microblink.github.io/blinkid-android/blinkid-core/com.microblink.blinkid.core/index.html)
- [iOS SDK documentation](https://microblink.github.io/blinkid-swift-package/documentation/blinkid/)

Native deserialization implementations:
- [Android](BlinkID/android/src/main/kotlin/com/microblink/blinkid/flutter/BlinkidDeserializationUtils.kt)
- [iOS](BlinkID/ios/blinkid_flutter/Sources/blinkid_flutter/BlinkidDeserializationUtils.swift)

### <a name="blinkid-results"></a> BlinkID Results

The scanning result is a `BlinkIdScanningResult` containing merged document-level fields and per-side detail.

**Top-level result** — aggregated fields such as `firstName`, `lastName`, `documentNumber`, `dateOfBirth`, `dateOfExpiry`, and images:
- `firstDocumentImage` / `secondDocumentImage` — cropped document images (Base64).
- `faceImage` / `signatureImage` — `DetailedCroppedImageResult` with image data and metadata.
- `firstInputImage` / `secondInputImage` / `barcodeInputImage` — raw input frames when enabled.
- `documentClassInfo` — nested `country` / `region` / `documentType` (`id?`, `rawValue`), plus country name / ISO codes.
- `dataMatchResult` — cross-side data match status.

**Per-side detail** — `subResults` is a `List<SingleSideScanningResult>`, one entry per scanned side. Each side contains:
- `viz` — `VizResult` with visual field data.
- `mrz` — `MrzResult` with MRZ parsed fields.
- `barcode` — `BarcodeResult` with barcode data.
- `documentImage`, `faceImage`, `signatureImage`, `inputImage` — side-specific images.

Field values use `StringResult` (with `value`, `latin`, `arabic`, etc.) and `DateResult` wrappers — access the extracted text via `.value`.

See [`BlinkID/lib/src/blinkid_result.dart`](BlinkID/lib/src/blinkid_result.dart) for the full result model.

Native result documentation:
- [Android](https://microblink.github.io/blinkid-android/blinkid-core/com.microblink.blinkid.core.session/-blink-id-scanning-result/index.html)
- [iOS](https://microblink.github.io/blinkid-swift-package/documentation/blinkid/blinkidscanningresult)

Native serialization implementations:
- [Android](BlinkID/android/src/main/kotlin/com/microblink/blinkid/flutter/BlinkidSerializationUtils.kt)
- [iOS](BlinkID/ios/blinkid_flutter/Sources/blinkid_flutter/BlinkidSerializationUtils.swift)

### <a name="class-filter--redaction"></a> Class filter & redaction

#### Class filter
Restrict which documents are accepted during camera scanning:
```dart
final filter = ClassFilter()
  ..includeDocuments = [DocumentFilter(country: CountryID.canada)]
  ..excludeDocuments = [
    DocumentFilter(country: CountryID.usa, documentType: DocumentTypeID.passport),
  ];
```

If `includeDocuments` is empty, all documents are accepted unless excluded. Rules can specify any combination of `country`, `region`, and `documentType` (`CountryID` / `RegionID` / `DocumentTypeID`).

#### Redaction
Redaction replaces or removes sensitive data from results and/or document images.

For **camera scanning**, pass a `RedactionSettingsResolver` with a list of `RedactionSettings` entries. The SDK picks the first entry whose `documentFilter` matches the scanned document:
```dart
final resolver = RedactionSettingsResolver([
  RedactionSettings(
    mode: RedactionMode.fullResult,
    fields: [FieldType.firstName, FieldType.lastName],
    documentNumberRedactionSettings: DocumentNumberRedactionSettings(
      prefixDigitsVisible: 0,
      suffixDigitsVisible: 4,
    ),
    documentFilter: [
      DocumentFilter(country: CountryID.usa, region: RegionID.california),
    ],
  ),
]);
```

For **DirectAPI scanning**, pass a single `RedactionSettings` object directly to `performDirectApiScan`.

`RedactionMode` values: `none`, `imageOnly`, `resultFieldsOnly`, `fullResult`.

## <a name="whats-new-in-v8001"></a> What's new in v8001

BlinkID v8001 builds on the modular architecture from v8000 with faster document support (including OTA resources), better frame selection, DirectAPI crop handling, Aztec barcodes, and nested document class info.

Highlights for Flutter:

| Area | Change |
| --- | --- |
| **SDK settings** | Flat resource fields → nested `resourcesConfig`; new optional `otaResourcesConfig` |
| **Document class info** | `country` / `region` / `documentType` are `{ id?, rawValue }` (filters still use flat `CountryID` / `RegionID` / `DocumentTypeID`) |
| **Document capture** | `inputImageCropped` → `cropType`; added `inputImageSelectionStrategy` |
| **Barcode** | `aztecScanningEnabled` |
| **Results** | `ethnicity`; `ParentInfo.fullName`; `FieldType.ethnicity` / `parentFullName` |

#### Migrating SDK settings from v8000

```dart
// v8000
final sdkSettings = BlinkIdSdkSettings(
  licenseKey: licenseKey,
  downloadResources: true,
);

// v8001
final sdkSettings = BlinkIdSdkSettings(
  licenseKey: licenseKey,
  resourcesConfig: ResourcesConfig(download: true),
  otaResourcesConfig: OtaResourcesConfig(
    checkForUpdates: true, // default
    strict: false,         // default — set true to fail init on OTA download errors
  ),
);
```

| v8000 (flat) | v8001 |
| --- | --- |
| `downloadResources` | `resourcesConfig.download` |
| `resourceDownloadUrl` | `resourcesConfig.serviceUrl` |
| `resourceLocalFolder` | `resourcesConfig.localFolder` |
| `resourceRequestTimeout` | `resourcesConfig.requestTimeout` ([`RequestTimeout`](BlinkID/lib/src/blinkid_settings.dart), milliseconds) |
| `bundleIdentifier` | `resourcesConfig.bundleIdentifier` (iOS) |

Do **not** cross-wire hosts: base resources use `https://models.cdn.microblink.com/resources`; OTA uses `https://blinkid-ota.microblink.com`.

#### Resource download timeouts

`resourcesConfig.requestTimeout` and `otaResourcesConfig.requestTimeout` accept a [`RequestTimeout`](BlinkID/lib/src/blinkid_settings.dart) object (milliseconds). Omit `requestTimeout` to use native defaults (30 seconds per timeout on current BlinkID native SDKs).

```dart
resourcesConfig: ResourcesConfig(
  download: true,
  requestTimeout: RequestTimeout.all(30000), // same value for connection, write, read
),

otaResourcesConfig: OtaResourcesConfig(
  requestTimeout: RequestTimeout(
    connectionTimeoutMilliseconds: 30000,
    readTimeoutMilliseconds: 60000,
  ), // write timeout uses native default when omitted
),
```

#### Migrating document capture settings

```dart
// v8000
DocumentCaptureModuleSettings(inputImageCropped: true)

// v8001 — DirectAPI only for cropped/unknown
DocumentCaptureModuleSettings(cropType: InputImageCropType.cropped)
// or InputImageCropType.unknown / InputImageCropType.notCropped
```

Camera UX (`performScan`) must use `InputImageCropType.notCropped`.

#### Document class info in results

```dart
final countryId = result.documentClassInfo?.country?.id;        // CountryID when known
final countryRaw = result.documentClassInfo?.country?.rawValue; // set when country is present
```

Full changelog (documents, bug fixes, API details): [Release notes.md](https://github.com/microblink/blinkid-flutter/blob/master/Release%20notes.md) and [platform release notes](https://docs.microblink.com/blinkid/release-notes).

## <a name="migrating-from-v7x"></a> Migrating from v7.x

If you are upgrading from BlinkID Flutter **v7**, the following changes apply:

| v7.x | v8000.0.0                                                                        |
|:-----|:---------------------------------------------------------------------------------|
| Flat scanning settings (`glareDetectionLevel`, `CroppedImageSettings`, etc.) | Module-based settings on `BlinkIdScanningSettings`                               |
| `BlinkIdUiSettings` | `BlinkIdScanningUxSettings`                                                      |
| Positional method arguments | Named parameters on `performScan` / `performDirectApiScan`                       |
| `BlinkIdSdkSettings(sdkLicenseKey)` constructor | `BlinkIdSdkSettings(licenseKey: sdkLicenseKey)`                                  |
| `ClassFilter.withIncludedDocumentClasses([...])` | `ClassFilter()..includeDocuments = [...]`                                        |
| Anonymization settings | `RedactionSettings` / `RedactionSettingsResolver`                                |
| Android: no Compose requirement | Android: no Compose requirement in your app (BlinkID UX uses Compose internally) |

Detailed migration guide done for native platforms can be found [here](https://docs.microblink.com/blinkid/migration-v8000).

**Settings migration examples:**

```dart
// v7 — image return via CroppedImageSettings
scanningSettings.croppedImageSettings = CroppedImageSettings(
  returnDocumentImage: true,
  returnFaceImage: true,
);

// v8000 — image return via DocumentCaptureModuleSettings
scanningSettings.documentCaptureModule = DocumentCaptureModuleSettings(
  documentImageReturnEnabled: true,
  faceImageExtractionEnabled: true,
);
```

```dart
// v7
await blinkIdPlugin.performScan(sdkSettings, sessionSettings, uiSettings);

// v8000
await blinkIdPlugin.performScan(
  blinkIdSdkSettings: sdkSettings,
  blinkIdSessionSettings: sessionSettings,
  blinkidScanningUxSettings: uxSettings,
);
```

Review the [scanning modules](#scanning-modules) section and the sample app configuration files to map your v7 settings to the appropriate v8000 modules.

After migrating from v7 to the modular API, also apply [What's new in v8001](#whats-new-in-v8001) (nested `resourcesConfig` / OTA, `cropType`, nested class info).

## <a name="additional-information"></a> Additional information
For any additional questions and information, feel free to contact us [here](https://help.microblink.com), or directly to the Support team via mail support@microblink.com.
