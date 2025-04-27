import 'dart:async';
import 'package:flutter/services.dart';

/// A flutter plugin to read network proxy info from native. It can be used to set up the network proxy for flutter.
class NativeProxyReader {
  /// channel
  static const MethodChannel _channel =
      const MethodChannel('native_flutter_proxy');

  /// ProxySetting
  static Future<ProxySetting> get proxySetting async {
    return _channel //
        .invokeMapMethod<String, dynamic>('getProxySetting')
        .then((e) => ProxySetting._fromMap(e));
  }
}

/// ProxySetting
class ProxySetting {
  /// host
  String? host;

  /// port
  int? port;

  /// private
  ProxySetting._({
    this.host,
    this.port,
  });

  /// private
  factory ProxySetting._fromMap(Map<String, dynamic>? map) {
    map ??= {};
    return ProxySetting._(
      host: map['host'],
      port: map['port'] != null //
          ? int.parse(map['port'].toString())
          : null,
    );
  }

  /// enabled
  bool get enabled =>
      (host?.isNotEmpty ?? false) && //
      (port != null && port! > 0);
}
