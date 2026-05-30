// Tests for InvoiceOverviewCard widget
// (lib/features/invoices/widgets/invoice_overview_card.dart)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/widgets/invoice_overview_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('InvoiceOverviewCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pump();
      expect(find.byType(InvoiceOverviewCard), findsOneWidget);
    });

    testWidgets('shows Invoices label', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pumpAndSettle();
      expect(find.text('Invoices'), findsOneWidget);
    });

    testWidgets('shows loading text while future pending', (tester) async {
      final completer = Completer<int>();
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () => completer.future,
      )));
      await tester.pump();
      expect(find.text('Loading unpaid invoices...'), findsOneWidget);
      completer.complete(0); // prevent pending timer warning
    });

    testWidgets('shows plural invoices not paid for count > 1', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 5,
      )));
      await tester.pumpAndSettle();
      expect(find.text('5 invoices not paid'), findsOneWidget);
    });

    testWidgets('shows singular invoice not paid for count = 1', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 1,
      )));
      await tester.pumpAndSettle();
      expect(find.text('1 invoice not paid'), findsOneWidget);
    });

    testWidgets('shows 0 invoices not paid when count is 0', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pumpAndSettle();
      expect(find.text('0 invoices not paid'), findsOneWidget);
    });

    testWidgets('shows error text when future throws', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => throw Exception('Network error'),
      )));
      await tester.pumpAndSettle();
      expect(find.text('Unable to load unpaid invoice count'), findsOneWidget);
    });

    testWidgets('shows receipt_long icon', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pump();
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('shows arrow forward icon', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('renders as a Card', (tester) async {
      await tester.pumpWidget(_wrap(InvoiceOverviewCard(
        getUnpaidCount: () async => 0,
      )));
      await tester.pump();
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
