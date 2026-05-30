// Tests for Address model (lib/models/AddressModel.dart).
// Pure Dart class with constructor, toJson, and fromJson.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/AddressModel.dart';

void main() {
  group('Address constructor', () {
    test('stores required fields', () {
      final addr = Address(
        line1: '123 Main St',
        line2: 'Apt 4B',
        city: 'Springfield',
        state: 'IL',
        zip: '62701',
      );
      expect(addr.line1, '123 Main St');
      expect(addr.line2, 'Apt 4B');
      expect(addr.city, 'Springfield');
      expect(addr.state, 'IL');
      expect(addr.zip, '62701');
      expect(addr.phone, isNull);
    });

    test('stores optional phone', () {
      final addr = Address(
        line1: '1 Oak Ave',
        line2: '',
        city: 'Chicago',
        state: 'IL',
        zip: '60601',
        phone: '555-1234',
      );
      expect(addr.phone, '555-1234');
    });
  });

  group('Address.toJson', () {
    test('serializes all fields including null phone', () {
      final addr = Address(
        line1: '10 Elm St',
        line2: '',
        city: 'Rockford',
        state: 'IL',
        zip: '61101',
      );
      final json = addr.toJson();
      expect(json['line1'], '10 Elm St');
      expect(json['line2'], '');
      expect(json['city'], 'Rockford');
      expect(json['state'], 'IL');
      expect(json['zip'], '61101');
      expect(json['phone'], isNull);
    });

    test('serializes phone when present', () {
      final addr = Address(
        line1: '5 Pine Rd',
        line2: 'Suite 100',
        city: 'Peoria',
        state: 'IL',
        zip: '61602',
        phone: '800-555-0000',
      );
      expect(addr.toJson()['phone'], '800-555-0000');
    });
  });

  group('Address.fromJson', () {
    test('parses complete JSON', () {
      final addr = Address.fromJson({
        'line1': '99 Lakeview Dr',
        'line2': 'Unit 3',
        'city': 'Aurora',
        'state': 'IL',
        'zip': '60505',
        'phone': '555-9999',
      });
      expect(addr.line1, '99 Lakeview Dr');
      expect(addr.line2, 'Unit 3');
      expect(addr.city, 'Aurora');
      expect(addr.state, 'IL');
      expect(addr.zip, '60505');
      expect(addr.phone, '555-9999');
    });

    test('uses empty string defaults for missing fields', () {
      final addr = Address.fromJson({});
      expect(addr.line1, '');
      expect(addr.line2, '');
      expect(addr.city, '');
      expect(addr.state, '');
      expect(addr.zip, '');
      expect(addr.phone, isNull);
    });

    test('round-trips through toJson', () {
      final original = Address(
        line1: '42 Answer Ln',
        line2: '',
        city: 'Galesburg',
        state: 'IL',
        zip: '61401',
        phone: '309-555-0001',
      );
      final copy = Address.fromJson(original.toJson());
      expect(copy.line1, original.line1);
      expect(copy.city, original.city);
      expect(copy.zip, original.zip);
      expect(copy.phone, original.phone);
    });
  });
}
