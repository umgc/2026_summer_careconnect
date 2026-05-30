// Tests for USPS domain models:
//   ActionLinks, MailPiece, PackageItem, USPSDigest
// (lib/features/usps/domain/models/)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/action_links.dart';
import 'package:care_connect_app/features/usps/domain/models/mail_piece.dart';
import 'package:care_connect_app/features/usps/domain/models/package_item.dart';
import 'package:care_connect_app/features/usps/domain/models/usps_digest.dart';

void main() {
  group('ActionLinks', () {
    test('all fields optional / default null', () {
      const a = ActionLinks();
      expect(a.track, isNull);
      expect(a.redelivery, isNull);
      expect(a.dashboard, isNull);
    });

    test('stores provided values', () {
      const a = ActionLinks(
        track: 'https://track.example.com',
        redelivery: 'https://redeliver.example.com',
        dashboard: 'https://dash.example.com',
      );
      expect(a.track, 'https://track.example.com');
      expect(a.redelivery, 'https://redeliver.example.com');
      expect(a.dashboard, 'https://dash.example.com');
    });
  });

  group('MailPiece', () {
    test('stores required id and actions', () {
      const mp = MailPiece(id: 'mp-1', actions: ActionLinks());
      expect(mp.id, 'mp-1');
      expect(mp.sender, isNull);
      expect(mp.summary, isNull);
    });

    test('stores optional fields', () {
      const mp = MailPiece(
        id: 'mp-2',
        sender: 'USPS',
        summary: 'You have mail',
        imageDataUrl: 'data:image/png;base64,abc',
        dateIso: '2025-12-01',
        actions: ActionLinks(track: 'https://t.usps.com'),
      );
      expect(mp.sender, 'USPS');
      expect(mp.summary, 'You have mail');
      expect(mp.dateIso, '2025-12-01');
      expect(mp.actions.track, 'https://t.usps.com');
    });
  });

  group('PackageItem', () {
    test('stores required trackingNumber and actions', () {
      const pkg = PackageItem(
        trackingNumber: '9400111899223456789012',
        actions: ActionLinks(),
      );
      expect(pkg.trackingNumber, '9400111899223456789012');
      expect(pkg.sender, isNull);
      expect(pkg.expectedDateIso, isNull);
    });

    test('stores optional sender and expectedDateIso', () {
      const pkg = PackageItem(
        trackingNumber: '9400111899223456789013',
        sender: 'Amazon',
        expectedDateIso: '2025-12-24',
        actions: ActionLinks(track: 'https://track.usps.com/pkg'),
      );
      expect(pkg.sender, 'Amazon');
      expect(pkg.expectedDateIso, '2025-12-24');
    });
  });

  group('USPSDigest', () {
    test('empty digest', () {
      const digest = USPSDigest(mailpieces: [], packages: []);
      expect(digest.digestDateIso, isNull);
      expect(digest.mailpieces, isEmpty);
      expect(digest.packages, isEmpty);
    });

    test('stores date and lists', () {
      const digest = USPSDigest(
        digestDateIso: '2025-12-01',
        mailpieces: [MailPiece(id: 'mp-1', actions: ActionLinks())],
        packages: [
          PackageItem(trackingNumber: 'track-1', actions: ActionLinks()),
        ],
      );
      expect(digest.digestDateIso, '2025-12-01');
      expect(digest.mailpieces.length, 1);
      expect(digest.packages.length, 1);
      expect(digest.mailpieces.first.id, 'mp-1');
      expect(digest.packages.first.trackingNumber, 'track-1');
    });
  });
}
