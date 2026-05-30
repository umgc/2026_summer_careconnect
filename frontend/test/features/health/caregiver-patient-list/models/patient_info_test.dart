// Tests for Patient (lib/features/health/caregiver-patient-list/models/patient-info.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';

Patient _basic() => Patient(
      id: 'p-1',
      firstName: 'Jane',
      lastName: 'Doe',
      lastUpdated: DateTime(2025, 1, 1),
      statusMessage: 'Feeling well',
      nextCheckIn: DateTime(2025, 1, 8),
      mood: 'Good',
      moodEmoji: '😊',
      isUrgent: false,
    );

void main() {
  group('Patient constructor', () {
    test('stores required fields', () {
      final p = _basic();
      expect(p.id, 'p-1');
      expect(p.firstName, 'Jane');
      expect(p.lastName, 'Doe');
      expect(p.statusMessage, 'Feeling well');
      expect(p.mood, 'Good');
      expect(p.moodEmoji, '😊');
      expect(p.isUrgent, isFalse);
    });

    test('messageCount defaults to 0', () {
      expect(_basic().messageCount, 0);
    });

    test('messageCount can be set', () {
      final p = Patient(
        id: 'p-2',
        firstName: 'John',
        lastName: 'Smith',
        lastUpdated: DateTime(2025, 2, 1),
        statusMessage: 'Has messages',
        nextCheckIn: DateTime(2025, 2, 8),
        mood: 'Fair',
        moodEmoji: '😐',
        isUrgent: true,
        messageCount: 5,
      );
      expect(p.messageCount, 5);
      expect(p.isUrgent, isTrue);
    });
  });

  group('Patient.fullName', () {
    test('concatenates firstName and lastName', () {
      expect(_basic().fullName, 'Jane Doe');
    });

    test('works with middle-name-like last names', () {
      final p = Patient(
        id: 'p-3',
        firstName: 'Mary',
        lastName: 'Van der Berg',
        lastUpdated: DateTime(2025, 3, 1),
        statusMessage: '',
        nextCheckIn: DateTime(2025, 3, 8),
        mood: 'Good',
        moodEmoji: '😊',
        isUrgent: false,
      );
      expect(p.fullName, 'Mary Van der Berg');
    });
  });

  group('Patient dates', () {
    test('lastUpdated is stored correctly', () {
      final dt = DateTime(2025, 6, 15, 10, 30);
      final p = Patient(
        id: 'p-4',
        firstName: 'A',
        lastName: 'B',
        lastUpdated: dt,
        statusMessage: '',
        nextCheckIn: DateTime(2025, 6, 22),
        mood: 'OK',
        moodEmoji: '😐',
        isUrgent: false,
      );
      expect(p.lastUpdated, dt);
    });

    test('nextCheckIn is stored correctly', () {
      final dt = DateTime(2025, 7, 1);
      final p = Patient(
        id: 'p-5',
        firstName: 'C',
        lastName: 'D',
        lastUpdated: DateTime(2025, 6, 24),
        statusMessage: '',
        nextCheckIn: dt,
        mood: 'Good',
        moodEmoji: '🙂',
        isUrgent: false,
      );
      expect(p.nextCheckIn, dt);
    });
  });
}
