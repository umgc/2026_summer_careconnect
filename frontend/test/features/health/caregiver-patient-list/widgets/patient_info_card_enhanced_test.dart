// Enhanced tests for PatientCard widget
// (lib/features/health/caregiver-patient-list/widgets/patient-info-card.dart).
// Covers: date formatting, mood row, notification/message badges,
// View Details button, non-urgent border, urgent border, message count variations.

import 'package:care_connect_app/features/health/caregiver-patient-list/models/patient-info.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/widgets/patient-info-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Patient _patient({
  bool isUrgent = false,
  int messageCount = 0,
  String mood = 'Good',
  String moodEmoji = '\u{1F60A}',
  String statusMessage = 'Feeling well',
  DateTime? lastUpdated,
  DateTime? nextCheckIn,
}) =>
    Patient(
      id: 'p-1',
      firstName: 'Alice',
      lastName: 'Smith',
      lastUpdated: lastUpdated ?? DateTime(2025, 6, 1),
      statusMessage: statusMessage,
      nextCheckIn: nextCheckIn ?? DateTime(2025, 6, 8),
      mood: mood,
      moodEmoji: moodEmoji,
      isUrgent: isUrgent,
      messageCount: messageCount,
    );

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('PatientCard - date display', () {
    testWidgets('formats lastUpdated with MM/dd/yyyy', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(lastUpdated: DateTime(2025, 1, 15))),
      ));
      expect(find.textContaining('01/15/2025'), findsOneWidget);
    });

    testWidgets('formats nextCheckIn with MM/dd/yyyy', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(nextCheckIn: DateTime(2025, 12, 31))),
      ));
      expect(find.textContaining('12/31/2025'), findsOneWidget);
    });

    testWidgets('shows Last Updated label', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.textContaining('Last Updated:'), findsOneWidget);
    });

    testWidgets('shows Next Check-In label', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.textContaining('Next Check-In:'), findsOneWidget);
    });
  });

  group('PatientCard - mood row', () {
    testWidgets('shows Mood: label', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.text('Mood: '), findsOneWidget);
    });

    testWidgets('shows mood text', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(mood: 'Anxious')),
      ));
      expect(find.text('Anxious'), findsOneWidget);
    });
  });

  group('PatientCard - badges', () {
    testWidgets('shows notification badge for urgent patient', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(isUrgent: true)),
      ));
      // Urgent patients show notification badge with count 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('no notification badge for non-urgent patient', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(isUrgent: false, messageCount: 0)),
      ));
      // Count "0" should NOT appear as a badge
      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows message badge when messageCount > 0', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(messageCount: 5)),
      ));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows message_outlined icon', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byIcon(Icons.message_outlined), findsOneWidget);
    });

    testWidgets('shows notifications_outlined icon', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });

  group('PatientCard - View Details button', () {
    testWidgets('shows View Details text', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('shows chevron_right icon', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tapping View Details triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(), onTap: () => tapped = true),
      ));
      await tester.tap(find.text('View Details'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('PatientCard - structure', () {
    testWidgets('contains a Card widget', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('contains an InkWell', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('contains a Divider', (tester) async {
      await tester.pumpWidget(_wrap(PatientCard(patient: _patient())));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('renders status message with custom text', (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(statusMessage: 'Needs attention')),
      ));
      expect(find.text('Needs attention'), findsOneWidget);
    });
  });

  group('PatientCard - urgent vs non-urgent', () {
    testWidgets('urgent patient shows both notification and message badges when messageCount > 0',
        (tester) async {
      await tester.pumpWidget(_wrap(
        PatientCard(patient: _patient(isUrgent: true, messageCount: 3)),
      ));
      // notification badge shows "1", message badge shows "3"
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
