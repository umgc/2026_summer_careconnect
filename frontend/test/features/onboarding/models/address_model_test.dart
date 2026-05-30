// Tests for Address model (lib/features/onboarding/models/address_model.dart).
// Pure-Dart data class with fromJson and toJson.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/onboarding/models/address_model.dart';

void main() {
  group('Address.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path where every JSON key is present.
      final address = Address.fromJson({
        'line1': '123 Main St',
        'line2': 'Apt 4B',
        'city': 'Springfield',
        'state': 'IL',
        'zip': '62701',
        'phone': '5551234567',
      });

      expect(address.line1, '123 Main St');
      expect(address.line2, 'Apt 4B');
      expect(address.city, 'Springfield');
      expect(address.state, 'IL');
      expect(address.zip, '62701');
      expect(address.phone, '5551234567');
    });

    test('optional line2 is null when absent', () {
      // Verifies that missing line2 key produces null.
      final address = Address.fromJson({
        'line1': '456 Oak Ave',
        'city': 'Chicago',
        'state': 'IL',
        'zip': '60601',
        'phone': '5559876543',
      });
      expect(address.line2, isNull);
    });

    test('required fields default to empty string when absent', () {
      // Verifies the ?? '' fallback for missing required string keys.
      final address = Address.fromJson({});
      expect(address.line1, '');
      expect(address.city, '');
      expect(address.state, '');
      expect(address.zip, '');
      expect(address.phone, '');
    });
  });

  group('Address.toJson', () {
    test('includes all fields when fully populated', () {
      // Verifies that all non-null fields appear in the serialized map.
      final address = Address(
        line1: '123 Main St',
        line2: 'Suite 5',
        city: 'Springfield',
        state: 'IL',
        zip: '62701',
        phone: '5551234567',
      );
      final json = address.toJson();

      expect(json['line1'], '123 Main St');
      expect(json['line2'], 'Suite 5');
      expect(json['city'], 'Springfield');
      expect(json['state'], 'IL');
      expect(json['zip'], '62701');
      expect(json['phone'], '5551234567');
    });

    test('excludes line2 when it is null', () {
      // Verifies that a null line2 is not included in the map.
      final address = Address(
        line1: '789 Elm St',
        city: 'Peoria',
        state: 'IL',
        zip: '61602',
        phone: '5550001111',
      );
      final json = address.toJson();
      expect(json.containsKey('line2'), isFalse);
    });

    test('excludes line2 when it is empty string', () {
      // Verifies the isNotEmpty guard: empty line2 is excluded.
      final address = Address(
        line1: '789 Elm St',
        line2: '',
        city: 'Peoria',
        state: 'IL',
        zip: '61602',
        phone: '5550001111',
      );
      final json = address.toJson();
      expect(json.containsKey('line2'), isFalse);
    });

    test('round-trips correctly via fromJson', () {
      // Verifies that toJson output can be re-parsed by fromJson.
      final original = Address(
        line1: '1 Test Blvd',
        line2: 'Floor 3',
        city: 'Rockford',
        state: 'IL',
        zip: '61101',
        phone: '8155551234',
      );
      final restored = Address.fromJson(original.toJson());

      expect(restored.line1, original.line1);
      expect(restored.line2, original.line2);
      expect(restored.city, original.city);
      expect(restored.state, original.state);
      expect(restored.zip, original.zip);
      expect(restored.phone, original.phone);
    });
  });
}
