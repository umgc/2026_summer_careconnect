// Enhanced tests for AllergyCard (allergies_card.dart - the version with onDelete)
// (lib/features/health/symptom-tracker/widgets/allergies_card.dart)
// Covers: structure, text formatting, icon color, multiple data variations.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/allergies_card.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('AllergyCard (with onDelete) - structure', () {
    testWidgets('uses a Stack widget for positioning delete button',
        (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Penicillin',
        reaction: 'Hives',
        severity: 'Moderate',
        note: 'Avoid',
        onDelete: () {},
      )));
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('has an IconButton for delete', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Aspirin',
        reaction: 'Rash',
        severity: 'Mild',
        note: '',
        onDelete: () {},
      )));
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('close icon is red colored', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Codeine',
        reaction: 'Nausea',
        severity: 'Severe',
        note: '',
        onDelete: () {},
      )));
      final icon = tester.widget<Icon>(find.byIcon(Icons.close));
      expect(icon.color, Colors.red);
    });
  });

  group('AllergyCard (with onDelete) - text content', () {
    testWidgets('formats reaction with Reaction: prefix', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Latex',
        reaction: 'Swelling',
        severity: 'Moderate',
        note: '',
        onDelete: () {},
      )));
      expect(find.text('Reaction: Swelling'), findsOneWidget);
    });

    testWidgets('formats severity with Severity: prefix', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Latex',
        reaction: 'Swelling',
        severity: 'Severe',
        note: '',
        onDelete: () {},
      )));
      expect(find.text('Severity: Severe'), findsOneWidget);
    });

    testWidgets('shows drug name in bold', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Sulfa drugs',
        reaction: 'Rash',
        severity: 'Mild',
        note: 'Check before prescribing',
        onDelete: () {},
      )));
      final textWidget = tester.widget<Text>(find.text('Sulfa drugs'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('shows empty note without crashing', (tester) async {
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Test',
        reaction: 'Test reaction',
        severity: 'Mild',
        note: '',
        onDelete: () {},
      )));
      // Empty note should still render (as empty Text widget)
      expect(find.byType(AllergyCard), findsOneWidget);
    });
  });

  group('AllergyCard (with onDelete) - interaction', () {
    testWidgets('onDelete fires exactly once per tap', (tester) async {
      var count = 0;
      await tester.pumpWidget(_wrap(AllergyCard(
        drug: 'Test',
        reaction: 'Reaction',
        severity: 'Mild',
        note: '',
        onDelete: () => count++,
      )));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(count, 1);
    });
  });
}
