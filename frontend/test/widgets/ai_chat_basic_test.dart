// Tests for AIChat from lib/widgets/ai_chat.dart.
// Pure StatelessWidget — no HTTP, no Provider.
// Shows header with 'CareConnect AI Assistant' text.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/ai_chat.dart' as basic_ai;

Widget _wrap({required String role, bool isModal = false}) => MaterialApp(
      home: Scaffold(
        body: basic_ai.AIChat(role: role, isModal: isModal),
      ),
    );

void main() {
  group('AIChat (basic ai_chat.dart) – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.byType(basic_ai.AIChat), findsOneWidget);
    });

    testWidgets('shows CareConnect AI Assistant header', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.text('CareConnect AI Assistant'), findsOneWidget);
    });

    testWidgets('shows role text in chat area', (tester) async {
      await tester.pumpWidget(_wrap(role: 'caregiver'));
      expect(find.textContaining('caregiver'), findsOneWidget);
    });

    testWidgets('shows assistant icon in header', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.byIcon(Icons.assistant), findsOneWidget);
    });

    testWidgets('shows TextField for message input', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hint text "Type your message..."', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.text('Type your message...'), findsOneWidget);
    });

    testWidgets('shows send icon button', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows Column as main layout', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('AIChat – role variants', () {
    testWidgets('shows patient role text', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      expect(find.text('AI Chat interface for patient role'), findsOneWidget);
    });

    testWidgets('shows caregiver role text', (tester) async {
      await tester.pumpWidget(_wrap(role: 'caregiver'));
      expect(find.text('AI Chat interface for caregiver role'), findsOneWidget);
    });

    testWidgets('shows admin role text', (tester) async {
      await tester.pumpWidget(_wrap(role: 'admin'));
      expect(find.text('AI Chat interface for admin role'), findsOneWidget);
    });
  });

  group('AIChat – modal mode', () {
    testWidgets('renders with isModal=true', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient', isModal: true));
      expect(find.byType(basic_ai.AIChat), findsOneWidget);
    });

    testWidgets('shows close icon when isModal=true', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient', isModal: true));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('does NOT show close icon when isModal=false', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient', isModal: false));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('can enter text in message field', (tester) async {
      await tester.pumpWidget(_wrap(role: 'patient'));
      await tester.enterText(find.byType(TextField), 'Hello AI');
      expect(find.text('Hello AI'), findsOneWidget);
    });
  });
}
