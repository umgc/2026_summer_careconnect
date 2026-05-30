// Tests for DigestRaw (lib/features/usps/domain/models/digest_raw.dart).
// Minimal data class — constructor and field access only.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/digest_raw.dart';

void main() {
  group('DigestRaw constructor', () {
    test('stores html, cids, and receivedAt', () {
      final received = DateTime(2025, 6, 1, 8, 0);
      final raw = DigestRaw(
        html: '<html><body>test</body></html>',
        cids: {'image001': [0x89, 0x50]},
        receivedAt: received,
      );
      expect(raw.html, '<html><body>test</body></html>');
      expect(raw.cids['image001'], [0x89, 0x50]);
      expect(raw.receivedAt, received);
    });

    test('empty cids map is valid', () {
      final raw = DigestRaw(
        html: '',
        cids: {},
        receivedAt: DateTime(2025),
      );
      expect(raw.cids, isEmpty);
      expect(raw.html, '');
    });

    test('stores multiple cid entries', () {
      final raw = DigestRaw(
        html: '<img />',
        cids: {
          'img1': [0x01, 0x02],
          'img2': [0x03, 0x04, 0x05],
        },
        receivedAt: DateTime(2025, 3, 15),
      );
      expect(raw.cids.length, 2);
      expect(raw.cids['img1'], [0x01, 0x02]);
      expect(raw.cids['img2']!.length, 3);
    });

    test('stores receivedAt date correctly', () {
      final date = DateTime(2025, 12, 25, 14, 30, 45);
      final raw = DigestRaw(html: '', cids: {}, receivedAt: date);
      expect(raw.receivedAt.year, 2025);
      expect(raw.receivedAt.month, 12);
      expect(raw.receivedAt.day, 25);
      expect(raw.receivedAt.hour, 14);
    });

    test('stores long html content', () {
      final longHtml = '<html>${'x' * 1000}</html>';
      final raw = DigestRaw(html: longHtml, cids: {}, receivedAt: DateTime(2025));
      expect(raw.html.length, greaterThan(1000));
      expect(raw.html, startsWith('<html>'));
      expect(raw.html, endsWith('</html>'));
    });

    test('cids with empty byte arrays', () {
      final raw = DigestRaw(
        html: 'test',
        cids: {'empty': []},
        receivedAt: DateTime(2025),
      );
      expect(raw.cids['empty'], isEmpty);
    });

    test('html can contain special characters', () {
      final raw = DigestRaw(
        html: '<p>&amp; &lt; &gt; "quotes"</p>',
        cids: {},
        receivedAt: DateTime(2025),
      );
      expect(raw.html, contains('&amp;'));
      expect(raw.html, contains('"quotes"'));
    });
  });
}
