// Tests for the caregiver and patient "More Features" bottom drawer widgets:
//   CaregiverMoreFeaturesBottomDrawerWidget
//     (lib/config/navigation/caregiver_more_features_bottom_drawer.dart)
//   PatientMoreFeaturesBottomDrawerWidget
//     (lib/config/navigation/patient_more_features_bottom_drawer.dart)
//
// Both are pure StatelessWidgets — no Provider, no API calls on render.
// They pass a list of FeatureItems to MoreFeaturesBottomDrawer.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/navigation/caregiver_more_features_bottom_drawer.dart';
import 'package:care_connect_app/config/navigation/patient_more_features_bottom_drawer.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(height: 800, child: child)),
    );

void main() {
  group('CaregiverMoreFeaturesBottomDrawerWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(
        find.byType(CaregiverMoreFeaturesBottomDrawerWidget),
        findsOneWidget,
      );
    });

    testWidgets('shows "Additional Features" heading', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Additional Features'), findsOneWidget);
    });

    testWidgets('shows "Calendar Assistant" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Calendar Assistant'), findsOneWidget);
    });

    testWidgets('shows "Invoice Assistant" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Invoice Assistant'), findsOneWidget);
    });

    testWidgets('shows "Settings" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('PatientMoreFeaturesBottomDrawerWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(
        find.byType(PatientMoreFeaturesBottomDrawerWidget),
        findsOneWidget,
      );
    });

    testWidgets('shows "Additional Features" heading', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Additional Features'), findsOneWidget);
    });

    testWidgets('shows "SOS" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('SOS'), findsOneWidget);
    });

    testWidgets('shows "Medication Tracker" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Medication Tracker'), findsOneWidget);
    });

    testWidgets('shows "Virtual Check-In" feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Virtual Check-In'), findsWidgets);
    });
  });
}
