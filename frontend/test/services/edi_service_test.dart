// Tests for EdiService static utility methods and generateEDIContent.
//
// Coverage strategy:
//   EdiService contains many pure static helpers that perform date/time
//   formatting, code mapping, unit/charge calculation, and EDI content
//   generation.  All are exercised without HTTP or platform channels.
//
//   exportVisitData uses universal_html (web-only) and is skipped.
//
//   generateEDIContent is tested with Patient model instances covering:
//     - maNumber present vs absent (fallback generation)
//     - dob present/valid, empty, invalid (parse error → default)
//     - gender MALE, M, FEMALE, F, null (→ F default)
//     - notes present (segment count 31) vs empty (segment count 30)
//     - address present vs null (defaults)
//     - optional location coordinates
//
//   Utility methods tested:
//     validateEDIContent — empty string, missing segment, all segments present.
//     parseServiceTypeToCode — all 10 known services and unknown fallback.
//     calculateBillableUnits — exact multiple of 900, remainder, zero.
//     calculateTotalCharge — default rate and custom rate.
//     formatMANumber — existing MA number, null/empty generates from patientId.
//     generateControlNumber — returns 9-char numeric string.
//     formatEDIDate — YYYYMMDD zero-padded.
//     formatEDITime — HHMM zero-padded.
//     formatISADate — YYMMDD zero-padded.
//     sanitizeNotes — removes ~, *, : characters.
//     generateMockEdi837 — default params, custom params.
//     generateMockEdiWithDetails — uses custom patient/service/duration.

import 'package:flutter_test/flutter_test.dart';

import 'package:care_connect_app/services/edi_service.dart';
import 'package:care_connect_app/features/dashboard/models/patient_model.dart';

/// Helper to build a Patient with sensible defaults, overridable per-field.
Patient _makePatient({
  int id = 1,
  String firstName = 'Jane',
  String lastName = 'Doe',
  String email = 'jane@example.com',
  String phone = '555-0100',
  String dob = '1990-06-15',
  String relationship = 'Self',
  String? gender = 'FEMALE',
  String? maNumber,
  Address? address,
}) {
  return Patient(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    dob: dob,
    relationship: relationship,
    gender: gender,
    maNumber: maNumber,
    address: address,
  );
}

