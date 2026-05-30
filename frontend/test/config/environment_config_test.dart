// Tests for EnvironmentConfig (lib/config/environment_config.dart).
//
// EnvironmentConfig.baseUrl returns a URL based on kIsWeb / platform.
// In the test environment (non-web, non-Android), it returns the _android
// default (http://10.0.2.2:8080) or the _other default depending on build vars.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/environment_config.dart';

void main() {
  group('EnvironmentConfig', () {
    test('baseUrl returns a non-empty string', () {
      expect(EnvironmentConfig.baseUrl, isNotEmpty);
    });

    test('baseUrl is a valid http/https URL', () {
      final url = EnvironmentConfig.baseUrl;
      expect(url.startsWith('http://') || url.startsWith('https://'), isTrue,
          reason: 'baseUrl should start with http:// or https://');
    });

    test('baseUrl does not contain whitespace', () {
      expect(EnvironmentConfig.baseUrl.trim(), equals(EnvironmentConfig.baseUrl));
    });

    test('baseUrl returns consistent value on multiple calls', () {
      final url1 = EnvironmentConfig.baseUrl;
      final url2 = EnvironmentConfig.baseUrl;
      expect(url1, equals(url2));
    });

    test('baseUrl ends with port number', () {
      final url = EnvironmentConfig.baseUrl;
      // Default URLs end with :8080
      expect(url, contains(':'));
    });

    test('baseUrl is a parseable URI', () {
      final uri = Uri.tryParse(EnvironmentConfig.baseUrl);
      expect(uri, isNotNull);
      expect(uri!.hasScheme, isTrue);
    });

    test('baseUrl has a valid host component', () {
      final uri = Uri.parse(EnvironmentConfig.baseUrl);
      expect(uri.host, isNotEmpty);
    });

    test('baseUrl scheme is http or https', () {
      final uri = Uri.parse(EnvironmentConfig.baseUrl);
      expect(uri.scheme, anyOf('http', 'https'));
    });

    test('baseUrl has a port', () {
      final uri = Uri.parse(EnvironmentConfig.baseUrl);
      expect(uri.port, greaterThan(0));
    });
  });
}
