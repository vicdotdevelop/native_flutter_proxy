[![Pub Version](https://img.shields.io/pub/v/native_flutter_proxy)](https://pub.dev/packages/native_flutter_proxy)

# native_flutter_proxy

A Flutter plugin to read system proxy settings from native code and apply them in Dart.
Use it to configure `HttpOverrides.global` with either the system proxy or a custom proxy.

Key features:
- Read system proxy settings on Android and iOS.
- Auto-update when the system proxy changes via `NativeProxyReader.setProxyChangedCallback`.
- Apply a custom proxy using `CustomProxy` / `CustomProxyHttpOverride`.

## Installing

You should add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  native_flutter_proxy: ^0.3.0
```

## Quick Start

```dart
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:native_flutter_proxy/native_flutter_proxy.dart';

Future<void> applyProxy(ProxySetting settings) async {
  if (!settings.enabled || settings.host == null) {
    HttpOverrides.global = null;
    return;
  }

  CustomProxy(ipAddress: settings.host!, port: settings.port).enable();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final settings = await NativeProxyReader.proxySetting;
    await applyProxy(settings);
  } catch (e) {
    print(e);
  }

  NativeProxyReader.setProxyChangedCallback((settings) async {
    await applyProxy(settings);
  });

  runApp(MyApp());
}
```

## Auto-update on proxy changes

`NativeProxyReader.setProxyChangedCallback` is invoked whenever the system proxy
changes, so your app can react immediately (including PAC-based proxies on
Android). Register it once at startup and update your overrides there.

## Manual proxy (optional)

If you want to force a proxy (e.g. for debugging), you can set it directly:

```dart
final proxy = CustomProxy(ipAddress: '127.0.0.1', port: 8888);
proxy.enable();
```

For a full example, see `example/lib/main.dart`.
