// Tests for Vital model (lib/features/analytics/models/vital_model.dart).
//
// Vital.fromJson uses internal helper functions (safeDouble, safeInt, safeDate)
// that handle null, numeric, and string inputs. All branches are tested here
// without platform channels or network calls.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/analytics/models/vital_model.dart';

void main() {
  group('Vital.fromJson', () {
    test('parses all fields when fully populated with numeric values', () {
      // Verifies the happy path: all fields present as expected types.
      final json = {
        'patientId': 42,
        'timestamp': '2025-06-15T10:30:00.000',
        'heartRate': 72.5,
        'spo2': 98.0,
        'systolic': 120,
        'diastolic': 80,
        'weight': 70.2,
        'moodValue': 7,
        'painValue': 3,
      };
      final vital = Vital.fromJson(json);

      expect(vital.patientId, 42);
      expect(vital.heartRate, closeTo(72.5, 0.001));
      expect(vital.spo2, closeTo(98.0, 0.001));
      expect(vital.systolic, 120);
      expect(vital.diastolic, 80);
      expect(vital.weight, closeTo(70.2, 0.001));
      expect(vital.moodValue, 7);
      expect(vital.painValue, 3);
      expect(vital.timestamp, DateTime.parse('2025-06-15T10:30:00.000'));
    });

    test('safeDouble handles string numeric values', () {
      // Verifies that string "72.5" is parsed to double 72.5.
      final vital = Vital.fromJson({
        'patientId': 1,
        'timestamp': '2025-01-01T00:00:00.000',
        'heartRate': '72.5',
        'spo2': '98.0',
        'systolic': '120',
        'diastolic': '80',
        'weight': '70.2',
      });
      expect(vital.heartRate, closeTo(72.5, 0.001));
      expect(vital.spo2, closeTo(98.0, 0.001));
      expect(vital.weight, closeTo(70.2, 0.001));
    });

    test('safeInt handles string numeric values', () {
      // Verifies that string "120" is parsed to int 120.
      final vital = Vital.fromJson({
        'patientId': '10',
        'timestamp': '2025-01-01T00:00:00.000',
        'heartRate': 72.0,
        'spo2': 98.0,
        'systolic': '120',
        'diastolic': '80',
        'weight': 70.0,
      });
      expect(vital.patientId, 10);
      expect(vital.systolic, 120);
      expect(vital.diastolic, 80);
    });

    test('null fields fall back to defaults', () {
      // Verifies that null JSON values use the default values (0 for numeric).
      final vital = Vital.fromJson({
        'timestamp': '2025-01-01T00:00:00.000',
        'heartRate': null,
        'spo2': null,
        'systolic': null,
        'diastolic': null,
        'weight': null,
        'moodValue': null,
        'painValue': null,
      });
      expect(vital.heartRate, 0.0);
      expect(vital.spo2, 0.0);
      expect(vital.systolic, 0);
      expect(vital.diastolic, 0);
      expect(vital.weight, 0.0);
      expect(vital.moodValue, isNull);
      expect(vital.painValue, isNull);
    });

    test('moodValue and painValue are null when absent from JSON', () {
      // Verifies optional mood/pain fields are null when key is absent.
      final vital = Vital.fromJson({
        'patientId': 1,
        'timestamp': '2025-01-01T00:00:00.000',
        'heartRate': 72.0,
        'spo2': 98.0,
        'systolic': 120,
        'diastolic': 80,
        'weight': 70.0,
      });
      expect(vital.moodValue, isNull);
      expect(vital.painValue, isNull);
    });

    test('safeDate falls back to DateTime.now() for null timestamp', () {
      // Verifies that a null timestamp does not throw and returns a valid DateTime.
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final vital = Vital.fromJson({
        'patientId': 1,
        'timestamp': null,
        'heartRate': 72.0,
        'spo2': 98.0,
        'systolic': 120,
        'diastolic': 80,
        'weight': 70.0,
      });
      expect(vital.timestamp.isAfter(before), isTrue);
    });

    test('safeDate falls back to DateTime.now() for unparseable string', () {
      // Verifies that an invalid date string does not throw.
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final vital = Vital.fromJson({
        'patientId': 1,
        'timestamp': 'not-a-date',
        'heartRate': 72.0,
        'spo2': 98.0,
        'systolic': 120,
        'diastolic': 80,
        'weight': 70.0,
      });
      expect(vital.timestamp.isAfter(before), isTrue);
    });

    test('uses id field when patientId is absent', () {
      // Verifies that json["id"] is used as the fallback for patientId.
      final vital = Vital.fromJson({
        'id': 99,
        'timestamp': '2025-01-01T00:00:00.000',
        'heartRate': 72.0,
        'spo2': 98.0,
        'systolic': 120,
        'diastolic': 80,
        'weight': 70.0,
      });
      expect(vital.patientId, 99);
    });

    test('constructor stores values directly', () {
      // Verifies the direct constructor without going through fromJson.
      final ts = DateTime(2025, 1, 1);
      final vital = Vital(
        timestamp: ts,
        heartRate: 60.0,
        spo2: 97.0,
        systolic: 115,
        diastolic: 75,
        weight: 65.0,
        patientId: 5,
        moodValue: 8,
        painValue: 2,
      );
      expect(vital.patientId, 5);
      expect(vital.moodValue, 8);
      expect(vital.painValue, 2);
      expect(vital.timestamp, ts);
    });
  });
}
