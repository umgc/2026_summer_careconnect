// Tests for Telemetry (lib/features/telemetry/telemetry.dart).
//
// Coverage strategy:
//   Telemetry uses top-level http.get/post/put calls, interceptable via
//   http.runWithClient + MockClient. TelemetrySettings uses SharedPreferences
//   which is mocked via setMockInitialValues.
//
//   Methods tested:
//     getBackendEnabled — 200 enabled, 200 disabled, non-200, exception
//     setBackendEnabled — 200 enabled, 200 disabled, non-200, exception
//     event             — enabled path, disabled path, guardrails blocked

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:care_connect_app/features/telemetry/telemetry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Not opted out, so local check passes.
    SharedPreferences.setMockInitialValues({'telemetry_opted_out': false});
  });

  // ─── getBackendEnabled ──────────────────────────────────────────────────

  group('Telemetry.getBackendEnabled', () {
    test('200 with enabled=true returns true', () async {
      final result = await http.runWithClient(
        () => Telemetry.getBackendEnabled(),
        () => MockClient((_) async =>
            http.Response(jsonEncode({'enabled': true}), 200)),
      );
      expect(result, isTrue);
    });

    test('200 with enabled=false returns false', () async {
      final result = await http.runWithClient(
        () => Telemetry.getBackendEnabled(),
        () => MockClient((_) async =>
            http.Response(jsonEncode({'enabled': false}), 200)),
      );
      expect(result, isFalse);
    });

    test('non-200 returns true (fail open)', () async {
      final result = await http.runWithClient(
        () => Telemetry.getBackendEnabled(),
        () => MockClient((_) async => http.Response('error', 500)),
      );
      expect(result, isTrue);
    });

    test('exception returns true (fail open)', () async {
      final result = await http.runWithClient(
        () => Telemetry.getBackendEnabled(),
        () => MockClient((_) async => throw Exception('network')),
      );
      expect(result, isTrue);
    });
  });

  // ─── setBackendEnabled ──────────────────────────────────────────────────

  group('Telemetry.setBackendEnabled', () {
    test('200 with enabled=true returns true', () async {
      final result = await http.runWithClient(
        () => Telemetry.setBackendEnabled(true),
        () => MockClient((_) async =>
            http.Response(jsonEncode({'enabled': true}), 200)),
      );
      expect(result, isTrue);
    });

    test('200 with enabled=false returns false', () async {
      final result = await http.runWithClient(
        () => Telemetry.setBackendEnabled(false),
        () => MockClient((_) async =>
            http.Response(jsonEncode({'enabled': false}), 200)),
      );
      expect(result, isFalse);
    });

    test('non-200 returns the requested value', () async {
      final result = await http.runWithClient(
        () => Telemetry.setBackendEnabled(true),
        () => MockClient((_) async => http.Response('error', 500)),
      );
      expect(result, isTrue);
    });

    test('exception returns the requested value', () async {
      final result = await http.runWithClient(
        () => Telemetry.setBackendEnabled(false),
        () => MockClient((_) async => throw Exception('fail')),
      );
      expect(result, isFalse);
    });
  });

  // ─── event ──────────────────────────────────────────────────────────────

  group('Telemetry.event', () {
    test('sends event when enabled and allowed', () async {
      String? capturedBody;
      await http.runWithClient(
        () async {
          // First enable the backend
          await Telemetry.setBackendEnabled(true);
          // Then send an event (allowed event name)
          await Telemetry.event('screen_view', {'screen': 'home'});
        },
        () => MockClient((req) async {
          if (req.method == 'POST' && req.url.path.contains('telemetry') && !req.url.path.contains('enabled')) {
            capturedBody = req.body;
          }
          return http.Response(jsonEncode({'enabled': true}), 200);
        }),
      );
      // The event should have been sent (POST body captured)
      expect(capturedBody, isNotNull);
      final decoded = jsonDecode(capturedBody!);
      expect(decoded['eventName'], 'screen_view');
    });

    test('blocks event not in allowed list', () async {
      bool postCalled = false;
      await http.runWithClient(
        () async {
          await Telemetry.setBackendEnabled(true);
          await Telemetry.event('not_allowed_event', {'key': 'val'});
        },
        () => MockClient((req) async {
          if (req.method == 'POST' && !req.url.path.contains('enabled')) {
            postCalled = true;
          }
          return http.Response(jsonEncode({'enabled': true}), 200);
        }),
      );
      expect(postCalled, isFalse);
    });

    test('does not send when opted out locally', () async {
      SharedPreferences.setMockInitialValues({'telemetry_opted_out': true});
      bool postCalled = false;
      await http.runWithClient(
        () async {
          await Telemetry.event('screen_view', {'screen': 'home'});
        },
        () => MockClient((req) async {
          if (req.method == 'POST' && !req.url.path.contains('enabled')) {
            postCalled = true;
          }
          return http.Response(jsonEncode({'enabled': true}), 200);
        }),
      );
      expect(postCalled, isFalse);
    });
  });
}
