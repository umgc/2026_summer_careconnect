// Tests for USPS domain models
// (lib/features/usps/domain/models/)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/action_links.dart';
import 'package:care_connect_app/features/usps/domain/models/mail_piece.dart';
import 'package:care_connect_app/features/usps/domain/models/package_item.dart';
import 'package:care_connect_app/features/usps/domain/models/usps_digest.dart';

void main() {
  group('ActionLinks', () {
    test('constructor stores all fields', () {
      const links = ActionLinks(
        track: 'https://track.usps.com',
        redelivery: 'https://redelivery.usps.com',
        dashboard: 'https://dashboard.usps.com',
      );
      expect(links.track, 'https://track.usps.com');
      expect(links.redelivery, 'https://redelivery.usps.com');
      expect(links.dashboard, 'https://dashboard.usps.com');
    });

    test('optional fields default to null', () {
      const links = ActionLinks();
      expect(links.track, isNull);
      expect(links.redelivery, isNull);
      expect(links.dashboard, isNull);
    });
  });

  group('MailPiece', () {
    test('constructor stores all fields', () {
      const actions = ActionLinks(track: 'https://track.usps.com');
      const piece = MailPiece(
        id: 'MP001',
        sender: 'Amazon',
        summary: 'Package arriving Tuesday',
        imageDataUrl: 'data:image/png;base64,abc',
        dateIso: '2024-06-15',
        actions: actions,
      );
      expect(piece.id, 'MP001');
      expect(piece.sender, 'Amazon');
      expect(piece.summary, 'Package arriving Tuesday');
      expect(piece.imageDataUrl, 'data:image/png;base64,abc');
      expect(piece.dateIso, '2024-06-15');
      expect(piece.actions.track, 'https://track.usps.com');
    });

    test('optional fields default to null', () {
      const piece = MailPiece(
        id: 'MP002',
        actions: ActionLinks(),
      );
      expect(piece.sender, isNull);
      expect(piece.summary, isNull);
      expect(piece.imageDataUrl, isNull);
      expect(piece.dateIso, isNull);
    });
  });

  group('PackageItem', () {
    test('constructor stores all fields', () {
      const actions = ActionLinks(track: 'https://track.usps.com/12345');
      const pkg = PackageItem(
        trackingNumber: '1Z999AA10123456784',
        sender: 'UPS Store',
        expectedDateIso: '2024-06-20',
        actions: actions,
      );
      expect(pkg.trackingNumber, '1Z999AA10123456784');
      expect(pkg.sender, 'UPS Store');
      expect(pkg.expectedDateIso, '2024-06-20');
      expect(pkg.actions.track, 'https://track.usps.com/12345');
    });

    test('optional fields default to null', () {
      const pkg = PackageItem(
        trackingNumber: '9400111899223397868690',
        actions: ActionLinks(),
      );
      expect(pkg.sender, isNull);
      expect(pkg.expectedDateIso, isNull);
    });
  });

  group('USPSDigest', () {
    test('constructor stores all fields', () {
      const actions = ActionLinks();
      const piece = MailPiece(id: 'M1', actions: actions);
      const pkg = PackageItem(trackingNumber: 'P1', actions: actions);
      const digest = USPSDigest(
        digestDateIso: '2024-06-15',
        mailpieces: [piece],
        packages: [pkg],
      );
      expect(digest.digestDateIso, '2024-06-15');
      expect(digest.mailpieces.length, 1);
      expect(digest.packages.length, 1);
    });

    test('digestDateIso defaults to null', () {
      const digest = USPSDigest(mailpieces: [], packages: []);
      expect(digest.digestDateIso, isNull);
      expect(digest.mailpieces, isEmpty);
      expect(digest.packages, isEmpty);
    });
  });
}
