// Tests for Permission enum (lib/models/permission.dart).
// Pure Dart enum with fromString/toBackendString/displayName/description/
// isAdminOnly/category and PermissionCategory.displayName.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/permission.dart';

void main() {
  group('Permission.fromString', () {
    test('parses VIEW_ALL_USERS (case-insensitive)', () {
      expect(Permission.fromString('VIEW_ALL_USERS'), Permission.viewAllUsers);
      expect(Permission.fromString('view_all_users'), Permission.viewAllUsers);
    });

    test('parses MANAGE_USERS', () {
      expect(Permission.fromString('MANAGE_USERS'), Permission.manageUsers);
    });

    test('parses CREATE_PATIENTS', () {
      expect(
        Permission.fromString('CREATE_PATIENTS'),
        Permission.createPatients,
      );
    });

    test('parses COMPLETE_TASKS', () {
      expect(
        Permission.fromString('COMPLETE_TASKS'),
        Permission.completeTasks,
      );
    });

    test('parses MANAGE_SYSTEM_SETTINGS', () {
      expect(
        Permission.fromString('MANAGE_SYSTEM_SETTINGS'),
        Permission.manageSystemSettings,
      );
    });

    test('throws ArgumentError for unknown permission', () {
      expect(() => Permission.fromString('UNKNOWN_PERM'), throwsArgumentError);
      expect(() => Permission.fromString(''), throwsArgumentError);
    });
  });

  group('Permission.toBackendString', () {
    test('viewAllUsers → VIEW_ALL_USERS', () {
      expect(Permission.viewAllUsers.toBackendString(), 'VIEW_ALL_USERS');
    });

    test('manageUsers → MANAGE_USERS', () {
      expect(Permission.manageUsers.toBackendString(), 'MANAGE_USERS');
    });

    test('viewAuditLogs → VIEW_AUDIT_LOGS', () {
      expect(Permission.viewAuditLogs.toBackendString(), 'VIEW_AUDIT_LOGS');
    });

    test('round-trips all 25 permissions', () {
      expect(Permission.values.length, 25);
      for (final perm in Permission.values) {
        expect(Permission.fromString(perm.toBackendString()), perm);
      }
    });
  });

  group('Permission.displayName', () {
    test('all permissions have non-empty display names', () {
      for (final perm in Permission.values) {
        expect(perm.displayName, isNotEmpty);
      }
    });

    test('viewAllUsers display name starts with capital', () {
      final name = Permission.viewAllUsers.displayName;
      expect(name[0], equals(name[0].toUpperCase()));
    });
  });

  group('Permission.description', () {
    test('all permissions have non-empty descriptions', () {
      for (final perm in Permission.values) {
        expect(perm.description, isNotEmpty);
      }
    });
  });

  group('Permission.isAdminOnly', () {
    test('viewAllUsers is admin-only', () {
      expect(Permission.viewAllUsers.isAdminOnly, isTrue);
    });

    test('manageUsers is admin-only', () {
      expect(Permission.manageUsers.isAdminOnly, isTrue);
    });

    test('deletePatients is admin-only', () {
      expect(Permission.deletePatients.isAdminOnly, isTrue);
    });

    test('manageSystemSettings is admin-only', () {
      expect(Permission.manageSystemSettings.isAdminOnly, isTrue);
    });

    test('viewHealthData is NOT admin-only', () {
      expect(Permission.viewHealthData.isAdminOnly, isFalse);
    });

    test('viewTasks is NOT admin-only', () {
      expect(Permission.viewTasks.isAdminOnly, isFalse);
    });
  });

  group('Permission.category', () {
    test('viewAllUsers → userManagement', () {
      expect(Permission.viewAllUsers.category, PermissionCategory.userManagement);
    });

    test('createPatients → patientManagement', () {
      expect(
        Permission.createPatients.category,
        PermissionCategory.patientManagement,
      );
    });

    test('viewHealthData → healthData', () {
      expect(Permission.viewHealthData.category, PermissionCategory.healthData);
    });

    test('completeTasks → taskManagement', () {
      expect(
        Permission.completeTasks.category,
        PermissionCategory.taskManagement,
      );
    });

    test('manageMedications → medicationManagement', () {
      expect(
        Permission.manageMedications.category,
        PermissionCategory.medicationManagement,
      );
    });

    test('viewAnalytics → analytics', () {
      expect(Permission.viewAnalytics.category, PermissionCategory.analytics);
    });

    test('sendMessages → messaging', () {
      expect(Permission.sendMessages.category, PermissionCategory.messaging);
    });

    test('manageSubscriptions → billing', () {
      expect(
        Permission.manageSubscriptions.category,
        PermissionCategory.billing,
      );
    });

    test('viewAuditLogs → system', () {
      expect(Permission.viewAuditLogs.category, PermissionCategory.system);
    });
  });

  group('PermissionCategory.displayName', () {
    test('all categories have non-empty display names', () {
      for (final cat in PermissionCategory.values) {
        expect(cat.displayName, isNotEmpty);
      }
    });

    test('userManagement → User Management', () {
      expect(PermissionCategory.userManagement.displayName, 'User Management');
    });

    test('analytics → Analytics & Reports', () {
      expect(PermissionCategory.analytics.displayName, 'Analytics & Reports');
    });
  });
}
