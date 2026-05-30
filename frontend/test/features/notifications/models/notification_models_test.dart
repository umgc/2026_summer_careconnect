// Tests for notification models:
// Notification_dto (notification_model.dart)
// ScheduledNotification (scheduled_notification_model.dart)

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/notifications/models/notification_model.dart';
import 'package:care_connect_app/features/notifications/models/scheduled_notification_model.dart';

void main() {
  group('Notification_dto', () {
    test('constructor stores all fields', () {
      final dt = DateTime(2024, 1, 15, 10, 30);
      final n = Notification_dto(
        id: 1,
        title: 'Test Title',
        message: 'Test Message',
        timestamp: dt,
        isRead: true,
      );
      expect(n.id, 1);
      expect(n.title, 'Test Title');
      expect(n.message, 'Test Message');
      expect(n.timestamp, dt);
      expect(n.isRead, isTrue);
    });

    test('isRead defaults to false', () {
      final n = Notification_dto(
        id: 2,
        title: 'Title',
        message: 'Message',
        timestamp: DateTime.now(),
      );
      expect(n.isRead, isFalse);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 10,
        'title': 'Reminder',
        'message': 'Take your medication',
        'timestamp': '2024-03-01T09:00:00.000',
        'isRead': true,
      };
      final n = Notification_dto.fromJson(json);
      expect(n.id, 10);
      expect(n.title, 'Reminder');
      expect(n.message, 'Take your medication');
      expect(n.isRead, isTrue);
    });

    test('fromJson defaults isRead to false when absent', () {
      final json = {
        'id': 11,
        'title': 'Alert',
        'message': 'Something happened',
        'timestamp': '2024-03-01T09:00:00.000',
      };
      final n = Notification_dto.fromJson(json);
      expect(n.isRead, isFalse);
    });

    test('toJson serializes all fields', () {
      final dt = DateTime(2024, 5, 1, 8, 0);
      final n = Notification_dto(
        id: 5,
        title: 'Title',
        message: 'Body',
        timestamp: dt,
        isRead: false,
      );
      final jsonStr = n.toJson();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['id'], 5);
      expect(decoded['title'], 'Title');
      expect(decoded['message'], 'Body');
      expect(decoded['isRead'], isFalse);
    });
  });

  group('ScheduledNotification', () {
    test('constructor stores all fields', () {
      final scheduled = DateTime(2024, 6, 1, 9, 0);
      final sent = DateTime(2024, 6, 1, 9, 0, 5);
      final n = ScheduledNotification(
        id: 1,
        taskId: 42,
        receiverId: 7,
        title: 'Appointment',
        body: 'Your appointment is in 1 hour',
        notificationType: 'REMINDER',
        scheduledTime: scheduled,
        sentTime: sent,
        status: 'SENT',
        messageId: 'msg-123',
        errorMessage: null,
      );
      expect(n.id, 1);
      expect(n.taskId, 42);
      expect(n.receiverId, 7);
      expect(n.title, 'Appointment');
      expect(n.body, 'Your appointment is in 1 hour');
      expect(n.notificationType, 'REMINDER');
      expect(n.scheduledTime, scheduled);
      expect(n.sentTime, sent);
      expect(n.status, 'SENT');
      expect(n.messageId, 'msg-123');
      expect(n.errorMessage, isNull);
    });

    test('status defaults to PENDING', () {
      final n = ScheduledNotification(
        receiverId: 1,
        title: 'Title',
        body: 'Body',
        scheduledTime: DateTime.now(),
      );
      expect(n.status, 'PENDING');
    });

    test('fromJson parses all fields', () {
      final json = <String, dynamic>{
        'id': 20,
        'taskId': 5,
        'receiverId': 3,
        'title': 'Med Reminder',
        'body': 'Take pill',
        'notificationType': 'ALERT',
        'scheduledTime': '2024-07-15T08:00:00.000',
        'sentTime': '2024-07-15T08:00:01.000',
        'status': 'SENT',
        'messageId': 'abc-456',
        'errorMessage': null,
      };
      final n = ScheduledNotification.fromJson(json);
      expect(n.id, 20);
      expect(n.taskId, 5);
      expect(n.receiverId, 3);
      expect(n.title, 'Med Reminder');
      expect(n.body, 'Take pill');
      expect(n.notificationType, 'ALERT');
      expect(n.status, 'SENT');
      expect(n.messageId, 'abc-456');
    });

    test('fromJson sets sentTime to null when absent', () {
      final json = <String, dynamic>{
        'receiverId': 1,
        'title': 'T',
        'body': 'B',
        'scheduledTime': '2024-07-15T08:00:00.000',
        'status': 'PENDING',
      };
      final n = ScheduledNotification.fromJson(json);
      expect(n.sentTime, isNull);
    });

    test('fromJson defaults id to -1 when absent', () {
      final json = <String, dynamic>{
        'receiverId': 1,
        'title': 'T',
        'body': 'B',
        'scheduledTime': '2024-07-15T08:00:00.000',
        'status': 'PENDING',
      };
      final n = ScheduledNotification.fromJson(json);
      expect(n.id, -1);
    });

    test('toJson includes required fields only', () {
      final n = ScheduledNotification(
        taskId: 10,
        receiverId: 5,
        title: 'Task Reminder',
        body: 'Complete your task',
        notificationType: 'REMINDER',
        scheduledTime: DateTime(2024, 8, 1, 7, 30),
        status: 'PENDING',
      );
      final json = n.toJson();
      expect(json['taskId'], 10);
      expect(json['receiverId'], 5);
      expect(json['title'], 'Task Reminder');
      expect(json['body'], 'Complete your task');
      expect(json['notificationType'], 'REMINDER');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('sentTime'), isFalse);
    });
  });
}
