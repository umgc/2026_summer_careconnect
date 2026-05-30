// Tests for ConnectionRequestResponse model
// (lib/features/dashboard/models/connection_request_model.dart).
//
// Pure-Dart model with fromJson factory and an isSuccess getter.
// No platform channels or network calls.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/dashboard/models/connection_request_model.dart';

void main() {
  group('ConnectionRequestResponse.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path where message, requestId, and error are all present.
      final model = ConnectionRequestResponse.fromJson({
        'message': 'Request sent',
        'requestId': 42,
        'error': null,
      });
      expect(model.message, 'Request sent');
      expect(model.requestId, 42);
      expect(model.error, isNull);
    });

    test('parses error field when present', () {
      // Verifies that an error string is stored correctly.
      final model = ConnectionRequestResponse.fromJson({
        'message': null,
        'requestId': null,
        'error': 'Not found',
      });
      expect(model.error, 'Not found');
      expect(model.requestId, isNull);
    });

    test('returns null fields when JSON values are absent', () {
      // Verifies that missing JSON keys produce null fields.
      final model = ConnectionRequestResponse.fromJson({});
      expect(model.message, isNull);
      expect(model.requestId, isNull);
      expect(model.error, isNull);
    });
  });

  group('ConnectionRequestResponse.isSuccess', () {
    test('returns true when requestId is set and error is null', () {
      // Verifies the success case: requestId present, no error.
      final model = ConnectionRequestResponse(
        message: 'OK',
        requestId: 1,
        error: null,
      );
      expect(model.isSuccess, isTrue);
    });

    test('returns false when requestId is null', () {
      // Verifies that a missing requestId means not-success.
      final model = ConnectionRequestResponse(
        message: 'Pending',
        requestId: null,
        error: null,
      );
      expect(model.isSuccess, isFalse);
    });

    test('returns false when error is present (even if requestId is set)', () {
      // Verifies that an error field overrides a valid requestId.
      final model = ConnectionRequestResponse(
        message: null,
        requestId: 5,
        error: 'Something went wrong',
      );
      expect(model.isSuccess, isFalse);
    });

    test('returns false when both requestId and error are null', () {
      // Verifies the empty-response case.
      final model = ConnectionRequestResponse();
      expect(model.isSuccess, isFalse);
    });
  });
}
