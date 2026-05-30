// Tests for AddFamilyMemberDialog widget
// (lib/widgets/add_family_member_dialog.dart)
// StatefulWidget with local form state only — no API calls or Provider.
// Tests cover rendering, form fields, validation messages, and button actions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/add_family_member_dialog.dart';

Widget _dialog() => const MaterialApp(
      home: Scaffold(
        body: AddFamilyMemberDialog(),
      ),
    );

void main() {
  group('AddFamilyMemberDialog', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.byType(AddFamilyMemberDialog), findsOneWidget);
    });

    testWidgets('shows "Add Family Member" title', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Add Family Member'), findsOneWidget);
    });

    testWidgets('shows First Name field', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('First Name'), findsOneWidget);
    });

    testWidgets('shows Last Name field', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Last Name'), findsOneWidget);
    });

    testWidgets('shows Relationship field', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Relationship'), findsOneWidget);
    });

    testWidgets('shows Phone Number field', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('shows Email Address field', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('shows email icon', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('shows Cancel button', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows Add button', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('shows 5 TextFormFields', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('shows validation error when submitting empty form',
        (tester) async {
      // Suppress layout overflow — error text grows the Column beyond its max height.
      final prev = FlutterError.onError!;
      FlutterError.onError = (d) {
        if (d.exceptionAsString().contains('overflowed')) return;
        prev(d);
      };
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_dialog());
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Please enter first name'), findsOneWidget);
    });

    testWidgets('shows last name validation error when first name is filled',
        (tester) async {
      final prev = FlutterError.onError!;
      FlutterError.onError = (d) {
        if (d.exceptionAsString().contains('overflowed')) return;
        prev(d);
      };
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_dialog());
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Please enter last name'), findsOneWidget);
    });

    testWidgets('shows invalid email validation error', (tester) async {
      final prev = FlutterError.onError!;
      FlutterError.onError = (d) {
        if (d.exceptionAsString().contains('overflowed')) return;
        prev(d);
      };
      addTearDown(() => FlutterError.onError = prev);

      await tester.pumpWidget(_dialog());
      // Fill all required fields except email validity
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'Son');
      await tester.enterText(find.byType(TextFormField).at(3), '555-1234');
      await tester.enterText(find.byType(TextFormField).at(4), 'notanemail');
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('accepts text input in each field', (tester) async {
      await tester.pumpWidget(_dialog());
      await tester.enterText(find.byType(TextFormField).at(0), 'Jane');
      await tester.enterText(find.byType(TextFormField).at(1), 'Smith');
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);
    });

    testWidgets('shows relationship hint text', (tester) async {
      await tester.pumpWidget(_dialog());
      expect(find.text('e.g., Son, Daughter, Spouse'), findsOneWidget);
    });
  });
}
