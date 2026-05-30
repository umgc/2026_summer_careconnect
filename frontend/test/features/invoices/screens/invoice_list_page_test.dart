// Tests for InvoiceListPage
// (lib/features/invoices/screens/invoice_list_page.dart).
//
// initState calls _fetch() which uses InvoiceService (async).
// _loading starts true — CircularProgressIndicator shown immediately.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/invoice_list_page.dart';

Widget _wrap({String? quickFilter}) =>
    MaterialApp(home: InvoiceListPage(quickFilter: quickFilter));

void main() {
  group('InvoiceListPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(InvoiceListPage), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with quickFilter parameter', (tester) async {
      await tester.pumpWidget(_wrap(quickFilter: 'pending'));
      expect(find.byType(InvoiceListPage), findsOneWidget);
    });

    testWidgets('shows no invoice items while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('does NOT show error text while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('shows Center while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });
  });
}
