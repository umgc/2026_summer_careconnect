import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/navigation/caregiver_more_features_bottom_drawer.dart';
import 'package:care_connect_app/shared/widgets/more_features_bottom_drawer.dart';

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

    testWidgets('wraps MoreFeaturesBottomDrawer', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.byType(MoreFeaturesBottomDrawer), findsOneWidget);
    });

    testWidgets('shows "Additional Features" heading', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Additional Features'), findsOneWidget);
    });

    testWidgets('shows Calendar Assistant feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Calendar Assistant'), findsOneWidget);
      expect(find.text('Manage your Calendar Assistant Settings'),
          findsOneWidget);
    });

    testWidgets('shows Invoice Assistant feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Invoice Assistant'), findsOneWidget);
      expect(find.text('Manage your medical invoices.'), findsOneWidget);
    });

    testWidgets('shows Medical Notetaker feature with subtitle',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Medical Notetaker'), findsOneWidget);
      expect(find.text('View Notetaker Notes'), findsOneWidget);
    });

    testWidgets('shows Settings feature with subtitle', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage application settings.'), findsOneWidget);
    });

    testWidgets('displays correct icons for each feature', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.payments), findsOneWidget);
      expect(find.byIcon(Icons.note_alt), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('has exactly 4 feature items', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      // Each feature renders an arrow_forward_ios trailing icon
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(4));
    });

    testWidgets('shows Close button', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('each feature is wrapped in a Card', (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      // The outer widget is a Card, plus each feature item is a Card
      // MoreFeaturesBottomDrawer uses Card widgets for each feature
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(4));
    });

    testWidgets('each feature has an InkWell for tap handling',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      final inkWells = find.byType(InkWell);
      // 4 feature InkWells
      expect(inkWells, findsWidgets);
    });

    testWidgets('all feature icons are blue except none special',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CaregiverMoreFeaturesBottomDrawerWidget()));
      // All icons should be blue in caregiver drawer
      final iconWidgets = tester.widgetList<Icon>(find.byType(Icon));
      final blueIcons = iconWidgets.where((icon) => icon.color == Colors.blue);
      // 4 feature icons are blue (trailing arrows have no color set)
      expect(blueIcons.length, 4);
    });
  });
}
