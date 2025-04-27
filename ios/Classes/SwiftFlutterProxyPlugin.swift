import Flutter
import UIKit

public class SwiftFlutterProxyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_flutter_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterProxyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "getProxySetting":
            result(getProxySetting())
            break
        default:
            result(FlutterMethodNotImplemented)
            break
    }
  }

    func getProxySetting() -> NSDictionary? {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue(),
            let url = URL(string: "https://www.bing.com/") else {
                return nil
        }
        let proxies = CFNetworkCopyProxiesForURL((url as CFURL), proxySettings).takeUnretainedValue() as NSArray
        guard let settings = proxies.firstObject as? NSDictionary,
            let _ = settings.object(forKey: (kCFProxyTypeKey as String)) as? String else {
                return nil
        }

        if let hostName = settings.object(forKey: (kCFProxyHostNameKey as String)), let port = settings.object(forKey: (kCFProxyPortNumberKey as String)) {
            return ["host":hostName, "port":port]
        }
        return nil;
    }
}