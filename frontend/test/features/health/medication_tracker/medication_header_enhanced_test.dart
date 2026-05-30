// Enhanced tests for MedicationAppHeader widget
// (lib/features/health/medication-tracker/widgets/medication-header.dart).
// Covers: structure, Row layout, button styling, PreferredSizeWidget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-header.dart';

void _suppressImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('Unable to load asset') ||
        details.exceptionAsString().contains('asset')) {
      return;
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(appBar: child as PreferredSizeWidget));

void main() {
  group('MedicationAppHeader - structure', () {
    testWidgets('implements PreferredSizeWidget', (tester) async {
      final header = MedicationAppHeader(onAddPressed: () {});
      expect(header, isA<PreferredSizeWidget>());
    });

    testWidgets('preferredSize width is double.infinity', (tester) async {
      final header = MedicationAppHeader(onAddPressed: () {});
      expect(header.preferredSize.width, double.infinity);
    });

    testWidgets('contains a Row widget', (tester) async {
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('contains an IconButton for back navigation', (tester) async {
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('contains an ElevatedButton for Add', (tester) async {
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('MedicationAppHeader - interaction', () {
    testWidgets('multiple taps on Add all fire callback', (tester) async {
      _suppressImageErrors();
      var count = 0;
      await tester.pumpWidget(_wrap(
        MedicationAppHeader(onAddPressed: () => count++),
      ));
      await tester.pump();

      await tester.tap(find.text('Add'));
      await tester.pump();
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(count, 2);
    });
  });
}
