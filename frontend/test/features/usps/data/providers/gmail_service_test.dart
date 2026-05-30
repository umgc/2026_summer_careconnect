// Tests for the GmailService abstract interface
// (lib/features/usps/data/providers/gmail_service.dart).
//
// GmailService is an abstract class that depends on OAuth/platform plugins at
// runtime.  These tests verify the interface contract and that concrete stubs
// can fulfill it, covering the type surface without requiring native plugins.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/data/providers/gmail_service.dart';
import 'package:care_connect_app/features/usps/data/parsers/gmail_parser.dart';

// ── concrete stubs ───────────────────────────────────────────────────────

class _NullGmailService extends GmailService {
  @override
  Future<GmailRaw?> fetchRaw() async => null;
}

class _FakeGmailService extends GmailService {
  final GmailRaw _raw;
  _FakeGmailService(this._raw);

  @override
  Future<GmailRaw?> fetchRaw() async => _raw;
}

class _ErrorGmailService extends GmailService {
  @override
  Future<GmailRaw?> fetchRaw() async => throw Exception('OAuth failed');
}

// ── tests ────────────────────────────────────────────────────────────────

void main() {
  group('GmailService interface', () {
    test('can be implemented by a concrete class', () {
      final service = _NullGmailService();
      expect(service, isA<GmailService>());
    });

    test('fetchRaw returns null when no email found', () async {
      final service = _NullGmailService();
      final result = await service.fetchRaw();
      expect(result, isNull);
    });

    test('fetchRaw returns GmailRaw with HTML content', () async {
      final raw = GmailRaw(
        '<html><body>Test digest</body></html>',
        {},
        DateTime.utc(2025, 6, 1),
      );
      final service = _FakeGmailService(raw);
      final result = await service.fetchRaw();
      expect(result, isNotNull);
      expect(result!.html, contains('Test digest'));
    });

    test('fetchRaw returns GmailRaw with cid map', () async {
      final raw = GmailRaw(
        '<html></html>',
        {'image001': 'data:image/png;base64,abc123'},
        DateTime.utc(2025, 6, 1),
      );
      final service = _FakeGmailService(raw);
      final result = await service.fetchRaw();
      expect(result, isNotNull);
      expect(result!.cidMap, hasLength(1));
      expect(result.cidMap['image001'], startsWith('data:image'));
    });

    test('fetchRaw returns GmailRaw with receivedAtUtc', () async {
      final dt = DateTime.utc(2025, 7, 4, 12, 30);
      final raw = GmailRaw('<html></html>', {}, dt);
      final service = _FakeGmailService(raw);
      final result = await service.fetchRaw();
      expect(result!.receivedAtUtc, dt);
    });

    test('fetchRaw returns GmailRaw with null receivedAtUtc', () async {
      final raw = GmailRaw('<html></html>', {}, null);
      final service = _FakeGmailService(raw);
      final result = await service.fetchRaw();
      expect(result!.receivedAtUtc, isNull);
    });

    test('fetchRaw propagates exceptions from implementation', () async {
      final service = _ErrorGmailService();
      expect(() => service.fetchRaw(), throwsException);
    });
  });

  group('GmailRaw', () {
    test('stores html string', () {
      final raw = GmailRaw('<html>Hello</html>', {}, null);
      expect(raw.html, '<html>Hello</html>');
    });

    test('stores empty cid map', () {
      final raw = GmailRaw('', {}, null);
      expect(raw.cidMap, isEmpty);
    });

    test('stores multiple cid entries', () {
      final raw = GmailRaw('', {
        'cid1': 'data:image/png;base64,a',
        'cid2': 'data:image/jpeg;base64,b',
      }, null);
      expect(raw.cidMap, hasLength(2));
    });

    test('stores receivedAtUtc', () {
      final dt = DateTime.utc(2025, 1, 15, 8, 0);
      final raw = GmailRaw('', {}, dt);
      expect(raw.receivedAtUtc, dt);
    });
  });
}
