// Tests for NotificationSettings model
// (lib/features/invoices/models/notification_settings.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/models/notification_settings.dart';

void main() {
  group('NotificationSettings.fromJson', () {
    test('parses all fields when fully populated', () {
      final settings = NotificationSettings.fromJson({
        'id': 5,
        'userId': 42,
        'gamification': true,
        'emergency': false,
        'videoCall': true,
        'audioCall': false,
        'sms': true,
        'significantVitals': false,
        'createdAt': '2024-01-15T10:00:00Z',
        'updatedAt': '2024-06-01T12:00:00Z',
      });

      expect(settings.id, 5);
      expect(settings.userId, 42);
      expect(settings.gamification, isTrue);
      expect(settings.emergency, isFalse);
      expect(settings.videoCall, isTrue);
      expect(settings.audioCall, isFalse);
      expect(settings.sms, isTrue);
      expect(settings.significantVitals, isFalse);
      expect(settings.createdAt, DateTime.parse('2024-01-15T10:00:00Z'));
      expect(settings.updatedAt, DateTime.parse('2024-06-01T12:00:00Z'));
    });

    test('applies defaults when boolean fields missing', () {
      final settings = NotificationSettings.fromJson({
        'userId': 1,
      });

      expect(settings.gamification, isFalse);
      expect(settings.emergency, isTrue);
      expect(settings.videoCall, isTrue);
      expect(settings.audioCall, isTrue);
      expect(settings.sms, isTrue);
      expect(settings.significantVitals, isTrue);
    });

    test('createdAt and updatedAt are null when absent', () {
      final settings = NotificationSettings.fromJson({
        'userId': 10,
        'gamification': false,
        'emergency': true,
        'videoCall': true,
        'audioCall': true,
        'sms': true,
        'significantVitals': true,
      });
      expect(settings.createdAt, isNull);
      expect(settings.updatedAt, isNull);
    });
  });

  group('NotificationSettings.toJson', () {
    test('serializes required fields', () {
      final settings = NotificationSettings(
        userId: 7,
        gamification: true,
        emergency: true,
        videoCall: false,
        audioCall: true,
        sms: false,
        significantVitals: true,
      );
      final json = settings.toJson();

      expect(json['userId'], 7);
      expect(json['gamification'], isTrue);
      expect(json['emergency'], isTrue);
      expect(json['videoCall'], isFalse);
      expect(json['audioCall'], isTrue);
      expect(json['sms'], isFalse);
      expect(json['significantVitals'], isTrue);
    });

    test('does not include id or timestamps in toJson', () {
      final settings = NotificationSettings(
        id: 99,
        userId: 1,
        gamification: false,
        emergency: false,
        videoCall: false,
        audioCall: false,
        sms: false,
        significantVitals: false,
        createdAt: DateTime.now(),
      );
      final json = settings.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('createdAt'), isFalse);
    });
  });

  group('NotificationSettings.copyWith', () {
    test('preserves unchanged fields', () {
      final original = NotificationSettings(
        userId: 3,
        gamification: false,
        emergency: true,
        videoCall: true,
        audioCall: true,
        sms: true,
        significantVitals: true,
      );
      final copy = original.copyWith();
      expect(copy.userId, 3);
      expect(copy.gamification, isFalse);
    });

    test('updates specified fields', () {
      final original = NotificationSettings(
        userId: 1,
        gamification: false,
        emergency: true,
        videoCall: true,
        audioCall: true,
        sms: true,
        significantVitals: true,
      );
      final copy = original.copyWith(gamification: true, sms: false);
      expect(copy.gamification, isTrue);
      expect(copy.sms, isFalse);
      expect(copy.emergency, isTrue); // unchanged
    });
  });
}
