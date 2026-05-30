// Tests for PatientCard widget
// (lib/features/health/caregiver-patient-list/widgets/patient-info-card.dart).
//
// Pure StatelessWidget with no Provider or HTTP.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/widgets/patient-info-card.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';

Patient _makePatient() => Patient(
      id: 'p-1',
      firstName: 'Sarah',
      lastName: 'Johnson',
      lastUpdated: DateTime(2025, 1, 1),
      statusMessage: 'Feeling good today',
      nextCheckIn: DateTime(2025, 1, 2, 10),
      mood: 'Good',
      moodEmoji: '😊',
      isUrgent: false,
      messageCount: 2,
    );

Widget _wrap() => MaterialApp(
      home: Scaffold(body: PatientCard(patient: _makePatient())),
    );

void main() {
  group('PatientCard widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(PatientCard), findsOneWidget);
    });

    testWidgets('shows patient first name', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Sarah'), findsOneWidget);
    });

    testWidgets('shows patient last name', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Johnson'), findsOneWidget);
    });

    testWidgets('shows mood emoji', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('😊'), findsWidgets);
    });

    testWidgets('shows status message', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Feeling good today'), findsOneWidget);
    });

    testWidgets('shows mood text', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Good'), findsWidgets);
    });

    testWidgets('shows message count badge', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('renders Card or InkWell wrapper', (tester) async {
      await tester.pumpWidget(_wrap());
      // The widget should have a tappable area (InkWell or GestureDetector)
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('renders urgent patient card', (tester) async {
      final urgentPatient = Patient(
        id: 'p-2',
        firstName: 'John',
        lastName: 'Doe',
        lastUpdated: DateTime(2025, 1, 1),
        statusMessage: 'Need help',
        nextCheckIn: DateTime(2025, 1, 2, 10),
        mood: 'Bad',
        moodEmoji: '😢',
        isUrgent: true,
        messageCount: 5,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PatientCard(patient: urgentPatient)),
        ),
      );
      expect(find.byType(PatientCard), findsOneWidget);
      expect(find.textContaining('John'), findsOneWidget);
    });

    testWidgets('shows Container or Card wrapper', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Container), findsWidgets);
    });
  });
}
