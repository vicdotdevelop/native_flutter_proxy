import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_flutter_proxy/src/native_proxy_reader.dart';

void main() {
  const channel = MethodChannel('native_flutter_proxy');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getProxySetting') {
        return <String, dynamic>{
          'host': '192.168.1.9',
          'port': 9909,
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativeProxyReader', () {
    test('returns valid proxy settings when data is available', () async {
      final setting = await NativeProxyReader.proxySetting;

      expect(setting.host, equals('192.168.1.9'));
      expect(setting.port, equals(9909));
      expect(setting.enabled, isTrue);
    });
  });
}
