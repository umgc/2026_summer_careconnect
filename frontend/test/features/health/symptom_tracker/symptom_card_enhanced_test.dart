// Enhanced tests for SymptomCard widget
// (lib/features/health/symptom-tracker/widgets/symptom_card.dart)
// Covers: severity color logic, card background color, font weights,
// moderate severity, unknown severity, no-attention text, structure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/symptom_card.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

SymptomCard _card({
  String title = 'Headache',
  String severity = 'mild',
  String time = '10:00 AM',
  String description = 'Mild headache.',
  bool requiresAttention = false,
  bool caregiverAlert = false,
}) =>
    SymptomCard(
      title: title,
      severity: severity,
      time: time,
      description: description,
      requiresAttention: requiresAttention,
      caregiverAlert: caregiverAlert,
      onDelete: () {},
    );

void main() {
  group('SymptomCard - severity colors', () {
    testWidgets('severe uses red icon color', (tester) async {
      await tester.pumpWidget(_wrap(_card(severity: 'severe')));
      final icon = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(icon.color, Colors.red);
    });

    testWidgets('moderate uses orange icon color', (tester) async {
      await tester.pumpWidget(_wrap(_card(severity: 'moderate')));
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.orange);
    });

    testWidgets('mild uses green icon color', (tester) async {
      await tester.pumpWidget(_wrap(_card(severity: 'mild')));
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.green);
    });

    testWidgets('unknown severity uses grey icon color', (tester) async {
      await tester.pumpWidget(_wrap(_card(severity: 'unknown')));
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, Colors.grey);
    });
  });

  group('SymptomCard - severity badge', () {
    testWidgets('severity badge text uses white color', (tester) async {
      await tester.pumpWidget(_wrap(_card(severity: 'moderate')));
      final texts = tester.widgetList<Text>(find.text('moderate'));
      final badgeText = texts.first;
      expect(badgeText.style?.color, Colors.white);
    });
  });

  group('SymptomCard - attention text', () {
    testWidgets('does not show attention text when requiresAttention is false',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(requiresAttention: false)));
      expect(find.textContaining('Requires immediate attention'), findsNothing);
    });

    testWidgets('shows attention text when requiresAttention is true',
        (tester) async {
      await tester
          .pumpWidget(_wrap(_card(severity: 'severe', requiresAttention: true)));
      expect(
        find.textContaining('Requires immediate attention'),
        findsOneWidget,
      );
    });
  });

  group('SymptomCard - title styling', () {
    testWidgets('title has fontWeight w600', (tester) async {
      await tester.pumpWidget(_wrap(_card(title: 'TestTitle')));
      final textWidget = tester.widget<Text>(find.text('TestTitle'));
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('title has fontSize 16', (tester) async {
      await tester.pumpWidget(_wrap(_card(title: 'TestTitle2')));
      final textWidget = tester.widget<Text>(find.text('TestTitle2'));
      expect(textWidget.style?.fontSize, 16);
    });
  });

  group('SymptomCard - multiple states combined', () {
    testWidgets(
        'severe with caregiver alert shows warning icon, severity badge, and alert badge',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(
        severity: 'severe',
        caregiverAlert: true,
        requiresAttention: true,
      )));
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('severe'), findsOneWidget);
      expect(find.text('Caregiver Alert'), findsOneWidget);
      expect(
        find.textContaining('Requires immediate attention'),
        findsOneWidget,
      );
    });

    testWidgets(
        'mild without alerts shows favorite icon, no alert badge, no attention text',
        (tester) async {
      await tester.pumpWidget(_wrap(_card(
        severity: 'mild',
        caregiverAlert: false,
        requiresAttention: false,
      )));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Caregiver Alert'), findsNothing);
      expect(find.textContaining('Requires immediate attention'), findsNothing);
    });
  });

  group('SymptomCard - close button', () {
    testWidgets('close button is 16px', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      final icon = tester.widget<Icon>(find.byIcon(Icons.close));
      expect(icon.size, 16);
    });

    testWidgets('onDelete fires when close is tapped', (tester) async {
      var deleted = false;
      await tester.pumpWidget(_wrap(SymptomCard(
        title: 'Test',
        severity: 'mild',
        time: '1:00',
        description: 'desc',
        requiresAttention: false,
        caregiverAlert: false,
        onDelete: () => deleted = true,
      )));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(deleted, isTrue);
    });
  });
}
