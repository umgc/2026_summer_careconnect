// Tests for caregiver-patient-list model classes:
// - MoodEntry (lib/features/health/caregiver-patient-list/models/mood_entry.dart)
// - SymptomEntry (lib/features/health/caregiver-patient-list/models/symptom_entry.dart)
// - Patient.fullName getter (lib/features/health/caregiver-patient-list/models/patient-info.dart)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/mood_entry.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/symptom_entry.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';

void main() {
  group('MoodEntry', () {
    test('constructor stores all fields', () {
      final entry = MoodEntry(
        id: 'me-1',
        date: DateTime(2024, 6, 10),
        score10: 7,
        label: 'Happy',
        emoji: '😊',
        note: 'Feeling good today',
      );

      expect(entry.id, 'me-1');
      expect(entry.date, DateTime(2024, 6, 10));
      expect(entry.score10, 7);
      expect(entry.label, 'Happy');
      expect(entry.emoji, '😊');
      expect(entry.note, 'Feeling good today');
    });

    test('note defaults to null when not provided', () {
      final entry = MoodEntry(
        id: 'me-2',
        date: DateTime(2024, 6, 11),
        score10: 3,
        label: 'Anxious',
        emoji: '😟',
      );
      expect(entry.note, isNull);
    });
  });

  group('SymptomEntry', () {
    test('constructor stores all fields', () {
      final entry = SymptomEntry(
        id: 'se-1',
        date: DateTime(2024, 7, 4),
        name: 'Headache',
        severity: 'Moderate',
        note: 'Worsens in bright light',
      );

      expect(entry.id, 'se-1');
      expect(entry.date, DateTime(2024, 7, 4));
      expect(entry.name, 'Headache');
      expect(entry.severity, 'Moderate');
      expect(entry.note, 'Worsens in bright light');
    });

    test('note defaults to null when not provided', () {
      final entry = SymptomEntry(
        id: 'se-2',
        date: DateTime(2024, 7, 5),
        name: 'Nausea',
        severity: 'Mild',
      );
      expect(entry.note, isNull);
    });
  });

  group('Patient', () {
    test('fullName combines firstName and lastName', () {
      final patient = Patient(
        id: 'p-1',
        firstName: 'Alice',
        lastName: 'Smith',
        lastUpdated: DateTime.now(),
        statusMessage: 'Stable',
        nextCheckIn: DateTime.now().add(const Duration(days: 1)),
        mood: 'Happy',
        moodEmoji: '😊',
        isUrgent: false,
      );
      expect(patient.fullName, 'Alice Smith');
    });

    test('messageCount defaults to 0', () {
      final patient = Patient(
        id: 'p-2',
        firstName: 'Bob',
        lastName: 'Jones',
        lastUpdated: DateTime.now(),
        statusMessage: 'Stable',
        nextCheckIn: DateTime.now(),
        mood: 'Calm',
        moodEmoji: '😐',
        isUrgent: false,
      );
      expect(patient.messageCount, 0);
    });
  });
}
