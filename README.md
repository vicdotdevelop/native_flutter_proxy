[![Pub Version](https://img.shields.io/pub/v/native_flutter_proxy)](https://pub.dev/packages/native_flutter_proxy)

# native_flutter_proxy

A flutter plugin to read network proxy info from native. It can be used to set up the network proxy for flutter.
The plugin provides classes to provide the HttpOverrides.global property with a proxy setting.
This ensures that the gap of flutter in supporting proxy communication is filled by a convenient solution.

## Installing

You should add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  native_flutter_proxy: latest
```


## Example

- Step 1: make your main()-method async
- Step 2: add WidgetsFlutterBinding.ensureInitialized(); to your async-main()-method
- Step 3: read the proxy settings from the wifi profile natively
- Step 4: if enabled, override the proxy settings with the CustomProxy.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool enabled = false;
  String? host;
  int? port;
  try {
    ProxySetting settings = await NativeProxyReader.proxySetting;
    enabled = settings.enabled;
    host = settings.host;
    port = settings.port;
  } catch (e) {
    print(e);
  }
  if (enabled && host != null) {
    final proxy = CustomProxy(ipAddress: host, port: port);
    proxy.enable();
    print("proxy enabled");
  }

  runApp(MyApp());
}
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.