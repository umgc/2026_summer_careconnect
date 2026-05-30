// Tests for digest_fixtures.dart helper (lib/features/usps/data/providers/digest_fixtures.dart).
// buildSimpleDigest is a test-helper factory; these tests verify its output structure.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/data/providers/digest_fixtures.dart';

void main() {
  group('buildSimpleDigest', () {
    test('returns a DigestRaw with non-empty html', () {
      final raw = buildSimpleDigest();
      expect(raw.html, isNotEmpty);
    });

    test('default title appears in html', () {
      final raw = buildSimpleDigest();
      expect(
        raw.html.contains('USPS Informed Delivery'),
        isTrue,
      );
    });

    test('custom title appears in html', () {
      final raw = buildSimpleDigest(title: 'My Custom Digest');
      expect(raw.html.contains('My Custom Digest'), isTrue);
    });

    test('imageCount 0 produces no cid entries', () {
      final raw = buildSimpleDigest(imageCount: 0);
      expect(raw.cids, isEmpty);
    });

    test('imageCount 1 produces one cid entry (default)', () {
      final raw = buildSimpleDigest();
      expect(raw.cids.length, 1);
    });

    test('imageCount 3 produces three cid entries', () {
      final raw = buildSimpleDigest(imageCount: 3);
      expect(raw.cids.length, 3);
    });

    test('cid values are non-empty byte lists', () {
      final raw = buildSimpleDigest(imageCount: 2);
      for (final bytes in raw.cids.values) {
        expect(bytes, isNotEmpty);
      }
    });

    test('uses provided receivedAt', () {
      final dt = DateTime(2025, 3, 15, 9, 30);
      final raw = buildSimpleDigest(receivedAt: dt);
      expect(raw.receivedAt, dt);
    });

    test('receivedAt defaults to a non-null DateTime when omitted', () {
      final raw = buildSimpleDigest();
      expect(raw.receivedAt, isNotNull);
    });
  });
}
