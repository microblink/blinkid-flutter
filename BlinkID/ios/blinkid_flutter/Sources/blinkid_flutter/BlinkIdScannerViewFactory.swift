import Flutter
import UIKit

public class BlinkIdScannerViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let sdkProvider: () -> AnyObject?

  init(messenger: FlutterBinaryMessenger, sdkProvider: @escaping () -> AnyObject?) {
    self.messenger = messenger
    self.sdkProvider = sdkProvider
  }

  public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    let params = args as? [String: Any] ?? [:]
    return BlinkIdScannerView(
      frame: frame,
      viewId: viewId,
      messenger: messenger,
      creationParams: params,
      sdkProvider: sdkProvider,
    )
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}
