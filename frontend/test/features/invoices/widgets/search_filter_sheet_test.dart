// Tests for SearchFilterSheetContent
// (lib/features/invoices/widgets/search_filter_sheet.dart).
//
// StatefulWidget — pure form widget, no HTTP or Provider in initState.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/widgets/search_filter_sheet.dart';

import 'package:care_connect_app/features/invoices/models/filter_result.dart';

Widget _wrap() => MaterialApp(
      home: Scaffold(
        body: SearchFilterSheetContent(
          invoices: const [],
          initialSort: 'recently_added',
          initialSearch: '',
          initialStatus: const {},
          onSubmit: (FilterResult _) {},
        ),
      ),
    );

void main() {
  group('SearchFilterSheetContent – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(SearchFilterSheetContent), findsOneWidget);
    });

    testWidgets('shows "Search & Filter Invoices" heading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Search & Filter Invoices'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows search TextField', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows Apply Filters button', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Apply'), findsOneWidget);
    });

    testWidgets('shows SafeArea', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('shows sort section', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('Sort'), findsWidgets);
    });
  });
}
