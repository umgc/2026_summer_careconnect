// Tests for UserSession and UserProvider (lib/providers/user_provider.dart)
//
// Coverage strategy:
//   - UserSession: constructor, fromJson, toJson, role getters
//   - UserProvider: setUser, clearUser, fetchUserDetails (with HTTP mocking),
//     updateUserName, updateUserRole, updatePatientId, setOfflineMode,
//     connectivity logic, isLoggedIn, isCaregiver, isPatient,
//     _fetchPatientDetails, _fetchCaregiverDetails via fetchUserDetails

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:care_connect_app/providers/user_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    // Mock flutter_secure_storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'read') return null;
        if (call.method == 'write') return null;
        if (call.method == 'delete') return null;
        if (call.method == 'deleteAll') return null;
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        return null;
      },
    );

    // Mock connectivity_plus
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async {
        if (call.method == 'check') return ['wifi'];
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      null,
    );
  });

  // ─── UserSession constructor ──────────────────────────────────────────────

  group('UserSession constructor', () {
    test('stores all required fields', () {
      final session = UserSession(
        id: 1,
        email: 'alice@test.com',
        role: 'PATIENT',
        token: 'jwt-abc',
      );
      expect(session.id, 1);
      expect(session.email, 'alice@test.com');
      expect(session.role, 'PATIENT');
      expect(session.token, 'jwt-abc');
    });

    test('optional fields default correctly', () {
      final session = UserSession(
        id: 2,
        email: 'b@t.com',
        role: 'ADMIN',
        token: 't',
      );
      expect(session.patientId, isNull);
      expect(session.caregiverId, isNull);
      expect(session.name, isNull);
      expect(session.emailVerified, isFalse);
    });

    test('stores all optional fields when provided', () {
      final session = UserSession(
        id: 3,
        email: 'c@t.com',
        role: 'CAREGIVER',
        token: 'tok',
        patientId: 10,
        caregiverId: 20,
        name: 'Carol',
        emailVerified: true,
      );
      expect(session.patientId, 10);
      expect(session.caregiverId, 20);
      expect(session.name, 'Carol');
      expect(session.emailVerified, isTrue);
    });
  });

  // ─── UserSession.fromJson ─────────────────────────────────────────────────

  group('UserSession.fromJson', () {
    test('parses all fields from JSON', () {
      final session = UserSession.fromJson({
        'id': 5,
        'email': 'e@test.com',
        'role': 'PATIENT',
        'token': 'jwt-xyz',
        'patientId': 42,
        'caregiverId': null,
        'name': 'Eve',
        'emailVerified': true,
      });
      expect(session.id, 5);
      expect(session.email, 'e@test.com');
      expect(session.role, 'PATIENT');
      expect(session.token, 'jwt-xyz');
      expect(session.patientId, 42);
      expect(session.caregiverId, isNull);
      expect(session.name, 'Eve');
      expect(session.emailVerified, isTrue);
    });

    test('defaults token to empty string when null', () {
      final session = UserSession.fromJson({
        'id': 6,
        'email': 'f@t.com',
        'role': 'ADMIN',
        'token': null,
      });
      expect(session.token, '');
    });

    test('defaults emailVerified to false when missing', () {
      final session = UserSession.fromJson({
        'id': 7,
        'email': 'g@t.com',
        'role': 'CAREGIVER',
        'token': 'tok',
      });
      expect(session.emailVerified, isFalse);
    });

    test('handles missing optional fields gracefully', () {
      final session = UserSession.fromJson({
        'id': 8,
        'email': 'h@t.com',
        'role': 'PATIENT',
        'token': 'tok',
      });
      expect(session.patientId, isNull);
      expect(session.caregiverId, isNull);
      expect(session.name, isNull);
    });
  });

  // ─── UserSession.toJson ───────────────────────────────────────────────────

  group('UserSession.toJson', () {
    test('serializes all fields to JSON map', () {
      final session = UserSession(
        id: 10,
        email: 'j@t.com',
        role: 'PATIENT',
        token: 'tok-10',
        patientId: 100,
        caregiverId: 200,
        name: 'John',
        emailVerified: true,
      );
      final json = session.toJson();
      expect(json['id'], 10);
      expect(json['email'], 'j@t.com');
      expect(json['role'], 'PATIENT');
      expect(json['token'], 'tok-10');
      expect(json['patientId'], 100);
      expect(json['caregiverId'], 200);
      expect(json['name'], 'John');
      expect(json['emailVerified'], isTrue);
    });

    test('serializes null optional fields', () {
      final session = UserSession(
        id: 11,
        email: 'k@t.com',
        role: 'ADMIN',
        token: 'tok-11',
      );
      final json = session.toJson();
      expect(json['patientId'], isNull);
      expect(json['caregiverId'], isNull);
      expect(json['name'], isNull);
      expect(json['emailVerified'], isFalse);
    });

    test('round-trips through fromJson/toJson', () {
      final original = UserSession(
        id: 11,
        email: 'k@t.com',
        role: 'CAREGIVER',
        token: 'tok-11',
        patientId: null,
        caregiverId: 55,
        name: 'Kate',
        emailVerified: false,
      );
      final restored = UserSession.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.email, original.email);
      expect(restored.role, original.role);
      expect(restored.token, original.token);
      expect(restored.patientId, original.patientId);
      expect(restored.caregiverId, original.caregiverId);
      expect(restored.name, original.name);
      expect(restored.emailVerified, original.emailVerified);
    });
  });

  // ─── UserSession role getters ─────────────────────────────────────────────

  group('UserSession role getters', () {
    test('isFamilyMember returns true for FAMILY_MEMBER', () {
      final s = UserSession(
          id: 1, email: 'a@t.com', role: 'FAMILY_MEMBER', token: 't');
      expect(s.isFamilyMember, isTrue);
      expect(s.isCaregiver, isFalse);
      expect(s.isPatient, isFalse);
    });

    test('isCaregiver returns true for CAREGIVER', () {
      final s =
          UserSession(id: 1, email: 'a@t.com', role: 'CAREGIVER', token: 't');
      expect(s.isCaregiver, isTrue);
      expect(s.isFamilyMember, isFalse);
      expect(s.isPatient, isFalse);
    });

    test('isPatient returns true for PATIENT', () {
      final s =
          UserSession(id: 1, email: 'a@t.com', role: 'PATIENT', token: 't');
      expect(s.isPatient, isTrue);
      expect(s.isCaregiver, isFalse);
      expect(s.isFamilyMember, isFalse);
    });

    test('hasWriteAccess is true only for CAREGIVER', () {
      final caregiver =
          UserSession(id: 1, email: 'a@t.com', role: 'CAREGIVER', token: 't');
      final patient =
          UserSession(id: 2, email: 'b@t.com', role: 'PATIENT', token: 't');
      final admin =
          UserSession(id: 3, email: 'c@t.com', role: 'ADMIN', token: 't');
      expect(caregiver.hasWriteAccess, isTrue);
      expect(patient.hasWriteAccess, isFalse);
      expect(admin.hasWriteAccess, isFalse);
    });

    test('role getters are case-sensitive (match exact role string)', () {
      final s =
          UserSession(id: 1, email: 'a@t.com', role: 'patient', token: 't');
      expect(s.isPatient, isFalse);
    });

    test('isFamilyMember is false for other roles', () {
      final s =
          UserSession(id: 1, email: 'a@t.com', role: 'ADMIN', token: 't');
      expect(s.isFamilyMember, isFalse);
    });

    test('hasWriteAccess is false for FAMILY_MEMBER', () {
      final s = UserSession(
          id: 1, email: 'a@t.com', role: 'FAMILY_MEMBER', token: 't');
      expect(s.hasWriteAccess, isFalse);
    });
  });

  // ─── UserProvider basic state ─────────────────────────────────────────────

  group('UserProvider basic state', () {
    test('starts with null user and not loading', () {
      final provider = UserProvider();
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.userModel, isNull);
      expect(provider.patientModel, isNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });

    test('isLoggedIn returns false when no user', () {
      final provider = UserProvider();
      expect(provider.isLoggedIn, isFalse);
      provider.dispose();
    });

    test('isCaregiver returns false when no user', () {
      final provider = UserProvider();
      expect(provider.isCaregiver, isFalse);
      provider.dispose();
    });

    test('isPatient returns false when no user', () {
      final provider = UserProvider();
      expect(provider.isPatient, isFalse);
      provider.dispose();
    });
  });

  // ─── UserProvider setUser ─────────────────────────────────────────────────

  group('UserProvider setUser', () {
    test('stores the user session', () {
      final provider = UserProvider();
      final session = UserSession(
        id: 1,
        email: 'test@test.com',
        role: 'PATIENT',
        token: 'tok-1',
        patientId: 10,
      );
      provider.setUser(session);
      expect(provider.user, same(session));
      expect(provider.isLoggedIn, isTrue);
      provider.dispose();
    });

    test('notifies listeners', () {
      final provider = UserProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));
      expect(notified, isTrue);
      provider.dispose();
    });

    test('isCaregiver returns true after setting caregiver user', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'CAREGIVER',
        token: 't',
        caregiverId: 5,
      ));
      expect(provider.isCaregiver, isTrue);
      expect(provider.isPatient, isFalse);
      provider.dispose();
    });

    test('isPatient returns true after setting patient user', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
        patientId: 5,
      ));
      expect(provider.isPatient, isTrue);
      expect(provider.isCaregiver, isFalse);
      provider.dispose();
    });

    test('isCaregiver is case-insensitive via toUpperCase', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'caregiver',
        token: 't',
      ));
      expect(provider.isCaregiver, isTrue);
      provider.dispose();
    });

    test('isPatient is case-insensitive via toUpperCase', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'patient',
        token: 't',
      ));
      expect(provider.isPatient, isTrue);
      provider.dispose();
    });
  });

  // ─── UserProvider clearUser ───────────────────────────────────────────────

  group('UserProvider clearUser', () {
    test('resets user to null', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'b@t.com',
        role: 'PATIENT',
        token: 'tok-2',
      ));
      await provider.clearUser();
      expect(provider.user, isNull);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.userModel, isNull);
      expect(provider.patientModel, isNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });

    test('notifies listeners', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 3,
        email: 'c@t.com',
        role: 'CAREGIVER',
        token: 'tok-3',
      ));
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.clearUser();
      expect(notified, isTrue);
      provider.dispose();
    });
  });

  // ─── UserProvider updateUserName ──────────────────────────────────────────

  group('UserProvider updateUserName', () {
    test('updates the name and notifies listeners', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
        name: 'OldName',
      ));
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      provider.updateUserName('NewName');
      expect(provider.user!.name, 'NewName');
      expect(notified, isTrue);
      provider.dispose();
    });

    test('preserves other fields when updating name', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 5,
        email: 'e@t.com',
        role: 'CAREGIVER',
        token: 'tok-5',
        patientId: 10,
        caregiverId: 20,
        emailVerified: true,
      ));
      provider.updateUserName('Updated');
      final u = provider.user!;
      expect(u.id, 5);
      expect(u.email, 'e@t.com');
      expect(u.role, 'CAREGIVER');
      expect(u.token, 'tok-5');
      expect(u.patientId, 10);
      expect(u.caregiverId, 20);
      expect(u.emailVerified, isTrue);
      expect(u.name, 'Updated');
      provider.dispose();
    });

    test('does nothing when no user is set', () {
      final provider = UserProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      provider.updateUserName('SomeName');
      expect(provider.user, isNull);
      expect(notified, isFalse);
      provider.dispose();
    });
  });

  // ─── UserProvider updateUserRole ──────────────────────────────────────────

  group('UserProvider updateUserRole', () {
    test('updates role and notifies listeners', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.updateUserRole('CAREGIVER');
      expect(provider.user!.role, 'CAREGIVER');
      expect(notified, isTrue);
      provider.dispose();
    });

    test('preserves other fields when updating role', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 7,
        email: 'g@t.com',
        role: 'PATIENT',
        token: 'tok-7',
        patientId: 77,
        caregiverId: 88,
        name: 'Grace',
        emailVerified: true,
      ));
      await provider.updateUserRole('ADMIN');
      final u = provider.user!;
      expect(u.id, 7);
      expect(u.email, 'g@t.com');
      expect(u.token, 'tok-7');
      expect(u.patientId, 77);
      expect(u.caregiverId, 88);
      expect(u.name, 'Grace');
      expect(u.emailVerified, isTrue);
      expect(u.role, 'ADMIN');
      provider.dispose();
    });

    test('does nothing when no user is set', () async {
      final provider = UserProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.updateUserRole('CAREGIVER');
      expect(provider.user, isNull);
      expect(notified, isFalse);
      provider.dispose();
    });
  });

  // ─── UserProvider updatePatientId ─────────────────────────────────────────

  group('UserProvider updatePatientId', () {
    test('updates patientId and notifies listeners', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'CAREGIVER',
        token: 't',
      ));
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.updatePatientId(42);
      expect(provider.user!.patientId, 42);
      expect(notified, isTrue);
      provider.dispose();
    });

    test('can set patientId to null', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'CAREGIVER',
        token: 't',
        patientId: 99,
      ));
      await provider.updatePatientId(null);
      expect(provider.user!.patientId, isNull);
      provider.dispose();
    });

    test('preserves other fields', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 9,
        email: 'i@t.com',
        role: 'CAREGIVER',
        token: 'tok-9',
        caregiverId: 33,
        name: 'Ian',
        emailVerified: true,
      ));
      await provider.updatePatientId(55);
      final u = provider.user!;
      expect(u.id, 9);
      expect(u.email, 'i@t.com');
      expect(u.role, 'CAREGIVER');
      expect(u.token, 'tok-9');
      expect(u.caregiverId, 33);
      expect(u.name, 'Ian');
      expect(u.emailVerified, isTrue);
      expect(u.patientId, 55);
      provider.dispose();
    });

    test('does nothing when no user is set', () async {
      final provider = UserProvider();
      var notified = false;
      provider.addListener(() {
        notified = true;
      });
      await provider.updatePatientId(10);
      expect(provider.user, isNull);
      expect(notified, isFalse);
      provider.dispose();
    });
  });

  // ─── UserProvider offline mode ────────────────────────────────────────────

  group('UserProvider offline mode', () {
    test('offlineModeEnabled defaults to true', () {
      final provider = UserProvider();
      expect(provider.offlineModeEnabled, isTrue);
      provider.dispose();
    });

    test('setOfflineMode toggles the flag and notifies', () {
      final provider = UserProvider();
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setOfflineMode(false);
      expect(provider.offlineModeEnabled, isFalse);
      expect(notifyCount, 1);

      provider.setOfflineMode(true);
      expect(provider.offlineModeEnabled, isTrue);
      expect(notifyCount, 2);
      provider.dispose();
    });

    test('setOfflineMode does not notify when value unchanged', () {
      final provider = UserProvider();
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      // Default is true, setting to true again should not notify
      provider.setOfflineMode(true);
      expect(notifyCount, 0);
      provider.dispose();
    });

    test('shouldShowOfflineWarning when offlineMode disabled', () {
      final provider = UserProvider();
      provider.setOfflineMode(false);
      expect(provider.shouldShowOfflineWarning, isTrue);
      provider.dispose();
    });

    test('shouldShowOfflineWarning is false when online and offline mode enabled', () {
      final provider = UserProvider();
      // Default: offlineModeEnabled=true, isDeviceOnline=true
      expect(provider.shouldShowOfflineWarning, isFalse);
      provider.dispose();
    });

    test('isDeviceOnline defaults to true', () {
      final provider = UserProvider();
      expect(provider.isDeviceOnline, isTrue);
      provider.dispose();
    });
  });

  // ─── UserProvider fetchUserDetails ────────────────────────────────────────

  group('UserProvider fetchUserDetails', () {
    test('returns early when no user is set', () async {
      final provider = UserProvider();
      await provider.fetchUserDetails();
      expect(provider.userModel, isNull);
      expect(provider.patientModel, isNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });

    test('creates userModel for patient and fetches patient details', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'patient@test.com',
        role: 'PATIENT',
        token: 'test-token',
        patientId: 42,
        name: 'Test Patient',
      ));

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/api/patients/42')) {
          return http.Response(
            jsonEncode({
              'firstName': 'John',
              'lastName': 'Doe',
              'phone': '555-1234',
              'dob': '1990-01-01',
              'gender': 'Male',
              'address': {
                'line1': '123 Main St',
                'city': 'Springfield',
                'state': 'IL',
                'zip': '62701',
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.userModel!.email, 'patient@test.com');
      expect(provider.userModel!.role, 'PATIENT');
      expect(provider.userModel!.userId, '1');

      expect(provider.patientModel, isNotNull);
      expect(provider.patientModel!.firstName, 'John');
      expect(provider.patientModel!.lastName, 'Doe');
      expect(provider.patientModel!.phone, '555-1234');
      expect(provider.patientModel!.dob, '1990-01-01');
      expect(provider.patientModel!.gender, 'Male');
      expect(provider.patientModel!.address.line1, '123 Main St');
      expect(provider.patientModel!.address.city, 'Springfield');

      expect(provider.caregiverModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('creates userModel for caregiver and fetches caregiver details',
        () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'caregiver@test.com',
        role: 'CAREGIVER',
        token: 'test-token',
        caregiverId: 99,
        name: 'Test Caregiver',
      ));

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/api/caregivers/99')) {
          return http.Response(
            jsonEncode({
              'firstName': 'Jane',
              'lastname': 'Smith',
              'first_name': 'Jane',
              'last_name': 'Smith',
              'phone': '555-5678',
              'dob': '1985-06-15',
              'gender': 'Female',
              'caregiverType': 'Professional',
              'address': {
                'line1': '456 Oak Ave',
                'city': 'Chicago',
                'state': 'IL',
                'zip': '60601',
              },
              'professional': {
                'licenseNumber': 'LIC-123',
                'issuingState': 'IL',
                'yearsExperience': 10,
              },
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.userModel!.email, 'caregiver@test.com');
      expect(provider.userModel!.role, 'CAREGIVER');

      expect(provider.caregiverModel, isNotNull);
      expect(provider.caregiverModel!.firstName, 'Jane');
      expect(provider.caregiverModel!.lastName, 'Smith');
      expect(provider.caregiverModel!.phone, '555-5678');
      expect(provider.caregiverModel!.caregiverType, 'Professional');
      expect(provider.caregiverModel!.professionalInfo, isNotNull);
      expect(provider.caregiverModel!.professionalInfo!.licenseNumber,
          'LIC-123');
      expect(
          provider.caregiverModel!.professionalInfo!.yearsExperience, 10);

      expect(provider.patientModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('handles patient fetch with non-200 response', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'patient@test.com',
        role: 'PATIENT',
        token: 'test-token',
        patientId: 42,
      ));

      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.patientModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('handles caregiver fetch with non-200 response', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'caregiver@test.com',
        role: 'CAREGIVER',
        token: 'test-token',
        caregiverId: 99,
      ));

      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.caregiverModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('handles HTTP exception during patient fetch', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'p@test.com',
        role: 'PATIENT',
        token: 'tok',
        patientId: 10,
      ));

      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.patientModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('handles HTTP exception during caregiver fetch', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'c@test.com',
        role: 'CAREGIVER',
        token: 'tok',
        caregiverId: 50,
      ));

      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel, isNotNull);
      expect(provider.caregiverModel, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('skips patient fetch when patientId is null', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'p@test.com',
        role: 'PATIENT',
        token: 'tok',
        patientId: null,
      ));

      var httpCalled = false;
      final mockClient = MockClient((request) async {
        httpCalled = true;
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(httpCalled, isFalse);
      expect(provider.userModel, isNotNull);
      expect(provider.patientModel, isNull);
      provider.dispose();
    });

    test('skips caregiver fetch when caregiverId is null', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'c@test.com',
        role: 'CAREGIVER',
        token: 'tok',
        caregiverId: null,
      ));

      var httpCalled = false;
      final mockClient = MockClient((request) async {
        httpCalled = true;
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(httpCalled, isFalse);
      expect(provider.userModel, isNotNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });

    test('does not fetch for non-patient non-caregiver role', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@test.com',
        role: 'ADMIN',
        token: 'tok',
      ));

      var httpCalled = false;
      final mockClient = MockClient((request) async {
        httpCalled = true;
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(httpCalled, isFalse);
      expect(provider.userModel, isNotNull);
      expect(provider.userModel!.role, 'ADMIN');
      expect(provider.patientModel, isNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });

    test('uses user name in userModel (fallback to empty string)', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@test.com',
        role: 'ADMIN',
        token: 'tok',
        name: null,
      ));

      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.userModel!.name, '');
      provider.dispose();
    });

    test('fetchUserDetails sets isLoading during fetch', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@test.com',
        role: 'ADMIN',
        token: 'tok',
      ));

      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      // Should have been notified with isLoading=true, then isLoading=false
      expect(loadingStates, contains(true));
      expect(loadingStates.last, isFalse);
      provider.dispose();
    });

    test('patient fetch handles missing address in response', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'p@test.com',
        role: 'PATIENT',
        token: 'tok',
        patientId: 10,
      ));

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'firstName': 'Pat',
            'lastName': 'Doe',
          }),
          200,
        );
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.patientModel, isNotNull);
      expect(provider.patientModel!.firstName, 'Pat');
      expect(provider.patientModel!.phone, '');
      expect(provider.patientModel!.dob, '');
      expect(provider.patientModel!.gender, '');
      provider.dispose();
    });

    test('caregiver fetch handles missing professional info', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'c@test.com',
        role: 'CAREGIVER',
        token: 'tok',
        caregiverId: 50,
      ));

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'firstName': 'Care',
            'lastname': 'Giver',
            'first_name': 'Care',
            'last_name': 'Giver',
            'phone': '555-0000',
            'dob': '1980-01-01',
            'gender': 'Male',
            'caregiverType': 'Family',
            'address': {},
          }),
          200,
        );
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(provider.caregiverModel, isNotNull);
      expect(provider.caregiverModel!.firstName, 'Care');
      expect(provider.caregiverModel!.caregiverType, 'Family');
      expect(provider.caregiverModel!.professionalInfo, isNull);
      provider.dispose();
    });

    test('patient fetch sends correct authorization header', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'p@test.com',
        role: 'PATIENT',
        token: 'my-jwt-token',
        patientId: 10,
      ));

      String? capturedAuth;
      final mockClient = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'firstName': 'A',
            'lastName': 'B',
          }),
          200,
        );
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(capturedAuth, 'Bearer my-jwt-token');
      provider.dispose();
    });

    test('caregiver fetch sends correct authorization header', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 2,
        email: 'c@test.com',
        role: 'CAREGIVER',
        token: 'cg-token',
        caregiverId: 50,
      ));

      String? capturedAuth;
      final mockClient = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(
          jsonEncode({
            'firstName': 'A',
            'lastname': 'B',
            'first_name': 'A',
            'last_name': 'B',
            'caregiverType': 'Pro',
            'address': {},
          }),
          200,
        );
      });

      await http.runWithClient(
        () => provider.fetchUserDetails(),
        () => mockClient,
      );

      expect(capturedAuth, 'Bearer cg-token');
      provider.dispose();
    });
  });

  // ─── UserProvider updateActivity ──────────────────────────────────────────

  group('UserProvider updateActivity', () {
    test('does nothing when no user is set', () async {
      final provider = UserProvider();
      // Should not throw
      await provider.updateActivity();
      provider.dispose();
    });

    test('calls updateLastActivity when user is set', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));
      // Should not throw
      await provider.updateActivity();
      provider.dispose();
    });
  });

  // ─── UserProvider validateSession ─────────────────────────────────────────

  group('UserProvider validateSession', () {
    test('returns false when no user is set', () async {
      final provider = UserProvider();
      final result = await provider.validateSession();
      expect(result, isFalse);
      provider.dispose();
    });

    test('clears user data when session is invalid', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));

      // With mocked secure storage returning null for reads,
      // validateCurrentSession will return false (no token found)
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final result = await http.runWithClient(
        () => provider.validateSession(),
        () => mockClient,
      );

      expect(result, isFalse);
      expect(provider.user, isNull);
      expect(provider.userModel, isNull);
      provider.dispose();
    });
  });

  // ─── UserProvider refreshToken ────────────────────────────────────────────

  group('UserProvider refreshToken', () {
    test('returns false when no user is set', () async {
      final provider = UserProvider();
      final result = await provider.refreshToken();
      expect(result, isFalse);
      provider.dispose();
    });

    test('clears user on refresh failure (exception)', () async {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));

      // AuthService.forceRefreshToken will likely fail due to mocked storage
      // returning null values - this exercises the catch block
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final result = await http.runWithClient(
        () => provider.refreshToken(),
        () => mockClient,
      );

      // Should return false and clear the user on failure
      expect(result, isFalse);
      expect(provider.user, isNull);
      expect(provider.userModel, isNull);
      expect(provider.patientModel, isNull);
      expect(provider.caregiverModel, isNull);
      provider.dispose();
    });
  });

  // ─── UserProvider initializeUser ──────────────────────────────────────────

  group('UserProvider initializeUser', () {
    test('sets isLoading during initialization and resets after', () async {
      final provider = UserProvider();

      final loadingStates = <bool>[];
      provider.addListener(() {
        loadingStates.add(provider.isLoading);
      });

      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.initializeUser(),
        () => mockClient,
      );

      // First notification should be isLoading=true, last should be false
      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });

    test('user remains null when no stored session exists', () async {
      final provider = UserProvider();

      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      await http.runWithClient(
        () => provider.initializeUser(),
        () => mockClient,
      );

      // With mocked secure storage returning null, restoreSession returns null
      expect(provider.user, isNull);
      expect(provider.isLoading, isFalse);
      provider.dispose();
    });
  });

  // ─── UserProvider getUserDataFromStorage ───────────────────────────────────

  group('UserProvider getUserDataFromStorage', () {
    test('returns null when no data stored', () async {
      final provider = UserProvider();
      final data = await provider.getUserDataFromStorage();
      expect(data, isNull);
      provider.dispose();
    });
  });

  // ─── UserProvider logout ──────────────────────────────────────────────────

  group('UserProvider logout', () {
    test('logout method exists and completes', () async {
      final provider = UserProvider();
      // The logout method is currently empty but should complete without error
      await provider.logout();
      provider.dispose();
    });
  });

  // ─── UserProvider dispose ─────────────────────────────────────────────────

  group('UserProvider dispose', () {
    test('disposes without error', () {
      final provider = UserProvider();
      // Should not throw
      provider.dispose();
    });

    test('can dispose after setting user', () {
      final provider = UserProvider();
      provider.setUser(UserSession(
        id: 1,
        email: 'a@t.com',
        role: 'PATIENT',
        token: 't',
      ));
      provider.dispose();
    });
  });
}
