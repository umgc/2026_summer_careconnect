// Tests for KpiCard widget
// (lib/features/invoices/screens/dashboard/widgets/kpi_card.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/widgets/kpi_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('KpiCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.attach_money,
        title: 'Revenue',
        subtitle: 'This month',
        value: '\$1,200',
        loading: false,
      )));
      expect(find.byType(KpiCard), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.people,
        title: 'Total Patients',
        subtitle: 'Active',
        value: '42',
        loading: false,
      )));
      expect(find.text('Total Patients'), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.people,
        title: 'Title',
        subtitle: 'Active patients',
        value: '10',
        loading: false,
      )));
      expect(find.text('Active patients'), findsOneWidget);
    });

    testWidgets('shows value when not loading', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.attach_money,
        title: 'Revenue',
        subtitle: 'This month',
        value: '\$500',
        loading: false,
      )));
      expect(find.text('\$500'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows LinearProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.attach_money,
        title: 'Revenue',
        subtitle: 'This month',
        value: '\$500',
        loading: true,
      )));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('\$500'), findsNothing);
    });

    testWidgets('shows the provided icon', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.assignment,
        title: 'Invoices',
        subtitle: 'Pending',
        value: '7',
        loading: false,
      )));
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('shows Card widget', (tester) async {
      await tester.pumpWidget(_wrap(const KpiCard(
        icon: Icons.attach_money,
        title: 'Revenue',
        subtitle: 'This month',
        value: '\$1,200',
        loading: false,
      )));
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
