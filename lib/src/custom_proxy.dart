import 'dart:io';

import 'package:native_flutter_proxy/native_flutter_proxy.dart';

/// {@template custom_proxy}
/// A class that manages custom proxy settings for Flutter applications.
///
/// This class provides functionality to set up and manage a proxy server configuration,
/// including the ability to enable/disable the proxy and handle custom certificates.
///
/// Example usage:
/// ```dart
/// final proxy = CustomProxy(ipAddress: '192.168.1.1', port: 8080);
/// proxy.enable(); // Enables the proxy
/// proxy.disable(); // Disables the proxy
/// ```
///
/// You can also create a proxy instance from a string:
/// ```dart
/// final proxy = CustomProxy.fromString(proxy: '192.168.1.1:8080');
/// ```
///
/// The class supports:
/// * Setting custom IP address and port
/// * Enabling/disabling proxy settings
/// * Optional bad certificate handling
/// * String representation of proxy settings
///
/// Note: When [allowBadCertificates] is set to true, it may pose security risks
/// and should be used with caution, especially in production environments.
/// {@endtemplate}
class CustomProxy {
  /// {@macro custom_proxy}
  const CustomProxy({
    required this.ipAddress,
    this.port,
    this.allowBadCertificates = false,
  });

  /// A string representing an IP address for the proxy server
  final String ipAddress;

  /// The port number for the proxy server
  /// Can be null if port is default.
  final int? port;

  /// Set this to true
  /// - Warning: Setting this to true in production apps can be dangerous. Use with care!
  final bool allowBadCertificates;

  /// Creates a [CustomProxy] instance from a string representation.
  ///
  /// The [proxy] string should be in the format "ipAddress:port".
  /// For example: "192.168.1.1:8080"
  ///
  /// Returns null if:
  /// * The proxy string is empty
  /// * The port number cannot be parsed to an integer
  ///
  /// Throws an [AssertionError] in debug mode if the proxy string is empty.
  static CustomProxy? fromString({required String proxy}) {
    // Check if the proxy string is empty
    if (proxy.isEmpty) {
      assert(
        false,
        'Proxy string passed to CustomProxy.fromString() is invalid.',
      );
      return null;
    }

    // Split the proxy string into parts and extract the IP address and port number if available
    // Format: "ipAddress:port"
    final proxyParts = proxy.split(':');
    final ipAddress = proxyParts.first;
    final port = proxyParts.length > 1 ? int.tryParse(proxyParts[1]) : null;

    return CustomProxy(ipAddress: ipAddress, port: port);
  }

  /// Enables the custom proxy by setting a global HTTP override.
  ///
  /// Sets [HttpOverrides.global] to a new instance of [CustomProxyHttpOverride]
  /// configured with the proxy settings from this object's string representation.
  void enable() => HttpOverrides.global = CustomProxyHttpOverride.withProxy(toString());

  /// Disables the global HTTP proxy settings by setting HttpOverrides.global to null.
  ///
  /// This method removes any previously configured proxy settings and restores
  /// the default HTTP client behavior for network requests.
  void disable() => HttpOverrides.global = null;

  @override
  String toString() {
    var proxy = ipAddress;

    if (port != null) proxy += ':$port';

    return proxy;
  }
}
