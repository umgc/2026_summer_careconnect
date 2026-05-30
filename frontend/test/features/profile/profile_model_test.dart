// Tests for UserProfile, CaregiverProfile, and PatientProfile models
// (lib/features/profile/models/profile_model.dart).
// Pure-Dart data classes with fromJson, toJson, and copyWith.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/profile/models/profile_model.dart';

void main() {
  // ──────────────────────────────────────────────────────────────
  // UserProfile
  // ──────────────────────────────────────────────────────────────

  group('UserProfile', () {
    test('constructor stores all fields', () {
      // Verifies the direct constructor sets all fields correctly.
      final profile = UserProfile(
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
        phoneNumber: '5551234567',
        address: '123 Main St',
        city: 'Springfield',
        state: 'IL',
        zipCode: '62701',
        country: 'US',
        profilePictureUrl: 'https://example.com/pic.jpg',
      );

      expect(profile.id, 1);
      expect(profile.name, 'Alice');
      expect(profile.email, 'alice@example.com');
      expect(profile.phoneNumber, '5551234567');
      expect(profile.city, 'Springfield');
      expect(profile.profilePictureUrl, 'https://example.com/pic.jpg');
    });

    test('toJson serializes correct fields', () {
      // Verifies that toJson includes name, email, and address fields.
      final profile = UserProfile(
        id: 1,
        name: 'Bob',
        email: 'bob@example.com',
        city: 'Chicago',
        state: 'IL',
      );
      final json = profile.toJson();

      expect(json['name'], 'Bob');
      expect(json['email'], 'bob@example.com');
      expect(json['city'], 'Chicago');
      expect(json['state'], 'IL');
    });

    test('copyWith preserves unchanged fields', () {
      // Verifies that copyWith without args returns an equivalent object.
      final original = UserProfile(id: 5, name: 'Carol');
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
    });

    test('copyWith updates specified fields', () {
      // Verifies that specified fields are replaced in the copy.
      final original = UserProfile(
        id: 1,
        name: 'Dave',
        email: 'dave@example.com',
        city: 'Old City',
      );
      final copy = original.copyWith(name: 'David', city: 'New City');

      expect(copy.name, 'David');
      expect(copy.city, 'New City');
      expect(copy.email, 'dave@example.com'); // unchanged
      expect(copy.id, 1); // id is never changed by copyWith
    });
  });

  // ──────────────────────────────────────────────────────────────
  // CaregiverProfile
  // ──────────────────────────────────────────────────────────────

  group('CaregiverProfile.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies every JSON key is correctly mapped.
      final profile = CaregiverProfile.fromJson({
        'id': 10,
        'name': 'Dr. Eve',
        'email': 'eve@hospital.com',
        'phoneNumber': '5559876543',
        'address': '456 Medical Way',
        'city': 'Medville',
        'state': 'CA',
        'zipCode': '90210',
        'country': 'US',
        'profilePictureUrl': 'https://example.com/eve.jpg',
        'specialization': 'Cardiology',
        'organization': 'City Hospital',
        'license': 'CA-12345',
        'dateOfBirth': '1980-03-15',
      });

      expect(profile.id, 10);
      expect(profile.name, 'Dr. Eve');
      expect(profile.email, 'eve@hospital.com');
      expect(profile.specialization, 'Cardiology');
      expect(profile.organization, 'City Hospital');
      expect(profile.license, 'CA-12345');
      expect(profile.dateOfBirth, '1980-03-15');
    });

    test('optional fields are null when absent', () {
      // Verifies null/absent optional keys produce null fields.
      final profile = CaregiverProfile.fromJson({
        'id': 2,
        'name': 'Frank',
      });

      expect(profile.email, isNull);
      expect(profile.specialization, isNull);
      expect(profile.organization, isNull);
      expect(profile.license, isNull);
      expect(profile.dateOfBirth, isNull);
    });

    test('id defaults to 0 and name to empty when absent', () {
      // Verifies the ?? fallback values for required fields.
      final profile = CaregiverProfile.fromJson({});
      expect(profile.id, 0);
      expect(profile.name, '');
    });
  });

  group('CaregiverProfile.toJson', () {
    test('includes base and caregiver-specific fields', () {
      // Verifies that toJson merges base UserProfile JSON with caregiver fields.
      final profile = CaregiverProfile(
        id: 1,
        name: 'Dr. Grace',
        email: 'grace@example.com',
        specialization: 'Neurology',
        organization: 'Brain Center',
        license: 'NY-99',
        dateOfBirth: '1975-07-01',
      );
      final json = profile.toJson();

      expect(json['name'], 'Dr. Grace');
      expect(json['email'], 'grace@example.com');
      expect(json['specialization'], 'Neurology');
      expect(json['organization'], 'Brain Center');
      expect(json['license'], 'NY-99');
      expect(json['dateOfBirth'], '1975-07-01');
    });
  });

  group('CaregiverProfile.copyWith', () {
    test('updates specified caregiver-specific fields', () {
      // Verifies that caregiver-specific fields can be updated via copyWith.
      final original = CaregiverProfile(
        id: 1,
        name: 'Hannah',
        specialization: 'Pediatrics',
        license: 'TX-001',
      );
      final copy = original.copyWith(
        specialization: 'Geriatrics',
        license: 'TX-002',
      );

      expect(copy.specialization, 'Geriatrics');
      expect(copy.license, 'TX-002');
      expect(copy.name, 'Hannah'); // unchanged
    });
  });

  // ──────────────────────────────────────────────────────────────
  // PatientProfile
  // ──────────────────────────────────────────────────────────────

  group('PatientProfile.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies every JSON key is correctly mapped.
      final profile = PatientProfile.fromJson({
        'id': 20,
        'name': 'Ivan Patient',
        'email': 'ivan@example.com',
        'phoneNumber': '5554445555',
        'address': '789 Oak Lane',
        'city': 'Wellness',
        'state': 'TX',
        'zipCode': '75001',
        'country': 'US',
        'profilePictureUrl': null,
        'dateOfBirth': '1990-11-22',
        'gender': 'Male',
        'emergencyContact': 'Jane Patient',
        'medicalConditions': 'Hypertension',
        'allergies': 'Penicillin',
        'medications': 'Lisinopril',
      });

      expect(profile.id, 20);
      expect(profile.name, 'Ivan Patient');
      expect(profile.dateOfBirth, '1990-11-22');
      expect(profile.gender, 'Male');
      expect(profile.emergencyContact, 'Jane Patient');
      expect(profile.medicalConditions, 'Hypertension');
      expect(profile.allergies, 'Penicillin');
      expect(profile.medications, 'Lisinopril');
    });

    test('optional fields are null when absent', () {
      // Verifies null/absent optional keys produce null fields.
      final profile = PatientProfile.fromJson({
        'id': 3,
        'name': 'Judy',
      });

      expect(profile.dateOfBirth, isNull);
      expect(profile.gender, isNull);
      expect(profile.emergencyContact, isNull);
      expect(profile.medicalConditions, isNull);
      expect(profile.allergies, isNull);
      expect(profile.medications, isNull);
    });
  });

  group('PatientProfile.toJson', () {
    test('includes base and patient-specific fields', () {
      // Verifies that toJson merges base UserProfile JSON with patient fields.
      final profile = PatientProfile(
        id: 1,
        name: 'Kevin',
        gender: 'Male',
        dateOfBirth: '1985-05-10',
        emergencyContact: 'Lisa',
        medicalConditions: 'Diabetes',
        allergies: 'Sulfa',
        medications: 'Metformin',
      );
      final json = profile.toJson();

      expect(json['name'], 'Kevin');
      expect(json['gender'], 'Male');
      expect(json['dateOfBirth'], '1985-05-10');
      expect(json['emergencyContact'], 'Lisa');
      expect(json['medicalConditions'], 'Diabetes');
      expect(json['allergies'], 'Sulfa');
      expect(json['medications'], 'Metformin');
    });
  });

  group('PatientProfile.copyWith', () {
    test('updates specified patient-specific fields', () {
      // Verifies that patient-specific fields can be updated via copyWith.
      final original = PatientProfile(
        id: 1,
        name: 'Lara',
        gender: 'Female',
        allergies: 'None',
      );
      final copy = original.copyWith(
        allergies: 'Penicillin',
        gender: 'Non-binary',
      );

      expect(copy.allergies, 'Penicillin');
      expect(copy.gender, 'Non-binary');
      expect(copy.name, 'Lara'); // unchanged
    });
  });
}
