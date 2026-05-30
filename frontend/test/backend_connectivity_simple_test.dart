import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/env_constant.dart';

void main() {
  group('Backend Connectivity Tests', () {
    test('getBackendBaseUrl should return valid URL', () {
      // Act
      final baseUrl = getBackendBaseUrl();

      // Assert
      expect(baseUrl, isNotNull);
      expect(baseUrl, isA<String>());
      expect(baseUrl.isNotEmpty, true);
      expect(baseUrl.contains('://'), true); // Should contain protocol
    });

    test('API endpoints should be properly constructed', () {
      // Act
      final baseUrl = getBackendBaseUrl();
      final authEndpoint = '$baseUrl/v1/api/auth';
      final usersEndpoint = '$baseUrl/v1/api/users';

      // Assert
      expect(authEndpoint, contains('/v1/api/auth'));
      expect(usersEndpoint, contains('/v1/api/users'));
    });

    test('Environment configuration should be consistent', () {
      final baseUrl = getBackendBaseUrl();
      expect(baseUrl, isNotNull);
      expect(baseUrl.length, greaterThan(0));
    });

    test('base URL starts with http or https', () {
      final baseUrl = getBackendBaseUrl();
      expect(
        baseUrl.startsWith('http://') || baseUrl.startsWith('https://'),
        isTrue,
      );
    });

    test('base URL does not end with slash', () {
      final baseUrl = getBackendBaseUrl();
      expect(baseUrl.endsWith('/'), isFalse);
    });

    test('calling getBackendBaseUrl multiple times returns same result', () {
      final first = getBackendBaseUrl();
      final second = getBackendBaseUrl();
      expect(first, second);
    });
  });
}
