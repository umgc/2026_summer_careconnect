// Tests for Template and ScheduledNotification models.
// Template lives in lib/features/tasks/models/template_model.dart;
// ScheduledNotification in lib/features/notifications/models/scheduled_notification_model.dart.
//
// Both are pure-Dart data classes with fromJson/toJson.
// No platform channels or network I/O required.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/tasks/models/template_model.dart';
import 'package:care_connect_app/features/notifications/models/scheduled_notification_model.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────
  // ScheduledNotification
  // ──────────────────────────────────────────────────────────────────

  group('ScheduledNotification.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path with every JSON key present.
      final json = {
        'id': 10,
        'taskId': 5,
        'receiverId': 99,
        'title': 'Take meds',
        'body': 'Time for your medication',
        'notificationType': 'REMINDER',
        'scheduledTime': '2025-06-15T08:00:00.000',
        'sentTime': '2025-06-15T08:00:01.000',
        'status': 'SENT',
        'messageId': 'msg-abc',
        'errorMessage': null,
      };
      final n = ScheduledNotification.fromJson(json);

      expect(n.id, 10);
      expect(n.taskId, 5);
      expect(n.receiverId, 99);
      expect(n.title, 'Take meds');
      expect(n.body, 'Time for your medication');
      expect(n.notificationType, 'REMINDER');
      expect(n.scheduledTime, DateTime.parse('2025-06-15T08:00:00.000'));
      expect(n.sentTime, DateTime.parse('2025-06-15T08:00:01.000'));
      expect(n.status, 'SENT');
      expect(n.messageId, 'msg-abc');
      expect(n.errorMessage, isNull);
    });

    test('sentTime is null when absent from JSON', () {
      // Verifies the null sentTime branch.
      final n = ScheduledNotification.fromJson({
        'id': 1,
        'receiverId': 1,
        'title': 'T',
        'body': 'B',
        'scheduledTime': '2025-01-01T00:00:00.000',
        'sentTime': null,
        'status': 'PENDING',
      });
      expect(n.sentTime, isNull);
    });

    test('status defaults to PENDING when absent', () {
      // Verifies the default status fallback.
      final n = ScheduledNotification.fromJson({
        'receiverId': 1,
        'title': 'T',
        'body': 'B',
        'scheduledTime': '2025-01-01T00:00:00.000',
      });
      expect(n.status, 'PENDING');
    });

    test('id defaults to -1 when absent', () {
      // Verifies the id ?? -1 fallback.
      final n = ScheduledNotification.fromJson({
        'receiverId': 1,
        'title': 'T',
        'body': 'B',
        'scheduledTime': '2025-01-01T00:00:00.000',
      });
      expect(n.id, -1);
    });
  });

  group('ScheduledNotification.toJson', () {
    test('serializes required fields correctly', () {
      // Verifies that toJson produces the expected map.
      final n = ScheduledNotification(
        taskId: 3,
        receiverId: 7,
        title: 'Alert',
        body: 'Body text',
        notificationType: 'ALERT',
        scheduledTime: DateTime.utc(2025, 6, 15, 8, 0),
      );
      final json = n.toJson();
      expect(json['taskId'], 3);
      expect(json['receiverId'], 7);
      expect(json['title'], 'Alert');
      expect(json['body'], 'Body text');
      expect(json['notificationType'], 'ALERT');
      expect(json['scheduledTime'], isA<String>());
    });

    test('scheduledTime is an ISO-8601 string', () {
      // Verifies the ISO-8601 encoding of scheduledTime.
      final n = ScheduledNotification(
        receiverId: 1,
        title: 'T',
        body: 'B',
        scheduledTime: DateTime.utc(2025, 1, 15, 10, 30),
      );
      final json = n.toJson();
      final parsed = DateTime.parse(json['scheduledTime'] as String);
      expect(parsed.month, 1);
      expect(parsed.day, 15);
      expect(parsed.hour, 10);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // Template
  // ──────────────────────────────────────────────────────────────────

  group('Template.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path with every JSON key present.
      final json = {
        'id': 1,
        'name': 'Morning Routine',
        'description': 'Daily morning tasks',
        'frequency': 'DAILY',
        'taskInterval': 1,
        'doCount': 3,
        'daysOfWeek': [true, false, true, false, true, false, false],
        'timeOfDay': '08:30',
        'icon': 0xe88a,
        'notifications': [
          {
            'id': 1,
            'receiverId': 1,
            'title': 'Reminder',
            'body': 'Do your morning routine',
            'scheduledTime': '2025-06-15T08:30:00.000',
          },
        ],
      };
      final t = Template.fromJson(json);

      expect(t.id, 1);
      expect(t.name, 'Morning Routine');
      expect(t.description, 'Daily morning tasks');
      expect(t.frequency, 'DAILY');
      expect(t.interval, 1);
      expect(t.count, 3);
      expect(t.daysOfWeek, [true, false, true, false, true, false, false]);
      expect(t.timeOfDay, const TimeOfDay(hour: 8, minute: 30));
      expect(t.iconCode, 0xe88a);
      expect(t.notifications, isNotNull);
      expect(t.notifications!.length, 1);
      expect(t.notifications!.first.title, 'Reminder');
    });

    test('optional fields are null when absent', () {
      // Verifies that null/absent optional JSON keys produce null fields.
      final json = {
        'id': 2,
        'name': 'Minimal',
        'description': 'Minimal template',
      };
      final t = Template.fromJson(json);

      expect(t.frequency, isNull);
      expect(t.interval, isNull);
      expect(t.count, isNull);
      expect(t.daysOfWeek, isNull);
      expect(t.timeOfDay, isNull);
      expect(t.notifications, isNull);
    });

    test('iconCode defaults to 0xe057 when icon is absent', () {
      // Verifies the default icon codePoint fallback.
      final t = Template.fromJson({
        'id': 1,
        'name': 'N',
        'description': 'D',
      });
      expect(t.iconCode, 0xe057);
    });

    test('timeOfDay is null when timeOfDay JSON key is null', () {
      // Verifies null timeOfDay produces null TimeOfDay.
      final t = Template.fromJson({
        'id': 1,
        'name': 'N',
        'description': 'D',
        'timeOfDay': null,
      });
      expect(t.timeOfDay, isNull);
    });

    test('parses timeOfDay with single-digit hour and minute', () {
      // Verifies the "H:M" split works for single-digit components.
      final t = Template.fromJson({
        'id': 1,
        'name': 'N',
        'description': 'D',
        'timeOfDay': '9:5',
      });
      expect(t.timeOfDay, const TimeOfDay(hour: 9, minute: 5));
    });
  });

  group('Template.toJson', () {
    test('serializes all fields correctly', () {
      // Verifies toJson round-trips a fully-populated Template.
      final t = Template(
        id: 1,
        name: 'Test',
        description: 'Desc',
        frequency: 'WEEKLY',
        interval: 2,
        count: 5,
        daysOfWeek: [true, true, false, false, false, false, false],
        timeOfDay: const TimeOfDay(hour: 9, minute: 30),
        iconCode: 0xe88a,
      );
      final json = t.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['description'], 'Desc');
      expect(json['frequency'], 'WEEKLY');
      expect(json['taskInterval'], 2);
      expect(json['doCount'], 5);
      expect(json['daysOfWeek'], [true, true, false, false, false, false, false]);
      expect(json['timeOfDay'], '9:30');
      expect(json['icon'], 0xe88a);
      expect(json['notifications'], isNull);
    });

    test('timeOfDay is null in JSON when not set', () {
      // Verifies that a null timeOfDay field serializes as null.
      final t = Template(id: 1, name: 'N', description: 'D');
      final json = t.toJson();
      expect(json['timeOfDay'], isNull);
    });

    test('notifications list is serialized when present', () {
      // Verifies that notifications are included in toJson output.
      final notif = ScheduledNotification(
        receiverId: 1,
        title: 'T',
        body: 'B',
        scheduledTime: DateTime.utc(2025, 1, 1),
      );
      final t = Template(
        id: 1,
        name: 'N',
        description: 'D',
        notifications: [notif],
      );
      final json = t.toJson();
      expect(json['notifications'], isA<List>());
      expect((json['notifications'] as List).length, 1);
    });
  });
}
