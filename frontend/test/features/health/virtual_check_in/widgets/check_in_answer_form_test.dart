import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/widgets/check_in_answer_form.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in_backend_question_model.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/question_type.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/answer_dto.dart';

void main() {
  group('CheckInAnswerForm', () {
    late List<AnswerUpsertRequestDTO> capturedAnswers;

    testWidgets('renders text input for TEXT question type', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'What is your name?',
          type: BackendQuestionType.text,
          required: false,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () {},
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('What is your name?'), findsOneWidget);
    });

    testWidgets('renders YES/NO buttons for YES_NO question type', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 2,
          prompt: 'Did you take medication?',
          type: BackendQuestionType.yesNo,
          required: true,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () {},
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Did you take medication? *'), findsOneWidget); // Required indicator
    });

    testWidgets('renders TRUE/FALSE buttons for TRUE_FALSE question type', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 3,
          prompt: 'Statement is true?',
          type: BackendQuestionType.trueFalse,
          required: false,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () {},
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('True'), findsOneWidget);
      expect(find.text('False'), findsOneWidget);
    });

    testWidgets('renders number input for NUMBER question type', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 4,
          prompt: 'What is your heart rate?',
          type: BackendQuestionType.number,
          required: false,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () {},
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('What is your heart rate?'), findsOneWidget);
    });

    testWidgets('submit button validates required fields', (WidgetTester tester) async {
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

      var submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () => submitCalled = true,
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Act - try to submit without filling required field
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () => submitCalled = true,
              onAnswersChanged: (answers) {},
            ),
          ),
        ),
      );

      // Assert
      expect(submitCalled, false);
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('onAnswersChanged callback fires when answer is entered', (WidgetTester tester) async {
      // Arrange
      capturedAnswers = [];
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'What is your name?',
          type: BackendQuestionType.text,
          required: false,
          active: true,
          ordinal: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckInAnswerForm(
              questions: questions,
              onSubmit: () {},
              onAnswersChanged: (answers) => capturedAnswers = answers,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), 'John Doe');
      await tester.pumpAndSettle();

      // Assert
      expect(capturedAnswers.length, 1);
      expect(capturedAnswers[0].questionId, 1);
      expect(capturedAnswers[0].valueText, 'John Doe');
    });

    testWidgets('renders multiple questions', (WidgetTester tester) async {
      // Arrange
      final questions = [
        const BackendQuestionDto(
          id: 1,
          prompt: 'Question 1',
          type: BackendQuestionType.text,
          required: false,
          active: true,
          ordinal: 0,
        ),
        const BackendQuestionDto(
          id: 2,
          prompt: 'Question 2',
          type: BackendQuestionType.yesNo,
          required: false,
          active: true,
          ordinal: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CheckInAnswerForm(
                questions: questions,
                onSubmit: () {},
                onAnswersChanged: (answers) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });
}
