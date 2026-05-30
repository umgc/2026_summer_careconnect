import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/user_model.dart';

void main() {
  group('UserModel JSON Tests', () {
    test('UserModel.fromJson creates correct instance', () {
      final json = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'userId': '123',
        'role': 'CAREGIVER',
      };

      final user = UserModel.fromJson(json);

      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.userId, '123');
      expect(user.role, 'CAREGIVER');
    });

    test('UserModel.toJson serializes correctly', () {
      final user = UserModel(
        name: 'Jane Doe',
        email: 'jane@example.com',
        userId: '456',
        role: 'PATIENT',
      );

      final json = user.toJson();

      expect(json['name'], 'Jane Doe');
      expect(json['email'], 'jane@example.com');
      expect(json['userId'], '456');
      expect(json['role'], 'PATIENT');
    });

    test('UserModel.fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final user = UserModel.fromJson(json);

      expect(user.name, '');
      expect(user.email, '');
      expect(user.userId, '');
      expect(user.role, '');
    });

    test('UserModel roundtrip preserves data', () {
      final original = UserModel(
        name: 'Test User',
        email: 'test@test.com',
        userId: '789',
        role: 'CAREGIVER',
      );
      final json = original.toJson();
      final restored = UserModel.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.userId, original.userId);
      expect(restored.role, original.role);
    });

    test('UserModel stores PATIENT role', () {
      final user = UserModel(
        name: 'Patient',
        email: 'p@test.com',
        userId: '1',
        role: 'PATIENT',
      );
      expect(user.role, 'PATIENT');
    });

    test('UserModel toJson includes all keys', () {
      final user = UserModel(
        name: 'N',
        email: 'e',
        userId: 'u',
        role: 'r',
      );
      final json = user.toJson();
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('email'), isTrue);
      expect(json.containsKey('userId'), isTrue);
      expect(json.containsKey('role'), isTrue);
    });
  });
}