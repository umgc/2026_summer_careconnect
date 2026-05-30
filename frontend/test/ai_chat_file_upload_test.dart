import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/ai_chat.dart';

void main() {
  group('AI Chat File Upload Tests', () {
    testWidgets('displays AI chat with patient role', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CareConnect AI Assistant'), findsOneWidget);
      expect(find.text('AI Chat interface for patient role'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows analytics role chat correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'analytics', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CareConnect AI Assistant'), findsOneWidget);
      expect(find.text('AI Chat interface for analytics role'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('caregiver role shows correct content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'caregiver', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CareConnect AI Assistant'), findsOneWidget);
      expect(find.text('AI Chat interface for caregiver role'), findsOneWidget);
    });

    testWidgets('can enter text in message field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello, AI assistant!');
      await tester.pumpAndSettle();

      expect(find.text('Hello, AI assistant!'), findsOneWidget);
    });

    testWidgets('modal mode shows close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('non-modal mode hides close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: false)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows assistant icon in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: false)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.assistant), findsOneWidget);
    });
  });
}
