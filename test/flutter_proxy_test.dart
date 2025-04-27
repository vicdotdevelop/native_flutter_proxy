import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/native_proxy_reader.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_flutter_proxy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return <String, dynamic>{
        'host': '192.168.1.9',
        'port': 9909,
      };
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getProxySetting', () async {
    final setting = await NativeProxyReader.proxySetting;
    expect(setting.enabled, true);
  });
}
