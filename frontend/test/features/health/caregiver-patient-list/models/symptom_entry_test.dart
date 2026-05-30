// Tests for SymptomEntry (lib/features/health/caregiver-patient-list/models/symptom_entry.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/symptom_entry.dart';

void main() {
  group('SymptomEntry constructor', () {
    test('stores all required fields', () {
      final dt = DateTime(2025, 6, 10);
      final entry = SymptomEntry(
        id: 'se-1',
        date: dt,
        name: 'Headache',
        severity: 'Mild',
      );
      expect(entry.id, 'se-1');
      expect(entry.date, dt);
      expect(entry.name, 'Headache');
      expect(entry.severity, 'Mild');
      expect(entry.note, isNull);
    });

    test('stores optional note', () {
      final entry = SymptomEntry(
        id: 'se-2',
        date: DateTime(2025, 7, 1),
        name: 'Nausea',
        severity: 'Moderate',
        note: 'After lunch',
      );
      expect(entry.note, 'After lunch');
    });

    test('severity can be Severe', () {
      final entry = SymptomEntry(
        id: 'se-3',
        date: DateTime(2025, 8, 1),
        name: 'Chest Pain',
        severity: 'Severe',
      );
      expect(entry.severity, 'Severe');
    });

    test('empty name is accepted', () {
      final entry = SymptomEntry(
        id: 'se-4',
        date: DateTime(2025, 9, 1),
        name: '',
        severity: 'Mild',
      );
      expect(entry.name, '');
    });

    test('empty id is accepted', () {
      final entry = SymptomEntry(
        id: '',
        date: DateTime(2025, 9, 2),
        name: 'Dizziness',
        severity: 'Moderate',
      );
      expect(entry.id, '');
    });

    test('is a SymptomEntry type', () {
      final entry = SymptomEntry(
        id: 'se-5',
        date: DateTime(2025, 10, 1),
        name: 'Fatigue',
        severity: 'Mild',
      );
      expect(entry, isA<SymptomEntry>());
    });
  });
}
