// Tests for PatientReportsScreen
// (lib/screens/patient_reports.dart).
//
// Pure StatelessWidget with no API calls or Provider dependencies.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:care_connect_app/screens/patient_reports.dart';

Widget _wrap() => const MaterialApp(home: PatientReportsScreen());

void main() {
  group('PatientReportsScreen – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(PatientReportsScreen), findsOneWidget);
    });

    testWidgets('shows "My Reports" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('My Reports'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows SingleChildScrollView', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('PatientReportsScreen – summary cards', () {
    testWidgets('shows Average Mood label', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Average Mood'), findsOneWidget);
    });

    testWidgets('shows mood value 7.5 / 10', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('7.5 / 10'), findsOneWidget);
    });

    testWidgets('shows Adherence label', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Adherence'), findsOneWidget);
    });

    testWidgets('shows adherence percentage', (tester) async {
      await tester.pumpWidget(_wrap());
      // totalTaken=19, totalMissed=9, pct = 19/28*100 ≈ 68%
      expect(find.text('68%'), findsOneWidget);
    });
  });

  group('PatientReportsScreen – chart headings', () {
    testWidgets('shows Mood Trend heading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Mood Trend (Last 7 Days)'), findsOneWidget);
    });

    testWidgets('shows Medication Adherence heading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Medication Adherence (Last 7 Days)'), findsOneWidget);
    });
  });

  group('PatientReportsScreen – chart widgets', () {
    testWidgets('shows LineChart for mood trend', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows BarChart for adherence', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  group('PatientReportsScreen – legend', () {
    testWidgets('shows Taken legend label', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Taken'), findsOneWidget);
    });

    testWidgets('shows Missed legend label', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Missed'), findsOneWidget);
    });
  });
}
