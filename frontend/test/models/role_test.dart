// Tests for Role enum (lib/models/role.dart).
//
// Pure Dart enum with fromString/toBackendString/displayName/description
// and boolean convenience getters.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/role.dart';

void main() {
  group('Role.fromString', () {
    test('parses ADMIN (case-insensitive)', () {
      expect(Role.fromString('ADMIN'), Role.admin);
      expect(Role.fromString('admin'), Role.admin);
      expect(Role.fromString('Admin'), Role.admin);
    });

    test('parses CAREGIVER', () {
      expect(Role.fromString('CAREGIVER'), Role.caregiver);
      expect(Role.fromString('caregiver'), Role.caregiver);
    });

    test('parses PATIENT', () {
      expect(Role.fromString('PATIENT'), Role.patient);
      expect(Role.fromString('patient'), Role.patient);
    });

    test('parses FAMILY_MEMBER', () {
      expect(Role.fromString('FAMILY_MEMBER'), Role.familyMember);
      expect(Role.fromString('family_member'), Role.familyMember);
    });

    test('throws ArgumentError for unknown role', () {
      expect(() => Role.fromString('UNKNOWN'), throwsArgumentError);
      expect(() => Role.fromString(''), throwsArgumentError);
    });
  });

  group('Role.toBackendString', () {
    test('admin → ADMIN', () => expect(Role.admin.toBackendString(), 'ADMIN'));
    test('caregiver → CAREGIVER', () => expect(Role.caregiver.toBackendString(), 'CAREGIVER'));
    test('patient → PATIENT', () => expect(Role.patient.toBackendString(), 'PATIENT'));
    test('familyMember → FAMILY_MEMBER', () => expect(Role.familyMember.toBackendString(), 'FAMILY_MEMBER'));

    test('round-trips through fromString', () {
      for (final role in Role.values) {
        expect(Role.fromString(role.toBackendString()), role);
      }
    });
  });

  group('Role.displayName', () {
    test('admin displayName is Administrator', () {
      expect(Role.admin.displayName, 'Administrator');
    });

    test('caregiver displayName is Caregiver', () {
      expect(Role.caregiver.displayName, 'Caregiver');
    });

    test('patient displayName is Patient', () {
      expect(Role.patient.displayName, 'Patient');
    });

    test('familyMember displayName is Family Member', () {
      expect(Role.familyMember.displayName, 'Family Member');
    });
  });

  group('Role.description', () {
    test('all roles have non-empty descriptions', () {
      for (final role in Role.values) {
        expect(role.description, isNotEmpty);
      }
    });
  });

  group('Role boolean getters', () {
    test('isAdmin is true only for admin', () {
      expect(Role.admin.isAdmin, isTrue);
      expect(Role.caregiver.isAdmin, isFalse);
      expect(Role.patient.isAdmin, isFalse);
      expect(Role.familyMember.isAdmin, isFalse);
    });

    test('isCaregiverOrAdmin is true for caregiver and admin', () {
      expect(Role.admin.isCaregiverOrAdmin, isTrue);
      expect(Role.caregiver.isCaregiverOrAdmin, isTrue);
      expect(Role.patient.isCaregiverOrAdmin, isFalse);
      expect(Role.familyMember.isCaregiverOrAdmin, isFalse);
    });

    test('isPatient is true only for patient', () {
      expect(Role.patient.isPatient, isTrue);
      expect(Role.admin.isPatient, isFalse);
      expect(Role.caregiver.isPatient, isFalse);
    });

    test('isFamilyMember is true only for familyMember', () {
      expect(Role.familyMember.isFamilyMember, isTrue);
      expect(Role.admin.isFamilyMember, isFalse);
    });

    test('canManagePatients is true for admin and caregiver', () {
      expect(Role.admin.canManagePatients, isTrue);
      expect(Role.caregiver.canManagePatients, isTrue);
      expect(Role.patient.canManagePatients, isFalse);
      expect(Role.familyMember.canManagePatients, isFalse);
    });

    test('isReadOnly is true only for familyMember', () {
      expect(Role.familyMember.isReadOnly, isTrue);
      expect(Role.admin.isReadOnly, isFalse);
      expect(Role.caregiver.isReadOnly, isFalse);
      expect(Role.patient.isReadOnly, isFalse);
    });
  });
}
