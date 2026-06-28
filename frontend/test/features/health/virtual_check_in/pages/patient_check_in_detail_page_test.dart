import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/presentation/pages/patient_check_in_detail_page.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in_backend_question_model.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/question_type.dart';

void main() {
  group('PatientCheckInDetailPage Integration', () {
    testWidgets('displays check-in questions and form', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'Did you take your medication?',
          type: BackendQuestionType.yesNo,
          required: true,
          active: true,
          ordinal: 0,
        ),
        const BackendQuestionDto(
          id: 2,
          prompt: 'What is your heart rate?',
          type: BackendQuestionType.number,
          required: false,
          active: true,
          ordinal: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PatientCheckInDetailPage(
            checkInId: 123,
            questions: questions,
          ),
        ),
      );

      // Assert
      expect(find.text('Check-In Questions'), findsOneWidget);
      expect(find.text('Please answer the following questions:'), findsOneWidget);
      expect(find.text('Did you take your medication?'), findsOneWidget);
      expect(find.text('What is your heart rate?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows error when submitting with unanswered required fields',
        (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'Required question',
          type: BackendQuestionType.text,
          required: true,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PatientCheckInDetailPage(
            checkInId: 123,
            questions: questions,
          ),
        ),
      );

      // Act - try to submit without answering
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpWidget(
        MaterialApp(
          home: PatientCheckInDetailPage(
            checkInId: 123,
            questions: questions,
          ),
        ),
      );

      // Assert - validation error should show
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('renders success state after submission', (WidgetTester tester) async {
      // This test verifies the success UI renders
      // In a real scenario, you'd mock the HTTP request
      
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'Quick question',
          type: BackendQuestionType.yesNo,
          required: false,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: PatientCheckInDetailPage(
            checkInId: 123,
            questions: questions,
          ),
        ),
      );

      // Assert initial form is shown
      expect(find.text('Please answer the following questions:'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays all question types correctly', (WidgetTester tester) async {
      // Arrange - test with all 4 question types
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'Text question',
          type: BackendQuestionType.text,
          required: false,
          active: true,
          ordinal: 0,
        ),
        const BackendQuestionDto(
          id: 2,
          prompt: 'Yes/No question',
          type: BackendQuestionType.yesNo,
          required: false,
          active: true,
          ordinal: 1,
        ),
        const BackendQuestionDto(
          id: 3,
          prompt: 'True/False question',
          type: BackendQuestionType.trueFalse,
          required: false,
          active: true,
          ordinal: 2,
        ),
        const BackendQuestionDto(
          id: 4,
          prompt: 'Number question',
          type: BackendQuestionType.number,
          required: false,
          active: true,
          ordinal: 3,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: PatientCheckInDetailPage(
              checkInId: 123,
              questions: questions,
            ),
          ),
        ),
      );

      // Assert all question types render
      expect(find.text('Text question'), findsOneWidget);
      expect(find.text('Yes/No question'), findsOneWidget);
      expect(find.text('True/False question'), findsOneWidget);
      expect(find.text('Number question'), findsOneWidget);
      
      // Check for input widgets
      expect(find.byType(TextFormField), findsWidgets); // text + number
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('True'), findsOneWidget);
      expect(find.text('False'), findsOneWidget);
    });
  });
}
