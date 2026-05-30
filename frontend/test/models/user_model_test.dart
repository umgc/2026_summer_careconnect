// Tests for UserModel (lib/models/user_model.dart).
// Pure Dart class with constructor, toJson, and fromJson.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/user_model.dart';

void main() {
  group('UserModel constructor', () {
    test('stores all fields correctly', () {
      final user = UserModel(
        name: 'Alice Smith',
        email: 'alice@example.com',
        userId: 'u-123',
        role: 'CAREGIVER',
      );
      expect(user.name, 'Alice Smith');
      expect(user.email, 'alice@example.com');
      expect(user.userId, 'u-123');
      expect(user.role, 'CAREGIVER');
    });

    test('fields are final and immutable', () {
      final user = UserModel(
        name: 'Test',
        email: 'test@test.com',
        userId: 'u-0',
        role: 'PATIENT',
      );
      // Verify the fields are accessible and hold their values
      expect(user.name, equals('Test'));
      expect(user.email, equals('test@test.com'));
      expect(user.userId, equals('u-0'));
      expect(user.role, equals('PATIENT'));
    });

    test('accepts empty string values', () {
      final user = UserModel(
        name: '',
        email: '',
        userId: '',
        role: '',
      );
      expect(user.name, '');
      expect(user.email, '');
      expect(user.userId, '');
      expect(user.role, '');
    });
  });

  group('UserModel.toJson', () {
    test('returns correct map with all fields', () {
      final user = UserModel(
        name: 'Bob',
        email: 'bob@test.com',
        userId: 'u-456',
        role: 'PATIENT',
      );
      final json = user.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['name'], 'Bob');
      expect(json['email'], 'bob@test.com');
      expect(json['userId'], 'u-456');
      expect(json['role'], 'PATIENT');
    });

    test('contains exactly four keys', () {
      final user = UserModel(
        name: 'Test',
        email: 'e@e.com',
        userId: 'id',
        role: 'ADMIN',
      );
      final json = user.toJson();
      expect(json.length, 4);
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('email'), isTrue);
      expect(json.containsKey('userId'), isTrue);
      expect(json.containsKey('role'), isTrue);
    });

    test('preserves empty string values', () {
      final user = UserModel(
        name: '',
        email: '',
        userId: '',
        role: '',
      );
      final json = user.toJson();
      expect(json['name'], '');
      expect(json['email'], '');
      expect(json['userId'], '');
      expect(json['role'], '');
    });
  });

  group('UserModel.fromJson', () {
    test('parses complete JSON', () {
      final user = UserModel.fromJson({
        'name': 'Carol',
        'email': 'carol@test.com',
        'userId': 'u-789',
        'role': 'ADMIN',
      });
      expect(user.name, 'Carol');
      expect(user.email, 'carol@test.com');
      expect(user.userId, 'u-789');
      expect(user.role, 'ADMIN');
    });

    test('defaults all fields to empty string when JSON is empty', () {
      final user = UserModel.fromJson({});
      expect(user.name, '');
      expect(user.email, '');
      expect(user.userId, '');
      expect(user.role, '');
    });

    test('defaults name to empty string when missing', () {
      final user = UserModel.fromJson({
        'email': 'a@b.com',
        'userId': 'id',
        'role': 'PATIENT',
      });
      expect(user.name, '');
      expect(user.email, 'a@b.com');
    });

    test('defaults email to empty string when missing', () {
      final user = UserModel.fromJson({
        'name': 'Name',
        'userId': 'id',
        'role': 'PATIENT',
      });
      expect(user.email, '');
      expect(user.name, 'Name');
    });

    test('defaults userId to empty string when missing', () {
      final user = UserModel.fromJson({
        'name': 'Name',
        'email': 'e@e.com',
        'role': 'PATIENT',
      });
      expect(user.userId, '');
    });

    test('defaults role to empty string when missing', () {
      final user = UserModel.fromJson({
        'name': 'Name',
        'email': 'e@e.com',
        'userId': 'id',
      });
      expect(user.role, '');
    });

    test('defaults null values to empty strings', () {
      final user = UserModel.fromJson({
        'name': null,
        'email': null,
        'userId': null,
        'role': null,
      });
      expect(user.name, '');
      expect(user.email, '');
      expect(user.userId, '');
      expect(user.role, '');
    });

    test('round-trips through toJson', () {
      final original = UserModel(
        name: 'Dave',
        email: 'dave@test.com',
        userId: 'u-999',
        role: 'FAMILY_MEMBER',
      );
      final copy = UserModel.fromJson(original.toJson());
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.userId, original.userId);
      expect(copy.role, original.role);
    });

    test('ignores extra JSON keys', () {
      final user = UserModel.fromJson({
        'name': 'Extra',
        'email': 'extra@test.com',
        'userId': 'u-extra',
        'role': 'PATIENT',
        'extraField': 'should be ignored',
        'anotherField': 42,
      });
      expect(user.name, 'Extra');
      expect(user.email, 'extra@test.com');
      expect(user.userId, 'u-extra');
      expect(user.role, 'PATIENT');
    });
  });

  group('UserModel edge cases', () {
    test('handles special characters in name', () {
      final user = UserModel(
        name: "O'Brien-Smith",
        email: 'test@example.com',
        userId: 'u-1',
        role: 'PATIENT',
      );
      expect(user.name, "O'Brien-Smith");
      final json = user.toJson();
      expect(json['name'], "O'Brien-Smith");
    });

    test('handles unicode characters', () {
      final user = UserModel(
        name: 'Jose Garcia',
        email: 'jose@test.com',
        userId: 'u-unicode',
        role: 'CAREGIVER',
      );
      final roundTrip = UserModel.fromJson(user.toJson());
      expect(roundTrip.name, 'Jose Garcia');
    });

    test('handles long string values', () {
      final longName = 'A' * 1000;
      final user = UserModel(
        name: longName,
        email: 'long@test.com',
        userId: 'u-long',
        role: 'PATIENT',
      );
      expect(user.name.length, 1000);
      final json = user.toJson();
      expect(json['name'], longName);
    });

    test('creates independent instances', () {
      final user1 = UserModel(
        name: 'User1',
        email: 'u1@test.com',
        userId: 'u-1',
        role: 'PATIENT',
      );
      final user2 = UserModel(
        name: 'User2',
        email: 'u2@test.com',
        userId: 'u-2',
        role: 'CAREGIVER',
      );
      expect(user1.name, isNot(user2.name));
      expect(user1.userId, isNot(user2.userId));
      expect(user1.role, isNot(user2.role));
    });
  });
}
