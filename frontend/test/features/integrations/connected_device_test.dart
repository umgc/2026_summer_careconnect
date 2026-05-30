// Tests for ConnectedDevice model
// (lib/features/integrations/presentation/pages/add_devices_screen.dart).

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/integrations/presentation/pages/add_devices_screen.dart';

void main() {
  group('ConnectedDevice constructor', () {
    test('stores all required fields', () {
      final dt = DateTime(2025, 6, 1, 12, 0);
      final device = ConnectedDevice(
        id: 'd-1',
        platform: 'iOS',
        name: 'iPhone 15',
        connectedAt: dt,
        permissions: ['steps', 'heart_rate'],
      );
      expect(device.id, 'd-1');
      expect(device.platform, 'iOS');
      expect(device.name, 'iPhone 15');
      expect(device.connectedAt, dt);
      expect(device.permissions, containsAll(['steps', 'heart_rate']));
      expect(device.isActive, isTrue); // default
    });

    test('isActive defaults to true', () {
      final device = ConnectedDevice(
        id: 'd-2',
        platform: 'Android',
        name: 'Pixel 8',
        connectedAt: DateTime(2025, 7, 1),
        permissions: [],
      );
      expect(device.isActive, isTrue);
    });

    test('isActive can be set to false', () {
      final device = ConnectedDevice(
        id: 'd-3',
        platform: 'WearOS',
        name: 'Galaxy Watch',
        connectedAt: DateTime(2025, 8, 1),
        permissions: ['heart_rate'],
        isActive: false,
      );
      expect(device.isActive, isFalse);
    });
  });

  group('ConnectedDevice.toJson', () {
    test('serializes all fields', () {
      final dt = DateTime(2025, 9, 1, 10, 0);
      final device = ConnectedDevice(
        id: 'd-4',
        platform: 'iOS',
        name: 'Apple Watch',
        connectedAt: dt,
        permissions: ['steps', 'sleep'],
        isActive: true,
      );
      final json = device.toJson();
      expect(json['id'], 'd-4');
      expect(json['platform'], 'iOS');
      expect(json['name'], 'Apple Watch');
      expect(json['connectedAt'], dt.toIso8601String());
      expect(json['permissions'], ['steps', 'sleep']);
      expect(json['isActive'], isTrue);
    });
  });

  group('ConnectedDevice.fromJson', () {
    test('deserializes all fields', () {
      final dt = DateTime(2025, 10, 1);
      final device = ConnectedDevice.fromJson({
        'id': 'd-5',
        'platform': 'Android',
        'name': 'Fitbit',
        'connectedAt': dt.toIso8601String(),
        'permissions': ['steps'],
        'isActive': true,
      });
      expect(device.id, 'd-5');
      expect(device.platform, 'Android');
      expect(device.name, 'Fitbit');
      expect(device.isActive, isTrue);
    });

    test('isActive defaults to true when missing', () {
      final device = ConnectedDevice.fromJson({
        'id': 'd-6',
        'platform': 'iOS',
        'name': 'Watch',
        'connectedAt': DateTime(2025, 1, 1).toIso8601String(),
        'permissions': [],
      });
      expect(device.isActive, isTrue);
    });

    test('round-trips through toJson/fromJson', () {
      final original = ConnectedDevice(
        id: 'd-7',
        platform: 'WearOS',
        name: 'Galaxy Watch 6',
        connectedAt: DateTime(2025, 11, 15, 8, 30),
        permissions: ['heart_rate', 'spo2'],
        isActive: false,
      );
      final copy = ConnectedDevice.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.platform, original.platform);
      expect(copy.name, original.name);
      expect(copy.isActive, original.isActive);
      expect(copy.permissions, original.permissions);
    });
  });
}
