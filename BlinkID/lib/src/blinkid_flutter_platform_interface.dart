import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'blinkid_flutter_method_channel.dart';
import 'blinkid_result.dart';
import 'blinkid_settings.dart';
import 'types.dart';

abstract class BlinkIdFlutterPlatform extends PlatformInterface {
  /// Constructs a BlinkidFlutterPlatform.
  BlinkIdFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BlinkIdFlutterPlatform _instance = MethodChannelBlinkIdFlutter();

  /// The default instance of [BlinkidFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBlinkidFlutter].
  static BlinkIdFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BlinkIdFlutterPlatform] when
  /// they register themselves.
  static set instance(BlinkIdFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the `performScan` method from the [MethodChannelBlinkIdFlutter].
  /// See [MethodChannelBlinkIdFlutter] for more detailed information.
  Future<BlinkIdScanningResult?> performScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    BlinkIdScanningUxSettings? blinkIdScanningUxSettings,
    ClassFilter? classFilter,
    RedactionSettingsResolver? redactionSettingsResolver,
  }) async {
    return MethodChannelBlinkIdFlutter().performScan(
      blinkIdSdkSettings: blinkIdSdkSettings,
      blinkIdSessionSettings: blinkIdSessionSettings,
      blinkIdScanningUxSettings: blinkIdScanningUxSettings,
      classFilter: classFilter,
      redactionSettingsResolver: redactionSettingsResolver,
    );
  }

  /// Returns the `performDirectApiScan` method from the [MethodChannelBlinkIdFlutter].
  /// See [MethodChannelBlinkIdFlutter] for more detailed information.
  Future<BlinkIdScanningResult?> performDirectApiScan({
    required BlinkIdSdkSettings blinkIdSdkSettings,
    required BlinkIdSessionSettings blinkIdSessionSettings,
    RedactionSettings? redactionSettings,
    required String firstImage,
    String? secondImage,
  }) async {
    return MethodChannelBlinkIdFlutter().performDirectApiScan(
      blinkIdSdkSettings: blinkIdSdkSettings,
      blinkIdSessionSettings: blinkIdSessionSettings,
      redactionSettings: redactionSettings,
      firstImage: firstImage,
      secondImage: secondImage,
    );
  }

  /// Returns the `loadBlinkIdSdk` method from the [MethodChannelBlinkIdFlutter].
  /// It takes the following parameter: [BlinkIdSdkSettings]
  /// See [MethodChannelBlinkIdFlutter] for more detailed information.
  Future<void> loadBlinkIdSdk(BlinkIdSdkSettings blinkIdSdkSettings) async {
    return MethodChannelBlinkIdFlutter().loadBlinkIdSdk(blinkIdSdkSettings);
  }

  /// Returns the `unloadBlinkIdSdk` method from the [MethodChannelBlinkIdFlutter].
  /// It takes the following parameter: [BlinkIdSdkSettings]
  /// See [MethodChannelBlinkIdFlutter] for more detailed information.
  Future<void> unloadBlinkIdSdk({bool deleteCachedResources = false}) async {
    return MethodChannelBlinkIdFlutter().unloadBlinkIdSdk(
      deleteCachedResources: deleteCachedResources,
    );
  }

  /// Returns the `refreshLicenseLease` method from the [MethodChannelBlinkIdFlutter].
  /// See [MethodChannelBlinkIdFlutter] for more detailed information.
  Future<void> refreshLicenseLease() async {
    return MethodChannelBlinkIdFlutter().refreshLicenseLease();
  }
}
