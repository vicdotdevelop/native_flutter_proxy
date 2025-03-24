import Flutter
import UIKit

/**
 * @class SwiftFlutterProxyPlugin
 * @brief A Swift implementation of the Flutter plugin for handling proxy settings.
 *
 * This class registers the plugin with the Flutter engine and handles method calls
 * from Dart code. It provides functionality to retrieve the system proxy settings.
 */
public class SwiftFlutterProxyPlugin: NSObject, FlutterPlugin {
  
  /**
   * Registers the plugin with the Flutter plugin registrar.
   *
   * @param registrar The Flutter plugin registrar.
   */
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_flutter_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterProxyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /**
   * Handles method calls from Dart code.
   *
   * @param call The method call from Dart.
   * @param result The result callback to send the response back to Dart.
   */
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

  /**
   * Retrieves the system proxy settings.
   *
   * @return A dictionary containing the proxy host and port, or nil if not available.
   */
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
        return ["host": hostName, "port": port]
    }
    return nil
  }
}