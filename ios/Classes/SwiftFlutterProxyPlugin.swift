import Flutter
import Network
import SystemConfiguration
import UIKit

/**
 * @class SwiftFlutterProxyPlugin
 * @brief A Swift implementation of the Flutter plugin for handling proxy settings.
 *
 * This class registers the plugin with the Flutter engine and handles method calls
 * from Dart code. It provides functionality to retrieve the system proxy settings.
 */
public class SwiftFlutterProxyPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  @available(iOS 12.0, *)
  private var pathMonitor: NWPathMonitor?
  private var pathMonitorQueue: DispatchQueue?
  private var reachability: SCNetworkReachability?
  private var reachabilityQueue: DispatchQueue?
  private var appActiveObserver: NSObjectProtocol?
  private var proxyPollTimer: DispatchSourceTimer?
  private let proxyStateLock = NSLock()
  private var lastProxyKey: String?

  struct ProxyInfo {
    let host: String
    let port: Int

    var dictionary: NSDictionary {
      return [
        "host": host,
        "port": port
      ]
    }
  }

  /**
   * Registers the plugin with the Flutter plugin registrar.
   *
   * @param registrar The Flutter plugin registrar.
   */
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_flutter_proxy", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterProxyPlugin()
    instance.channel = channel
    instance.startProxyChangeObserver()
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

  deinit {
    stopProxyChangeObserver()
  }

  private func startProxyChangeObserver() {
    if appActiveObserver == nil {
      appActiveObserver = NotificationCenter.default.addObserver(
        forName: UIApplication.didBecomeActiveNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.notifyProxyChanged()
      }
    }

    seedProxyKey()
    startProxyPolling()

    if #available(iOS 12.0, *) {
      guard pathMonitor == nil else {
        return
      }

      let monitor = NWPathMonitor()
      pathMonitor = monitor
      let queue = DispatchQueue(label: "native_flutter_proxy.pathMonitor")
      pathMonitorQueue = queue
      monitor.pathUpdateHandler = { [weak self] _ in
        self?.notifyProxyChanged()
      }
      monitor.start(queue: queue)
      return
    }

    startReachabilityObserver()
  }

  private func startReachabilityObserver() {
    guard reachability == nil else {
      return
    }

    guard let reachability = makeReachability() else {
      return
    }

    self.reachability = reachability
    reachabilityQueue = DispatchQueue(label: "native_flutter_proxy.reachability")

    var context = SCNetworkReachabilityContext(
      version: 0,
      info: Unmanaged.passUnretained(self).toOpaque(),
      retain: nil,
      release: nil,
      copyDescription: nil
    )

    let callback: SCNetworkReachabilityCallBack = { _, _, info in
      guard let info = info else {
        return
      }
      let plugin = Unmanaged<SwiftFlutterProxyPlugin>
        .fromOpaque(info)
        .takeUnretainedValue()
      plugin.notifyProxyChanged()
    }

    if !SCNetworkReachabilitySetCallback(reachability, callback, &context) {
      self.reachability = nil
      reachabilityQueue = nil
      return
    }

    if let queue = reachabilityQueue,
       !SCNetworkReachabilitySetDispatchQueue(reachability, queue) {
      SCNetworkReachabilitySetCallback(reachability, nil, nil)
      self.reachability = nil
      reachabilityQueue = nil
    }
  }

  private func stopProxyChangeObserver() {
    if let appActiveObserver {
      NotificationCenter.default.removeObserver(appActiveObserver)
      self.appActiveObserver = nil
    }

    if #available(iOS 12.0, *) {
      if let pathMonitor {
        pathMonitor.cancel()
        self.pathMonitor = nil
      }
      pathMonitorQueue = nil
    }

    stopProxyPolling()
    stopReachabilityObserver()
  }

  private func stopReachabilityObserver() {
    if let reachability {
      SCNetworkReachabilitySetDispatchQueue(reachability, nil)
      self.reachability = nil
    }
    reachabilityQueue = nil
  }

  private func makeReachability() -> SCNetworkReachability? {
    var address = sockaddr_in()
    address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    address.sin_family = sa_family_t(AF_INET)

    return withUnsafePointer(to: &address) { pointer in
      pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPointer in
        SCNetworkReachabilityCreateWithAddress(nil, addrPointer)
      }
    }
  }

  private func startProxyPolling() {
    guard proxyPollTimer == nil else {
      return
    }

    let queue = DispatchQueue(label: "native_flutter_proxy.proxyPoll")
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.schedule(deadline: .now(), repeating: 5.0)
    timer.setEventHandler { [weak self] in
      self?.notifyProxyChanged()
    }
    timer.resume()
    proxyPollTimer = timer
  }

  private func stopProxyPolling() {
    if let proxyPollTimer {
      proxyPollTimer.cancel()
      self.proxyPollTimer = nil
    }
  }

  private func seedProxyKey() {
    let snapshot = proxySettingSnapshot()
    proxyStateLock.lock()
    lastProxyKey = snapshot.key
    proxyStateLock.unlock()
  }

  private func notifyProxyChanged() {
    let snapshot = proxySettingSnapshot()
    proxyStateLock.lock()
    let shouldNotify = snapshot.key != lastProxyKey
    if shouldNotify {
      lastProxyKey = snapshot.key
    }
    proxyStateLock.unlock()

    guard shouldNotify else {
      return
    }
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod("proxyChangedCallback", arguments: snapshot.payload)
    }
  }

  private func proxySettingSnapshot() -> (payload: [String: Any], key: String) {
    guard let setting = getProxySetting() as? [String: Any] else {
      let payload: [String: Any] = ["host": NSNull(), "port": NSNull()]
      return (payload, "<nil>|<nil>")
    }

    let hostValue = setting["host"] as? String
    let portValue = setting["port"]
    let hostPayload: Any = hostValue ?? NSNull()
    let portPayload: Any = portValue ?? NSNull()
    let portKey: String
    if let portNumber = portValue as? NSNumber {
      portKey = portNumber.stringValue
    } else if let portInt = portValue as? Int {
      portKey = "\(portInt)"
    } else if let portString = portValue as? String {
      portKey = portString
    } else {
      portKey = "<nil>"
    }
    let key = "\(hostValue ?? "<nil>")|\(portKey)"
    return (["host": hostPayload, "port": portPayload], key)
  }

  /**
   * Retrieves the system proxy settings.
   *
   * @return A dictionary containing the proxy host and port, or nil if not available.
   */
  func getProxySetting() -> NSDictionary? {
    guard let url = URL(string: "https://www.bing.com/") else {
      return nil
    }
    return resolve(url: url)?.dictionary
  }

  private func resolve(url: URL) -> ProxyInfo? {
    guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue(),
          let proxySettingsDict = proxySettings as NSDictionary? else {
      return nil
    }

    if proxySettingsDict[kCFNetworkProxiesProxyAutoConfigEnable] as? Bool == true {
      if let pacContent = proxySettingsDict[kCFNetworkProxiesProxyAutoConfigJavaScript] as? String,
         let proxyInfo = self.handlePacContent(pacContent: pacContent, url: url) {
        return proxyInfo
      }

      if let pacUrl = proxySettingsDict[kCFNetworkProxiesProxyAutoConfigURLString] as? String,
         let proxyInfo = SwiftFlutterProxyPlugin.handlePacUrl(pacUrl: pacUrl, url: url) {
        return proxyInfo
      }
    }

    if proxySettingsDict[kCFNetworkProxiesHTTPEnable] as? Bool == true ||
        proxySettingsDict["HTTPSEnable"] as? Bool == true {
      if let proxyInfo = self.handleHTTPProxy(proxySettings: proxySettings, url: url) {
        return proxyInfo
      }
    }

    return nil
  }

  private func handleHTTPProxy(proxySettings: CFDictionary, url: URL) -> ProxyInfo? {
    let proxies = CFNetworkCopyProxiesForURL(url as CFURL,
                                             proxySettings).takeUnretainedValue() as? [[CFString: Any]]

    return SwiftFlutterProxyPlugin.retrieveHTTPProxyFrom(proxies: proxies)
  }

  private func handlePacContent(pacContent: String, url: URL) -> ProxyInfo? {
    let proxies = CFNetworkCopyProxiesForAutoConfigurationScript(pacContent as CFString,
                                                                 CFURLCreateWithString(kCFAllocatorDefault,
                                                                                       url.absoluteString as CFString,
                                                                                       nil),
                                                                 nil)?.takeUnretainedValue() as? [[CFString: Any]]

    return SwiftFlutterProxyPlugin.retrieveHTTPProxyFrom(proxies: proxies)
  }

  private static var proxyCache: [String: ProxyInfo] = [:]
  private static func handlePacUrl(pacUrl: String, url: URL) -> ProxyInfo? {
    guard let pacUrl = CFURLCreateWithString(kCFAllocatorDefault, pacUrl as CFString?, nil),
          let targetUrl = CFURLCreateWithString(kCFAllocatorDefault, url.absoluteString as CFString?, nil) else {
      return nil
    }

    var info = url.absoluteString

    withUnsafeMutablePointer(to: &info, { infoPointer in
      var context = CFStreamClientContext(version: 0,
                                          info: infoPointer,
                                          retain: nil,
                                          release: nil,
                                          copyDescription: nil)

      let runLoopSource = CFNetworkExecuteProxyAutoConfigurationURL(pacUrl, targetUrl, { client, proxies, _ in
        let url = client.assumingMemoryBound(to: String.self).pointee

        SwiftFlutterProxyPlugin.proxyCache[url] = SwiftFlutterProxyPlugin
          .retrieveHTTPProxyFrom(proxies: proxies as? [[CFString: Any]])
        CFRunLoopStop(CFRunLoopGetCurrent())
      }, &context)

      CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.defaultMode)
      CFRunLoopRun()
      CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.defaultMode)
    })

    return SwiftFlutterProxyPlugin.proxyCache[url.absoluteString]
  }

  private static func retrieveHTTPProxyFrom(proxies: [[CFString: Any]]?) -> ProxyInfo? {
    guard let proxies else {
      return nil
    }

    for proxy in proxies {
      let proxyType = proxy[kCFProxyTypeKey] as? String
      if proxyType == kCFProxyTypeHTTP as String || proxyType == kCFProxyTypeHTTPS as String {
        if let host = proxy[kCFProxyHostNameKey] as? String,
           let port = proxy[kCFProxyPortNumberKey] as? Int {
          return ProxyInfo(host: host, port: port)
        }
      }
    }

    return nil
  }
}
