// Tests for PatientVirtualCheckIn (web stub page)
// (lib/features/health/virtual_check_in/presentation/pages/patient_check_in_page_web.dart).
//
// Pure StatelessWidget — no Provider, no API calls.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/presentation/pages/patient_check_in_page_web.dart';

Widget _wrap() =>
    const MaterialApp(home: PatientVirtualCheckIn());

void main() {
  group('PatientVirtualCheckIn – web stub', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(PatientVirtualCheckIn), findsOneWidget);
    });

    testWidgets('shows "Virtual Check-In" in the AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Virtual Check-In'), findsOneWidget);
    });

    testWidgets('shows web-only notice text', (tester) async {
      // Informs the user that camera flow is only on mobile.
      await tester.pumpWidget(_wrap());
      expect(
        find.textContaining('Virtual check-in camera flow is available on mobile'),
        findsOneWidget,
      );
    });

    testWidgets('renders a Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows Center widget', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('does NOT show CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
