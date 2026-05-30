// Tests for PatientUserModel (lib/models/patient_model.dart).
// Covers constructor, toJson, fromJson, toString, edge cases, and inheritance.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/patient_model.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';

Address _addr() => Address(
      line1: '50 Oak St',
      line2: 'Floor 2',
      city: 'Naperville',
      state: 'IL',
      zip: '60540',
    );

PatientUserModel _patient() => PatientUserModel(
      name: 'Pat Tient',
      email: 'pat@health.com',
      userId: 'pt-001',
      role: 'PATIENT',
      firstName: 'Pat',
      lastName: 'Tient',
      phone: '630-555-0001',
      dob: '1990-07-04',
      gender: 'Non-binary',
      address: _addr(),
    );

void main() {
  // ---------------------------------------------------------------------------
  // PatientUserModel - constructor
  // ---------------------------------------------------------------------------
  group('PatientUserModel constructor', () {
    test('stores all fields correctly', () {
      final p = _patient();
      expect(p.name, 'Pat Tient');
      expect(p.email, 'pat@health.com');
      expect(p.userId, 'pt-001');
      expect(p.role, 'PATIENT');
      expect(p.firstName, 'Pat');
      expect(p.lastName, 'Tient');
      expect(p.phone, '630-555-0001');
      expect(p.dob, '1990-07-04');
      expect(p.gender, 'Non-binary');
      expect(p.address, isA<Address>());
    });

    test('address fields are accessible through the model', () {
      final p = _patient();
      expect(p.address.line1, '50 Oak St');
      expect(p.address.line2, 'Floor 2');
      expect(p.address.city, 'Naperville');
      expect(p.address.state, 'IL');
      expect(p.address.zip, '60540');
    });
  });

  // ---------------------------------------------------------------------------
  // PatientUserModel - toJson
  // ---------------------------------------------------------------------------
  group('PatientUserModel.toJson', () {
    test('includes base UserModel fields', () {
      final json = _patient().toJson();
      expect(json['name'], 'Pat Tient');
      expect(json['email'], 'pat@health.com');
      expect(json['userId'], 'pt-001');
    });

    test('role is always PATIENT regardless of constructor value', () {
      final p = PatientUserModel(
        name: 'X',
        email: 'x@x.com',
        userId: 'u1',
        role: 'ADMIN', // deliberately not PATIENT
        firstName: 'X',
        lastName: 'Y',
        phone: '000',
        dob: '2000-01-01',
        gender: 'Other',
        address: _addr(),
      );
      final json = p.toJson();
      expect(json['role'], 'PATIENT');
    });

    test('includes all patient-specific fields', () {
      final json = _patient().toJson();
      expect(json['firstName'], 'Pat');
      expect(json['lastName'], 'Tient');
      expect(json['phone'], '630-555-0001');
      expect(json['dob'], '1990-07-04');
      expect(json['gender'], 'Non-binary');
    });

    test('address is serialized as a map with correct keys', () {
      final json = _patient().toJson();
      expect(json['address'], isA<Map<String, dynamic>>());
      expect(json['address']['line1'], '50 Oak St');
      expect(json['address']['line2'], 'Floor 2');
      expect(json['address']['city'], 'Naperville');
      expect(json['address']['state'], 'IL');
      expect(json['address']['zip'], '60540');
    });

    test('contains exactly the expected keys', () {
      final json = _patient().toJson();
      expect(
        json.keys.toSet(),
        containsAll([
          'name',
          'email',
          'userId',
          'role',
          'firstName',
          'lastName',
          'phone',
          'dob',
          'gender',
          'address',
        ]),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // PatientUserModel - fromJson
  // ---------------------------------------------------------------------------
  group('PatientUserModel.fromJson', () {
    test('parses complete JSON with all fields', () {
      final p = PatientUserModel.fromJson({
        'name': 'Sam Patient',
        'email': 'sam@care.com',
        'userId': 'pt-002',
        'role': 'PATIENT',
        'firstName': 'Sam',
        'lastName': 'Patient',
        'phone': '312-555-0002',
        'dob': '1985-11-20',
        'gender': 'Male',
        'address': {
          'line1': '1 River Rd',
          'line2': '',
          'city': 'Joliet',
          'state': 'IL',
          'zip': '60432',
        },
      });
      expect(p.name, 'Sam Patient');
      expect(p.email, 'sam@care.com');
      expect(p.userId, 'pt-002');
      expect(p.role, 'PATIENT');
      expect(p.firstName, 'Sam');
      expect(p.lastName, 'Patient');
      expect(p.phone, '312-555-0002');
      expect(p.dob, '1985-11-20');
      expect(p.gender, 'Male');
      expect(p.address.line1, '1 River Rd');
      expect(p.address.city, 'Joliet');
    });

    test('uses empty-string defaults for all missing fields', () {
      final p = PatientUserModel.fromJson({});
      expect(p.name, '');
      expect(p.email, '');
      expect(p.userId, '');
      expect(p.role, 'PATIENT');
      expect(p.firstName, '');
      expect(p.lastName, '');
      expect(p.phone, '');
      expect(p.dob, '');
      expect(p.gender, '');
    });

    test('defaults role to PATIENT when missing', () {
      final p = PatientUserModel.fromJson({'name': 'No Role'});
      expect(p.role, 'PATIENT');
    });

    test('uses provided role when present', () {
      final p = PatientUserModel.fromJson({'role': 'CUSTOM'});
      expect(p.role, 'CUSTOM');
    });

    test('handles null address by creating empty Address', () {
      final p = PatientUserModel.fromJson({'address': null});
      expect(p.address, isA<Address>());
      expect(p.address.line1, isNull);
      expect(p.address.city, isNull);
    });

    test('handles missing address key gracefully', () {
      final p = PatientUserModel.fromJson({'firstName': 'Only'});
      expect(p.address, isA<Address>());
    });

    test('round-trips through toJson preserving all fields', () {
      final original = _patient();
      final copy = PatientUserModel.fromJson(original.toJson());
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.userId, original.userId);
      expect(copy.firstName, original.firstName);
      expect(copy.lastName, original.lastName);
      expect(copy.phone, original.phone);
      expect(copy.dob, original.dob);
      expect(copy.gender, original.gender);
      expect(copy.role, 'PATIENT');
      expect(copy.address.line1, original.address.line1);
      expect(copy.address.line2, original.address.line2);
      expect(copy.address.city, original.address.city);
      expect(copy.address.state, original.address.state);
      expect(copy.address.zip, original.address.zip);
    });

    test('extra unknown keys do not cause errors', () {
      final p = PatientUserModel.fromJson({
        'name': 'Test',
        'unknownField': 42,
        'anotherExtra': true,
      });
      expect(p.name, 'Test');
      expect(p.firstName, '');
    });
  });

  // ---------------------------------------------------------------------------
  // PatientUserModel - toString
  // ---------------------------------------------------------------------------
  group('PatientUserModel.toString', () {
    test('contains class name prefix', () {
      final s = _patient().toString();
      expect(s, contains('PatientUserModel'));
    });

    test('contains all patient-specific field values', () {
      final s = _patient().toString();
      expect(s, contains('firstName: Pat'));
      expect(s, contains('lastName: Tient'));
      expect(s, contains('phone: 630-555-0001'));
      expect(s, contains('dob: 1990-07-04'));
      expect(s, contains('gender: Non-binary'));
      expect(s, contains('address:'));
    });
  });

  // ---------------------------------------------------------------------------
  // PatientUserModel - inheritance from UserModel
  // ---------------------------------------------------------------------------
  group('PatientUserModel inheritance', () {
    test('toJson merges parent and child fields', () {
      final json = _patient().toJson();
      // parent keys
      expect(json.containsKey('name'), isTrue);
      expect(json.containsKey('email'), isTrue);
      expect(json.containsKey('userId'), isTrue);
      expect(json.containsKey('role'), isTrue);
      // child keys
      expect(json.containsKey('firstName'), isTrue);
      expect(json.containsKey('lastName'), isTrue);
      expect(json.containsKey('phone'), isTrue);
      expect(json.containsKey('dob'), isTrue);
      expect(json.containsKey('gender'), isTrue);
      expect(json.containsKey('address'), isTrue);
    });

    test('parent role is overridden by PATIENT in toJson', () {
      final p = PatientUserModel(
        name: 'A',
        email: 'a@a.com',
        userId: 'u',
        role: 'CAREGIVER',
        firstName: 'A',
        lastName: 'B',
        phone: '1',
        dob: '2000-01-01',
        gender: 'Male',
        address: Address(),
      );
      expect(p.toJson()['role'], 'PATIENT');
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------
  group('PatientUserModel edge cases', () {
    test('handles empty strings for all fields', () {
      final p = PatientUserModel(
        name: '',
        email: '',
        userId: '',
        role: '',
        firstName: '',
        lastName: '',
        phone: '',
        dob: '',
        gender: '',
        address: Address(),
      );
      expect(p.firstName, '');
      expect(p.toJson()['firstName'], '');
      expect(p.toJson()['role'], 'PATIENT');
    });

    test('address phone field is separate from patient phone', () {
      final addr = Address(
        line1: '1 Main',
        phone: '555-1234',
      );
      final p = PatientUserModel(
        name: 'N',
        email: 'e@e.com',
        userId: 'u',
        role: 'PATIENT',
        firstName: 'N',
        lastName: 'L',
        phone: '555-0000',
        dob: '2000-01-01',
        gender: 'Female',
        address: addr,
      );
      final json = p.toJson();
      expect(json['address']['phone'], '555-1234');
      expect(json['phone'], '555-0000');
    });

    test('fromJson with partial address', () {
      final p = PatientUserModel.fromJson({
        'address': {'line1': 'Only line1'},
      });
      expect(p.address.line1, 'Only line1');
      expect(p.address.line2, isNull);
      expect(p.address.city, isNull);
    });

    test('fromJson preserves special characters in fields', () {
      final p = PatientUserModel.fromJson({
        'firstName': "O'Brien",
        'lastName': 'De La Cruz',
        'email': 'user+tag@test.com',
      });
      expect(p.firstName, "O'Brien");
      expect(p.lastName, 'De La Cruz');
      expect(p.email, 'user+tag@test.com');
    });
  });
}
