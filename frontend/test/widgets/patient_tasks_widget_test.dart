// Tests for PatientTasksWidget
// (lib/widgets/patient_tasks_widget.dart).
//
// initState calls _fetchTasks() which hits the API (ApiService.getPatientTasks).
// The call has try/catch — test failure leaves loading=false after error.
// Tests use pump() only to catch the loading state before the async call resolves.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/patient_tasks_widget.dart';

Widget _wrap({int patientId = 1, String patientName = 'Alice', bool isCaregiver = false}) =>
    MaterialApp(
      home: Scaffold(
        body: PatientTasksWidget(
          patientId: patientId,
          patientName: patientName,
          isCaregiver: isCaregiver,
        ),
      ),
    );

void main() {
  group('PatientTasksWidget – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(PatientTasksWidget), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      // loading starts true; API call is pending.
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows no task ListTile items while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('renders with isCaregiver=true without crashing', (tester) async {
      await tester.pumpWidget(_wrap(isCaregiver: true));
      expect(find.byType(PatientTasksWidget), findsOneWidget);
    });

    testWidgets('shows Center while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('does NOT show error text while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('renders with different patientId', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 99, patientName: 'Bob'));
      expect(find.byType(PatientTasksWidget), findsOneWidget);
    });
  });
}
