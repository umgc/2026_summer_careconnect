// Tests for CheckInQuestionType enum and VirtualCheckInQuestion model
// (lib/features/health/virtual_check_in/models/virtual_check_in_question.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in_question.dart';

void main() {
  group('CheckInQuestionType', () {
    test('enum has numerical, yesNo, textInput values', () {
      expect(CheckInQuestionType.values.length, 3);
      expect(CheckInQuestionType.values, contains(CheckInQuestionType.numerical));
      expect(CheckInQuestionType.values, contains(CheckInQuestionType.yesNo));
      expect(CheckInQuestionType.values, contains(CheckInQuestionType.textInput));
    });
  });

  group('VirtualCheckInQuestion', () {
    test('constructor stores all fields', () {
      const q = VirtualCheckInQuestion(
        id: 'q-1',
        type: CheckInQuestionType.numerical,
        required: true,
        text: 'Rate your pain from 0 to 10',
      );
      expect(q.id, 'q-1');
      expect(q.type, CheckInQuestionType.numerical);
      expect(q.required, isTrue);
      expect(q.text, 'Rate your pain from 0 to 10');
    });

    test('yesNo type', () {
      const q = VirtualCheckInQuestion(
        id: 'q-2',
        type: CheckInQuestionType.yesNo,
        required: false,
        text: 'Did you take your medication today?',
      );
      expect(q.type, CheckInQuestionType.yesNo);
      expect(q.required, isFalse);
    });

    test('textInput type', () {
      const q = VirtualCheckInQuestion(
        id: 'q-3',
        type: CheckInQuestionType.textInput,
        required: true,
        text: 'Describe your symptoms',
      );
      expect(q.type, CheckInQuestionType.textInput);
    });

    test('required defaults correctly', () {
      const q = VirtualCheckInQuestion(
        id: 'q-4',
        type: CheckInQuestionType.numerical,
        required: false,
        text: 'Optional question',
      );
      expect(q.required, isFalse);
      expect(q.id, 'q-4');
    });

    test('text stores long string', () {
      const longText = 'This is a very long question text that tests boundary conditions for the model';
      const q = VirtualCheckInQuestion(
        id: 'q-5',
        type: CheckInQuestionType.textInput,
        required: true,
        text: longText,
      );
      expect(q.text, longText);
    });

    test('empty id is accepted', () {
      const q = VirtualCheckInQuestion(
        id: '',
        type: CheckInQuestionType.yesNo,
        required: false,
        text: 'Test',
      );
      expect(q.id, '');
    });
  });
}
