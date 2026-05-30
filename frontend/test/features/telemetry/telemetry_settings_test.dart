// Tests for TelemetrySettings
// (lib/features/telemetry/telemetry_settings.dart).
//
// Uses SharedPreferences.setMockInitialValues so tests run without
// platform channels or a real device.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/telemetry/telemetry_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TelemetrySettings.isOptedOut', () {
    test('returns false by default', () async {
      // Verifies the default (no stored value) is not opted out.
      expect(await TelemetrySettings.isOptedOut(), isFalse);
    });

    test('returns true after setOptedOut(true)', () async {
      // Verifies that opting out persists correctly.
      await TelemetrySettings.setOptedOut(true);
      expect(await TelemetrySettings.isOptedOut(), isTrue);
    });

    test('returns false after setOptedOut(false)', () async {
      // Verifies that opting back in persists correctly.
      await TelemetrySettings.setOptedOut(true);
      await TelemetrySettings.setOptedOut(false);
      expect(await TelemetrySettings.isOptedOut(), isFalse);
    });
  });

  group('TelemetrySettings.hasSeenDialog', () {
    test('returns false by default', () async {
      // Verifies the default (no stored value) is false.
      expect(await TelemetrySettings.hasSeenDialog(), isFalse);
    });

    test('returns true after setHasSeenDialog(true)', () async {
      // Verifies that marking dialog as seen persists correctly.
      await TelemetrySettings.setHasSeenDialog(true);
      expect(await TelemetrySettings.hasSeenDialog(), isTrue);
    });

    test('returns false after setHasSeenDialog(false)', () async {
      // Verifies that unsetting the dialog seen flag persists correctly.
      await TelemetrySettings.setHasSeenDialog(true);
      await TelemetrySettings.setHasSeenDialog(false);
      expect(await TelemetrySettings.hasSeenDialog(), isFalse);
    });
  });
}
