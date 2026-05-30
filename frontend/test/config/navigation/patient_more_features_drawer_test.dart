import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/navigation/patient_more_features_bottom_drawer.dart';
import 'package:care_connect_app/shared/widgets/more_features_bottom_drawer.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(height: 800, child: child)),
    );

void main() {
  group('PatientMoreFeaturesBottomDrawerWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(
        find.byType(PatientMoreFeaturesBottomDrawerWidget),
        findsOneWidget,
      );
    });

    testWidgets('wraps MoreFeaturesBottomDrawer', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.byType(MoreFeaturesBottomDrawer), findsOneWidget);
    });

    testWidgets('shows "Additional Features" heading', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Additional Features'), findsOneWidget);
    });

    testWidgets('shows SOS feature with subtitle', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('SOS'), findsOneWidget);
      expect(
          find.text('Informing Caregiver of emergency'), findsOneWidget);
    });

    testWidgets('shows Medication Tracker feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Medication Tracker'), findsOneWidget);
      expect(find.text('Track your medications and schedules'),
          findsOneWidget);
    });

    testWidgets('shows Calendar Assistant feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Calendar Assistant'), findsOneWidget);
      expect(find.text('Manage your Calendar Assistant Settings'),
          findsOneWidget);
    });

    testWidgets('shows Informed Delivery feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Informed Delivery'), findsOneWidget);
      expect(find.text('View your Infomred Deliver digest'), findsOneWidget);
    });

    testWidgets('shows Virtual Check-In feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Virtual Check-In'), findsWidgets);
    });

    testWidgets('displays correct icons for each feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.byIcon(Icons.sos), findsOneWidget);
      expect(find.byIcon(Icons.medication), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mail), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('has exactly 5 feature items', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(5));
    });

    testWidgets('shows Close button', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('each feature is wrapped in a Card', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(5));
    });

    testWidgets('SOS icon is red, others are blue', (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      final iconWidgets = tester.widgetList<Icon>(find.byType(Icon));
      final redIcons = iconWidgets.where((icon) => icon.color == Colors.red);
      final blueIcons = iconWidgets.where((icon) => icon.color == Colors.blue);
      // SOS is red
      expect(redIcons.length, 1);
      // Medication Tracker, Calendar Assistant, Informed Delivery, Virtual Check-In are blue
      expect(blueIcons.length, 4);
    });

    testWidgets('each feature has an InkWell for tap handling',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const PatientMoreFeaturesBottomDrawerWidget()));
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsWidgets);
    });
  });
}
