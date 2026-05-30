// Tests for BackendQuestionType and BackendQuestionDto models
// (lib/features/health/virtual_check_in/models/question_type.dart)
// (lib/features/health/virtual_check_in/models/virtual_check_in_backend_question_model.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/question_type.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in_backend_question_model.dart';

void main() {
  group('BackendQuestionType.fromWire', () {
    test('parses TEXT', () {
      expect(BackendQuestionType.fromWire('TEXT'), BackendQuestionType.text);
    });

    test('parses YES_NO', () {
      expect(BackendQuestionType.fromWire('YES_NO'), BackendQuestionType.yesNo);
    });

    test('parses TRUE_FALSE', () {
      expect(
          BackendQuestionType.fromWire('TRUE_FALSE'), BackendQuestionType.trueFalse);
    });

    test('parses NUMBER', () {
      expect(BackendQuestionType.fromWire('NUMBER'), BackendQuestionType.number);
    });

    test('parses NUMERIC alias', () {
      expect(BackendQuestionType.fromWire('NUMERIC'), BackendQuestionType.number);
    });

    test('falls back to text for unknown value', () {
      expect(BackendQuestionType.fromWire('UNKNOWN'), BackendQuestionType.text);
    });

    test('falls back to text for null', () {
      expect(BackendQuestionType.fromWire(null), BackendQuestionType.text);
    });

    test('case insensitive via toUpperCase normalization', () {
      expect(BackendQuestionType.fromWire('text'), BackendQuestionType.text);
      expect(BackendQuestionType.fromWire('yes_no'), BackendQuestionType.yesNo);
    });
  });

  group('BackendQuestionType.toWire', () {
    test('text -> TEXT', () {
      expect(BackendQuestionType.text.toWire(), 'TEXT');
    });

    test('yesNo -> YES_NO', () {
      expect(BackendQuestionType.yesNo.toWire(), 'YES_NO');
    });

    test('trueFalse -> TRUE_FALSE', () {
      expect(BackendQuestionType.trueFalse.toWire(), 'TRUE_FALSE');
    });

    test('number -> NUMBER', () {
      expect(BackendQuestionType.number.toWire(), 'NUMBER');
    });
  });

  group('BackendQuestionDto.fromJson', () {
    test('parses all fields when fully populated', () {
      final dto = BackendQuestionDto.fromJson({
        'id': 10,
        'prompt': 'How are you feeling?',
        'type': 'YES_NO',
        'required': true,
        'active': true,
        'ordinal': 3,
      });

      expect(dto.id, 10);
      expect(dto.prompt, 'How are you feeling?');
      expect(dto.type, BackendQuestionType.yesNo);
      expect(dto.required, isTrue);
      expect(dto.active, isTrue);
      expect(dto.ordinal, 3);
    });

    test('applies defaults for missing fields', () {
      final dto = BackendQuestionDto.fromJson({
        'prompt': 'Rate your pain',
        'type': 'NUMBER',
      });

      expect(dto.id, isNull);
      expect(dto.required, isFalse);
      expect(dto.active, isTrue);
      expect(dto.ordinal, 0);
    });

    test('handles numeric id as int', () {
      final dto = BackendQuestionDto.fromJson({
        'id': 5.0, // num instead of int
        'prompt': 'Test',
        'type': 'TEXT',
        'required': false,
        'active': true,
        'ordinal': 1,
      });
      expect(dto.id, 5);
    });
  });

  group('BackendQuestionDto.toJson', () {
    test('serializes all fields', () {
      final dto = BackendQuestionDto(
        id: 1,
        prompt: 'Do you have pain?',
        type: BackendQuestionType.yesNo,
        required: true,
        active: true,
        ordinal: 2,
      );
      final json = dto.toJson();

      expect(json['id'], 1);
      expect(json['prompt'], 'Do you have pain?');
      expect(json['type'], 'YES_NO');
      expect(json['required'], isTrue);
      expect(json['active'], isTrue);
      expect(json['ordinal'], 2);
    });

    test('omits id when null', () {
      final dto = BackendQuestionDto(
        prompt: 'Test',
        type: BackendQuestionType.text,
        required: false,
        active: true,
        ordinal: 0,
      );
      final json = dto.toJson();
      expect(json.containsKey('id'), isFalse);
    });
  });

  group('BackendQuestionDto.copyWith', () {
    test('updates specified fields', () {
      final original = BackendQuestionDto(
        id: 1,
        prompt: 'Original',
        type: BackendQuestionType.text,
        required: false,
        active: true,
        ordinal: 1,
      );
      final copy = original.copyWith(
        prompt: 'Updated',
        type: BackendQuestionType.number,
        ordinal: 5,
      );

      expect(copy.prompt, 'Updated');
      expect(copy.type, BackendQuestionType.number);
      expect(copy.ordinal, 5);
      expect(copy.required, isFalse); // unchanged
      expect(copy.id, 1); // unchanged
    });
  });
}
