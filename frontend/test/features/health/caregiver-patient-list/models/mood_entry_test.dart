// Tests for MoodEntry (lib/features/health/caregiver-patient-list/models/mood_entry.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/mood_entry.dart';

void main() {
  group('MoodEntry constructor', () {
    test('stores all required fields', () {
      final dt = DateTime(2025, 1, 15);
      final entry = MoodEntry(
        id: 'me-1',
        date: dt,
        score10: 8,
        label: 'Happy',
        emoji: '😀',
      );
      expect(entry.id, 'me-1');
      expect(entry.date, dt);
      expect(entry.score10, 8);
      expect(entry.label, 'Happy');
      expect(entry.emoji, '😀');
      expect(entry.note, isNull);
    });

    test('stores optional note', () {
      final entry = MoodEntry(
        id: 'me-2',
        date: DateTime(2025, 2, 1),
        score10: 3,
        label: 'Anxious',
        emoji: '😰',
        note: 'Feeling stressed today',
      );
      expect(entry.note, 'Feeling stressed today');
    });

    test('score10 boundary: 0', () {
      final entry = MoodEntry(
        id: 'me-3',
        date: DateTime(2025, 3, 1),
        score10: 0,
        label: 'Terrible',
        emoji: '😭',
      );
      expect(entry.score10, 0);
    });

    test('score10 boundary: 10', () {
      final entry = MoodEntry(
        id: 'me-4',
        date: DateTime(2025, 3, 2),
        score10: 10,
        label: 'Excellent',
        emoji: '🌟',
      );
      expect(entry.score10, 10);
    });

    test('empty label is accepted', () {
      final entry = MoodEntry(
        id: 'me-5',
        date: DateTime(2025, 4, 1),
        score10: 5,
        label: '',
        emoji: '',
      );
      expect(entry.label, '');
      expect(entry.emoji, '');
    });

    test('is a MoodEntry type', () {
      final entry = MoodEntry(
        id: 'me-6',
        date: DateTime(2025, 5, 1),
        score10: 7,
        label: 'Good',
        emoji: '🙂',
      );
      expect(entry, isA<MoodEntry>());
    });
  });
}
