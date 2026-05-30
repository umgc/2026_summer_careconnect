// Tests for RoleEnum (lib/models/role-enum.dart).
// Simple Dart enum with fromJson factory.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/role-enum.dart';

void main() {
  group('RoleEnum.fromJson', () {
    test('parses "patient" (lowercase)', () {
      expect(RoleEnum.fromJson('patient'), RoleEnum.patient);
    });

    test('parses "PATIENT" (uppercase)', () {
      expect(RoleEnum.fromJson('PATIENT'), RoleEnum.patient);
    });

    test('parses "caregiver" (lowercase)', () {
      expect(RoleEnum.fromJson('caregiver'), RoleEnum.caregiver);
    });

    test('parses "CAREGIVER" (uppercase)', () {
      expect(RoleEnum.fromJson('CAREGIVER'), RoleEnum.caregiver);
    });

    test('returns forbidden for unknown role', () {
      expect(RoleEnum.fromJson('admin'), RoleEnum.forbidden);
      expect(RoleEnum.fromJson('UNKNOWN'), RoleEnum.forbidden);
      expect(RoleEnum.fromJson(''), RoleEnum.forbidden);
    });
  });

  group('RoleEnum values', () {
    test('has exactly three values', () {
      expect(RoleEnum.values.length, 3);
    });

    test('contains patient, caregiver, forbidden', () {
      expect(RoleEnum.values, containsAll([
        RoleEnum.patient,
        RoleEnum.caregiver,
        RoleEnum.forbidden,
      ]));
    });
  });
}
