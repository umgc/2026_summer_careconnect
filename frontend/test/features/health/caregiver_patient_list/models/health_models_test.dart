// Tests for health domain models:
//   MoodEntry    (models/mood_entry.dart)
//   SymptomEntry (models/symptom_entry.dart)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/mood_entry.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/symptom_entry.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // MoodEntry
  // ───────────────────────────────────────────────────────────────────────────
  group('MoodEntry', () {
    test('stores all required fields', () {
      final date = DateTime(2024, 6, 15, 10, 30);
      final entry = MoodEntry(
        id: 'mood-001',
        date: date,
        score10: 8,
        label: 'Happy',
        emoji: '😀',
      );
      expect(entry.id, 'mood-001');
      expect(entry.date, date);
      expect(entry.score10, 8);
      expect(entry.label, 'Happy');
      expect(entry.emoji, '😀');
    });

    test('note defaults to null when not provided', () {
      final entry = MoodEntry(
        id: 'mood-002',
        date: DateTime.now(),
        score10: 5,
        label: 'Neutral',
        emoji: '😐',
      );
      expect(entry.note, isNull);
    });

    test('stores optional note when provided', () {
      final entry = MoodEntry(
        id: 'mood-003',
        date: DateTime.now(),
        score10: 3,
        label: 'Sad',
        emoji: '😔',
        note: 'Feeling under the weather',
      );
      expect(entry.note, 'Feeling under the weather');
    });

    test('accepts score10 = 0 (minimum)', () {
      final entry = MoodEntry(
        id: 'mood-min',
        date: DateTime.now(),
        score10: 0,
        label: 'Very Low',
        emoji: '😢',
      );
      expect(entry.score10, 0);
    });

    test('accepts score10 = 10 (maximum)', () {
      final entry = MoodEntry(
        id: 'mood-max',
        date: DateTime.now(),
        score10: 10,
        label: 'Excellent',
        emoji: '🤩',
      );
      expect(entry.score10, 10);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // SymptomEntry
  // ───────────────────────────────────────────────────────────────────────────
  group('SymptomEntry', () {
    test('stores all required fields', () {
      final date = DateTime(2024, 6, 15, 14, 0);
      final entry = SymptomEntry(
        id: 'sym-001',
        date: date,
        name: 'Headache',
        severity: 'Mild',
      );
      expect(entry.id, 'sym-001');
      expect(entry.date, date);
      expect(entry.name, 'Headache');
      expect(entry.severity, 'Mild');
    });

    test('note defaults to null when not provided', () {
      final entry = SymptomEntry(
        id: 'sym-002',
        date: DateTime.now(),
        name: 'Fatigue',
        severity: 'Moderate',
      );
      expect(entry.note, isNull);
    });

    test('stores optional note when provided', () {
      final entry = SymptomEntry(
        id: 'sym-003',
        date: DateTime.now(),
        name: 'Nausea',
        severity: 'Severe',
        note: 'After taking medication',
      );
      expect(entry.note, 'After taking medication');
    });

    test('accepts "Mild" severity', () {
      final entry = SymptomEntry(
        id: 'sym-mild',
        date: DateTime.now(),
        name: 'Cough',
        severity: 'Mild',
      );
      expect(entry.severity, 'Mild');
    });

    test('accepts "Moderate" severity', () {
      final entry = SymptomEntry(
        id: 'sym-mod',
        date: DateTime.now(),
        name: 'Fever',
        severity: 'Moderate',
      );
      expect(entry.severity, 'Moderate');
    });

    test('accepts "Severe" severity', () {
      final entry = SymptomEntry(
        id: 'sym-sev',
        date: DateTime.now(),
        name: 'Chest pain',
        severity: 'Severe',
      );
      expect(entry.severity, 'Severe');
    });
  });
}
