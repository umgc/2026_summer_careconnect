// Tests for UspsDigestRepositoryImpl
// (lib/features/usps/data/usps_digest_repository_impl.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/data/usps_digest_repository_impl.dart';
import 'package:care_connect_app/features/usps/data/providers/gmail_service.dart';
import 'package:care_connect_app/features/usps/data/parsers/gmail_parser.dart';
import 'package:care_connect_app/features/usps/domain/models/usps_digest.dart';

// ── fakes ──────────────────────────────────────────────────────────────────

class _NullGmailService extends GmailService {
  @override
  Future<GmailRaw?> fetchRaw() async => null;
}

class _FakeGmailService extends GmailService {
  final GmailRaw raw;
  _FakeGmailService(this.raw);

  @override
  Future<GmailRaw?> fetchRaw() async => raw;
}

class _FakeGmailParser extends GmailParser {
  final USPSDigest digest;
  _FakeGmailParser(this.digest);

  @override
  USPSDigest toDomain(GmailRaw raw) => digest;
}

// ── tests ──────────────────────────────────────────────────────────────────

void main() {
  group('UspsDigestRepositoryImpl.fromGmail', () {
    test('returns null when GmailService returns null', () async {
      final repo = UspsDigestRepositoryImpl(
        gmail: _NullGmailService(),
        gParser: GmailParser(),
      );

      final result = await repo.fromGmail();
      expect(result, isNull);
    });

    test('returns parsed digest when GmailService returns raw data', () async {
      final fakeRaw = GmailRaw('<html></html>', {}, DateTime(2025, 6, 1));
      final expected = const USPSDigest(
        digestDateIso: '2025-06-01',
        mailpieces: [],
        packages: [],
      );

      final repo = UspsDigestRepositoryImpl(
        gmail: _FakeGmailService(fakeRaw),
        gParser: _FakeGmailParser(expected),
      );

      final result = await repo.fromGmail();
      expect(result, isNotNull);
      expect(result!.digestDateIso, '2025-06-01');
    });
  });

  group('UspsDigestRepositoryImpl.latestDigest', () {
    test('returns null when GmailService always returns null', () async {
      final repo = UspsDigestRepositoryImpl(
        gmail: _NullGmailService(),
        gParser: GmailParser(),
      );

      final result = await repo.latestDigest();
      expect(result, isNull);
    });

    test('returns parsed digest via latestDigest', () async {
      final fakeRaw = GmailRaw('<html></html>', {}, DateTime(2025, 7, 4));
      final expected = const USPSDigest(
        digestDateIso: '2025-07-04',
        mailpieces: [],
        packages: [],
      );

      final repo = UspsDigestRepositoryImpl(
        gmail: _FakeGmailService(fakeRaw),
        gParser: _FakeGmailParser(expected),
      );

      final result = await repo.latestDigest();
      expect(result, isNotNull);
      expect(result!.digestDateIso, '2025-07-04');
    });
  });

  group('UspsDigestRepositoryImpl constructor', () {
    test('accepts custom gmail and parser', () {
      final repo = UspsDigestRepositoryImpl(
        gmail: _NullGmailService(),
        gParser: GmailParser(),
      );
      expect(repo, isA<UspsDigestRepositoryImpl>());
    });
  });

  group('UspsDigestRepositoryImpl.fromGmail result fields', () {
    test('returns digest with empty mailpieces list', () async {
      final fakeRaw = GmailRaw('<html></html>', {}, DateTime(2025, 8, 1));
      final expected = const USPSDigest(
        digestDateIso: '2025-08-01',
        mailpieces: [],
        packages: [],
      );

      final repo = UspsDigestRepositoryImpl(
        gmail: _FakeGmailService(fakeRaw),
        gParser: _FakeGmailParser(expected),
      );

      final result = await repo.fromGmail();
      expect(result!.mailpieces, isEmpty);
      expect(result.packages, isEmpty);
    });
  });
}
