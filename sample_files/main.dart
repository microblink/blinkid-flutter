import 'dart:io';
import 'package:flutter/material.dart';
import "dart:async";
import 'package:flutter/services.dart';
import "dart:convert";
import 'package:image_picker/image_picker.dart';

/// import the blinkid_flutter package
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'blinkid_result_builder.dart';
import 'module_settings_panel.dart';
import 'optional_scan_settings_panel.dart';
import 'scanning_modules_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String sdkLicenseKey = "";
  String resultString = "";

  String firstDocumentImageBase64 = "";
  String secondDocumentImageBase64 = "";
  String faceImageBase64 = "";
  String signatureImageBase64 = "";

  String firstInputImageBase64 = "";
  String secondInputImageBase64 = "";
  String barcodeInputImageBase64 = "";

  /// Initialize the BlinkID plugin
  ///
  /// It will be used both for the default UX scan (performScan method),
  /// and the DirectAPI scan (directApiMultiSideScan and directApiSingleSideScan methods).
  final blinkIdPlugin = BlinkIdFlutter();

  final _modulesConfig = ScanningModulesConfig();

  static const String? _microblinkProxyUrl = null;

  BlinkIdSdkSettings _buildSdkSettings() {
    final sdkSettings = BlinkIdSdkSettings(
      licenseKey: sdkLicenseKey,
      microblinkProxyUrl: _microblinkProxyUrl,
      resourcesConfig: ResourcesConfig(
        download: true,
        // Optional: override resource download timeouts (milliseconds).
        // requestTimeout: RequestTimeout.all(30000),
      ),
      otaResourcesConfig: _modulesConfig.toOtaResourcesConfig(),
    );
    return sdkSettings;
  }

  BlinkIdSessionSettings _buildSessionSettings() =>
      _modulesConfig.toSessionSettings();

  void _logScanConfiguration(String action) {
    final sessionSettings = _buildSessionSettings();
    final scanningSettings = sessionSettings.scanningSettings;
    final otaResourcesConfig = _modulesConfig.toOtaResourcesConfig();
    debugPrint('[BlinkIdSample] $action');
    debugPrint('[BlinkIdSample] scanningMode: ${sessionSettings.scanningMode}');
    debugPrint(
      '[BlinkIdSample] stepTimeoutDuration: ${sessionSettings.stepTimeoutDuration}, '
      'inactivityTimeoutDuration: ${sessionSettings.inactivityTimeoutDuration}',
    );
    debugPrint(
      '[BlinkIdSample] showOnboardingDialog: ${_modulesConfig.showOnboardingDialog}',
    );
    debugPrint(
      '[BlinkIdSample] modules enabled: '
      'documentCapture=${_modulesConfig.documentCaptureEnabled}, '
      'barcode=${_modulesConfig.barcodeEnabled}, '
      'mrz=${_modulesConfig.mrzEnabled}, '
      'viz=${_modulesConfig.vizEnabled}',
    );
    debugPrint(
      '[BlinkIdSample] scanningSettings JSON: ${jsonEncode(scanningSettings.toJson())}',
    );
    debugPrint(
      '[BlinkIdSample] full sessionSettings JSON: ${jsonEncode(sessionSettings.toJson())}',
    );
    debugPrint(
      '[BlinkIdSample] otaResourcesConfig: '
      '${otaResourcesConfig != null ? jsonEncode(otaResourcesConfig.toJson()) : 'null'}',
    );
  }

  @override
  void initState() {
    super.initState();

    /// Add a valid license key, based on the platform
    /// A valid license key can be obtained from the Microblink Developer Hub, here: https://developer.microblink.com
    if (Platform.isAndroid) {
      sdkLicenseKey =
          "sRwCABVjb20ubWljcm9ibGluay5zYW1wbGUAbGV5SkRjbVZoZEdWa1QyNGlPakUzTnpreE1ESXpOVGMxT1RBc0lrTnlaV0YwWldSR2IzSWlPaUprWkdRd05qWmxaaTAxT0RJekxUUXdNRGd0T1RRNE1DMDFORFU0WWpBeFlUVTJZamdpZlE9PRXlOs6VFBOfXCx1+6HuENpn05k2kl20pJr4kQ4S1sMxuSzZ+B8YhC9rYMsFXr3HSskFmMFwEe+44OQ1ZE2sm9iHUpxNBmVGpgBTKPOrc2vquGbpqmFwm1feyTL9Aw==";
    } else if (Platform.isIOS) {
      sdkLicenseKey =
          "sRwCABVjb20ubWljcm9ibGluay5zYW1wbGUBbGV5SkRjbVZoZEdWa1QyNGlPakUzTnpreE56VTBNekE0T1Rrc0lrTnlaV0YwWldSR2IzSWlPaUprWkdRd05qWmxaaTAxT0RJekxUUXdNRGd0T1RRNE1DMDFORFU0WWpBeFlUVTJZamdpZlE9PaObKYfb4FlwqmqVoofXLicsmElmnSm1gmoXWaFx8MgdmmJRSLpdAfP6uV5xAr3K4rColEBYQ38GNh+FT081yjXPFB16LwdVhDiJcEK07cTBG5hQPXRy8+hoJJ1U7w==";
    }

    // If necessary, the SDK can be pre-loaded with the necessary resources before the scanning session starts.
    // This will decreasing the SDK loading time when starting a scanning session (since the resources will be downloaded and the license verified).

    // blinkIdPlugin.loadBlinkIdSdk(
    //   blinkidSdkSettings: BlinkIdSdkSettings(licenseKey: sdkLicenseKey),
    // );
  }

  Future<void> performScan() async {
    try {
      _logScanConfiguration('Scan with camera');
      final sdkSettings = _buildSdkSettings();
      final sessionSettings = _buildSessionSettings();

      final uiSettings = _modulesConfig.toUxSettings();
      final classFilter = _modulesConfig.toClassFilter();
      final redactionSettingsResolver =
          _modulesConfig.toRedactionSettingsResolver();

      /// Call the 'performScan' method and handle the results
      /// Check how the results are handled in the blinkid_result_builder.dart file
      await blinkIdPlugin
          .performScan(
            blinkIdSdkSettings: sdkSettings,
            blinkIdSessionSettings: sessionSettings,
            blinkidScanningUxSettings: uiSettings,
            classFilter: classFilter,
            redactionSettingsResolver: redactionSettingsResolver,
          )
          .then((result) {
            resetImages();
            setState(() {
              if (result != null) {
                resultString = BlinkIdResultBuilder.getIdResultString(result);
                setImages(result);
              }
            });
          })
          .catchError((scanningError) {
            setState(() {
              if (scanningError is PlatformException) {
                final errorMessage = scanningError.message;
                resultString = "BlinkID scanning error: $errorMessage";
                resetImages();
              }
            });
          });
    } catch (blinkidScanningError) {
      if (blinkidScanningError is PlatformException) {
        final errorMessage = blinkidScanningError.message;
        setState(() {
          resultString = "BlinkID scanning error: $errorMessage";
          resetImages();
        });
      }
    }
  }

  Future<void> directApiMultiSideScan() async {
    try {
      _logScanConfiguration('DirectAPI MultiSide');
      /// Get the front and the back side of the document with the pickMultiImage method
      /// First select the front and the then back side of the image
      final images = await ImagePicker().pickMultiImage();

      /// Convert the first picked image to the Base64 format
      String frontImageBase64 = base64Encode(await images[0].readAsBytes());

      /// Get the second selected image as the back side of the document
      /// Convert the picked image to the Base64 format
      String backImageBase64 = base64Encode(await images[1].readAsBytes());

      final sdkSettings = _buildSdkSettings();
      final sessionSettings = _buildSessionSettings();

      /// Call the 'performDirectApiScan' method and handle the results
      /// Check how the results are handled in the blinkid_result_builder.dart file
      await blinkIdPlugin
          .performDirectApiScan(
            blinkIdSdkSettings: sdkSettings,
            blinkIdSessionSettings: sessionSettings,
            firstImage: frontImageBase64,
            secondImage: backImageBase64,
          )
          .then((result) {
            setState(() {
              resetImages();
              if (result != null) {
                resultString = BlinkIdResultBuilder.getIdResultString(result);
                setImages(result);
              }
            });
          })
          .catchError((scanningError) {
            setState(() {
              if (scanningError is PlatformException) {
                final errorMessage = scanningError.message;
                resultString = "BlinkID scanning error: $errorMessage";
                resetImages();
              }
            });
          });
    } catch (blinkidScanningError) {
      if (blinkidScanningError is PlatformException) {
        final errorMessage = blinkidScanningError.message;
        setState(() {
          resultString = "BlinkID scanning error: $errorMessage";
          resetImages();
        });
      }
    }
  }

  Future<void> directApiSingleSideScan() async {
    try {
      _logScanConfiguration('DirectAPI SingleSide');
      /// Get either the front or the back side of the document with the pickImage method
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      /// Convert the picked image to the Base64 format
      String imageBase64 = base64Encode(await image.readAsBytes());

      final sdkSettings = _buildSdkSettings();
      final sessionSettings = _buildSessionSettings();

      /// Call the 'performDirectApiScan' method and handle the results
      /// Check how the results are handled in the blinkid_result_builder.dart file
      await blinkIdPlugin
          .performDirectApiScan(
            blinkIdSdkSettings: sdkSettings,
            blinkIdSessionSettings: sessionSettings,
            firstImage: imageBase64,
          )
          .then((result) {
            setState(() {
              resetImages();
              if (result != null) {
                resultString = BlinkIdResultBuilder.getIdResultString(result);
                setImages(result);
              }
            });
          })
          .catchError((scanningError) {
            setState(() {
              if (scanningError is PlatformException) {
                final errorMessage = scanningError.message;
                resultString = "BlinkID scanning error: $errorMessage";
                resetImages();
              }
            });
          });
    } catch (blinkidScanningError) {
      if (blinkidScanningError is PlatformException) {
        final errorMessage = blinkidScanningError.message;
        setState(() {
          resultString = "BlinkID scanning error: $errorMessage";
          resetImages();
        });
      }
    }
  }

  void setImages(BlinkIdScanningResult? result) {
    if (result?.firstDocumentImage != null) {
      firstDocumentImageBase64 = result!.firstDocumentImage!;
    }
    if (result?.secondDocumentImage != null) {
      secondDocumentImageBase64 = result!.secondDocumentImage!;
    }
    if (result?.faceImage != null) {
      faceImageBase64 = result!.faceImage!.image!;
    }
    if (result?.signatureImage != null) {
      signatureImageBase64 = result!.signatureImage!.image!;
    }
    if (result?.firstInputImage != null) {
      firstInputImageBase64 = result!.firstInputImage!;
    }
    if (result?.secondInputImage != null) {
      secondInputImageBase64 = result!.secondInputImage!;
    }
    if (result?.barcodeInputImage != null) {
      barcodeInputImageBase64 = result!.barcodeInputImage!;
    }
  }

  void resetImages() {
    firstDocumentImageBase64 = "";
    secondDocumentImageBase64 = "";
    firstInputImageBase64 = "";
    secondInputImageBase64 = "";
    faceImageBase64 = "";
    signatureImageBase64 = "";
    barcodeInputImageBase64 = "";
  }

  @override
  Widget build(BuildContext context) {
    Widget firstDocumentImage = Container();
    if (firstDocumentImageBase64 != "") {
      firstDocumentImage = Column(
        children: <Widget>[
          Text("First document image:"),
          Image.memory(
            Base64Decoder().convert(firstDocumentImageBase64),
            height: 180,
            width: 350,
          ),
        ],
      );
    }

    Widget secondDocumentImage = Container();
    if (secondDocumentImageBase64 != "") {
      secondDocumentImage = Column(
        children: <Widget>[
          Text("Second document image:"),
          Image.memory(
            Base64Decoder().convert(secondDocumentImageBase64),
            height: 180,
            width: 350,
          ),
        ],
      );
    }
    Widget firstInputImage = Container();
    if (firstInputImageBase64 != "") {
      firstInputImage = Column(
        children: <Widget>[
          Text("First input image:"),
          Image.memory(
            Base64Decoder().convert(firstInputImageBase64),
            height: 180,
            width: 350,
          ),
        ],
      );
    }
    Widget secondInputImage = Container();
    if (secondInputImageBase64 != "") {
      secondInputImage = Column(
        children: <Widget>[
          Text("Second input image:"),
          Image.memory(
            Base64Decoder().convert(secondInputImageBase64),
            height: 180,
            width: 350,
          ),
        ],
      );
    }
    Widget barcodeInputImage = Container();
    if (barcodeInputImageBase64 != "") {
      barcodeInputImage = Column(
        children: <Widget>[
          Text("Barcode input image:"),
          Image.memory(
            Base64Decoder().convert(barcodeInputImageBase64),
            height: 180,
            width: 350,
          ),
        ],
      );
    }

    Widget faceImage = Container();
    if (faceImageBase64 != "") {
      faceImage = Column(
        children: <Widget>[
          Text("Face Image:"),
          Image.memory(
            Base64Decoder().convert(faceImageBase64),
            height: 150,
            width: 100,
          ),
        ],
      );
    }

    Widget signatureImage = Container();
    if (signatureImageBase64 != "") {
      signatureImage = Column(
        children: <Widget>[
          Text("Signature Image:"),
          Image.memory(
            Base64Decoder().convert(signatureImageBase64),
            height: 150,
            width: 100,
          ),
        ],
      );
    }

    Future<void> showAlertDialog(
      BuildContext context,
      String title,
      String message,
    ) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("BlinkID Sample")),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16.0),
            child: Builder(
            builder: (BuildContext context) {
              return Column(
                children: <Widget>[
                  ModuleSettingsPanel(
                    config: _modulesConfig,
                    onChanged: () => setState(() {}),
                  ),
                  OptionalScanSettingsPanel(
                    config: _modulesConfig,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () => performScan(),
                      child: Text("Scan with camera"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showAlertDialog(
                          context,
                          'DirectAPI MultiSide instructions',
                          'Select two images for processing.\nThe first selected image needs to be front side of the document.\nThe second image needs to be the back side of the document.',
                        ).then((_) {
                          directApiMultiSideScan();
                        });
                      },
                      child: Text("DirectAPI MultiSide"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showAlertDialog(
                          context,
                          'DirectAPI SingleSide instructions',
                          'Select one image for processing.\nThe image can be either the front or the back side of the document.',
                        ).then((_) {
                          directApiSingleSideScan();
                        });
                      },
                      child: Text("DirectAPI SingleSide"),
                    ),
                  ),
                  Text(resultString),
                  firstDocumentImage,
                  secondDocumentImage,
                  firstInputImage,
                  secondInputImage,
                  barcodeInputImage,
                  faceImage,
                  signatureImage,
                ],
              );
            },
          ),
          ),
        ),
      ),
    );
  }
}
