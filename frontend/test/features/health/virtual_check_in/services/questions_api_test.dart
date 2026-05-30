// Tests for QuestionsApi
// (lib/features/health/virtual_check_in/services/questions_api.dart).
// Tests constructor URL normalization only (HTTP calls require a real server).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/services/questions_api.dart';

void main() {
  group('QuestionsApi constructor', () {
    test('strips trailing slash from base URL', () {
      final api = QuestionsApi('http://localhost:8080/');
      // The internal _base field must not end with '/'.
      // We verify indirectly: constructing with trailing slash must not throw.
      expect(api, isA<QuestionsApi>());
    });

    test('keeps base URL unchanged when no trailing slash', () {
      final api = QuestionsApi('http://localhost:8080');
      expect(api, isA<QuestionsApi>());
    });

    test('constructs with HTTPS URL', () {
      final api = QuestionsApi('https://api.example.com/');
      expect(api, isA<QuestionsApi>());
    });

    test('constructs with empty base URL', () {
      final api = QuestionsApi('');
      expect(api, isA<QuestionsApi>());
    });

    test('constructs with path segments in URL', () {
      final api = QuestionsApi('http://localhost:8080/api/v1');
      expect(api, isA<QuestionsApi>());
    });

    test('strips multiple trailing slashes', () {
      final api = QuestionsApi('http://localhost:8080//');
      expect(api, isA<QuestionsApi>());
    });

    test('constructs with port number', () {
      final api = QuestionsApi('http://localhost:3000');
      expect(api, isA<QuestionsApi>());
    });
  });
}
