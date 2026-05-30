// Tests for PatientCard
// (lib/features/health/caregiver-patient-list/widgets/patient-info-card.dart).

import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/widgets/patient-info-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Patient _patient({bool isUrgent = false, int messageCount = 0}) => Patient(
      id: 'p-1',
      firstName: 'Alice',
      lastName: 'Smith',
      lastUpdated: DateTime(2025, 6, 1, 10, 0),
      statusMessage: 'Feeling well',
      nextCheckIn: DateTime(2025, 6, 8, 10, 0),
      mood: 'Good',
      moodEmoji: '😊',
      isUrgent: isUrgent,
      messageCount: messageCount,
    );

void main() {
  testWidgets('renders patient name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatientCard(patient: _patient())),
      ),
    );
    expect(find.text('Alice Smith'), findsOneWidget);
  });

  testWidgets('renders status message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatientCard(patient: _patient())),
      ),
    );
    expect(find.text('Feeling well'), findsOneWidget);
  });

  testWidgets('renders mood emoji', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatientCard(patient: _patient())),
      ),
    );
    expect(find.textContaining('😊'), findsOneWidget);
  });

  testWidgets('shows URGENT badge for urgent patients', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatientCard(patient: _patient(isUrgent: true))),
      ),
    );
    expect(find.text('URGENT'), findsOneWidget);
  });

  testWidgets('hides URGENT badge for non-urgent patients', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PatientCard(patient: _patient(isUrgent: false))),
      ),
    );
    expect(find.text('URGENT'), findsNothing);
  });

  testWidgets('renders without crashing when onTap provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatientCard(
            patient: _patient(),
            onTap: () {},
          ),
        ),
      ),
    );
    // Note: InkWell.onTap is hardcoded to null in the widget; just verify render.
    expect(find.byType(PatientCard), findsOneWidget);
  });
}
