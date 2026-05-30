// Tests for ApiClient and ApiException
// (lib/config/network/api_client.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/network/api_client.dart';

void main() {
  group('ApiException', () {
    test('stores message and statusCode', () {
      final e = ApiException('Not found', 404);
      expect(e.message, 'Not found');
      expect(e.statusCode, 404);
    });

    test('toString includes message and status', () {
      final e = ApiException('Server error', 500);
      final s = e.toString();
      expect(s, contains('Server error'));
      expect(s, contains('500'));
    });

    test('implements Exception', () {
      final e = ApiException('Oops', 400);
      expect(e, isA<Exception>());
    });
  });

  group('ApiClient', () {
    test('is a singleton', () {
      final a = ApiClient();
      final b = ApiClient();
      expect(identical(a, b), isTrue);
    });

    test('returns same instance on multiple calls', () {
      final instances = List.generate(3, (_) => ApiClient());
      expect(instances.every((i) => identical(i, instances.first)), isTrue);
    });
  });

  group('ApiException additional', () {
    test('stores null-like empty message', () {
      final e = ApiException('', 0);
      expect(e.message, '');
      expect(e.statusCode, 0);
    });

    test('toString returns non-empty string', () {
      final e = ApiException('test', 200);
      expect(e.toString().isNotEmpty, isTrue);
    });
  });
}
