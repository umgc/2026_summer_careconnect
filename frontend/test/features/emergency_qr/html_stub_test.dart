// Tests for html_stub.dart
// (lib/features/emergency_qr/html_stub.dart).
//
// The stub classes throw UnsupportedError on non-web platforms.
// These tests verify that each method throws as documented,
// and that valid construction doesn't throw.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/emergency_qr/html_stub.dart';

void main() {
  group('Window', () {
    test('open throws UnsupportedError', () {
      // Verifies the stub throws UnsupportedError for web-only operations.
      expect(
        () => window.open('https://example.com', '_blank'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('Blob', () {
    test('can be constructed without throwing', () {
      // Verifies the Blob stub constructor does not throw.
      expect(() => Blob(['data']), returnsNormally);
    });
  });

  group('Url', () {
    test('createObjectUrlFromBlob throws UnsupportedError', () {
      // Verifies the URL creation stub throws on non-web.
      final blob = Blob(['data']);
      expect(
        () => Url.createObjectUrlFromBlob(blob),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('revokeObjectUrl throws UnsupportedError', () {
      // Verifies the URL revocation stub throws on non-web.
      expect(
        () => Url.revokeObjectUrl('blob:http://example.com/abc'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('AnchorElement', () {
    test('can be constructed without throwing', () {
      // Verifies the AnchorElement stub constructor does not throw.
      expect(() => AnchorElement(href: 'https://example.com'), returnsNormally);
      expect(() => AnchorElement(), returnsNormally);
    });

    test('setAttribute throws UnsupportedError', () {
      // Verifies the setAttribute stub throws on non-web.
      final anchor = AnchorElement();
      expect(
        () => anchor.setAttribute('download', 'file.pdf'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('click throws UnsupportedError', () {
      // Verifies the click stub throws on non-web.
      final anchor = AnchorElement();
      expect(
        () => anchor.click(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
