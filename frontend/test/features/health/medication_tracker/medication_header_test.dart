// Tests for MedicationAppHeader widget
// (lib/features/health/medication-tracker/widgets/medication-header.dart).
// Pure StatelessWidget implementing PreferredSizeWidget.
// Tests cover rendering, button presence, and add button callback.
// The Image.asset for the logo is expected to fail gracefully in tests
// (no asset bundle in test environment) — suppressed via FlutterError handler.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-header.dart';

// Suppress Image.asset errors caused by missing asset bundle in tests.
void _suppressImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('Unable to load asset') ||
        details.exceptionAsString().contains('asset')) { return; }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(appBar: child as PreferredSizeWidget));

void main() {
  group('MedicationAppHeader', () {
    testWidgets('preferredSize is kToolbarHeight', (tester) async {
      // Verifies the preferred height matches a standard toolbar.
      final header = MedicationAppHeader(onAddPressed: () {});
      expect(header.preferredSize.height, kToolbarHeight);
    });

    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget tree builds without error.
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.byType(MedicationAppHeader), findsOneWidget);
    });

    testWidgets('shows Add button with add icon', (tester) async {
      // Verifies the "Add" label and add icon are present.
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.text('Add'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows back arrow icon button', (tester) async {
      // Verifies the back navigation button is present.
      _suppressImageErrors();
      await tester.pumpWidget(_wrap(MedicationAppHeader(onAddPressed: () {})));
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('tapping Add button calls onAddPressed', (tester) async {
      // Verifies the onAddPressed callback fires.
      _suppressImageErrors();
      var pressed = false;
      await tester.pumpWidget(_wrap(
        MedicationAppHeader(onAddPressed: () => pressed = true),
      ));
      await tester.pump();
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(pressed, isTrue);
    });
  });
}
