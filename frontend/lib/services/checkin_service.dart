import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_constant.dart';
import 'auth_token_manager.dart';

/// Service that handles creating and retrieving patient check-ins.
/// Used by both patient and caregiver dashboards.
class CheckinService {
  static String get _baseUrl => '${getBackendBaseUrl()}/api/checkins';
  static String get _questionsUrl => '${getBackendBaseUrl()}/api/questions';

  static int? _parseIntId(String raw) => int.tryParse(raw.trim());

  static List<int> _extractQuestionIds(dynamic decoded) {
    if (decoded is! List) return const [];

    final ids = <int>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final rawId = item['id'];
      if (rawId is int) {
        ids.add(rawId);
      } else if (rawId is num) {
        ids.add(rawId.toInt());
      } else if (rawId is String) {
        final parsed = int.tryParse(rawId);
        if (parsed != null) ids.add(parsed);
      }
    }
    return ids;
  }

  static Future<List<int>> _fetchActiveQuestionIds() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    headers['Accept'] = 'application/json';

    final url = Uri.parse(_questionsUrl).replace(
      queryParameters: const {'active': 'true'},
    );
    final response = await http.get(url, headers: headers);
    if (response.statusCode != 200) return const [];

    final decoded = jsonDecode(response.body);
    return _extractQuestionIds(decoded);
  }

  /// Adds a new check-in for a patient.
  /// Uses the snapshot creation contract: patientId + selectedQuestionIds.
  static Future<bool> addCheckin(String patientId, String caregiverId) async {
    if (caregiverId.isEmpty) return false;

    final parsedPatientId = _parseIntId(patientId);
    if (parsedPatientId == null) return false;

    final selectedQuestionIds = await _fetchActiveQuestionIds();
    if (selectedQuestionIds.isEmpty) return false;

    final url = Uri.parse(_baseUrl);
    final body = jsonEncode({
      'patientId': parsedPatientId,
      'selectedQuestionIds': selectedQuestionIds,
    });

    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  /// Creates a check-in using explicit question IDs and returns the new check-in ID.
  /// Returns null if the request fails or the response does not include an ID.
  static Future<int?> createCheckinWithSelectedQuestions({
    required String patientId,
    required List<int> selectedQuestionIds,
  }) async {
    final parsedPatientId = _parseIntId(patientId);
    if (parsedPatientId == null || selectedQuestionIds.isEmpty) return null;

    final url = Uri.parse(_baseUrl);
    final body = jsonEncode({
      'patientId': parsedPatientId,
      'selectedQuestionIds': selectedQuestionIds,
    });

    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode != 201 && response.statusCode != 200) return null;

    final rawBody = response.body.trim();
    if (rawBody.isEmpty) return null;

    final decoded = jsonDecode(rawBody);
    if (decoded is! Map<String, dynamic>) return null;

    final rawId = decoded['checkInId'] ?? decoded['checkinId'] ?? decoded['id'];
    if (rawId is int) return rawId;
    if (rawId is num) return rawId.toInt();
    if (rawId is String) return int.tryParse(rawId);
    return null;
  }

  /// Fetches the total number of check-ins tied to a caregiver.
  /// Example use: final count = await CheckinService.getCheckinCount(caregiverId);
  static Future<int> getCheckinCount(String caregiverId) async {
    final url = Uri.parse('$_baseUrl/count?caregiverId=$caregiverId');
    final headers = await AuthTokenManager.getAuthHeaders();
    headers['Accept'] = 'application/json';
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    } else {
      return 0;
    }
  }
}
