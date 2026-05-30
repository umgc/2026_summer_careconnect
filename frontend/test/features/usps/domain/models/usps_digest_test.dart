// Comprehensive tests for USPSDigest model.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/action_links.dart';
import 'package:care_connect_app/features/usps/domain/models/mail_piece.dart';
import 'package:care_connect_app/features/usps/domain/models/package_item.dart';
import 'package:care_connect_app/features/usps/domain/models/usps_digest.dart';

void main() {
  group('USPSDigest', () {
    test('constructor with empty lists and no date', () {
      const digest = USPSDigest(mailpieces: [], packages: []);
      expect(digest.digestDateIso, isNull);
      expect(digest.mailpieces, isEmpty);
      expect(digest.packages, isEmpty);
    });

    test('constructor with all fields populated', () {
      const actions = ActionLinks(track: 'https://track.usps.com');
      const mail1 = MailPiece(id: 'M1', sender: 'Bank', actions: actions);
      const mail2 = MailPiece(id: 'M2', sender: 'IRS', actions: actions);
      const pkg1 = PackageItem(
        trackingNumber: 'T1',
        sender: 'Amazon',
        actions: actions,
      );
      const digest = USPSDigest(
        digestDateIso: '2026-03-14',
        mailpieces: [mail1, mail2],
        packages: [pkg1],
      );
      expect(digest.digestDateIso, '2026-03-14');
      expect(digest.mailpieces.length, 2);
      expect(digest.packages.length, 1);
      expect(digest.mailpieces[0].id, 'M1');
      expect(digest.mailpieces[1].id, 'M2');
      expect(digest.packages[0].trackingNumber, 'T1');
    });

    test('mailpieces list preserves order', () {
      const actions = ActionLinks();
      const digest = USPSDigest(
        mailpieces: [
          MailPiece(id: 'first', actions: actions),
          MailPiece(id: 'second', actions: actions),
          MailPiece(id: 'third', actions: actions),
        ],
        packages: [],
      );
      expect(digest.mailpieces[0].id, 'first');
      expect(digest.mailpieces[1].id, 'second');
      expect(digest.mailpieces[2].id, 'third');
    });

    test('packages list preserves order', () {
      const actions = ActionLinks();
      const digest = USPSDigest(
        mailpieces: [],
        packages: [
          PackageItem(trackingNumber: 'PKG-A', actions: actions),
          PackageItem(trackingNumber: 'PKG-B', actions: actions),
          PackageItem(trackingNumber: 'PKG-C', actions: actions),
        ],
      );
      expect(digest.packages[0].trackingNumber, 'PKG-A');
      expect(digest.packages[1].trackingNumber, 'PKG-B');
      expect(digest.packages[2].trackingNumber, 'PKG-C');
    });

    test('digest with mailpieces but no packages', () {
      const actions = ActionLinks();
      const digest = USPSDigest(
        digestDateIso: '2026-01-01',
        mailpieces: [MailPiece(id: 'only-mail', actions: actions)],
        packages: [],
      );
      expect(digest.mailpieces.length, 1);
      expect(digest.packages, isEmpty);
    });

    test('digest with packages but no mailpieces', () {
      const actions = ActionLinks();
      const digest = USPSDigest(
        digestDateIso: '2026-01-01',
        mailpieces: [],
        packages: [PackageItem(trackingNumber: 'only-pkg', actions: actions)],
      );
      expect(digest.mailpieces, isEmpty);
      expect(digest.packages.length, 1);
    });

    test('can be used as const', () {
      const a = USPSDigest(mailpieces: [], packages: []);
      const b = USPSDigest(mailpieces: [], packages: []);
      expect(identical(a, b), isTrue);
    });

    test('non-const digest with mutable lists', () {
      final mailpieces = <MailPiece>[
        const MailPiece(id: 'm1', actions: ActionLinks()),
      ];
      final packages = <PackageItem>[
        const PackageItem(trackingNumber: 'p1', actions: ActionLinks()),
      ];
      final digest = USPSDigest(
        digestDateIso: '2026-06-01',
        mailpieces: mailpieces,
        packages: packages,
      );
      expect(digest.mailpieces.length, 1);
      expect(digest.packages.length, 1);
      expect(digest.digestDateIso, '2026-06-01');
    });

    test('digestDateIso accepts full ISO datetime', () {
      const digest = USPSDigest(
        digestDateIso: '2026-03-14T15:30:00.000Z',
        mailpieces: [],
        packages: [],
      );
      expect(digest.digestDateIso, contains('T15:30:00'));
    });

    test('mailpieces with full data are accessible through digest', () {
      const actions = ActionLinks(
        track: 'https://track.usps.com',
        redelivery: 'https://redelivery.usps.com',
        dashboard: 'https://dashboard.usps.com',
      );
      const piece = MailPiece(
        id: 'full-piece',
        sender: 'Netflix',
        summary: 'Monthly statement',
        imageDataUrl: 'data:image/png;base64,abc',
        dateIso: '2026-03-10',
        actions: actions,
      );
      const digest = USPSDigest(
        digestDateIso: '2026-03-14',
        mailpieces: [piece],
        packages: [],
      );
      final mp = digest.mailpieces.first;
      expect(mp.id, 'full-piece');
      expect(mp.sender, 'Netflix');
      expect(mp.summary, 'Monthly statement');
      expect(mp.imageDataUrl, isNotNull);
      expect(mp.dateIso, '2026-03-10');
      expect(mp.actions.track, isNotNull);
    });
  });
}
