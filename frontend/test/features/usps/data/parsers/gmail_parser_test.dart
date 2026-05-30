// Tests for GmailParser (lib/features/usps/data/parsers/gmail_parser.dart).
//
// NOTE: GmailParser.toDomain uses non-standard CSS pseudo-selectors
// (*:matchesOwn(...), :has(...)) that the dart `html` package's querySelector
// does not support. Calling toDomain() always throws a FormatException in the
// pure-Dart/mobile environment. Those integration paths require a browser DOM
// (i.e. universal_html on web) and cannot be unit-tested here.
//
// This file tests only the GmailRaw data class which can be constructed freely.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/data/parsers/gmail_parser.dart';

void main() {
  group('GmailRaw constructor', () {
    test('stores html, cidMap, and receivedAtUtc', () {
      final dt = DateTime(2025, 6, 1);
      final raw = GmailRaw('<html/>', {'cid1': 'data:image/png;base64,abc'}, dt);
      expect(raw.html, '<html/>');
      expect(raw.cidMap['cid1'], 'data:image/png;base64,abc');
      expect(raw.receivedAtUtc, dt);
    });

    test('receivedAtUtc may be null', () {
      final raw = GmailRaw('<html/>', {}, null);
      expect(raw.receivedAtUtc, isNull);
    });

    test('empty cidMap is valid', () {
      final raw = GmailRaw('<p>text</p>', {}, null);
      expect(raw.cidMap, isEmpty);
    });

    test('multiple cid entries are stored', () {
      final raw = GmailRaw(
        '<html/>',
        {'a': 'data:img/a', 'b': 'data:img/b'},
        null,
      );
      expect(raw.cidMap.length, 2);
      expect(raw.cidMap['b'], 'data:img/b');
    });
  });

  group('GmailParser.toDomain (FormatException from unsupported selectors)', () {
    final parser = GmailParser();

    test('throws FormatException for any HTML input', () {
      // The html package does not support *:matchesOwn() or :has() pseudo-selectors
      // used in GmailParser. This documents the known limitation.
      expect(
        () => parser.toDomain(GmailRaw('<html><body></body></html>', {}, null)),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
