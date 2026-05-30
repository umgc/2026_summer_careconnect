// Tests for PatientData.fromJson
// (lib/features/health/caregiver-patient-list/data/patient_api_simple.dart).

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:care_connect_app/features/health/caregiver-patient-list/data/patient_api_simple.dart';

Map<String, dynamic> _fullJson() => {
      'id': 'p-1',
      'mrn': 'MRN-001',
      'fullName': 'Alice Smith',
      'sex': 'F',
      'age': 72,
      'currentMoodLabel': 'Happy',
      'currentMoodEmoji': '😊',
      'lastCheckIn': '2025-11-01T09:00:00.000Z',
      'diagnoses': ['Hypertension', 'Diabetes'],
      'allergies': ['Penicillin'],
      'emergencyContacts': [
        {'phone': '555-1234'},
        {'phone': ''},
      ],
      'vitals': {
        'heartRateBpm': 72,
        'bpSystolic': 120,
        'bpDiastolic': 80,
        'oxygenPercent': 98,
        'temperatureF': 98.6,
      },
      'pain': {
        'current': 3,
        'location': 'Lower back',
        'dizziness': 1,
        'fatigue': 2,
      },
      'symptoms': [
        {'name': 'Headache', 'severity': 'mild'},
      ],
      'medications': [
        {'name': 'Metformin', 'dose': '500mg'},
      ],
      'virtualCheckIns': [
        {'id': 'ci-1', 'date': '2025-10-30'},
      ],
    };

void main() {
  group('PatientData.fromJson', () {
    test('parses all scalar fields', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.id, 'p-1');
      expect(p.mrn, 'MRN-001');
      expect(p.fullName, 'Alice Smith');
      expect(p.sex, 'F');
      expect(p.age, 72);
      expect(p.moodLabel, 'Happy');
      expect(p.moodEmoji, '😊');
    });

    test('parses lastCheckIn as DateTime', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.lastCheckIn, isNotNull);
      expect(p.lastCheckIn!.year, 2025);
      expect(p.lastCheckIn!.month, 11);
    });

    test('lastCheckIn is null when missing', () {
      final j = _fullJson()..remove('lastCheckIn');
      final p = PatientData.fromJson(j);
      expect(p.lastCheckIn, isNull);
    });

    test('parses diagnoses and allergies', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.diagnoses, ['Hypertension', 'Diabetes']);
      expect(p.allergies, ['Penicillin']);
    });

    test('emergencyPhones filters out empty strings', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.emergencyPhones, ['555-1234']);
    });

    test('parses vitals', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.heartRate, 72);
      expect(p.bpSys, 120);
      expect(p.bpDia, 80);
      expect(p.oxygen, 98);
      expect(p.tempF, 98.6);
    });

    test('parses pain fields', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.painCurrent, 3);
      expect(p.painLocation, 'Lower back');
      expect(p.dizziness, 1);
      expect(p.fatigue, 2);
    });

    test('parses symptoms, medications, checkIns', () {
      final p = PatientData.fromJson(_fullJson());
      expect(p.symptoms.length, 1);
      expect(p.medications.length, 1);
      expect(p.checkIns.length, 1);
    });

    test('uses defaults when optional fields are absent', () {
      // vitals and pain must be provided as empty typed maps; the source code
      // uses `(j['vitals'] ?? {}) as Map<String, dynamic>` which would throw
      // a cast error if null — so we supply empty maps explicitly.
      final p = PatientData.fromJson({
        'id': 'p-0',
        'mrn': '',
        'fullName': '',
        'sex': '',
        'age': 0,
        'vitals': <String, dynamic>{},
        'pain': <String, dynamic>{},
      });
      expect(p.moodLabel, '—');
      expect(p.moodEmoji, '🙂');
      expect(p.diagnoses, isEmpty);
      expect(p.allergies, isEmpty);
      expect(p.emergencyPhones, isEmpty);
      expect(p.heartRate, isNull);
      expect(p.tempF, isNull);
      expect(p.symptoms, isEmpty);
    });
  });

  group('PatientApiSimple', () {
    test('constructs with a base URL', () {
      final api = PatientApiSimple('http://localhost:8080');
      expect(api.baseUrl, 'http://localhost:8080');
    });

    test('fetchPatient returns PatientData on 200', () async {
      // Use a simple JSON without emoji to avoid Latin1 encoding issues
      final simpleJson = {
        'id': 'p-1',
        'mrn': 'MRN-001',
        'fullName': 'Alice Smith',
        'sex': 'F',
        'age': 72,
        'vitals': <String, dynamic>{},
        'pain': <String, dynamic>{},
      };
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/patients/p-1');
        return http.Response(jsonEncode({'data': simpleJson}), 200);
      });

      await http.runWithClient(() async {
        final api = PatientApiSimple('http://localhost:8080');
        final result = await api.fetchPatient('p-1');
        expect(result.id, 'p-1');
        expect(result.fullName, 'Alice Smith');
        expect(result.age, 72);
      }, () => mockClient);
    });

    test('fetchPatient handles response without data wrapper', () async {
      final simpleJson = {
        'id': 'p-2',
        'mrn': 'MRN-002',
        'fullName': 'Bob Jones',
        'sex': 'M',
        'age': 55,
        'vitals': <String, dynamic>{},
        'pain': <String, dynamic>{},
      };
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(simpleJson), 200);
      });

      await http.runWithClient(() async {
        final api = PatientApiSimple('http://localhost:8080');
        final result = await api.fetchPatient('p-2');
        expect(result.id, 'p-2');
      }, () => mockClient);
    });

    test('fetchPatient throws on non-200 status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      await http.runWithClient(() async {
        final api = PatientApiSimple('http://localhost:8080');
        expect(
          () => api.fetchPatient('p-99'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Load failed: 404'),
          )),
        );
      }, () => mockClient);
    });

    test('fetchPatient includes query parameters in URL', () async {
      final simpleJson = {
        'id': 'p-1',
        'fullName': 'Test',
        'sex': 'M',
        'age': 30,
        'vitals': <String, dynamic>{},
        'pain': <String, dynamic>{},
      };
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['include'],
            'medications,symptoms,checkins');
        return http.Response(jsonEncode({'data': simpleJson}), 200);
      });

      await http.runWithClient(() async {
        final api = PatientApiSimple('http://localhost:8080');
        await api.fetchPatient('p-1');
      }, () => mockClient);
    });
  });
}
