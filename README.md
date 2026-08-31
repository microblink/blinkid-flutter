<p align="center" >
  <img src="https://raw.githubusercontent.com/wiki/blinkid/blinkid-android/images/logo-microblink.png" alt="Microblink" title="Microblink">
</p>

# _BlinkID_ Flutter plugin

The BlinkID SDK is a comprehensive solution for implementing secure document scanning on the Flutter cross-platform.
It offers powerful capabilities for capturing and analyzing a wide range of identification documents. The Flutter plugin consists of BlinkID, which serves as the core module, and the BlinkIDUX package that provides a complete, ready-to-use solution with a user-friendly interface.

**Please note that, for maximum performance and full access to all features, it’s best to go with one of our native SDKs (for [iOS](https://github.com/microblink/blinkid-ios) or [Android](https://github.com/microblink/blinkid-android)).**

However, since the wrapper is open source, you can add the features you need on your own.

# Table of contents
- [Licensing](#licensing)
- [Requirements](#requirements)
- [Quickstart with the sample application](#quickstart-with-the-sample-application)
- [Plugin integration](#plugin-integration)
- [Plugin usage](#plugin-usage)
- [Scanning modules](#scanning-modules)
- [Plugin specifics](#plugin-specifics)
  - [Scanning methods](#scanning-methods)
    - [performScan](#performscan)
    - [performDirectApiScan](#performdirectapiscan)
    - [Custom scanner UI](#custom-scanner-ui)
  - [SDK loading & unloading](#sdk-loading--unloading)
  - [BlinkID settings](#blinkid-settings)
  - [BlinkID results](#blinkid-results)
  - [Class filter & redaction](#class-filter--redaction)
  - [Customizing performScan strings](#customizing-performscan-strings)
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
4. **Custom scanner UI** — a fully custom Flutter overlay built on top of `BlinkIdScannerView`, demonstrating guidance text, flip animation, scan timeout, and retry logic.

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
  blinkid_flutter: ^8000.0.0
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

The plugin's own manifest declares `android.permission.CAMERA` (merged into your app's manifest automatically) — you do not need to add it yourself. The plugin requests it at runtime before starting the camera (both `performScan` and `BlinkIdScannerView`); see [Camera permission](#camera-permission) under Custom scanner UI for the denial-handling flow.

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
  downloadResources: true
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
    DocumentFilter(country: Country.usa),
    DocumentFilter(
      country: Country.usa,
      region: Region.california,
      documentType: DocumentType.id,
    ),
  ];
```

> **Tip:** Leave a module **unset** for the SDK default (enabled). Set it explicitly to **`null`** to disable that module entirely — omitting it is not the same as disabling it. For example, an MRZ-only passport flow must null out the other three: `BlinkIdScanningSettings(mrzModule: MrzModuleSettings(), documentCaptureModule: null, barcodeModule: null, vizModule: null)`.

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
  barcodeModule: null, // explicitly disabled — see the Tip above
  vizModule: null,
)
```

**Standalone barcode scanning** — disable document capture; enable only barcode formats you need:
```dart
BlinkIdScanningSettings(
  documentCaptureModule: null, // required: retail formats need capture disabled
  barcodeModule: BarcodeModuleSettings(
    pdf417ScanningEnabled: true,
    qrScanningEnabled: true,
  ),
  mrzModule: null,
  vizModule: null,
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
- `inputImageCropped` — for DirectAPI only; set to `true` when input images are already cropped.

Key VIZ settings:
- `signatureImageExtractionEnabled` — extract signature images when supported.
- `characterValidationEnabled` — validate extracted characters against expected field rules.
- `resultAggregationEnabled` — aggregate data across video frames (camera scanning only).

## <a name="plugin-specifics"></a> Plugin specifics
The BlinkID plugin implementation is located in the `BlinkID/lib` folder, while platform-specific implementation is located in the `BlinkID/android` and `BlinkID/ios` folders.

### <a name="scanning-methods"></a> Scanning methods
The BlinkID plugin exposes two camera scanning methods, a custom scanner widget, and two lifecycle methods.

#### <a name="performscan"></a> `performScan`
Launches camera scanning with the built-in BlinkID UX.

| Parameter | Type | Required | Description |
|:----------|:-----|:--------:|:------------|
| `blinkIdSdkSettings` | `BlinkIdSdkSettings` | Yes | License key and resource download settings. |
| `blinkIdSessionSettings` | `BlinkIdSessionSettings` | Yes | Scanning mode, module settings, and timeouts. |
| `blinkidScanningUxSettings` | `BlinkIdScanningUxSettings` | No | Help button, onboarding, haptics, preferred camera. |
| `classFilter` | `ClassFilter` | No | Accept or reject specific document classes. |
| `redactionSettingsResolver` | `RedactionSettingsResolver` | No | Per-document redaction rules applied before the result is finalized. |

Returns `Future<BlinkIdScanningResult?>`.

Implementation: [`BlinkID/lib/src/blinkid_flutter_method_channel.dart`](BlinkID/lib/src/blinkid_flutter_method_channel.dart)

#### <a name="performdirectapiscan"></a> `performDirectApiScan`
Extracts data from one or two Base64-encoded static images.

| Parameter | Type | Required | Description |
|:----------|:-----|:--------:|:------------|
| `blinkIdSdkSettings` | `BlinkIdSdkSettings` | Yes | License key and resource download settings. |
| `blinkIdSessionSettings` | `BlinkIdSessionSettings` | Yes | Scanning mode and module settings. |
| `firstImage` | `String` | Yes | Base64 image of the first document side. |
| `secondImage` | `String` | No | Base64 image of the second side (for `ScanningMode.automatic`). |
| `redactionSettings` | `RedactionSettings` | No | Static redaction settings for this scan. |

Returns `Future<BlinkIdScanningResult?>`.

For `ScanningMode.automatic`, `firstImage` should be the front side and `secondImage` the back side. For `ScanningMode.single`, `firstImage` can be either side. Single-sided documents (e.g. passports) are detected automatically.

#### <a name="custom-scanner-ui"></a> Custom scanner UI

`BlinkIdScannerView` is a Flutter platform view that gives you complete control over the scanning UI. Use it when you need custom strings, branding, animations, or any overlay behavior that `performScan` does not expose.

##### Key classes

| Class | Description |
|:------|:------------|
| `BlinkIdScannerController` | `ChangeNotifier` that manages scan state, phase, and guidance. Create one instance per scan screen. |
| `BlinkIdScannerView` | Platform view widget that renders the camera surface. Mount it once the controller is initialized. |
| `BlinkIdScannerStatus` | Scan lifecycle: `uninitialized` → `loadingSdk` → `initializing` → `ready` → `scanning` → `processing` → `done` (or `error`, or `cameraPermissionRequired` — see [Camera permission](#camera-permission)). |
| `BlinkIdScanPhase` | Current side: `front`, `flip` (waiting for user to flip document), `back`. |
| `BlinkIdGuidance` | Per-frame detection guidance sealed class (see below). |

##### Quick-start

```dart
import 'dart:async';

import 'package:blinkid_flutter/blinkid_flutter.dart';

class ScanScreen extends StatefulWidget { ... }

class _ScanScreenState extends State<ScanScreen> {
  late final BlinkIdScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BlinkIdScannerController();
    unawaited(_run());
  }

  Future<void> _run() async {
    // 1. Load SDK + prepare platform view creation params.
    await _controller.initialize(sdkSettings, sessionSettings);

    // 2. scan() suspends until the platform view is ready, then starts scanning.
    //    Loop so reset() (retry) resumes without rebuilding the screen.
    while (mounted) {
      try {
        final result = await _controller.scan();
        // success — use result
        return;
      } on BlinkIdScanCancelException {
        Navigator.pop(context);
        return;
      } on BlinkIdScanResetException {
        // controller.reset() was called — loop restarts scan()
      } on BlinkIdScanCameraSwitchException {
        // Camera switch interrupted the scan — loop restarts scan()
        // once the new camera is ready.
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          // Always mount the view — status overlays go on top of it.
          BlinkIdScannerView(controller: _controller),

          // Show a spinner while SDK loads or view initializes.
          if (_controller.status == BlinkIdScannerStatus.loadingSdk ||
              _controller.status == BlinkIdScannerStatus.initializing)
            const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            ),

          // Show flip UI when front side is done.
          if (_controller.phase == BlinkIdScanPhase.flip)
            _FlipOverlay(controller: _controller),
        ],
      ),
    ),
  );
}
```

##### Guidance stream

Subscribe to `controller.guidanceStream` for per-frame detection hints:

```dart
_controller.guidanceStream.listen((guidance) {
  switch (guidance) {
    case BlinkIdGuidanceTooFar():    showHint('Move closer');
    case BlinkIdGuidanceTooClose():  showHint('Move farther away');
    case BlinkIdGuidanceTilted():    showHint('Keep document flat');
    case BlinkIdGuidanceBlur():      showHint('Hold still');
    case BlinkIdGuidanceGlare():     showHint('Reduce glare');
    default:                         showHint('Align the document');
  }
});
```

`BlinkIdGuidanceFlipDocument` is **never** emitted to `guidanceStream` — it drives the `phase` transition from `front` to `flip` internally. Guidance events are also suppressed during the flip phase; listen to `phase` instead.

Full guidance types: `searching`, `tooFar`, `tooClose`, `tooCloseToEdge`, `tilted`, `notFullyVisible`, `wrongSide`, `holdStill`, `blur`, `glare`, `lowLight`, `tooMuchLight`.

##### Two-sided documents and the flip phase

When the front side is complete, `phase` changes to `BlinkIdScanPhase.flip`. Show your flip animation and then call `controller.onFlipComplete()` once it finishes:

```dart
// After your animation ends:
widget.controller.onFlipComplete();
// phase moves to 'back' automatically once the camera sees the first back-side frame.
```

Failing to call `onFlipComplete()` leaves the scanner paused indefinitely.

##### Camera selection

Pass `preferredCamera` to `initialize()` to choose the starting lens:

```dart
await _controller.initialize(
  sdkSettings,
  sessionSettings,
  preferredCamera: PreferredCamera.back, // or PreferredCamera.front
);
```

To switch cameras at runtime call `switchCamera()`. It cancels any in-progress scan (the current `scan()` future completes with `BlinkIdScanCameraSwitchException`), rebinds the native camera, and returns once the controller is back in `ready` state — which is only reached once the camera has actually bound, not merely dispatched. Call `scan()` again to resume:

```dart
final activeCamera = await _controller.switchCamera(PreferredCamera.front);
final result = await _controller.scan();
```

`switchCamera()` returns the lens actually bound, which **may differ from the request** — e.g. `front` silently resolves to `back` on a device with no front lens. The resolved value is also available afterwards via `controller.activeCamera`.

`switchCamera()` throws `StateError` if the platform view is not yet attached or if `status` doesn't support switching (`uninitialized`, `loadingSdk`, `initializing`, `error`, or `cameraPermissionRequired`).

##### <a name="camera-permission"></a> Camera permission

The plugin requests `CAMERA` itself — both platforms show the system permission prompt before the first camera bind. If it's denied, `status` becomes `BlinkIdScannerStatus.cameraPermissionRequired` and any in-progress `scan()` completes with `BlinkIdCameraPermissionException`; check `exception.permanentlyDenied` (or `controller.lastPermissionException`) to decide between re-requesting and sending the user to system Settings. Once the host app has obtained the permission by its own means (e.g. via the `permission_handler` package, as in the example), call `controller.retryAfterPermissionGrant()` to resume:

```dart
} on BlinkIdCameraPermissionException catch (e) {
  if (e.permanentlyDenied) {
    await openAppSettings(); // permission_handler
  } else if ((await Permission.camera.request()).isGranted) {
    _controller.retryAfterPermissionGrant();
  }
}
```

No manifest changes are needed on Android — the plugin declares `CAMERA` itself (see "Android — minimum SDK and Kotlin version" under Plugin integration, above). On iOS, `NSCameraUsageDescription` in `Info.plist` (see "iOS — permissions and deployment target") is required, or the OS kills the app instead of prompting.

##### Debug logging

Enable native lifecycle log forwarding to Flutter's `debugPrint`:

```dart
_controller.setDebugLogging(true);
// Logs appear as: [BlinkID] SideScanned — pausing for flip
```

Disabled by default — no method-channel traffic is incurred when not opted in. Safe to call before or after the platform view is created.

##### Full example

See [`BlinkID/example/lib/custom_scanner_screen.dart`](BlinkID/example/lib/custom_scanner_screen.dart) for a complete implementation including scan timeout, retry dialog, flip animation, and guidance overlay.

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
| [`BlinkIdSdkSettings`](BlinkID/lib/src/blinkid_settings.dart) | License key, resource download URL/folder, proxy URL, iOS bundle identifier. |
| [`BlinkIdSessionSettings`](BlinkID/lib/src/blinkid_settings.dart) | `ScanningMode`, `BlinkIdScanningSettings`, step and inactivity timeouts. |
| [`BlinkIdScanningSettings`](BlinkID/lib/src/blinkid_settings.dart) | Module settings and `maxAllowedMismatchesPerField`. |
| [`DocumentCaptureModuleSettings`](BlinkID/lib/src/types.dart) | Document detection, image quality, face/document image return. |
| [`MrzModuleSettings`](BlinkID/lib/src/types.dart) | MRZ presence requirement. |
| [`BarcodeModuleSettings`](BlinkID/lib/src/types.dart) | Barcode format toggles and image return. |
| [`VizModuleSettings`](BlinkID/lib/src/types.dart) | VIZ extraction, validation, signature return. |
| [`BlinkIdScanningUxSettings`](BlinkID/lib/src/blinkid_settings.dart) | UX customization for `performScan` (help button, onboarding, haptics, camera). |
| [`BlinkIdScannerController`](BlinkID/lib/src/scanner/blinkid_scanner_controller.dart) | Controller for custom scanner UI (`BlinkIdScannerView`). |
| [`BlinkIdScannerView`](BlinkID/lib/src/scanner/blinkid_scanner_view.dart) | Platform view widget for custom scanner UI. |
| [`BlinkIdGuidance`](BlinkID/lib/src/scanner/blinkid_guidance.dart) | Sealed class for per-frame detection guidance events. |

Each Dart file documents available properties in detail. Native equivalents:
- [Android SDK documentation](https://blinkid.github.io/blinkid-android/blinkid-core/com.microblink.blinkid.core/index.html)
- [iOS SDK documentation](https://blinkid.github.io/blinkid-swift-package/documentation/blinkid/)

Native deserialization implementations:
- [Android](BlinkID/android/src/main/kotlin/com/microblink/blinkid/flutter/BlinkidDeserializationUtils.kt)
- [iOS](BlinkID/ios/blinkid_flutter/Sources/blinkid_flutter/BlinkidDeserializationUtils.swift)

### <a name="blinkid-results"></a> BlinkID Results

The scanning result is a `BlinkIdScanningResult` containing merged document-level fields and per-side detail.

**Top-level result** — aggregated fields such as `firstName`, `lastName`, `documentNumber`, `dateOfBirth`, `dateOfExpiry`, and images:
- `firstDocumentImage` / `secondDocumentImage` — cropped document images (Base64).
- `faceImage` / `signatureImage` — `DetailedCroppedImageResult` with image data and metadata.
- `firstInputImage` / `secondInputImage` / `barcodeInputImage` — raw input frames when enabled.
- `documentClassInfo` — detected country, region, document type.
- `dataMatchResult` — cross-side data match status.

**Per-side detail** — `subResults` is a `List<SingleSideScanningResult>`, one entry per scanned side. Each side contains:
- `viz` — `VizResult` with visual field data.
- `mrz` — `MrzResult` with MRZ parsed fields.
- `barcode` — `BarcodeResult` with barcode data.
- `documentImage`, `faceImage`, `signatureImage`, `inputImage` — side-specific images.

Field values use `StringResult` (with `value`, `latin`, `arabic`, etc.) and `DateResult` wrappers — access the extracted text via `.value`.

See [`BlinkID/lib/src/blinkid_result.dart`](BlinkID/lib/src/blinkid_result.dart) for the full result model.

Native result documentation:
- [Android](https://blinkid.github.io/blinkid-android/blinkid-core/com.microblink.blinkid.core.session/-blink-id-scanning-result/index.html)
- [iOS](https://blinkid.github.io/blinkid-swift-package/documentation/blinkid/blinkidscanningresult)

Native serialization implementations:
- [Android](BlinkID/android/src/main/kotlin/com/microblink/blinkid/flutter/BlinkidSerializationUtils.kt)
- [iOS](BlinkID/ios/blinkid_flutter/Sources/blinkid_flutter/BlinkidSerializationUtils.swift)

### <a name="class-filter--redaction"></a> Class filter & redaction

#### Class filter
Restrict which documents are accepted during camera scanning:
```dart
final filter = ClassFilter()
  ..includeDocuments = [DocumentFilter(country: Country.canada)]
  ..excludeDocuments = [DocumentFilter(country: Country.usa, documentType: DocumentType.passport)];
```

If `includeDocuments` is empty, all documents are accepted unless excluded. Rules can specify any combination of `country`, `region`, and `documentType`.

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
      DocumentFilter(country: Country.usa, region: Region.california),
    ],
  ),
]);
```

For **DirectAPI scanning**, pass a single `RedactionSettings` object directly to `performDirectApiScan`.

`RedactionMode` values: `none`, `imageOnly`, `resultFieldsOnly`, `fullResult`.

### <a name="customizing-performscan-strings"></a> Customizing `performScan` strings

`performScan` uses the native BlinkID UX overlay, which ships with built-in translations for 40+ languages and auto-selects based on the device locale. String customization is done through platform-native resource overrides — the SDK picks them up automatically at launch without any code changes.

#### Android

Add overrides in your app's `android/app/src/main/res/values/strings.xml` (or a locale-specific `values-XX/strings.xml`):

```xml
<resources>
    <!-- Scanning instructions -->
    <string name="mb_blinkid_front_instructions">Scan front of document</string>
    <string name="mb_blinkid_back_instructions">Scan back of document</string>
    <string name="mb_blinkid_camera_flip_document">Flip to back side</string>
    <string name="mb_blinkid_move_closer">Move closer</string>
    <string name="mb_blinkid_move_farther">Move farther away</string>
    <string name="mb_blinkid_blur_detected">Hold still</string>
    <string name="mb_blinkid_glare_detected">Reduce glare</string>
    <string name="mb_blinkid_keep_document_parallel">Keep document flat</string>
    <string name="mb_blinkid_document_not_fully_visible">Keep document fully in view</string>
    <string name="mb_blinkid_scanning_wrong_side">Flip the document</string>

    <!-- Onboarding dialog -->
    <string name="mb_blinkid_onboarding_dialog_title">Scan your document</string>
    <string name="mb_blinkid_onboarding_dialog_message">Place the front of your document within the frame</string>

    <!-- Timeout dialog -->
    <string name="mb_blinkid_recognition_timeout_dialog_title">Scan unsuccessful</string>
    <string name="mb_blinkid_recognition_timeout_dialog_message">Ensure the document is well-lit and fully visible</string>
    <string name="mb_blinkid_recognition_timeout_dialog_retry_button">Try Again</string>
</resources>
```

For a complete list of overridable keys, extract them from the blinkid-ux AAR:
```bash
# Unzip the AAR and inspect res/values/values.xml
unzip -p ~/.gradle/caches/modules-2/files-2.1/com.microblink/blinkid-ux/8000.0.0/*/blinkid-ux-8000.0.0.aar \
  res/values/values.xml | grep 'name="mb_'
```

#### iOS

Add a `BlinkID.strings` file to your `Runner` target for each locale (e.g. `en.lproj/BlinkID.strings`):

```
"mb_front_instructions" = "Scan front of document";
"mb_back_instructions" = "Scan back of document";
"mb_camera_flip_document" = "Flip to back side";
"mb_move_closer" = "Move closer";
"mb_move_farther" = "Move farther away";
"mb_blur_detected" = "Hold still";
"mb_glare_detected" = "Reduce glare";
"mb_keep_document_parallel" = "Keep document flat";
"mb_document_not_fully_visible" = "Keep document fully in view";
"mb_scanning_wrong_side" = "Flip the document";
"mb_onboarding_dialog_title" = "Scan your document";
"mb_onboarding_dialog_message" = "Place the front of your document within the frame";
"mb_recognition_timeout_dialog_title" = "Scan unsuccessful";
"mb_recognition_timeout_dialog_message" = "Ensure the document is well-lit and fully visible";
"mb_recognition_timeout_dialog_retry_button" = "Try Again";
```

Note: iOS keys use the `mb_` prefix (without `blinkid`), while Android uses `mb_blinkid_`.

> **Custom scanner (`BlinkIdScannerView`)**: string customization is fully in Flutter — pass whatever strings you want directly to your overlay widgets.

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

## <a name="additional-information"></a> Additional information
For any additional questions and information, feel free to contact us [here](https://help.microblink.com), or directly to the Support team via mail support@microblink.com.
