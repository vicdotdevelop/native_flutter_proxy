import 'dart:io';

/// {@template custom_proxy_http_override}
/// A custom HTTP override class that allows setting a global proxy for all HTTP requests.
///
/// This class extends [HttpOverrides] to provide proxy configuration capabilities.
/// It can be used to route all HTTP traffic through a specified proxy server and
/// optionally allow bad certificates for testing purposes.
///
/// Example usage:
/// ```dart
/// HttpOverrides.global = CustomProxyHttpOverride.withProxy(
///   'localhost:8888',
///   allowBadCertificates: true,
/// );
/// ```
///
/// Important:
/// - The proxy string must be in the format "host:port"
/// - Allowing bad certificates should only be used for development/testing
/// - This affects all HTTP requests made by the application
///
/// Note: Use with caution in production environments as it can compromise
/// security if not configured properly.
/// {@endtemplate}
final class CustomProxyHttpOverride extends HttpOverrides {
  /// Create a new instance of [CustomProxyHttpOverride] with the specified proxy settings.
  ///
  /// {@macro custom_proxy_http_override}
  CustomProxyHttpOverride.withProxy(
    this.proxyString, {
    this.allowBadCertificates = false,
  });

  /// The entire proxy server
  /// Format: "localhost:8888"
  final String proxyString;

  /// Set this to true
  /// - Warning: Setting this to true in production apps can be dangerous. Use with care!
  final bool allowBadCertificates;

  /// Override HTTP client creation to set the proxy and bad certificate callback.
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..findProxy = (uri) {
        assert(proxyString.isNotEmpty,
            'You must set a valid proxy if you enable it!',);
        return 'PROXY $proxyString;';
      };
    if (allowBadCertificates) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    return client;
  }
}
