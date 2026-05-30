// Tests for allergy_card.dart (the standalone AllergyCard without onDelete)
// (lib/features/health/symptom-tracker/widgets/allergy_card.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/allergy_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AllergyCard (standalone)', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Penicillin',
        severity: 'Severe',
        reaction: 'Anaphylaxis',
        note: 'Avoid all penicillin-based antibiotics',
      )));
      expect(find.byType(AllergyCard), findsOneWidget);
    });

    testWidgets('shows drug name', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Penicillin',
        severity: 'Severe',
        reaction: 'Anaphylaxis',
        note: 'Note',
      )));
      expect(find.text('Penicillin'), findsOneWidget);
    });

    testWidgets('shows severity label', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Aspirin',
        severity: 'Moderate',
        reaction: 'Hives',
        note: 'Avoid NSAIDs',
      )));
      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('shows reaction text', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Peanuts',
        severity: 'Severe',
        reaction: 'Throat swelling',
        note: 'Carry EpiPen',
      )));
      expect(find.text('Throat swelling'), findsOneWidget);
    });

    testWidgets('shows note text', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Latex',
        severity: 'Mild',
        reaction: 'Rash',
        note: 'Use nitrile gloves instead',
      )));
      expect(find.text('Use nitrile gloves instead'), findsOneWidget);
    });

    testWidgets('shows warning_rounded icon', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Sulfa',
        severity: 'Severe',
        reaction: 'Rash',
        note: '',
      )));
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('shows close icon button', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Codeine',
        severity: 'Mild',
        reaction: 'Nausea',
        note: 'Monitor',
      )));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
