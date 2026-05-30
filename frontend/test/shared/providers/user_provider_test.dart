// Tests for UserProvider and UserSession (lib/shared/providers/user_provider.dart).
// Pure ChangeNotifier — no Flutter framework needed for the model/provider logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/shared/providers/user_provider.dart';

void main() {
  group('UserSession constructor', () {
    test('stores required fields', () {
      final session = UserSession(
        id: 10,
        role: 'CAREGIVER',
        token: 'tok-abc',
      );
      expect(session.id, 10);
      expect(session.role, 'CAREGIVER');
      expect(session.token, 'tok-abc');
      expect(session.patientId, isNull);
      expect(session.caregiverId, isNull);
    });

    test('stores optional patientId and caregiverId', () {
      final session = UserSession(
        id: 5,
        role: 'PATIENT',
        token: 'tok-xyz',
        patientId: 42,
        caregiverId: 7,
      );
      expect(session.patientId, 42);
      expect(session.caregiverId, 7);
    });
  });

  group('UserProvider', () {
    test('starts with null user', () {
      final provider = UserProvider();
      expect(provider.user, isNull);
    });

    test('setUser stores the user', () {
      final provider = UserProvider();
      final session = UserSession(id: 1, role: 'ADMIN', token: 'tok-1');
      provider.setUser(session);
      expect(provider.user, same(session));
    });

    test('clearUser resets user to null', () {
      final provider = UserProvider();
      provider.setUser(UserSession(id: 2, role: 'PATIENT', token: 'tok-2'));
      provider.clearUser();
      expect(provider.user, isNull);
    });

    test('setUser notifies listeners', () {
      final provider = UserProvider();
      var notified = false;
      provider.addListener(() { notified = true; });
      provider.setUser(UserSession(id: 3, role: 'CAREGIVER', token: 'tok-3'));
      expect(notified, isTrue);
    });

    test('clearUser notifies listeners', () {
      final provider = UserProvider();
      provider.setUser(UserSession(id: 4, role: 'PATIENT', token: 'tok-4'));
      var notified = false;
      provider.addListener(() { notified = true; });
      provider.clearUser();
      expect(notified, isTrue);
    });
  });
}
