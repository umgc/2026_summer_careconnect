// Tests for AddMedicationModal from
// lib/features/health/medication-tracker/widgets/medication-add-input-form.dart.
// Pure form widget — no HTTP in initState, Provider only in action handler.
// Needs wide viewport (700px) to avoid Row overflow in header.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-add-input-form.dart';

Widget _wrap() => MaterialApp(
      home: Scaffold(
        body: AddMedicationModal(
          onMedicationAdded: (_) {},
        ),
      ),
    );

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(700, 1600);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  group('AddMedicationModal – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.byType(AddMedicationModal), findsOneWidget);
    });

    testWidgets('shows Add New Medication title', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Add New Medication'), findsOneWidget);
    });

    testWidgets('shows form fields', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows close icon button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows "Medication Name *" label', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Medication Name *'), findsOneWidget);
    });

    testWidgets('shows "Dosage *" label', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Dosage *'), findsOneWidget);
    });

    testWidgets('shows "Frequency *" label', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Frequency *'), findsOneWidget);
    });

    testWidgets('shows "Use AI Service" button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Use AI Service'), findsOneWidget);
    });

    testWidgets('shows smart_toy icon for AI button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('shows Form widget', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('shows frequency dropdown with "Once daily" default',
        (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      expect(find.text('Once daily'), findsOneWidget);
    });
  });
}
