// Tests for RoleMismatchDialog widget
// (lib/widgets/role_mismatch_dialog.dart).
//
// RoleMismatchDialog uses go_router's context.go — MaterialApp.router with a
// GoRouter config is required.  The dialog is opened via showDialog.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/widgets/role_mismatch_dialog.dart';

GoRouter _makeRouter(Widget dialogWidget) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () => showDialog(
                context: ctx,
                builder: (_) => dialogWidget,
              ),
              child: const Text('Open'),
            );
          }),
        ),
      ),
      GoRoute(path: '/login/caregiver', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/login/patient', builder: (_, __) => const Scaffold()),
    ],
  );
}

Widget _wrapDialog({
  String actualRole = 'PATIENT',
  String expectedRole = 'CAREGIVER',
  String correctLoginRoute = '/login/patient',
  String message = 'Wrong login page.',
}) {
  return MaterialApp.router(
    routerConfig: _makeRouter(RoleMismatchDialog(
      actualRole: actualRole,
      expectedRole: expectedRole,
      correctLoginRoute: correctLoginRoute,
      message: message,
    )),
  );
}

void main() {
  group('RoleMismatchDialog', () {
    testWidgets('shows "Wrong Login Page" title', (tester) async {
      // Verifies the dialog title is correct.
      await tester.pumpWidget(_wrapDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Wrong Login Page'), findsOneWidget);
    });

    testWidgets('shows the message text', (tester) async {
      // Verifies that the message passed to the dialog is displayed.
      await tester.pumpWidget(_wrapDialog(message: 'Please use correct login.'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Please use correct login.'), findsOneWidget);
    });

    testWidgets('shows warning icon', (tester) async {
      // Verifies the warning icon is shown in the title row.
      await tester.pumpWidget(_wrapDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows Account Information section', (tester) async {
      // Verifies the info box with account details is present.
      await tester.pumpWidget(_wrapDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Account Information'), findsOneWidget);
    });

    testWidgets('shows actual role display name', (tester) async {
      // Verifies the actual role is shown in the info box.
      await tester.pumpWidget(_wrapDialog(actualRole: 'PATIENT'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      // RoleValidator.getRoleDisplayName('PATIENT') → 'Patient'
      expect(find.textContaining('Patient'), findsWidgets);
    });

    testWidgets('shows Cancel button', (tester) async {
      // Verifies the Cancel action button is present.
      await tester.pumpWidget(_wrapDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping Cancel closes the dialog', (tester) async {
      // Verifies that tapping Cancel pops the dialog.
      await tester.pumpWidget(_wrapDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Wrong Login Page'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Wrong Login Page'), findsNothing);
    });

    testWidgets('shows Go to login button', (tester) async {
      // Verifies the "Go to ... Login" button is present.
      await tester.pumpWidget(_wrapDialog(actualRole: 'CAREGIVER'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Go to'), findsOneWidget);
    });

    testWidgets('RoleMismatchDialog.show opens the dialog', (tester) async {
      // Verifies the static show() method displays the dialog correctly.
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Scaffold(
              body: Builder(builder: (ctx) {
                return ElevatedButton(
                  onPressed: () => RoleMismatchDialog.show(
                    context: ctx,
                    actualRole: 'PATIENT',
                    expectedRole: 'CAREGIVER',
                    correctLoginRoute: '/login/patient',
                    message: 'Use patient login.',
                  ),
                  child: const Text('Show'),
                );
              }),
            ),
          ),
          GoRoute(path: '/login/patient', builder: (_, __) => const Scaffold()),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Wrong Login Page'), findsOneWidget);
      expect(find.text('Use patient login.'), findsOneWidget);
    });
  });
}
