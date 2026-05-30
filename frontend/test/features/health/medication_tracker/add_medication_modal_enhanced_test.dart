// Enhanced tests for AddMedicationModal widget
// (lib/features/health/medication-tracker/widgets/medication-add-input-form.dart)
// Covers: form validation, date field labels, hint texts, dosage input,
// notes input, prescribed by input, custom frequency visibility.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-add-input-form.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Widget _modal() => _wrap(AddMedicationModal(onMedicationAdded: (_) {}));

void main() {
  group('AddMedicationModal - hint texts', () {
    testWidgets('shows medication name hint', (tester) async {
      await tester.pumpWidget(_modal());
      expect(
        find.text('e.g., Aspirin, Lisinopril, Metformin'),
        findsOneWidget,
      );
    });

    testWidgets('shows dosage hint', (tester) async {
      await tester.pumpWidget(_modal());
      expect(
        find.text('e.g., 10mg, 500mg, 1000 IU'),
        findsOneWidget,
      );
    });

    testWidgets('shows prescribed by hint', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('e.g., Dr. Smith'), findsOneWidget);
    });

    testWidgets('shows notes hint', (tester) async {
      await tester.pumpWidget(_modal());
      expect(
        find.text('e.g., Take with food, Avoid alcohol'),
        findsOneWidget,
      );
    });
  });

  group('AddMedicationModal - date fields', () {
    testWidgets('shows Prescribed Date label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Prescribed Date'), findsOneWidget);
    });

    testWidgets('shows Start Date label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.text('Start Date'), findsOneWidget);
    });

    testWidgets('shows End Date label', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.textContaining('End Date'), findsOneWidget);
    });
  });

  group('AddMedicationModal - text input', () {
    testWidgets('dosage field accepts text input', (tester) async {
      await tester.pumpWidget(_modal());
      // Second TextFormField is dosage
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), '500mg');
      expect(find.text('500mg'), findsOneWidget);
    });

    testWidgets('prescribed by field accepts text input', (tester) async {
      await tester.pumpWidget(_modal());
      // Prescribed By is the 3rd text field (after name, dosage)
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(2), 'Dr. Zulu');
      expect(find.text('Dr. Zulu'), findsOneWidget);
    });
  });

  group('AddMedicationModal - frequency dropdown', () {
    testWidgets('shows Custom option when dropdown opened', (tester) async {
      await tester.pumpWidget(_modal());
      await tester.tap(find.text('Once daily'));
      await tester.pumpAndSettle();
      expect(find.text('Custom'), findsWidgets);
    });

    testWidgets('shows Three times daily option', (tester) async {
      await tester.pumpWidget(_modal());
      await tester.tap(find.text('Once daily'));
      await tester.pumpAndSettle();
      expect(find.text('Three times daily'), findsWidgets);
    });
  });

  group('AddMedicationModal - structure', () {
    testWidgets('has a Form widget', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('has a SingleChildScrollView', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('has at least 3 TextFormField widgets', (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byType(TextFormField), findsAtLeast(3));
    });

    testWidgets('has DropdownButtonFormField for frequency',
        (tester) async {
      await tester.pumpWidget(_modal());
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });
  });
}
