// Tests for RBACTestScreen
// (lib/screens/rbac_test_screen.dart).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/screens/rbac_test_screen.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../mock_user_provider.dart';

Widget _wrapNoUser() {
  final provider = MockUserProvider(
    mockUser: MockUser(id: 1, role: 'PATIENT'),
  );
  // Override userSession to be null so login buttons show
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: const RBACTestScreen(),
    ),
  );
}

Widget _wrapWithUser({String role = 'PATIENT', int? patientId, int? caregiverId}) {
  final provider = UserProvider();
  provider.setUser(UserSession(
    id: 1,
    email: '${role.toLowerCase()}@test.com',
    role: role,
    token: 'mock_token',
    name: 'Test ${role.toLowerCase()}',
    patientId: patientId ?? (role == 'PATIENT' ? 1 : null),
    caregiverId: caregiverId ?? (role == 'CAREGIVER' ? 1 : null),
  ));
  // Set userSession field to the same user session
  provider.userSession = provider.user;
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: const RBACTestScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        return null;
      },
    );
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

  group('RBACTestScreen – no user (login buttons)', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrapNoUser());
      expect(find.byType(RBACTestScreen), findsOneWidget);
    });

    testWidgets('shows RBAC Test in AppBar', (tester) async {
      await tester.pumpWidget(_wrapNoUser());
      expect(find.text('RBAC Test'), findsOneWidget);
    });

    testWidgets('shows role selection prompt', (tester) async {
      await tester.pumpWidget(_wrapNoUser());
      expect(find.text('Select a role to test RBAC:'), findsOneWidget);
    });

    testWidgets('shows all 4 login buttons', (tester) async {
      await tester.pumpWidget(_wrapNoUser());
      expect(find.text('Login as Admin'), findsOneWidget);
      expect(find.text('Login as Caregiver'), findsOneWidget);
      expect(find.text('Login as Patient'), findsOneWidget);
      expect(find.text('Login as Family Member'), findsOneWidget);
    });

    testWidgets('shows role icons', (tester) async {
      await tester.pumpWidget(_wrapNoUser());
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.family_restroom), findsOneWidget);
    });
  });

  group('RBACTestScreen – PATIENT logged in', () {
    testWidgets('shows user info card', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.textContaining('Current User:'), findsOneWidget);
      expect(find.text('Role: PATIENT'), findsOneWidget);
    });

    testWidgets('shows role chip in AppBar', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('shows admin-only section heading', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.text('Admin-Only Section:'), findsOneWidget);
    });

    testWidgets('shows caregiver or admin section heading', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.text('Caregiver or Admin Section:'), findsOneWidget);
    });

    testWidgets('shows permission-based buttons heading', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.text('Permission-Based Buttons:'), findsOneWidget);
    });

    testWidgets('shows not family member section heading', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      expect(find.text('Not Family Member Section:'), findsOneWidget);
    });

    testWidgets('shows logout button when scrolled', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      // Scroll down to find logout button
      await tester.scrollUntilVisible(find.text('Logout'), 200);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('patient does not see Admin Control Panel', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'PATIENT'));
      await tester.pump();
      // Patient should see admin fallback, not the panel
      expect(find.text('Admin Control Panel'), findsNothing);
    });
  });

  group('RBACTestScreen – ADMIN logged in', () {
    testWidgets('shows admin control panel', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'ADMIN'));
      await tester.pump();
      expect(find.text('Admin Control Panel'), findsOneWidget);
    });

    testWidgets('shows patient management', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'ADMIN'));
      await tester.pump();
      expect(find.text('Patient Management'), findsOneWidget);
    });
  });

  group('RBACTestScreen – CAREGIVER logged in', () {
    testWidgets('shows patient management for caregiver', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'CAREGIVER', caregiverId: 1));
      await tester.pump();
      expect(find.text('Patient Management'), findsOneWidget);
    });

    testWidgets('shows role chip with CAREGIVER', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'CAREGIVER', caregiverId: 1));
      await tester.pump();
      expect(find.byType(Chip), findsOneWidget);
    });
  });

  group('RBACTestScreen – FAMILY_MEMBER logged in', () {
    testWidgets('renders with family member role', (tester) async {
      await tester.pumpWidget(_wrapWithUser(role: 'FAMILY_MEMBER'));
      await tester.pump();
      expect(find.text('Role: FAMILY_MEMBER'), findsOneWidget);
    });
  });
}
