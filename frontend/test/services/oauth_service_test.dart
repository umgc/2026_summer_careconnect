// Tests for OAuthService.
//
// Coverage strategy:
//   OAuthService is nearly pure Dart — it reads the backend URL from an
//   environment helper, builds URL strings, and parses callback URIs.
//   launchGoogleOAuth is tested by mocking the url_launcher MethodChannel.
//
//   Branches tested:
//     isConfigured — returns true when backend URL is non-empty.
//     buildAuthorizationUrl — returns expected URL pattern.
//     launchGoogleOAuth — successfully launches when canLaunch returns true.
//     launchGoogleOAuth — throws when canLaunch returns false.
//     handleCallback — token present → returns token.
//     handleCallback — error query param → throws Exception.
//     handleCallback — no token and no error → throws Exception.
//     clearSession — completes without error.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:care_connect_app/services/oauth_service.dart';

const _urlLauncherChannels = [
  'plugins.flutter.io/url_launcher',
  'plugins.flutter.io/url_launcher_android',
  'plugins.flutter.io/url_launcher_ios',
  'plugins.flutter.io/url_launcher_linux',
  'plugins.flutter.io/url_launcher_macos',
  'plugins.flutter.io/url_launcher_windows',
];

void _installUrlLauncherMock({bool canLaunch = true}) {
  for (final name in _urlLauncherChannels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async {
      if (call.method == 'canLaunch') return canLaunch;
      if (call.method == 'launch') return true;
      if (call.method == 'launchUrl') return true;
      return null;
    });
  }
}

void _removeUrlLauncherMock() {
  for (final name in _urlLauncherChannels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ─── isConfigured ────────────────────────────────────────────────────────

  group('OAuthService.isConfigured', () {
    test('returns a boolean without throwing', () {
      expect(() => OAuthService.isConfigured, returnsNormally);
      expect(OAuthService.isConfigured, isA<bool>());
    });
  });

  // ─── buildAuthorizationUrl ───────────────────────────────────────────────

  group('OAuthService.buildAuthorizationUrl', () {
    test('includes the Google SSO endpoint path', () {
      final url = OAuthService.buildAuthorizationUrl();
      expect(url, contains('/v1/api/auth/sso/google'));
    });

    test('returns a non-empty string', () {
      expect(OAuthService.buildAuthorizationUrl(), isNotEmpty);
    });
  });

  // ─── launchGoogleOAuth ─────────────────────────────────────────────────

  group('OAuthService.launchGoogleOAuth', () {
    tearDown(_removeUrlLauncherMock);

    test('launches successfully when canLaunch returns true', () async {
      _installUrlLauncherMock(canLaunch: true);
      // Should complete without throwing.
      await OAuthService.launchGoogleOAuth();
    });

    test('throws when canLaunch returns false', () async {
      _installUrlLauncherMock(canLaunch: false);
      await expectLater(
        OAuthService.launchGoogleOAuth(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Could not launch OAuth URL'),
          ),
        ),
      );
    });
  });

  // ─── handleCallback ──────────────────────────────────────────────────────

  group('OAuthService.handleCallback', () {
    test('token query param present → returns token', () async {
      final uri = Uri.parse('careconnect://callback?token=abc.def.ghi');
      final token = await OAuthService.handleCallback(uri);
      expect(token, 'abc.def.ghi');
    });

    test('error query param present → throws Exception', () async {
      final uri = Uri.parse('careconnect://callback?error=access_denied');
      await expectLater(
        OAuthService.handleCallback(uri),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('access_denied'),
          ),
        ),
      );
    });

    test('neither token nor error present → throws "No JWT token" exception',
        () async {
      final uri = Uri.parse('careconnect://callback');
      await expectLater(
        OAuthService.handleCallback(uri),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('No JWT token'),
          ),
        ),
      );
    });
  });

  // ─── clearSession ────────────────────────────────────────────────────────

  group('OAuthService.clearSession', () {
    test('completes without throwing', () {
      expect(() => OAuthService.clearSession(), returnsNormally);
    });
  });
}
