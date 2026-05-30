// Tests for QuestionsApi HTTP methods (listQuestions, listQuestionsForCheckIn)
// (lib/features/health/virtual_check_in/services/questions_api.dart).
//
// Uses http.runWithClient() to intercept top-level http.get calls with a
// MockClient. No real network traffic occurs.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:care_connect_app/features/health/virtual_check_in/services/questions_api.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in_backend_question_model.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/question_type.dart';

// -- Constants ----------------------------------------------------------------

const _base = 'http://localhost:8080';
const _checkInId = 'checkin-abc-123';

// -- Fixture helpers ----------------------------------------------------------

Map<String, dynamic> _questionJson({
  int id = 1,
  String prompt = 'How are you?',
  String type = 'TEXT',
  bool required = true,
  bool active = true,
  int ordinal = 0,
}) =>
    {
      'id': id,
      'prompt': prompt,
      'type': type,
      'required': required,
      'active': active,
      'ordinal': ordinal,
    };

MockClient _mockJson(int statusCode, Object body) =>
    MockClient((_) async => http.Response(jsonEncode(body), statusCode));

MockClient _mockRaw(int statusCode, String rawBody) =>
    MockClient((_) async => http.Response(rawBody, statusCode));

(MockClient, List<http.Request>) _capturingClient(int statusCode, Object body) {
  final captured = <http.Request>[];
  final client = MockClient((req) async {
    captured.add(req);
    return http.Response(jsonEncode(body), statusCode);
  });
  return (client, captured);
}

QuestionsApi _api() => QuestionsApi(_base);

// -- Tests --------------------------------------------------------------------

void main() {
  // ---------- listQuestions() ----------

  group('listQuestions()', () {
    test('uses GET method', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(),
        () => client,
      );
      expect(requests.single.method, 'GET');
    });

    test('hits /api/questions endpoint', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(),
        () => client,
      );
      expect(requests.single.url.path, '/api/questions');
    });

    test('sends Accept: application/json header', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(),
        () => client,
      );
      expect(requests.single.headers['Accept'], 'application/json');
    });

    test('omits active query param when active is null', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(),
        () => client,
      );
      expect(requests.single.url.queryParameters.containsKey('active'), isFalse);
    });

    test('includes active=true query param when active is true', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(active: true),
        () => client,
      );
      expect(requests.single.url.queryParameters['active'], 'true');
    });

    test('includes active=false query param when active is false', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestions(active: false),
        () => client,
      );
      expect(requests.single.url.queryParameters['active'], 'false');
    });

    test('returns empty list when server responds with []', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, <dynamic>[]),
      );
      expect(result, isEmpty);
    });

    test('returns a list of BackendQuestionDto on 200', () async {
      final body = [_questionJson(id: 1), _questionJson(id: 2)];
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, body),
      );
      expect(result, hasLength(2));
      expect(result.first, isA<BackendQuestionDto>());
    });

    test('returned DTO has correct id', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(id: 99)]),
      );
      expect(result.single.id, 99);
    });

    test('returned DTO has correct prompt', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(prompt: 'Rate your pain')]),
      );
      expect(result.single.prompt, 'Rate your pain');
    });

    test('returned DTO has correct type', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(type: 'YES_NO')]),
      );
      expect(result.single.type, BackendQuestionType.yesNo);
    });

    test('returned DTO has correct required flag', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(required: false)]),
      );
      expect(result.single.required, isFalse);
    });

    test('returned DTO has correct active flag', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(active: false)]),
      );
      expect(result.single.active, isFalse);
    });

    test('returned DTO has correct ordinal', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(ordinal: 5)]),
      );
      expect(result.single.ordinal, 5);
    });

    test('parses NUMBER type correctly', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(type: 'NUMBER')]),
      );
      expect(result.single.type, BackendQuestionType.number);
    });

    test('parses TRUE_FALSE type correctly', () async {
      final result = await http.runWithClient(
        () => _api().listQuestions(),
        () => _mockJson(200, [_questionJson(type: 'TRUE_FALSE')]),
      );
      expect(result.single.type, BackendQuestionType.trueFalse);
    });

    test('throws Exception on 404 status', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestions(),
          () => _mockRaw(404, 'Not Found'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws Exception on 500 status', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestions(),
          () => _mockRaw(500, 'Internal Server Error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('exception message includes status code', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestions(),
          () => _mockRaw(403, 'Forbidden'),
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('403'),
        )),
      );
    });
  });

  // ---------- listQuestionsForCheckIn() ----------

  group('listQuestionsForCheckIn()', () {
    test('uses GET method', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => client,
      );
      expect(requests.single.method, 'GET');
    });

    test('hits /api/checkins/{checkInId}/questions endpoint', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => client,
      );
      expect(
        requests.single.url.path,
        '/api/checkins/$_checkInId/questions',
      );
    });

    test('embeds a different checkInId in the URL path', () async {
      const otherId = 'other-999';
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestionsForCheckIn(otherId),
        () => client,
      );
      expect(requests.single.url.path, contains(otherId));
    });

    test('sends Accept: application/json header', () async {
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => client,
      );
      expect(requests.single.headers['Accept'], 'application/json');
    });

    test('returns empty list when server responds with []', () async {
      final result = await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => _mockJson(200, <dynamic>[]),
      );
      expect(result, isEmpty);
    });

    test('returns a list of BackendQuestionDto on 200', () async {
      final body = [_questionJson(id: 10), _questionJson(id: 20)];
      final result = await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => _mockJson(200, body),
      );
      expect(result, hasLength(2));
      expect(result.first, isA<BackendQuestionDto>());
      expect(result.first.id, 10);
      expect(result.last.id, 20);
    });

    test('returned DTO has correct prompt', () async {
      final result = await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => _mockJson(200, [_questionJson(prompt: 'Feeling okay?')]),
      );
      expect(result.single.prompt, 'Feeling okay?');
    });

    test('returned DTO has correct type', () async {
      final result = await http.runWithClient(
        () => _api().listQuestionsForCheckIn(_checkInId),
        () => _mockJson(200, [_questionJson(type: 'YES_NO')]),
      );
      expect(result.single.type, BackendQuestionType.yesNo);
    });

    test('throws Exception on 404 status', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestionsForCheckIn(_checkInId),
          () => _mockRaw(404, 'Not Found'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('throws Exception on 500 status', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestionsForCheckIn(_checkInId),
          () => _mockRaw(500, 'Server Error'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('exception message includes status code', () async {
      await expectLater(
        http.runWithClient(
          () => _api().listQuestionsForCheckIn(_checkInId),
          () => _mockRaw(401, 'Unauthorized'),
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('401'),
        )),
      );
    });
  });

  // ---------- URL normalisation (supplement to existing tests) ----------

  group('URL normalisation in HTTP calls', () {
    test('trailing slash in base URL does not cause double slashes', () async {
      final api = QuestionsApi('$_base/');
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => api.listQuestions(),
        () => client,
      );
      expect(requests.single.url.path, startsWith('/api/'));
      expect(requests.single.url.path, isNot(contains('//')));
    });

    test('base URL without trailing slash produces correct path', () async {
      final api = QuestionsApi(_base);
      final (client, requests) = _capturingClient(200, <dynamic>[]);
      await http.runWithClient(
        () => api.listQuestions(),
        () => client,
      );
      expect(requests.single.url.path, '/api/questions');
    });
  });
}
