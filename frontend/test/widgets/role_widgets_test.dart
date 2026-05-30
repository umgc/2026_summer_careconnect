import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/widgets/role_widgets.dart';
import 'package:care_connect_app/providers/user_provider.dart';

// Mock UserSession for testing
class MockUserSession {
  final int id;
  final String name;
  final String email;
  final String role;
  final String token;

  MockUserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });
}

// Mock UserProvider for testing
class MockUserProvider extends UserProvider {
  MockUserSession? mockSession;

  MockUserProvider({this.mockSession});

  @override
  UserSession? get userSession {
    if (mockSession == null) return null;
    return UserSession(
      id: mockSession!.id,
      name: mockSession!.name,
      email: mockSession!.email,
      role: mockSession!.role,
      token: mockSession!.token,
      patientId: null,
      caregiverId: null,
    );
  }
}

void main() {
  group('Role Widget Tests', () {
    testWidgets('AdminOnly shows content for admin', (tester) async {
      final mockProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Admin User',
          email: 'admin@test.com',
          role: 'ADMIN',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsOneWidget);
    });

    testWidgets('AdminOnly hides content for non-admin', (tester) async {
      final mockProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Patient User',
          email: 'patient@test.com',
          role: 'PATIENT',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Admin Content'), findsNothing);
    });

    testWidgets('CaregiverOrAdmin shows for both roles', (tester) async {
      // Test with Caregiver
      final caregiverProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Caregiver',
          email: 'caregiver@test.com',
          role: 'CAREGIVER',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: caregiverProvider,
          child: MaterialApp(
            home: Scaffold(
              body: CaregiverOrAdmin(
                child: Text('Caregiver or Admin Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Caregiver or Admin Content'), findsOneWidget);

      // Test with Admin
      final adminProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Admin',
          email: 'admin@test.com',
          role: 'ADMIN',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: adminProvider,
          child: MaterialApp(
            home: Scaffold(
              body: CaregiverOrAdmin(
                child: Text('Caregiver or Admin Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Caregiver or Admin Content'), findsOneWidget);
    });

    testWidgets('NotFamilyMember hides for family members', (tester) async {
      final mockProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Family',
          email: 'family@test.com',
          role: 'FAMILY_MEMBER',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: NotFamilyMember(
                child: Text('Not Family Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Not Family Content'), findsNothing);
    });

    testWidgets('PermissionButton shows for users with permission',
        (tester) async {
      final mockProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Caregiver',
          email: 'caregiver@test.com',
          role: 'CAREGIVER',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionButton(
                permission: 'CREATE_TASKS',
                onPressed: () {},
                child: Text('Create Task'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Create Task'), findsOneWidget);
    });

    testWidgets('PermissionButton hides for users without permission',
        (tester) async {
      final mockProvider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1,
          name: 'Patient',
          email: 'patient@test.com',
          role: 'PATIENT',
          token: 'token',
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionButton(
                permission: 'DELETE_PATIENTS',
                onPressed: () {},
                child: Text('Delete Patient'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Delete Patient'), findsNothing);
    });

    testWidgets('CaregiverOnly shows for CAREGIVER', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'CG', email: 'c@t.com', role: 'CAREGIVER', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: CaregiverOnly(child: Text('CG Only'))),
          ),
        ),
      );
      expect(find.text('CG Only'), findsOneWidget);
    });

    testWidgets('CaregiverOnly hides for PATIENT', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: CaregiverOnly(child: Text('CG Only'))),
          ),
        ),
      );
      expect(find.text('CG Only'), findsNothing);
    });

    testWidgets('PatientOnly shows for PATIENT', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: PatientOnly(child: Text('Patient Only'))),
          ),
        ),
      );
      expect(find.text('Patient Only'), findsOneWidget);
    });

    testWidgets('PatientOnly hides for ADMIN', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'A', email: 'a@t.com', role: 'ADMIN', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: PatientOnly(child: Text('Patient Only'))),
          ),
        ),
      );
      expect(find.text('Patient Only'), findsNothing);
    });

    testWidgets('RoleWidget shows fallback when no session', (tester) async {
      final provider = MockUserProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: RoleWidget(
                shouldShow: (_) => true,
                fallback: const Text('Fallback'),
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Fallback'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('RoleWidget shows fallback when role check fails', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: RoleWidget(
                shouldShow: (_) => false,
                fallback: const Text('No Access'),
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('No Access'), findsOneWidget);
    });

    testWidgets('PermissionIconButton shows for user with permission', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'A', email: 'a@t.com', role: 'ADMIN', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionIconButton(
                permission: 'DELETE_PATIENTS',
                onPressed: () {},
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('PermissionIconButton hidden when no session', (tester) async {
      final provider = MockUserProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionIconButton(
                permission: 'DELETE_PATIENTS',
                onPressed: () {},
                icon: const Icon(Icons.delete),
              ),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('PermissionMenuItem shows for user with permission', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'CG', email: 'c@t.com', role: 'CAREGIVER', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionMenuItem(
                permission: 'CREATE_TASKS',
                leading: const Icon(Icons.add),
                title: 'New Task',
                subtitle: 'Create a new task',
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('Create a new task'), findsOneWidget);
    });

    testWidgets('PermissionMenuItem hidden for user without permission', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionMenuItem(
                permission: 'DELETE_PATIENTS',
                leading: const Icon(Icons.delete),
                title: 'Delete Patient',
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Delete Patient'), findsNothing);
    });

    testWidgets('PermissionMenuItem hidden when no session', (tester) async {
      final provider = MockUserProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionMenuItem(
                permission: 'CREATE_TASKS',
                leading: const Icon(Icons.add),
                title: 'New Task',
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('New Task'), findsNothing);
    });

    testWidgets('PermissionButton hidden when no session', (tester) async {
      final provider = MockUserProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: PermissionButton(
                permission: 'CREATE_TASKS',
                onPressed: () {},
                child: const Text('Create'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Create'), findsNothing);
    });

    testWidgets('AdminOnly shows fallback for non-admin', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                fallback: Text('No admin'),
                child: Text('Admin'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('No admin'), findsOneWidget);
    });

    testWidgets('NotFamilyMember shows for PATIENT', (tester) async {
      final provider = MockUserProvider(
        mockSession: MockUserSession(
          id: 1, name: 'P', email: 'p@t.com', role: 'PATIENT', token: 't',
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: NotFamilyMember(child: Text('Visible'))),
          ),
        ),
      );
      expect(find.text('Visible'), findsOneWidget);
    });
  });
}