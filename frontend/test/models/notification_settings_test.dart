// Tests for NotificationSettings (lib/models/notification_settings.dart).
// Pure Dart class with constructor, fromJson, toJson, and copyWith.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/notification_settings.dart';

NotificationSettings _basic() => NotificationSettings(
  userId: 42,
  gamification: false,
  emergency: true,
  videoCall: true,
  audioCall: true,
  sms: true,
  significantVitals: true,
);

void main() {
  group('NotificationSettings constructor', () {
    test('stores required fields', () {
      final ns = _basic();
      expect(ns.userId, 42);
      expect(ns.gamification, isFalse);
      expect(ns.emergency, isTrue);
      expect(ns.id, isNull);
      expect(ns.createdAt, isNull);
    });

    test('stores optional id and dates', () {
      final now = DateTime(2025, 1, 15);
      final ns = NotificationSettings(
        id: 7,
        userId: 10,
        gamification: true,
        emergency: false,
        videoCall: false,
        audioCall: false,
        sms: false,
        significantVitals: false,
        createdAt: now,
        updatedAt: now,
      );
      expect(ns.id, 7);
      expect(ns.createdAt, now);
      expect(ns.updatedAt, now);
    });
  });

  group('NotificationSettings.fromJson', () {
    test('parses complete JSON', () {
      final ns = NotificationSettings.fromJson({
        'id': 3,
        'userId': 99,
        'gamification': true,
        'emergency': false,
        'videoCall': true,
        'audioCall': false,
        'sms': true,
        'significantVitals': false,
        'createdAt': '2025-06-01T10:00:00.000Z',
        'updatedAt': '2025-06-02T10:00:00.000Z',
      });
      expect(ns.id, 3);
      expect(ns.userId, 99);
      expect(ns.gamification, isTrue);
      expect(ns.emergency, isFalse);
      expect(ns.videoCall, isTrue);
      expect(ns.audioCall, isFalse);
      expect(ns.sms, isTrue);
      expect(ns.significantVitals, isFalse);
      expect(ns.createdAt, isNotNull);
      expect(ns.updatedAt, isNotNull);
    });

    test('uses defaults for missing boolean fields', () {
      final ns = NotificationSettings.fromJson({'userId': 1});
      expect(ns.gamification, isFalse);
      expect(ns.emergency, isTrue);
      expect(ns.videoCall, isTrue);
      expect(ns.audioCall, isTrue);
      expect(ns.sms, isTrue);
      expect(ns.significantVitals, isTrue);
    });

    test('null dates remain null', () {
      final ns = NotificationSettings.fromJson({'userId': 5});
      expect(ns.createdAt, isNull);
      expect(ns.updatedAt, isNull);
    });
  });

  group('NotificationSettings.toJson', () {
    test('serializes boolean and userId fields', () {
      final ns = NotificationSettings(
        userId: 7,
        gamification: true,
        emergency: false,
        videoCall: true,
        audioCall: false,
        sms: true,
        significantVitals: false,
      );
      final json = ns.toJson();
      expect(json['userId'], 7);
      expect(json['gamification'], isTrue);
      expect(json['emergency'], isFalse);
      expect(json['videoCall'], isTrue);
      expect(json['audioCall'], isFalse);
      expect(json['sms'], isTrue);
      expect(json['significantVitals'], isFalse);
    });

    test('does not include id or dates', () {
      final ns = NotificationSettings(
        id: 99,
        userId: 1,
        gamification: false,
        emergency: true,
        videoCall: true,
        audioCall: true,
        sms: true,
        significantVitals: true,
        createdAt: DateTime(2025),
      );
      final json = ns.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('createdAt'), isFalse);
    });
  });

  group('NotificationSettings.copyWith', () {
    test('copies unchanged fields', () {
      final original = _basic();
      final copy = original.copyWith();
      expect(copy.userId, original.userId);
      expect(copy.gamification, original.gamification);
      expect(copy.emergency, original.emergency);
    });

    test('overrides specified fields', () {
      final original = _basic();
      final copy = original.copyWith(gamification: true, sms: false);
      expect(copy.gamification, isTrue);
      expect(copy.sms, isFalse);
      // unchanged
      expect(copy.userId, original.userId);
      expect(copy.emergency, original.emergency);
    });
  });
}