void main() {
  // ─── generateEDIContent ──────────────────────────────────────────────────

  group('EdiService.generateEDIContent', () {
    final checkinTime = DateTime(2025, 3, 10, 9, 0);
    final checkoutTime = DateTime(2025, 3, 10, 10, 0);

    test('produces valid EDI content', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(EdiService.validateEDIContent(edi), isTrue);
    });

    test('includes patient name in NM1*IL segment', () {
      final patient = _makePatient(firstName: 'Alice', lastName: 'Smith');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('NM1*IL*1*Smith*Alice'));
    });

    // ── maNumber branch ──

    test('uses patient.maNumber when provided', () {
      final patient = _makePatient(maNumber: 'MA999');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('MA999'));
    });

    test('generates SUBSCR fallback when maNumber is null', () {
      final patient = _makePatient(id: 42, maNumber: null);
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('SUBSCR00042'));
    });

    // ── dob branches ──

    test('formats valid dob correctly (YYYYMMDD)', () {
      final patient = _makePatient(dob: '1990-06-15');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('DMG*D8*19900615'));
    });

    test('uses default dob 19700101 when dob is empty', () {
      final patient = _makePatient(dob: '');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('DMG*D8*19700101'));
    });

    test('uses default dob 19700101 when dob is unparseable', () {
      final patient = _makePatient(dob: 'not-a-date');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('DMG*D8*19700101'));
    });

    test('zero-pads single-digit month/day in dob', () {
      final patient = _makePatient(dob: '2000-01-05');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('DMG*D8*20000105'));
    });

    // ── gender branches ──

    test('gender MALE → M', () {
      final patient = _makePatient(gender: 'MALE');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('*M~'));
    });

    test('gender M → M', () {
      final patient = _makePatient(gender: 'M');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('*M~'));
    });

    test('gender FEMALE → F', () {
      final patient = _makePatient(gender: 'FEMALE');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('*F~'));
    });

    test('gender null → F (default)', () {
      final patient = _makePatient(gender: null);
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('*F~'));
    });

    test('gender lowercase male → F (case-sensitive uppercase check)', () {
      final patient = _makePatient(gender: 'male');
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      // toUpperCase() is called, so 'male' becomes 'MALE' → M
      expect(edi, contains('*M~'));
    });

    // ── notes branch (segment count) ──

    test('empty notes → segment count 30, no NTE segment', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('SE*30*0001'));
      expect(edi, isNot(contains('NTE*ADD')));
    });

    test('non-empty notes → segment count 31 and NTE segment present', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: 'Patient was cooperative',
      );
      expect(edi, contains('SE*31*0001'));
      expect(edi, contains('NTE*ADD*Patient was cooperative'));
    });

    test('notes with tilde (~) are sanitized in NTE segment', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: 'note~with~tildes',
      );
      expect(edi, contains('NTE*ADD*notewithtildes'));
    });

    // ── address branches ──

    test('uses patient address when provided', () {
      final patient = _makePatient(
        address: Address(
          line1: '456 Oak Ave',
          city: 'Springfield',
          state: 'IL',
          zip: '62701',
        ),
      );
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('N3*456 Oak Ave'));
      expect(edi, contains('N4*Springfield*IL*62701'));
    });

    test('uses default address when patient address is null', () {
      final patient = _makePatient(address: null);
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('N3*123 Main St'));
      expect(edi, contains('N4*Richmond*VA*23220'));
    });

    // ── duration / charge calculation ──

    test('duration 30 → 2 units, charge 60.00', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 30,
        notes: '',
      );
      expect(edi, contains('*60.00*'));
      expect(edi, contains('*UN*2*'));
    });

    test('duration 45 → 3 units, charge 90.00', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 45,
        notes: '',
      );
      expect(edi, contains('*90.00*'));
      expect(edi, contains('*UN*3*'));
    });

    // ── service date ──

    test('service date is derived from checkinTime', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: DateTime(2025, 1, 5, 8, 0),
        checkoutTime: DateTime(2025, 1, 5, 9, 0),
        duration: 60,
        notes: '',
      );
      expect(edi, contains('20250105'));
    });

    // ── optional location params (accepted but not output in EDI) ──

    test('accepts optional location parameters without error', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
        checkinLatitude: 37.5407,
        checkinLongitude: -77.4360,
        checkoutLatitude: 37.5408,
        checkoutLongitude: -77.4361,
        checkinLocationType: 'Home',
        checkoutLocationType: 'Home',
      );
      expect(EdiService.validateEDIContent(edi), isTrue);
    });

    // ── ISA / GS / control segments ──

    test('contains required EDI envelope segments', () {
      final patient = _makePatient();
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('ISA*00'));
      expect(edi, contains('GS*HC'));
      expect(edi, contains('ST*837'));
      expect(edi, contains('BHT*0019'));
      expect(edi, contains('GE*1'));
      expect(edi, contains('IEA*1'));
    });

    // ── claim and EVV identifiers ──

    test('contains EVV reference with patient id', () {
      final patient = _makePatient(id: 7);
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      expect(edi, contains('REF*F8*EVV-'));
    });

    // ── address with partial null fields ──

    test('uses defaults for null address sub-fields', () {
      final patient = _makePatient(
        address: Address(line1: null, city: null, state: null, zip: null),
      );
      final edi = EdiService.generateEDIContent(
        patient: patient,
        serviceType: 'Personal Care',
        checkinTime: checkinTime,
        checkoutTime: checkoutTime,
        duration: 60,
        notes: '',
      );
      // When address exists but fields are null, fallback defaults apply
      expect(edi, contains('N3*123 Main St'));
      expect(edi, contains('N4*Richmond*VA*23220'));
    });
  });

  // ─── validateEDIContent ──────────────────────────────────────────────────

  group('EdiService.validateEDIContent', () {
    test('empty string returns false', () {
      expect(EdiService.validateEDIContent(''), isFalse);
    });

    test('missing ISA segment returns false', () {
      const content = 'GS*HC~\nST*837~\nBHT~\nSE~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing GS segment returns false', () {
      const content = 'ISA~\nST*837~\nBHT~\nSE~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing ST segment returns false', () {
      const content = 'ISA~\nGS~\nBHT~\nSE~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing BHT segment returns false', () {
      const content = 'ISA~\nGS~\nST~\nSE~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing SE segment returns false', () {
      const content = 'ISA~\nGS~\nST~\nBHT~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing GE segment returns false', () {
      const content = 'ISA~\nGS~\nST~\nBHT~\nSE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('missing IEA segment returns false', () {
      const content = 'ISA~\nGS~\nST~\nBHT~\nSE~\nGE~';
      expect(EdiService.validateEDIContent(content), isFalse);
    });

    test('all required segments present returns true', () {
      const content = 'ISA~\nGS~\nST~\nBHT~\nSE~\nGE~\nIEA~';
      expect(EdiService.validateEDIContent(content), isTrue);
    });
  });

  // ─── parseServiceTypeToCode ──────────────────────────────────────────────

  group('EdiService.parseServiceTypeToCode', () {
    test('Personal Care → T1019', () {
      expect(EdiService.parseServiceTypeToCode('Personal Care'), 'T1019');
    });

    test('Companion Care → S5125', () {
      expect(EdiService.parseServiceTypeToCode('Companion Care'), 'S5125');
    });

    test('Respite Care → T1005', () {
      expect(EdiService.parseServiceTypeToCode('Respite Care'), 'T1005');
    });

    test('Homemaker Services → S5130', () {
      expect(EdiService.parseServiceTypeToCode('Homemaker Services'), 'S5130');
    });

    test('Skilled Nursing → 99601', () {
      expect(EdiService.parseServiceTypeToCode('Skilled Nursing'), '99601');
    });

    test('Physical Therapy → 97110', () {
      expect(EdiService.parseServiceTypeToCode('Physical Therapy'), '97110');
    });

    test('Occupational Therapy → 97530', () {
      expect(EdiService.parseServiceTypeToCode('Occupational Therapy'), '97530');
    });

    test('Speech Therapy → 92507', () {
      expect(EdiService.parseServiceTypeToCode('Speech Therapy'), '92507');
    });

    test('Medical Social Work → G0155', () {
      expect(EdiService.parseServiceTypeToCode('Medical Social Work'), 'G0155');
    });

    test('Home Health Aide → G0156', () {
      expect(EdiService.parseServiceTypeToCode('Home Health Aide'), 'G0156');
    });

    test('unknown service type → T1019 default', () {
      expect(EdiService.parseServiceTypeToCode('Unknown'), 'T1019');
    });
  });

  // ─── calculateBillableUnits ──────────────────────────────────────────────

  group('EdiService.calculateBillableUnits', () {
    test('900 s (exactly 1 unit) → 1', () {
      expect(EdiService.calculateBillableUnits(900), 1);
    });

    test('1800 s (exactly 2 units) → 2', () {
      expect(EdiService.calculateBillableUnits(1800), 2);
    });

    test('901 s (just over 1 unit) → 2 (ceiling)', () {
      expect(EdiService.calculateBillableUnits(901), 2);
    });

    test('3600 s (4 units) → 4', () {
      expect(EdiService.calculateBillableUnits(3600), 4);
    });

    test('1 s → 1 (ceiling of tiny value)', () {
      expect(EdiService.calculateBillableUnits(1), 1);
    });
  });

  // ─── calculateTotalCharge ────────────────────────────────────────────────

  group('EdiService.calculateTotalCharge', () {
    test('900 s with default rate (30.0) → 30.0', () {
      expect(EdiService.calculateTotalCharge(900), 30.0);
    });

    test('1800 s with default rate → 60.0', () {
      expect(EdiService.calculateTotalCharge(1800), 60.0);
    });

    test('1800 s with custom rate 50.0 → 100.0', () {
      expect(EdiService.calculateTotalCharge(1800, ratePerUnit: 50.0), 100.0);
    });

    test('901 s with default rate → 60.0 (ceiling 2 units)', () {
      expect(EdiService.calculateTotalCharge(901), 60.0);
    });
  });

  // ─── formatMANumber ──────────────────────────────────────────────────────

  group('EdiService.formatMANumber', () {
    test('existing MA number is returned unchanged', () {
      expect(EdiService.formatMANumber(42, 'MA123'), 'MA123');
    });

    test('null MA number → generated from patientId', () {
      final result = EdiService.formatMANumber(7, null);
      expect(result, 'MA000000007');
    });

    test('empty MA number → generated from patientId', () {
      final result = EdiService.formatMANumber(99, '');
      expect(result, 'MA000000099');
    });
  });

  // ─── generateControlNumber ───────────────────────────────────────────────

  group('EdiService.generateControlNumber', () {
    test('returns a 9-character numeric string', () {
      final cn = EdiService.generateControlNumber();
      expect(cn.length, 9);
      expect(int.tryParse(cn), isNotNull);
    });
  });

  // ─── formatEDIDate ───────────────────────────────────────────────────────

  group('EdiService.formatEDIDate', () {
    test('2025-01-05 → 20250105 (zero-padded month and day)', () {
      final d = DateTime(2025, 1, 5);
      expect(EdiService.formatEDIDate(d), '20250105');
    });

    test('2024-12-31 → 20241231', () {
      final d = DateTime(2024, 12, 31);
      expect(EdiService.formatEDIDate(d), '20241231');
    });
  });

  // ─── formatEDITime ───────────────────────────────────────────────────────

  group('EdiService.formatEDITime', () {
    test('09:05 → 0905 (zero-padded)', () {
      final t = DateTime(2024, 1, 1, 9, 5);
      expect(EdiService.formatEDITime(t), '0905');
    });

    test('14:30 → 1430', () {
      final t = DateTime(2024, 1, 1, 14, 30);
      expect(EdiService.formatEDITime(t), '1430');
    });

    test('00:00 → 0000', () {
      final t = DateTime(2024, 1, 1, 0, 0);
      expect(EdiService.formatEDITime(t), '0000');
    });
  });

  // ─── formatISADate ───────────────────────────────────────────────────────

  group('EdiService.formatISADate', () {
    test('2025-01-05 → 250105 (YYMMDD)', () {
      final d = DateTime(2025, 1, 5);
      expect(EdiService.formatISADate(d), '250105');
    });

    test('2024-12-31 → 241231', () {
      final d = DateTime(2024, 12, 31);
      expect(EdiService.formatISADate(d), '241231');
    });
  });

  // ─── sanitizeNotes ───────────────────────────────────────────────────────

  group('EdiService.sanitizeNotes', () {
    test('removes ~ characters', () {
      expect(EdiService.sanitizeNotes('hello~world'), 'helloworld');
    });

    test('removes * characters', () {
      expect(EdiService.sanitizeNotes('a*b'), 'ab');
    });

    test('removes : characters', () {
      expect(EdiService.sanitizeNotes('x:y'), 'xy');
    });

    test('removes all special characters', () {
      expect(EdiService.sanitizeNotes('a~b*c:d'), 'abcd');
    });

    test('plain string is unchanged', () {
      expect(EdiService.sanitizeNotes('plain text'), 'plain text');
    });

    test('empty string returns empty', () {
      expect(EdiService.sanitizeNotes(''), '');
    });
  });

  // ─── generateMockEdi837 ──────────────────────────────────────────────────

  group('EdiService.generateMockEdi837', () {
    test('default params produces valid EDI content', () {
      final edi = EdiService.generateMockEdi837();
      expect(EdiService.validateEDIContent(edi), isTrue);
    });

    test('default params use John Doe', () {
      final edi = EdiService.generateMockEdi837();
      expect(edi, contains('Doe'));
      expect(edi, contains('John'));
    });

    test('custom patient name appears in output', () {
      final edi = EdiService.generateMockEdi837(
        patientFirstName: 'Alice',
        patientLastName: 'Smith',
      );
      expect(edi, contains('Alice'));
      expect(edi, contains('Smith'));
    });

    test('custom MA number appears in output', () {
      final edi = EdiService.generateMockEdi837(maNumber: 'MATEST99');
      expect(edi, contains('MATEST99'));
    });

    test('custom service type code appears in output', () {
      final edi = EdiService.generateMockEdi837(serviceType: 'Skilled Nursing');
      expect(edi, contains('99601'));
    });

    test('custom charge amount appears in output', () {
      final edi = EdiService.generateMockEdi837(chargeAmount: 250.50);
      expect(edi, contains('250.50'));
    });

    test('custom service units appears in output', () {
      final edi = EdiService.generateMockEdi837(serviceUnits: 8);
      expect(edi, contains('*8*'));
    });

    test('custom provider name appears in output', () {
      final edi = EdiService.generateMockEdi837(providerName: 'Test Agency');
      expect(edi, contains('Test Agency'));
    });

    test('custom provider NPI appears in output', () {
      final edi = EdiService.generateMockEdi837(providerNPI: '9999999999');
      expect(edi, contains('9999999999'));
    });

    test('custom service date is formatted in output', () {
      final edi = EdiService.generateMockEdi837(
        serviceDate: DateTime(2025, 7, 4),
      );
      expect(edi, contains('20250704'));
    });

    test('contains SE*30 segment count', () {
      final edi = EdiService.generateMockEdi837();
      expect(edi, contains('SE*30*0001'));
    });
  });

  // ─── generateMockEdiWithDetails ──────────────────────────────────────────

  group('EdiService.generateMockEdiWithDetails', () {
    test('produces valid EDI content with custom parameters', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '42',
        patientFirstName: 'Bob',
        patientLastName: 'Jones',
        serviceType: 'Personal Care',
        serviceDate: DateTime(2025, 6, 15),
        durationMinutes: 60,
      );
      expect(EdiService.validateEDIContent(edi), isTrue);
      expect(edi, contains('Bob'));
      expect(edi, contains('Jones'));
    });

    test('provided MA number is used instead of generated one', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '1',
        patientFirstName: 'X',
        patientLastName: 'Y',
        serviceType: 'Personal Care',
        serviceDate: DateTime(2025, 1, 1),
        durationMinutes: 30,
        maNumber: 'CUSTOM-MA',
      );
      expect(edi, contains('CUSTOM-MA'));
    });

    test('null MA number generates from patientId', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '5',
        patientFirstName: 'A',
        patientLastName: 'B',
        serviceType: 'Personal Care',
        serviceDate: DateTime(2025, 1, 1),
        durationMinutes: 15,
      );
      expect(edi, contains('MA000000005'));
    });

    test('duration 45 min → 3 units, charge 90', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '1',
        patientFirstName: 'A',
        patientLastName: 'B',
        serviceType: 'Personal Care',
        serviceDate: DateTime(2025, 1, 1),
        durationMinutes: 45,
      );
      expect(edi, contains('90.00'));
      expect(edi, contains('*3*'));
    });

    test('notes parameter is accepted', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '1',
        patientFirstName: 'A',
        patientLastName: 'B',
        serviceType: 'Personal Care',
        serviceDate: DateTime(2025, 1, 1),
        durationMinutes: 30,
        notes: 'Some notes here',
      );
      // notes are not directly included in generateMockEdiWithDetails output
      // (it delegates to generateMockEdi837 which doesn't accept notes)
      expect(EdiService.validateEDIContent(edi), isTrue);
    });

    test('service type Respite Care uses code T1005', () {
      final edi = EdiService.generateMockEdiWithDetails(
        patientId: '1',
        patientFirstName: 'A',
        patientLastName: 'B',
        serviceType: 'Respite Care',
        serviceDate: DateTime(2025, 1, 1),
        durationMinutes: 30,
      );
      expect(edi, contains('T1005'));
    });
  });
}
