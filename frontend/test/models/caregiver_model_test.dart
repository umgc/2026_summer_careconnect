// Tests for CaregiverModel and ProfessionalInfo (lib/models/caregiver_model.dart).
// Pure Dart classes with constructor, toJson, fromJson.
// Note: CaregiverModel uses Address from lib/features/dashboard/models/patient_model.dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/caregiver_model.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';

Address _addr() => Address(
  line1: '1 Main St',
  line2: '',
  city: 'Chicago',
  state: 'IL',
  zip: '60601',
);

CaregiverModel _caregiver({ProfessionalInfo? professionalInfo}) =>
    CaregiverModel(
      name: 'Jane Doe',
      email: 'jane@care.com',
      userId: 'cg-001',
      role: 'CAREGIVER',
      firstName: 'Jane',
      lastName: 'Doe',
      phone: '555-1234',
      dob: '1985-03-15',
      gender: 'Female',
      caregiverType: 'Professional',
      address: _addr(),
      professionalInfo: professionalInfo,
    );

void main() {
  group('ProfessionalInfo constructor', () {
    test('stores all fields', () {
      final info = ProfessionalInfo(
        licenseNumber: 'LIC-999',
        issuingState: 'IL',
        yearsExperience: 10,
      );
      expect(info.licenseNumber, 'LIC-999');
      expect(info.issuingState, 'IL');
      expect(info.yearsExperience, 10);
    });
  });

  group('ProfessionalInfo.toJson', () {
    test('returns correct map', () {
      final info = ProfessionalInfo(
        licenseNumber: 'LIC-123',
        issuingState: 'CA',
        yearsExperience: 5,
      );
      final json = info.toJson();
      expect(json['licenseNumber'], 'LIC-123');
      expect(json['issuingState'], 'CA');
      expect(json['yearsExperience'], 5);
    });
  });

  group('ProfessionalInfo.fromJson', () {
    test('parses complete JSON', () {
      final info = ProfessionalInfo.fromJson({
        'licenseNumber': 'L-42',
        'issuingState': 'NY',
        'yearsExperience': 8,
      });
      expect(info.licenseNumber, 'L-42');
      expect(info.issuingState, 'NY');
      expect(info.yearsExperience, 8);
    });

    test('uses defaults for missing fields', () {
      final info = ProfessionalInfo.fromJson({});
      expect(info.licenseNumber, '');
      expect(info.issuingState, '');
      expect(info.yearsExperience, 0);
    });
  });

  group('CaregiverModel constructor', () {
    test('stores all fields', () {
      final cg = _caregiver();
      expect(cg.name, 'Jane Doe');
      expect(cg.email, 'jane@care.com');
      expect(cg.role, 'CAREGIVER');
      expect(cg.firstName, 'Jane');
      expect(cg.caregiverType, 'Professional');
      expect(cg.professionalInfo, isNull);
    });

    test('stores optional professional info', () {
      final info = ProfessionalInfo(
        licenseNumber: 'L-1',
        issuingState: 'TX',
        yearsExperience: 3,
      );
      final cg = _caregiver(professionalInfo: info);
      expect(cg.professionalInfo, isNotNull);
      expect(cg.professionalInfo!.licenseNumber, 'L-1');
    });
  });

  group('CaregiverModel.toJson', () {
    test('includes base UserModel fields', () {
      final json = _caregiver().toJson();
      expect(json['name'], 'Jane Doe');
      expect(json['email'], 'jane@care.com');
      expect(json['userId'], 'cg-001');
      expect(json['role'], 'CAREGIVER');
    });

    test('includes caregiver-specific fields', () {
      final json = _caregiver().toJson();
      expect(json['firstName'], 'Jane');
      expect(json['lastName'], 'Doe');
      expect(json['phone'], '555-1234');
      expect(json['dob'], '1985-03-15');
      expect(json['gender'], 'Female');
      expect(json['caregiverType'], 'Professional');
      expect(json['address'], isA<Map>());
    });

    test('omits professional key when no professional info', () {
      final json = _caregiver().toJson();
      expect(json.containsKey('professional'), isFalse);
    });

    test('includes professional key when professional info present', () {
      final info = ProfessionalInfo(
        licenseNumber: 'L-2',
        issuingState: 'FL',
        yearsExperience: 7,
      );
      final json = _caregiver(professionalInfo: info).toJson();
      expect(json.containsKey('professional'), isTrue);
      expect(json['professional']['licenseNumber'], 'L-2');
    });
  });

  group('CaregiverModel.fromJson', () {
    test('parses minimal JSON (no professional info)', () {
      final cg = CaregiverModel.fromJson({
        'name': 'Bob',
        'email': 'bob@test.com',
        'userId': 'cg-002',
        'firstName': 'Bob',
        'lastName': 'Smith',
        'phone': '555-9999',
        'dob': '1970-01-01',
        'gender': 'Male',
        'caregiverType': 'Family',
      });
      expect(cg.firstName, 'Bob');
      expect(cg.role, 'CAREGIVER');
      expect(cg.professionalInfo, isNull);
    });

    test('uses empty defaults for missing fields', () {
      final cg = CaregiverModel.fromJson({});
      expect(cg.name, '');
      expect(cg.email, '');
      expect(cg.firstName, '');
    });

    test('parses professional info when present', () {
      final cg = CaregiverModel.fromJson({
        'professional': {
          'licenseNumber': 'L-99',
          'issuingState': 'WA',
          'yearsExperience': 12,
        },
      });
      expect(cg.professionalInfo, isNotNull);
      expect(cg.professionalInfo!.licenseNumber, 'L-99');
    });

    test('handles null values with defaults', () {
      final cg = CaregiverModel.fromJson({
        'name': null,
        'email': null,
        'userId': null,
        'role': null,
        'firstName': null,
        'lastName': null,
        'phone': null,
        'dob': null,
        'gender': null,
        'caregiverType': null,
        'address': null,
        'professional': null,
      });
      expect(cg.name, '');
      expect(cg.email, '');
      expect(cg.userId, '');
      expect(cg.role, 'CAREGIVER');
      expect(cg.firstName, '');
      expect(cg.lastName, '');
      expect(cg.phone, '');
      expect(cg.dob, '');
      expect(cg.gender, '');
      expect(cg.caregiverType, '');
      expect(cg.professionalInfo, isNull);
    });

    test('parses nested address from JSON', () {
      final cg = CaregiverModel.fromJson({
        'address': {
          'line1': '10 Elm St',
          'line2': 'Suite 5',
          'city': 'Denver',
          'state': 'CO',
          'zip': '80201',
          'phone': '303-555-0000',
        },
      });
      expect(cg.address.line1, '10 Elm St');
      expect(cg.address.line2, 'Suite 5');
      expect(cg.address.city, 'Denver');
      expect(cg.address.state, 'CO');
      expect(cg.address.zip, '80201');
      expect(cg.address.phone, '303-555-0000');
    });

    test('empty address map creates address with null fields', () {
      final cg = CaregiverModel.fromJson({'address': <String, dynamic>{}});
      expect(cg.address.line1, isNull);
      expect(cg.address.line2, isNull);
      expect(cg.address.city, isNull);
      expect(cg.address.state, isNull);
      expect(cg.address.zip, isNull);
    });
  });

  group('ProfessionalInfo round-trip', () {
    test('toJson then fromJson preserves all data', () {
      final original = ProfessionalInfo(
        licenseNumber: 'RT-500',
        issuingState: 'OR',
        yearsExperience: 25,
      );
      final restored = ProfessionalInfo.fromJson(original.toJson());
      expect(restored.licenseNumber, original.licenseNumber);
      expect(restored.issuingState, original.issuingState);
      expect(restored.yearsExperience, original.yearsExperience);
    });

    test('fromJson with null values produces defaults', () {
      final info = ProfessionalInfo.fromJson({
        'licenseNumber': null,
        'issuingState': null,
        'yearsExperience': null,
      });
      expect(info.licenseNumber, '');
      expect(info.issuingState, '');
      expect(info.yearsExperience, 0);
    });
  });

  group('CaregiverModel round-trip', () {
    test('toJson then fromJson preserves data without professionalInfo', () {
      final original = _caregiver();
      final restored = CaregiverModel.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.userId, original.userId);
      expect(restored.role, original.role);
      expect(restored.firstName, original.firstName);
      expect(restored.lastName, original.lastName);
      expect(restored.phone, original.phone);
      expect(restored.dob, original.dob);
      expect(restored.gender, original.gender);
      expect(restored.caregiverType, original.caregiverType);
      expect(restored.address.line1, original.address.line1);
      expect(restored.address.city, original.address.city);
      expect(restored.professionalInfo, isNull);
    });

    test('toJson then fromJson preserves data with professionalInfo', () {
      final profInfo = ProfessionalInfo(
        licenseNumber: 'ROUND-TRIP',
        issuingState: 'TX',
        yearsExperience: 7,
      );
      final original = _caregiver(professionalInfo: profInfo);
      final restored = CaregiverModel.fromJson(original.toJson());

      expect(restored.professionalInfo, isNotNull);
      expect(restored.professionalInfo!.licenseNumber,
          original.professionalInfo!.licenseNumber);
      expect(restored.professionalInfo!.issuingState,
          original.professionalInfo!.issuingState);
      expect(restored.professionalInfo!.yearsExperience,
          original.professionalInfo!.yearsExperience);
    });
  });

  group('CaregiverModel.toJson address serialization', () {
    test('serializes address fields correctly', () {
      final json = _caregiver().toJson();
      final addrJson = json['address'] as Map<String, dynamic>;
      expect(addrJson['line1'], '1 Main St');
      expect(addrJson['line2'], '');
      expect(addrJson['city'], 'Chicago');
      expect(addrJson['state'], 'IL');
      expect(addrJson['zip'], '60601');
    });
  });
}
