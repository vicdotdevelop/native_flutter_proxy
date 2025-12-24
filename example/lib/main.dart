import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_flutter_proxy/native_flutter_proxy.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final proxyInfoNotifier = ValueNotifier<ProxyInfo>(
    const ProxyInfo(enabled: false, applied: false),
  );

  Future<void> updateProxyInfo(ProxySetting settings) async {
    final enabled = settings.enabled;
    final host = settings.host;
    final port = settings.port;
    var applied = false;

    if (enabled && host != null) {
      final proxy = CustomProxy(ipAddress: host, port: port);
      proxy.enable();
      applied = true;
      debugPrint('====\nProxy enabled\n====');
    } else {
      HttpOverrides.global = null;
      debugPrint('====\nProxy disabled\n====');
    }

    proxyInfoNotifier.value = ProxyInfo(
      enabled: enabled,
      applied: applied,
      host: host,
      port: port,
    );
  }

  Future<void> handleError(Object error) async {
    HttpOverrides.global = null;
    final message = error.toString();
    debugPrint(message);
    proxyInfoNotifier.value = ProxyInfo(
      enabled: false,
      applied: false,
      error: message,
    );
  }

  try {
    final settings = await NativeProxyReader.proxySetting;
    await updateProxyInfo(settings);
  } catch (e) {
    await handleError(e);
  }

  NativeProxyReader.setProxyChangedCallback((settings) async {
    debugPrint('Callback for proxy change was used');
    try {
      await updateProxyInfo(settings);
    } catch (e) {
      await handleError(e);
    }
  });

  runApp(App(proxyInfoListenable: proxyInfoNotifier));
}
