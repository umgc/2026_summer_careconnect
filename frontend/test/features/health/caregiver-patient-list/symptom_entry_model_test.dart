// Tests for SymptomEntry model
// (lib/features/health/caregiver-patient-list/models/symptom_entry.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/symptom_entry.dart';

void main() {
  group('SymptomEntry model', () {
    test('creates with all required fields', () {
      final entry = SymptomEntry(
        id: 's1',
        date: DateTime(2024, 12, 27),
        name: 'Headache',
        severity: 'Moderate',
      );
      expect(entry.id, 's1');
      expect(entry.date, DateTime(2024, 12, 27));
      expect(entry.name, 'Headache');
      expect(entry.severity, 'Moderate');
      expect(entry.note, isNull);
    });

    test('creates with optional note', () {
      final entry = SymptomEntry(
        id: 's2',
        date: DateTime(2024, 12, 25),
        name: 'Fatigue',
        severity: 'Severe',
        note: 'Feeling very tired after medication change',
      );
      expect(entry.note, 'Feeling very tired after medication change');
    });

    test('note defaults to null', () {
      final entry = SymptomEntry(
        id: 's3',
        date: DateTime(2024, 1, 1),
        name: 'Nausea',
        severity: 'Mild',
      );
      expect(entry.note, isNull);
    });

    test('stores Mild severity', () {
      final entry = SymptomEntry(
        id: 'a',
        date: DateTime(2024, 1, 1),
        name: 'test',
        severity: 'Mild',
      );
      expect(entry.severity, 'Mild');
    });

    test('stores Moderate severity', () {
      final entry = SymptomEntry(
        id: 'b',
        date: DateTime(2024, 1, 1),
        name: 'test',
        severity: 'Moderate',
      );
      expect(entry.severity, 'Moderate');
    });

    test('stores Severe severity', () {
      final entry = SymptomEntry(
        id: 'c',
        date: DateTime(2024, 1, 1),
        name: 'test',
        severity: 'Severe',
      );
      expect(entry.severity, 'Severe');
    });

    test('stores comma-separated symptom names', () {
      final entry = SymptomEntry(
        id: 'd',
        date: DateTime(2024, 6, 15),
        name: 'Fatigue, Headache, Joint pain',
        severity: 'Moderate',
      );
      expect(entry.name, contains('Fatigue'));
      expect(entry.name, contains('Headache'));
      expect(entry.name, contains('Joint pain'));
    });

    test('id stores unique identifier', () {
      final e1 = SymptomEntry(
        id: 'unique-1',
        date: DateTime(2024, 1, 1),
        name: 'x',
        severity: 'Mild',
      );
      final e2 = SymptomEntry(
        id: 'unique-2',
        date: DateTime(2024, 1, 1),
        name: 'x',
        severity: 'Mild',
      );
      expect(e1.id, isNot(equals(e2.id)));
    });

    test('date stores precise DateTime', () {
      final dt = DateTime(2024, 3, 15, 10, 30, 45);
      final entry = SymptomEntry(
        id: 'e',
        date: dt,
        name: 'test',
        severity: 'Mild',
      );
      expect(entry.date.year, 2024);
      expect(entry.date.month, 3);
      expect(entry.date.day, 15);
      expect(entry.date.hour, 10);
      expect(entry.date.minute, 30);
    });
  });
}
