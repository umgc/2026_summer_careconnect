// Tests for UploadInvoicePage
// (lib/features/invoices/screens/upload_invoice.dart).
//
// _watchConnectivity() uses Connectivity plugin — in tests, platform channels
// return defaults (no exception). offline=false initially.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/upload_invoice.dart';

Widget _wrap() => const MaterialApp(home: UploadInvoicePage());

void main() {
  group('UploadInvoicePage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(UploadInvoicePage), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows "Upload File" button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Upload'), findsWidgets);
    });

    testWidgets('shows SafeArea in body', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('shows ListView', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows Take Photo option', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Take Photo'), findsOneWidget);
    });

    testWidgets('shows Manual Entry option', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Manual Entry'), findsOneWidget);
    });

    testWidgets('shows Secure Storage card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Secure Storage'), findsOneWidget);
    });
  });
}
