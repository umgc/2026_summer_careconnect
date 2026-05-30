// Comprehensive tests for PackageItem model.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/action_links.dart';
import 'package:care_connect_app/features/usps/domain/models/package_item.dart';

void main() {
  group('PackageItem', () {
    test('constructor with only required fields', () {
      const pkg = PackageItem(
        trackingNumber: '9400111899223456789012',
        actions: ActionLinks(),
      );
      expect(pkg.trackingNumber, '9400111899223456789012');
      expect(pkg.sender, isNull);
      expect(pkg.expectedDateIso, isNull);
      expect(pkg.actions.track, isNull);
    });

    test('constructor with all fields populated', () {
      const actions = ActionLinks(
        track: 'https://track.usps.com/9400',
        redelivery: 'https://redelivery.usps.com/9400',
        dashboard: 'https://dash.usps.com',
      );
      const pkg = PackageItem(
        trackingNumber: '9400111899223456789012',
        sender: 'Amazon Fulfillment',
        expectedDateIso: '2026-03-20',
        actions: actions,
      );
      expect(pkg.trackingNumber, '9400111899223456789012');
      expect(pkg.sender, 'Amazon Fulfillment');
      expect(pkg.expectedDateIso, '2026-03-20');
      expect(pkg.actions.track, 'https://track.usps.com/9400');
      expect(pkg.actions.redelivery, 'https://redelivery.usps.com/9400');
      expect(pkg.actions.dashboard, 'https://dash.usps.com');
    });

    test('trackingNumber can be empty string', () {
      const pkg = PackageItem(trackingNumber: '', actions: ActionLinks());
      expect(pkg.trackingNumber, '');
    });

    test('sender can be empty string', () {
      const pkg = PackageItem(
        trackingNumber: 'T1',
        sender: '',
        actions: ActionLinks(),
      );
      expect(pkg.sender, '');
    });

    test('expectedDateIso stores ISO-formatted date', () {
      const pkg = PackageItem(
        trackingNumber: 'T2',
        expectedDateIso: '2026-12-25T08:00:00Z',
        actions: ActionLinks(),
      );
      expect(pkg.expectedDateIso, contains('2026-12-25'));
    });

    test('can be used as const', () {
      const a = PackageItem(trackingNumber: 'X', actions: ActionLinks());
      const b = PackageItem(trackingNumber: 'X', actions: ActionLinks());
      expect(identical(a, b), isTrue);
    });

    test('different tracking numbers produce non-identical instances', () {
      const a = PackageItem(trackingNumber: 'A', actions: ActionLinks());
      const b = PackageItem(trackingNumber: 'B', actions: ActionLinks());
      expect(identical(a, b), isFalse);
    });

    test('sender with unicode characters', () {
      const pkg = PackageItem(
        trackingNumber: 'U1',
        sender: 'Muller GmbH',
        actions: ActionLinks(),
      );
      expect(pkg.sender, 'Muller GmbH');
    });

    test('actions with partial links', () {
      const pkg = PackageItem(
        trackingNumber: 'P1',
        actions: ActionLinks(track: 'https://track.usps.com/P1'),
      );
      expect(pkg.actions.track, isNotNull);
      expect(pkg.actions.redelivery, isNull);
      expect(pkg.actions.dashboard, isNull);
    });

    test('long tracking number is stored correctly', () {
      const longTracking = '94001118992234567890121234567890';
      const pkg = PackageItem(
        trackingNumber: longTracking,
        actions: ActionLinks(),
      );
      expect(pkg.trackingNumber, longTracking);
      expect(pkg.trackingNumber.length, 32);
    });
  });
}
