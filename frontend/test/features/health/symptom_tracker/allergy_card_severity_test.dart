// Tests for allergy_card.dart severity color logic
// (lib/features/health/symptom-tracker/widgets/allergy_card.dart)
// Covers: severity color mapping (severe=red, moderate=orange, mild=green, unknown=grey),
// icon presence, layout structure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/allergy_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AllergyCard (standalone) - severity colors', () {
    testWidgets('severe severity uses red color', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Penicillin',
        severity: 'Severe',
        reaction: 'Anaphylaxis',
        note: '',
      )));
      // The warning_rounded icon should be red for severe
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      expect(icon.color, Colors.red);
    });

    testWidgets('moderate severity uses orange color', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Aspirin',
        severity: 'Moderate',
        reaction: 'Hives',
        note: '',
      )));
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      expect(icon.color, Colors.orange);
    });

    testWidgets('mild severity uses green color', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Latex',
        severity: 'Mild',
        reaction: 'Rash',
        note: '',
      )));
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      expect(icon.color, Colors.green);
    });

    testWidgets('unknown severity uses grey color', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Unknown',
        severity: 'Unknown',
        reaction: 'None',
        note: '',
      )));
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      expect(icon.color, Colors.grey);
    });

    testWidgets('severity is case insensitive', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Test',
        severity: 'SEVERE',
        reaction: 'Test',
        note: '',
      )));
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_rounded));
      expect(icon.color, Colors.red);
    });
  });

  group('AllergyCard (standalone) - severity badge', () {
    testWidgets('severity badge text is displayed', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Test Drug',
        severity: 'Moderate',
        reaction: 'Hives',
        note: 'Watch closely',
      )));
      // Severity appears both as badge text
      expect(find.text('Moderate'), findsOneWidget);
    });

    testWidgets('severity badge uses white text color', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Test',
        severity: 'Severe',
        reaction: 'Test',
        note: '',
      )));
      // Find the severity badge text (inside a Container with colored background)
      final textFinder = find.text('Severe');
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, Colors.white);
    });
  });

  group('AllergyCard (standalone) - layout', () {
    testWidgets('drug name has fontWeight w600', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'BoldDrug',
        severity: 'Mild',
        reaction: 'None',
        note: '',
      )));
      final textWidget = tester.widget<Text>(find.text('BoldDrug'));
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('has close icon button', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Test',
        severity: 'Mild',
        reaction: 'None',
        note: '',
      )));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows reaction text', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Drug',
        severity: 'Mild',
        reaction: 'Throat swelling and hives',
        note: '',
      )));
      expect(find.text('Throat swelling and hives'), findsOneWidget);
    });

    testWidgets('shows note text', (tester) async {
      await tester.pumpWidget(_wrap(const AllergyCard(
        drug: 'Drug',
        severity: 'Mild',
        reaction: 'None',
        note: 'Always carry EpiPen',
      )));
      expect(find.text('Always carry EpiPen'), findsOneWidget);
    });
  });
}
