// Tests for PatientCard widget
// (lib/features/health/caregiver-patient-list/widgets/patient-info-card.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/widgets/patient-info-card.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';

Patient _makePatient({
  bool isUrgent = false,
  int messageCount = 0,
}) =>
    Patient(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      lastUpdated: DateTime(2024, 6, 15),
      statusMessage: 'Feeling better today',
      nextCheckIn: DateTime(2024, 6, 20),
      mood: 'Happy',
      moodEmoji: '😊',
      isUrgent: isUrgent,
      messageCount: messageCount,
    );

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('PatientCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.byType(PatientCard), findsOneWidget);
    });

    testWidgets('shows full name', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows last updated date', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.textContaining('Last Updated:'), findsOneWidget);
      expect(find.textContaining('06/15/2024'), findsOneWidget);
    });

    testWidgets('shows status message', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.text('Feeling better today'), findsOneWidget);
    });

    testWidgets('shows next check-in date', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.textContaining('Next Check-In:'), findsOneWidget);
    });

    testWidgets('shows mood', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.text('Happy'), findsOneWidget);
    });

    testWidgets('shows mood emoji', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.text('😊'), findsOneWidget);
    });

    testWidgets('shows URGENT badge when isUrgent is true', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient(isUrgent: true))));
      expect(find.text('URGENT'), findsOneWidget);
    });

    testWidgets('does not show URGENT badge when isUrgent is false', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient(isUrgent: false))));
      expect(find.text('URGENT'), findsNothing);
    });

    testWidgets('shows notification icon', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('shows message icon', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.byIcon(Icons.message_outlined), findsOneWidget);
    });

    testWidgets('shows View Details button', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient())));
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('tapping View Details calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(PatientCard(
        patient: _makePatient(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('View Details'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('shows message count badge when messageCount > 0', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _makePatient(messageCount: 3))));
      expect(find.text('3'), findsOneWidget);
    });
  });
}
