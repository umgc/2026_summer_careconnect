// Tests for TaskUtils
// (lib/features/tasks/utils/task_utils.dart)

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/tasks/utils/task_utils.dart';

void main() {
  group('TaskUtils.normalizeDate', () {
    test('strips time components', () {
      final dt = DateTime(2024, 6, 15, 14, 35, 55);
      final result = TaskUtils.normalizeDate(dt);
      expect(result, DateTime(2024, 6, 15));
    });

    test('returns same date when time is midnight', () {
      final dt = DateTime(2024, 1, 1, 0, 0, 0);
      final result = TaskUtils.normalizeDate(dt);
      expect(result, DateTime(2024, 1, 1));
    });
  });

  group('TaskUtils.isSameDay', () {
    test('returns true for same day', () {
      final a = DateTime(2024, 1, 10, 8, 0);
      final b = DateTime(2024, 1, 10, 20, 0);
      expect(TaskUtils.isSameDay(a, b), isTrue);
    });

    test('returns false for different day', () {
      final a = DateTime(2024, 1, 10);
      final b = DateTime(2024, 1, 11);
      expect(TaskUtils.isSameDay(a, b), isFalse);
    });

    test('returns false when b is null', () {
      final a = DateTime(2024, 1, 10);
      expect(TaskUtils.isSameDay(a, null), isFalse);
    });

    test('returns false for same day different month', () {
      final a = DateTime(2024, 1, 10);
      final b = DateTime(2024, 2, 10);
      expect(TaskUtils.isSameDay(a, b), isFalse);
    });

    test('returns false for same day different year', () {
      final a = DateTime(2024, 1, 10);
      final b = DateTime(2025, 1, 10);
      expect(TaskUtils.isSameDay(a, b), isFalse);
    });
  });

  group('TaskUtils.getStartOfWeek', () {
    // Use January dates to avoid DST transitions
    test('Monday start: returns Monday for a Wednesday', () {
      final wednesday = DateTime(2024, 1, 10); // Wednesday
      final result = TaskUtils.getStartOfWeek(wednesday, mondayStart: true);
      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 8); // Monday
    });

    test('Monday start: returns same day for a Monday', () {
      final monday = DateTime(2024, 1, 8); // Monday
      final result = TaskUtils.getStartOfWeek(monday, mondayStart: true);
      expect(result.day, 8);
    });

    test('Sunday start: returns Sunday for a Wednesday', () {
      final wednesday = DateTime(2024, 1, 10); // Wednesday
      final result = TaskUtils.getStartOfWeek(wednesday, mondayStart: false);
      expect(result.year, 2024);
      expect(result.month, 1);
      expect(result.day, 7); // Sunday Jan 7
    });

    test('strips time from result', () {
      final dt = DateTime(2024, 1, 10, 15, 30, 45);
      final result = TaskUtils.getStartOfWeek(dt);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });

  group('TaskUtils.normalizeTaskMap', () {
    test('replaces space with T in date string', () {
      final map = <String, dynamic>{'date': '2024-01-10 12:00:00', 'name': 'Test'};
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['date'], '2024-01-10T12:00:00');
    });

    test('leaves date unchanged when T already present', () {
      final map = <String, dynamic>{'date': '2024-01-10T12:00:00', 'name': 'Test'};
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['date'], '2024-01-10T12:00:00');
    });

    test('parses daysOfWeek from JSON string', () {
      final map = <String, dynamic>{
        'date': '2024-01-10T00:00:00',
        'daysOfWeek': jsonEncode([true, false, true, false, true, false, false]),
      };
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['daysOfWeek'], [true, false, true, false, true, false, false]);
    });

    test('maps completed to isComplete when isComplete is null', () {
      final map = <String, dynamic>{
        'date': '2024-01-10T00:00:00',
        'completed': true,
        'isComplete': null,
      };
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['isComplete'], isTrue);
    });

    test('keeps isComplete when already set', () {
      final map = <String, dynamic>{
        'date': '2024-01-10T00:00:00',
        'completed': false,
        'isComplete': true,
      };
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['isComplete'], isTrue);
    });

    test('handles invalid daysOfWeek JSON string gracefully', () {
      final map = <String, dynamic>{
        'date': '2024-01-10T00:00:00',
        'daysOfWeek': 'not-valid-json',
      };
      final result = TaskUtils.normalizeTaskMap(map);
      expect(result['daysOfWeek'], isEmpty);
    });
  });
}
