// Tests for LoginScreen
// (lib/screens/login_screen.dart).
//
// LoginScreen is a pure form widget — no API calls in initState.
// AuthService is only invoked on button press.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/screens/login_screen.dart';

Widget _wrap() => const MaterialApp(home: LoginScreen());

void main() {
  group('LoginScreen – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows "CareConnect" title', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('CareConnect'), findsOneWidget);
    });

    testWidgets('shows "Login to continue" subtitle', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Login to continue'), findsOneWidget);
    });

    testWidgets('shows Icons.health_and_safety logo', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('shows Username TextFormField', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    });

    testWidgets('shows Password TextFormField', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('shows "Login" button', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows Icons.person in username field', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows Icons.lock in password field', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows Demo Accounts expansion tile', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Demo Accounts'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Form widget', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('does NOT show CircularProgressIndicator initially',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('password field is obscured', (tester) async {
      await tester.pumpWidget(_wrap());
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final passwordField = textFields.where((tf) => tf.obscureText).toList();
      expect(passwordField.length, 1);
    });

    testWidgets('shows info_outline icon for demo accounts', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows ExpansionTile for demo accounts', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('shows ElevatedButton for login', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows two TextFormField widgets (username + password)',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('shows ConstrainedBox with maxWidth 400', (tester) async {
      await tester.pumpWidget(_wrap());
      final boxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final narrow = boxes.where((b) => b.constraints.maxWidth == 400);
      expect(narrow, isNotEmpty);
    });
  });

  group('LoginScreen – form validation', () {
    testWidgets('empty username shows validation error', (tester) async {
      await tester.pumpWidget(_wrap());
      // Tap login without filling fields
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Please enter your username'), findsOneWidget);
    });

    testWidgets('empty password shows validation error', (tester) async {
      await tester.pumpWidget(_wrap());
      // Fill username only
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('both empty shows both validation errors', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('can enter text in username field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'), 'admin');
      expect(find.text('admin'), findsOneWidget);
    });

    testWidgets('can enter text in password field', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'secret');
      expect(find.text('secret'), findsOneWidget);
    });
  });

  group('LoginScreen – demo accounts', () {
    testWidgets('expanding Demo Accounts shows role tiles', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Admin: admin'), findsOneWidget);
      expect(find.text('Caregiver: caregiver'), findsOneWidget);
      expect(find.text('Patient: patient'), findsOneWidget);
      expect(find.text('Family: family'), findsOneWidget);
    });

    testWidgets('shows role descriptions when expanded', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Full system access'), findsOneWidget);
      expect(find.text('Manage patients'), findsOneWidget);
      expect(find.text('View own data'), findsOneWidget);
      expect(find.text('Read-only access'), findsOneWidget);
    });

    testWidgets('shows "Use" buttons when expanded', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Use'), findsNWidgets(4));
    });

    testWidgets('tapping "Use" fills in credentials', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      // Tap first "Use" button (Admin)
      await tester.tap(find.text('Use').first);
      await tester.pump();
      expect(find.text('admin'), findsWidgets);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('shows ListTile for each demo account', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      // 4 demo account tiles + 1 ExpansionTile (which is itself a ListTile)
      expect(find.byType(ListTile), findsNWidgets(5));
    });

    testWidgets('shows TextButton for each "Use" action', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.tap(find.text('Demo Accounts'));
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsNWidgets(4));
    });
  });
}
