// Tests for AddMedicationModal widget
// (lib/features/health/medication-tracker/widgets/medication-add-input-form.dart)
// StatefulWidget with no API calls in initState — render tests are safe.
// Provider/API calls only happen in _addMedication() on button tap.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-add-input-form.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Widget _modal() => _wrap(AddMedicationModal(onMedicationAdded: (_) {}));

void main() {
  group('AddMedicationModal', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byType(AddMedicationModal), findsOneWidget);
    });

    testWidgets('shows Add New Medication title', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Add New Medication'), findsOneWidget);
    });

    testWidgets('shows close (X) icon button', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows Use AI Service button', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Use AI Service'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });

    testWidgets('shows Medication Name field label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.textContaining('Medication Name'), findsOneWidget);
    });

    testWidgets('shows Dosage field label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.textContaining('Dosage'), findsOneWidget);
    });

    testWidgets('shows Frequency label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Frequency *'), findsOneWidget);
    });

    testWidgets('shows Route label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Route *'), findsOneWidget);
    });

    testWidgets('shows Medication Type label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Medication Type'), findsOneWidget);
    });

    testWidgets('shows Prescribed By field label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Prescribed By'), findsOneWidget);
    });

    testWidgets('shows Notes field label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows Add Medication submit button', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Add Medication'), findsOneWidget);
    });

    testWidgets('shows frequency dropdown with Once daily default',
        (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Once daily'), findsOneWidget);
    });

    testWidgets('shows frequency dropdown options when opened', (tester) async {
      await tester.pumpWidget(_modal());
      // Open the frequency dropdown (first DropdownButtonFormField)
      await tester.tap(find.text('Once daily'));
      await tester.pumpAndSettle();
      expect(find.text('Twice daily'), findsWidgets);
      expect(find.text('As needed'), findsWidgets);
    });

    testWidgets('shows route dropdown with Oral default', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Oral'), findsOneWidget);
    });

    testWidgets('shows calendar icons for date fields', (tester) async {
      await tester.pumpWidget(_modal());
      // There are 3 date fields: Prescribed Date, Start Date, End Date
      expect(find.byIcon(Icons.calendar_today), findsNWidgets(3));
    });

    testWidgets('shows Select date placeholder for unset date fields',
        (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Select date'), findsNWidgets(3));
    });

    testWidgets('medication name field accepts text input', (tester) async {
      await tester.pumpWidget(_modal());
      // First TextFormField is the Medication Name field
      await tester.enterText(find.byType(TextFormField).first, 'Metformin');
      expect(find.text('Metformin'), findsOneWidget);
    });
  });
}
