// Tests for the UspsDigestRepository abstract interface
// (lib/features/usps/domain/repositories/usps_digest_repository.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/repositories/usps_digest_repository.dart';
import 'package:care_connect_app/features/usps/domain/models/usps_digest.dart';

// ── concrete stub implementing the abstract class ────────────────────────

class _StubDigestRepository extends UspsDigestRepository {
  final USPSDigest? _digest;
  _StubDigestRepository([this._digest]);

  @override
  Future<USPSDigest?> latestDigest() async => _digest;

  @override
  Future<USPSDigest?> fromGmail() async => _digest;
}

// ── tests ────────────────────────────────────────────────────────────────

void main() {
  group('UspsDigestRepository interface', () {
    test('can be implemented by a concrete class', () {
      final repo = _StubDigestRepository();
      expect(repo, isA<UspsDigestRepository>());
    });

    test('latestDigest returns null when no digest available', () async {
      final repo = _StubDigestRepository(null);
      final result = await repo.latestDigest();
      expect(result, isNull);
    });

    test('latestDigest returns a digest when available', () async {
      const digest = USPSDigest(
        digestDateIso: '2025-06-01',
        mailpieces: [],
        packages: [],
      );
      final repo = _StubDigestRepository(digest);
      final result = await repo.latestDigest();
      expect(result, isNotNull);
      expect(result!.digestDateIso, '2025-06-01');
      expect(result.mailpieces, isEmpty);
      expect(result.packages, isEmpty);
    });

    test('fromGmail returns null when no digest available', () async {
      final repo = _StubDigestRepository(null);
      final result = await repo.fromGmail();
      expect(result, isNull);
    });

    test('fromGmail returns a digest when available', () async {
      const digest = USPSDigest(
        digestDateIso: '2025-12-25',
        mailpieces: [],
        packages: [],
      );
      final repo = _StubDigestRepository(digest);
      final result = await repo.fromGmail();
      expect(result, isNotNull);
      expect(result!.digestDateIso, '2025-12-25');
    });

    test('latestDigest and fromGmail return the same type', () async {
      const digest = USPSDigest(
        digestDateIso: '2025-01-01',
        mailpieces: [],
        packages: [],
      );
      final repo = _StubDigestRepository(digest);
      final a = await repo.latestDigest();
      final b = await repo.fromGmail();
      expect(a, isA<USPSDigest?>());
      expect(b, isA<USPSDigest?>());
    });
  });
}
