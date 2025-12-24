import 'package:flutter/material.dart';
import 'package:native_flutter_proxy/native_flutter_proxy.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool enabled = false;
  String? host;
  int? port;
  bool applied = false;
  String? error;

  try {
    ProxySetting settings = await NativeProxyReader.proxySetting;
    NativeProxyReader.setProxyChangedCallback((_) async {
      debugPrint('Callback for proxy change');
    });

    enabled = settings.enabled;
    host = settings.host;
    port = settings.port;
  } catch (e) {
    error = e.toString();
    debugPrint(error);
  }

  if (enabled && host != null) {
    final proxy = CustomProxy(ipAddress: host, port: port);
    proxy.enable();
    applied = true;
    debugPrint("====\nProxy enabled\n====");
  } else {
    debugPrint("====\nProxy disabled\n====");
  }

  runApp(
    App(
      proxyInfo: ProxyInfo(
        enabled: enabled,
        applied: applied,
        host: host,
        port: port,
        error: error,
      ),
    ),
  );
}
