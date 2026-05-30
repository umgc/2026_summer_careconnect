// Comprehensive tests for ActionLinks model.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/usps/domain/models/action_links.dart';

void main() {
  group('ActionLinks', () {
    test('default constructor creates instance with all null fields', () {
      const links = ActionLinks();
      expect(links.track, isNull);
      expect(links.redelivery, isNull);
      expect(links.dashboard, isNull);
    });

    test('constructor with all fields populated', () {
      const links = ActionLinks(
        track: 'https://track.usps.com/123',
        redelivery: 'https://redelivery.usps.com/456',
        dashboard: 'https://dashboard.usps.com/home',
      );
      expect(links.track, 'https://track.usps.com/123');
      expect(links.redelivery, 'https://redelivery.usps.com/456');
      expect(links.dashboard, 'https://dashboard.usps.com/home');
    });

    test('constructor with only track set', () {
      const links = ActionLinks(track: 'https://track.usps.com');
      expect(links.track, 'https://track.usps.com');
      expect(links.redelivery, isNull);
      expect(links.dashboard, isNull);
    });

    test('constructor with only redelivery set', () {
      const links = ActionLinks(redelivery: 'https://redelivery.usps.com');
      expect(links.track, isNull);
      expect(links.redelivery, 'https://redelivery.usps.com');
      expect(links.dashboard, isNull);
    });

    test('constructor with only dashboard set', () {
      const links = ActionLinks(dashboard: 'https://dashboard.usps.com');
      expect(links.track, isNull);
      expect(links.redelivery, isNull);
      expect(links.dashboard, 'https://dashboard.usps.com');
    });

    test('fields accept empty strings', () {
      const links = ActionLinks(track: '', redelivery: '', dashboard: '');
      expect(links.track, '');
      expect(links.redelivery, '');
      expect(links.dashboard, '');
    });

    test('fields accept URLs with special characters', () {
      const links = ActionLinks(
        track: 'https://track.usps.com?id=123&type=mail',
        redelivery: 'https://redelivery.usps.com/path?q=hello%20world',
        dashboard: 'https://dashboard.usps.com#section',
      );
      expect(links.track, contains('&type=mail'));
      expect(links.redelivery, contains('%20'));
      expect(links.dashboard, contains('#section'));
    });

    test('can be used as const', () {
      const a = ActionLinks(track: 'a');
      const b = ActionLinks(track: 'a');
      expect(identical(a, b), isTrue);
    });

    test('two const instances with different values are not identical', () {
      const a = ActionLinks(track: 'a');
      const b = ActionLinks(track: 'b');
      expect(identical(a, b), isFalse);
    });

    test('fields accept very long URLs', () {
      final longUrl = 'https://example.com/${'a' * 2000}';
      final links = ActionLinks(track: longUrl);
      expect(links.track!.length, greaterThan(2000));
    });
  });
}
