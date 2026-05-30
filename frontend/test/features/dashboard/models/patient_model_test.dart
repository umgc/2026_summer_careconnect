// Tests for dashboard Patient and Address models
// (lib/features/dashboard/models/patient_model.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';

void main() {
  // ── Address ──────────────────────────────────────────────────────────

  group('Address', () {
    test('constructor stores all fields', () {
      final address = Address(
        line1: '123 Main St',
        line2: 'Apt 4B',
        city: 'Springfield',
        state: 'IL',
        zip: '62701',
        phone: '(555) 123-4567',
      );
      expect(address.line1, '123 Main St');
      expect(address.line2, 'Apt 4B');
      expect(address.city, 'Springfield');
      expect(address.state, 'IL');
      expect(address.zip, '62701');
      expect(address.phone, '(555) 123-4567');
    });

    test('constructor defaults all fields to null', () {
      final address = Address();
      expect(address.line1, isNull);
      expect(address.line2, isNull);
      expect(address.city, isNull);
      expect(address.state, isNull);
      expect(address.zip, isNull);
      expect(address.phone, isNull);
    });

    test('fromJson parses all fields', () {
      final address = Address.fromJson({
        'line1': '456 Oak Ave',
        'line2': 'Suite 2',
        'city': 'Chicago',
        'state': 'IL',
        'zip': '60601',
        'phone': '(555) 987-6543',
      });
      expect(address.line1, '456 Oak Ave');
      expect(address.line2, 'Suite 2');
      expect(address.city, 'Chicago');
      expect(address.state, 'IL');
      expect(address.zip, '60601');
      expect(address.phone, '(555) 987-6543');
    });

    test('fromJson allows null / missing fields', () {
      final address = Address.fromJson({});
      expect(address.line1, isNull);
      expect(address.line2, isNull);
      expect(address.city, isNull);
      expect(address.state, isNull);
      expect(address.zip, isNull);
      expect(address.phone, isNull);
    });

    test('toJson includes all fields', () {
      final address = Address(
        line1: '789 Pine Rd',
        line2: 'Floor 3',
        city: 'Naperville',
        state: 'IL',
        zip: '60540',
        phone: '555-0000',
      );
      final json = address.toJson();
      expect(json['line1'], '789 Pine Rd');
      expect(json['line2'], 'Floor 3');
      expect(json['city'], 'Naperville');
      expect(json['state'], 'IL');
      expect(json['zip'], '60540');
      expect(json['phone'], '555-0000');
    });

    test('toJson preserves null values', () {
      final address = Address();
      final json = address.toJson();
      expect(json.containsKey('line1'), isTrue);
      expect(json['line1'], isNull);
      expect(json.containsKey('line2'), isTrue);
      expect(json['line2'], isNull);
    });

    test('fromJson -> toJson round-trip', () {
      final original = {
        'line1': 'A',
        'line2': 'B',
        'city': 'C',
        'state': 'D',
        'zip': 'E',
        'phone': 'F',
      };
      final json = Address.fromJson(original).toJson();
      expect(json, equals(original));
    });
  });

  // ── Patient constructor ──────────────────────────────────────────────

  group('Patient constructor', () {
    test('stores required and optional fields', () {
      final addr = Address(line1: '1 St');
      final patient = Patient(
        id: 1,
        firstName: 'A',
        lastName: 'B',
        email: 'a@b.com',
        phone: '555',
        dob: '2000-01-01',
        relationship: 'Friend',
        profileImageUrl: 'http://img.png',
        address: addr,
        linkId: 10,
        linkStatus: 'PENDING',
        gender: 'Male',
        maNumber: 'MA-1',
        allergies: ['pollen'],
        vitalConditions: {'bp': '120/80'},
      );
      expect(patient.id, 1);
      expect(patient.firstName, 'A');
      expect(patient.lastName, 'B');
      expect(patient.email, 'a@b.com');
      expect(patient.phone, '555');
      expect(patient.dob, '2000-01-01');
      expect(patient.relationship, 'Friend');
      expect(patient.profileImageUrl, 'http://img.png');
      expect(patient.address, addr);
      expect(patient.linkId, 10);
      expect(patient.linkStatus, 'PENDING');
      expect(patient.gender, 'Male');
      expect(patient.maNumber, 'MA-1');
      expect(patient.allergies, ['pollen']);
      expect(patient.vitalConditions, {'bp': '120/80'});
    });

    test('linkStatus defaults to ACTIVE', () {
      final patient = Patient(
        id: 2,
        firstName: 'X',
        lastName: 'Y',
        email: '',
        phone: '',
        dob: '',
        relationship: '',
      );
      expect(patient.linkStatus, 'ACTIVE');
      expect(patient.profileImageUrl, isNull);
      expect(patient.address, isNull);
      expect(patient.linkId, isNull);
      expect(patient.gender, isNull);
      expect(patient.maNumber, isNull);
      expect(patient.allergies, isNull);
      expect(patient.vitalConditions, isNull);
    });
  });

  // ── Patient.fromJson ─────────────────────────────────────────────────

  group('Patient.fromJson', () {
    Map<String, dynamic> makeBase({Map<String, dynamic> extra = const {}}) {
      return {
        'id': 1,
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@test.com',
        'phone': '555',
        'dob': '2000-01-01',
        'relationship': 'Self',
        ...extra,
      };
    }

    // ── id parsing variants ──

    test('parses id as int', () {
      final p = Patient.fromJson(makeBase());
      expect(p.id, 1);
    });

    test('parses id as String', () {
      final p = Patient.fromJson(makeBase(extra: {'id': '42'}));
      expect(p.id, 42);
    });

    test('parses id as unparseable String defaults to 0', () {
      final p = Patient.fromJson(makeBase(extra: {'id': 'abc'}));
      expect(p.id, 0);
    });

    test('uses patientId as int when id missing', () {
      final json = makeBase();
      json.remove('id');
      json['patientId'] = 99;
      expect(Patient.fromJson(json).id, 99);
    });

    test('uses patientId as String when id missing', () {
      final json = makeBase();
      json.remove('id');
      json['patientId'] = '77';
      expect(Patient.fromJson(json).id, 77);
    });

    test('patientId unparseable String defaults to 0', () {
      final json = makeBase();
      json.remove('id');
      json['patientId'] = 'xyz';
      expect(Patient.fromJson(json).id, 0);
    });

    test('id defaults to 0 when both id and patientId absent', () {
      final json = makeBase();
      json.remove('id');
      expect(Patient.fromJson(json).id, 0);
    });

    // ── nested patient structure ──

    test('parses nested patient structure', () {
      final p = Patient.fromJson({
        'patient': {
          'id': 20,
          'firstName': 'Bob',
          'lastName': 'Jones',
          'email': 'bob@example.com',
          'phone': '555-5678',
          'dob': '1985-06-01',
          'relationship': 'Father',
        },
      });
      expect(p.id, 20);
      expect(p.firstName, 'Bob');
      expect(p.lastName, 'Jones');
    });

    // ── linkId / linkStatus from direct fields ──

    test('linkId and linkStatus from direct fields (int)', () {
      final p = Patient.fromJson(makeBase(extra: {
        'linkId': 55,
        'linkStatus': 'PENDING',
      }));
      expect(p.linkId, 55);
      expect(p.linkStatus, 'PENDING');
    });

    test('linkId from direct field as String', () {
      final p = Patient.fromJson(makeBase(extra: {'linkId': '33'}));
      expect(p.linkId, 33);
    });

    test('linkStatus defaults to ACTIVE when absent', () {
      final p = Patient.fromJson(makeBase());
      expect(p.linkStatus, 'ACTIVE');
    });

    // ── linkId / linkStatus from link object ──

    test('linkId and linkStatus from link object (int id)', () {
      final p = Patient.fromJson(makeBase(extra: {
        'link': {'id': 77, 'status': 'ACTIVE', 'linkType': 'Friend'},
      }));
      expect(p.linkId, 77);
      expect(p.linkStatus, 'ACTIVE');
    });

    test('linkId from link object with String id', () {
      final p = Patient.fromJson(makeBase(extra: {
        'link': {'id': '88'},
      }));
      expect(p.linkId, 88);
    });

    test('link object without id does not set linkId', () {
      final p = Patient.fromJson(makeBase(extra: {
        'link': {'status': 'INACTIVE'},
      }));
      expect(p.linkId, isNull);
      expect(p.linkStatus, 'INACTIVE');
    });

    test('relationship falls back to link.linkType', () {
      final json = makeBase();
      json.remove('relationship');
      json['link'] = {'id': 1, 'linkType': 'Caregiver'};
      final p = Patient.fromJson(json);
      expect(p.relationship, 'Caregiver');
    });

    test('relationship empty when no relationship and no link', () {
      final json = makeBase();
      json.remove('relationship');
      final p = Patient.fromJson(json);
      // Falls through to empty string
      expect(p.relationship, '');
    });

    // ── profileImageUrl ──

    test('profileImageUrl from flat field', () {
      final p = Patient.fromJson(
          makeBase(extra: {'profileImageUrl': 'http://img.png'}));
      expect(p.profileImageUrl, 'http://img.png');
    });

    test('profileImageUrl from nested user object', () {
      final p = Patient.fromJson(makeBase(extra: {
        'user': {'profileImageUrl': 'http://user-img.png'},
      }));
      expect(p.profileImageUrl, 'http://user-img.png');
    });

    test('profileImageUrl null when user has no image', () {
      final p = Patient.fromJson(makeBase(extra: {
        'user': {'name': 'someone'},
      }));
      // user exists but profileImageUrl is null -> toString returns 'null'
      // The code does ?.toString() which would be null
      expect(p.profileImageUrl, isNull);
    });

    // ── address ──

    test('parses address when present', () {
      final p = Patient.fromJson(makeBase(extra: {
        'address': {'line1': '321 Elm St', 'city': 'Decatur', 'state': 'IL'},
      }));
      expect(p.address, isNotNull);
      expect(p.address?.line1, '321 Elm St');
      expect(p.address?.city, 'Decatur');
    });

    test('address is null when not in json', () {
      final p = Patient.fromJson(makeBase());
      expect(p.address, isNull);
    });

    // ── gender, maNumber ──

    test('parses gender', () {
      final p = Patient.fromJson(makeBase(extra: {'gender': 'Female'}));
      expect(p.gender, 'Female');
    });

    test('gender is null when absent', () {
      final p = Patient.fromJson(makeBase());
      expect(p.gender, isNull);
    });

    test('parses maNumber', () {
      final p = Patient.fromJson(makeBase(extra: {'maNumber': 'MA-123456'}));
      expect(p.maNumber, 'MA-123456');
    });

    // ── allergies ──

    test('parses allergies list', () {
      final p = Patient.fromJson(
          makeBase(extra: {'allergies': ['peanuts', 'shellfish']}));
      expect(p.allergies, ['peanuts', 'shellfish']);
    });

    test('allergies defaults to empty list when absent', () {
      final p = Patient.fromJson(makeBase());
      expect(p.allergies, []);
    });

    // ── vitalConditions / latestVitals ──

    test('parses latestVitals into vitalConditions', () {
      final p = Patient.fromJson(makeBase(extra: {
        'latestVitals': {'heartRate': 72, 'bp': '120/80'},
      }));
      expect(p.vitalConditions, {'heartRate': 72, 'bp': '120/80'});
    });

    test('vitalConditions defaults to empty map when latestVitals absent', () {
      final p = Patient.fromJson(makeBase());
      expect(p.vitalConditions, {});
    });

    // ── missing string fields default to empty string ──

    test('missing string fields default to empty string', () {
      final p = Patient.fromJson({'id': 1});
      expect(p.firstName, '');
      expect(p.lastName, '');
      expect(p.email, '');
      expect(p.phone, '');
      expect(p.dob, '');
    });
  });

  // ── Patient.toString ─────────────────────────────────────────────────

  group('Patient.toString', () {
    test('returns formatted string with all fields', () {
      final patient = Patient(
        id: 42,
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@doe.com',
        phone: '555-1234',
        dob: '1990-05-20',
        relationship: 'Self',
        linkId: 7,
        linkStatus: 'ACTIVE',
        gender: 'Female',
        maNumber: 'MA-999',
        allergies: ['dust'],
        vitalConditions: {'temp': 98.6},
      );
      final str = patient.toString();
      expect(str, contains('id: 42'));
      expect(str, contains('firstName: Jane'));
      expect(str, contains('lastName: Doe'));
      expect(str, contains('email: jane@doe.com'));
      expect(str, contains('phone: 555-1234'));
      expect(str, contains('dob: 1990-05-20'));
      expect(str, contains('relationship: Self'));
      expect(str, contains('maNumber: MA-999'));
      expect(str, contains('linkId: 7'));
      expect(str, contains('linkStatus: ACTIVE'));
      expect(str, contains('gender: Female'));
      expect(str, contains('allergies: [dust]'));
      expect(str, contains('vitalConditions: {temp: 98.6}'));
    });

    test('toString handles null optional fields', () {
      final patient = Patient(
        id: 0,
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        dob: '',
        relationship: '',
      );
      final str = patient.toString();
      expect(str, contains('linkId: null'));
      expect(str, contains('gender: null'));
      expect(str, contains('maNumber: null'));
      expect(str, contains('allergies: null'));
      expect(str, contains('vitalConditions: null'));
    });
  });
}
