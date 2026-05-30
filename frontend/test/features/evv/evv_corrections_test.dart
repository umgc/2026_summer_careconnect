// Tests for EvvCorrectionsPage
// (lib/features/evv/presentation/pages/evv_corrections.dart).
//
// _isLoading starts true; _loadData() API call has try/catch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/evv/presentation/pages/evv_corrections.dart';

Widget _wrap() => const MaterialApp(home: EvvCorrectionsPage());

void main() {
  group('EvvCorrectionsPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(EvvCorrectionsPage), findsOneWidget);
    });

    testWidgets('shows "EVV Corrections & Approvals" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('EVV Corrections & Approvals'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows Center while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('does NOT show ListView while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ListView), findsNothing);
    });
  });
}
