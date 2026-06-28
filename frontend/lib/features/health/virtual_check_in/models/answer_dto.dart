import 'package:care_connect_app/features/health/virtual_check_in/models/question_type.dart';

/// Represents a single answer to a check-in question.
class AnswerUpsertRequestDTO {
  final int questionId;
  final String? valueText;
  final bool? valueBoolean;
  final num? valueNumber;

  const AnswerUpsertRequestDTO({
    required this.questionId,
    this.valueText,
    this.valueBoolean,
    this.valueNumber,
  });

  /// Factory to create answer from question type and user input
  factory AnswerUpsertRequestDTO.fromInput({
    required int questionId,
    required BackendQuestionType type,
    required dynamic value,
  }) {
    switch (type) {
      case BackendQuestionType.text:
        return AnswerUpsertRequestDTO(
          questionId: questionId,
          valueText: value is String ? value : null,
        );
      case BackendQuestionType.yesNo:
      case BackendQuestionType.trueFalse:
        return AnswerUpsertRequestDTO(
          questionId: questionId,
          valueBoolean: value is bool ? value : null,
        );
      case BackendQuestionType.number:
        return AnswerUpsertRequestDTO(
          questionId: questionId,
          valueNumber: value is num ? value : null,
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      if (valueText != null) 'valueText': valueText,
      if (valueBoolean != null) 'valueBoolean': valueBoolean,
      if (valueNumber != null) 'valueNumber': valueNumber,
    };
  }
}

/// Request DTO for submitting multiple answers
class SubmitAnswersRequestDTO {
  final List<AnswerUpsertRequestDTO> answers;

  const SubmitAnswersRequestDTO({
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

/// Response DTO from answer submission
class SubmitAnswersResponseDTO {
  final int checkInId;
  final int submitted;
  final List<String> validationErrors;

  const SubmitAnswersResponseDTO({
    required this.checkInId,
    required this.submitted,
    required this.validationErrors,
  });

  factory SubmitAnswersResponseDTO.fromJson(Map<String, dynamic> json) {
    return SubmitAnswersResponseDTO(
      checkInId: json['checkInId'] as int? ?? 0,
      submitted: json['submitted'] as int? ?? 0,
      validationErrors: (json['validationErrors'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
    );
  }
}
