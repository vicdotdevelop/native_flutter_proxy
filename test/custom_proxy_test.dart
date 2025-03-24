import 'package:flutter_test/flutter_test.dart';
import 'package:native_flutter_proxy/native_flutter_proxy.dart';

void main() {
  group('CustomProxy', () {
    test('creates instance with required parameters', () {
      const proxy = CustomProxy(ipAddress: '192.168.1.1');
      expect(proxy.ipAddress, equals('192.168.1.1'));
      expect(proxy.port, isNull);
      expect(proxy.allowBadCertificates, isFalse);
    });

    test('creates instance with all parameters', () {
      const proxy = CustomProxy(
        ipAddress: '192.168.1.1',
        port: 8080,
        allowBadCertificates: true,
      );

      expect(proxy.ipAddress, equals('192.168.1.1'));
      expect(proxy.port, equals(8080));
      expect(proxy.allowBadCertificates, isTrue);
    });

    group('fromString', () {
      test('creates instance from valid proxy string with port', () {
        final proxy = CustomProxy.fromString(proxy: '192.168.1.1:8080');

        expect(proxy, isNotNull);
        expect(proxy?.ipAddress, equals('192.168.1.1'));
        expect(proxy?.port, equals(8080));
      });
    });

    group('toString', () {
      test('returns correct string with port', () {
        const proxy = CustomProxy(ipAddress: '192.168.1.1', port: 8080);
        expect(proxy.toString(), equals('192.168.1.1:8080'));
      });

      test('returns correct string without port', () {
        const proxy = CustomProxy(ipAddress: '192.168.1.1');
        expect(proxy.toString(), equals('192.168.1.1'));
      });
    });
  });
}
