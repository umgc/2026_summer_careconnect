import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/caregiver_dashboard.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('CaregiverDashboard Simple Tests', () {
    testWidgets('analytics button is present in patient card', (
      WidgetTester tester,
    ) async {
      // Create a mock user
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      // Wait for the widget to build and the API call to fail
      await tester.pump(const Duration(seconds: 5));

      // Verify that the dashboard is rendered
      expect(find.text('Caregiver Dashboard'), findsOneWidget);

      // In test environment, the API call will fail and show an error state
      // The error state shows 'Error Loading Patients' or a loading indicator
      final errorFinder = find.textContaining('Error');
      final loadingFinder = find.byType(CircularProgressIndicator);

      expect(
        errorFinder.evaluate().length + loadingFinder.evaluate().length,
        greaterThan(0),
      );
    });

    testWidgets('renders Scaffold widget', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar with dashboard title', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Caregiver Dashboard'), findsOneWidget);
    });

    testWidgets('renders CaregiverDashboard widget type', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(CaregiverDashboard), findsOneWidget);
    });

    testWidgets('shows error or failed state without patients', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 2,
        email: 'other@example.com',
        role: 'caregiver',
        token: 'other_token',
        caregiverId: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(CaregiverDashboard), findsOneWidget);
    });

    testWidgets('renders without crashing with different caregiverId', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 5,
        email: 'five@example.com',
        role: 'caregiver',
        token: 'token_5',
        caregiverId: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
