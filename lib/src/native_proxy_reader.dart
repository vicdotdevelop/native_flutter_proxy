import 'dart:async';

import 'package:flutter/services.dart';

/// {@template native_proxy_reader}
/// A class to read network proxy settings from native platform code.
///
/// This class provides functionality to retrieve proxy settings like host and
/// port from the native platform (iOS/Android) through a method channel.
///
/// Example usage:
/// ```dart
/// ProxySetting settings = await NativeProxyReader.proxySetting;
/// if (settings.enabled) {
///   print('Proxy host: ${settings.host}');
///   print('Proxy port: ${settings.port}');
/// }
/// ```
/// {@endtemplate}
abstract final class NativeProxyReader {
  /// Method channel for native platform communication.
  static const _channel = MethodChannel('native_flutter_proxy');

  /// Get the proxy settings from the native platform.
  static Future<ProxySetting> get proxySetting async {
    return _channel.invokeMapMethod<String, dynamic>('getProxySetting').then(ProxySetting._fromMap);
  }

  /// Register callback, when the system proxy is changed.
  /// This is the only way to use a proxy specified by PAC.
  static void setProxyChangedCallback(Future<dynamic> Function(ProxySetting)? handler) {
    _channel.setMethodCallHandler((call) async {
      if (handler != null &&
          call.method == 'proxyChangedCallback' &&
          call.arguments is Map<Object?, Object?>) {
        final map = (call.arguments as Map<Object?, Object?>).cast<String, dynamic>();
        await handler(ProxySetting._fromMap(map));
      } else {
        throw MissingPluginException('notImplemented');
      }
    });
  }
}

/// {@template proxy_setting}
/// A class to hold proxy settings like host and port.
/// {@endtemplate}
class ProxySetting {
  /// {@macro proxy_setting}
  const ProxySetting._({this.host, this.port});

  /// Create a new instance of [ProxySetting] from a map.
  ///
  /// {@macro proxy_setting}
  factory ProxySetting._fromMap(Map<String, dynamic>? map) {
    map ??= {};

    final host = map['host'];
    final port = map['port'];

    return ProxySetting._(
      host: host is String ? host : null,
      port: port != null ? int.tryParse(port.toString()) : null,
    );
  }

  /// The proxy server hostname or IP address.
  final String? host;

  /// The proxy server port number.
  final int? port;

  /// A boolean indicating if proxy settings are valid and can be used.
  bool get enabled {
    final validHost = host?.isNotEmpty ?? false;
    final validPort = port != null && port! > 0;

    return validHost && validPort;
  }
}
