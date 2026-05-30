// Tests for PatientNote model
// (lib/features/notetaker/models/patient_note_model.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/notetaker/models/patient_note_model.dart';

void main() {
  group('PatientNote.fromJson', () {
    test('parses all fields when fully populated', () {
      final note = PatientNote.fromJson({
        'id': 42,
        'patientId': 7,
        'note': 'Patient reported mild headache.',
        'aiSummary': 'Mild headache, no serious concerns.',
        'createdAt': '2024-03-15T09:00:00.000Z',
        'updatedAt': '2024-03-15T10:00:00.000Z',
      });

      expect(note.id, '42');
      expect(note.patientId, '7');
      expect(note.note, 'Patient reported mild headache.');
      expect(note.aiSummary, 'Mild headache, no serious concerns.');
      expect(note.createdAt, DateTime.parse('2024-03-15T09:00:00.000Z'));
      expect(note.updatedAt, DateTime.parse('2024-03-15T10:00:00.000Z'));
    });

    test('defaults to empty strings when fields are null', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final note = PatientNote.fromJson({});

      expect(note.id, '');
      expect(note.patientId, '');
      expect(note.note, '');
      expect(note.aiSummary, '');
      expect(note.createdAt.isAfter(before), isTrue);
      expect(note.updatedAt.isAfter(before), isTrue);
    });

    test('converts numeric id to string', () {
      final note = PatientNote.fromJson({
        'id': 99,
        'patientId': 5,
        'note': 'Test',
        'aiSummary': 'Summary',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(note.id, '99');
      expect(note.patientId, '5');
    });

    test('uses DateTime.now() fallback for invalid date strings', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final note = PatientNote.fromJson({
        'id': '1',
        'patientId': '1',
        'note': 'Test',
        'aiSummary': '',
        'createdAt': 'invalid-date',
        'updatedAt': 'not-a-date',
      });
      expect(note.createdAt.isAfter(before), isTrue);
      expect(note.updatedAt.isAfter(before), isTrue);
    });
  });

  group('PatientNote.toJson', () {
    test('serializes all fields', () {
      final note = PatientNote(
        id: 'note-1',
        patientId: 'pat-5',
        note: 'Follow-up needed.',
        aiSummary: 'Patient stable.',
        createdAt: DateTime(2024, 5, 10, 8, 0),
        updatedAt: DateTime(2024, 5, 10, 9, 0),
      );
      final json = note.toJson();

      expect(json['id'], 'note-1');
      expect(json['patientId'], 'pat-5');
      expect(json['note'], 'Follow-up needed.');
      expect(json['aiSummary'], 'Patient stable.');
      expect(json['createdAt'], '2024-05-10T08:00:00.000');
      expect(json['updatedAt'], '2024-05-10T09:00:00.000');
    });

    test('toJson includes all expected keys', () {
      final note = PatientNote(
        id: 'id-1',
        patientId: 'pat-1',
        note: 'Test note',
        aiSummary: 'AI summary',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      final json = note.toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('patientId'), isTrue);
      expect(json.containsKey('note'), isTrue);
      expect(json.containsKey('aiSummary'), isTrue);
      expect(json.containsKey('createdAt'), isTrue);
      expect(json.containsKey('updatedAt'), isTrue);
    });

    test('roundtrip: fromJson(toJson) preserves data', () {
      final original = PatientNote(
        id: 'rt-1',
        patientId: 'rt-pat',
        note: 'Roundtrip test',
        aiSummary: 'AI roundtrip',
        createdAt: DateTime(2024, 6, 15, 12, 0),
        updatedAt: DateTime(2024, 6, 15, 13, 0),
      );
      final restored = PatientNote.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.patientId, original.patientId);
      expect(restored.note, original.note);
      expect(restored.aiSummary, original.aiSummary);
    });
  });

  group('PatientNote constructor', () {
    test('stores empty strings', () {
      final note = PatientNote(
        id: '',
        patientId: '',
        note: '',
        aiSummary: '',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(note.id, '');
      expect(note.note, '');
    });
  });
}
