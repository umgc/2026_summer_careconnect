// Tests for CommunicationService
// (lib/services/communication_service.dart).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/services/communication_service.dart';

/// Install mock handlers for every url_launcher platform channel so that
/// canLaunchUrl / launchUrl succeed without a real platform implementation.
void _installUrlLauncherMock() {
  const channels = [
    'plugins.flutter.io/url_launcher',
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher_linux',
    'plugins.flutter.io/url_launcher_macos',
    'plugins.flutter.io/url_launcher_windows',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async {
      if (call.method == 'canLaunch') return true;
      if (call.method == 'launch') return true;
      if (call.method == 'launchUrl') return true;
      return null;
    });
  }
}

void _clearUrlLauncherMock() {
  const channels = [
    'plugins.flutter.io/url_launcher',
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher_linux',
    'plugins.flutter.io/url_launcher_macos',
    'plugins.flutter.io/url_launcher_windows',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), null);
  }
}

void main() {
  group('CommunicationService', () {
    setUp(() {
      _installUrlLauncherMock();
    });

    tearDown(() {
      _clearUrlLauncherMock();
    });

    // ---------------------------------------------------------------
    // makePhoneCall
    // ---------------------------------------------------------------
    group('makePhoneCall', () {
      testWidgets('launches phone app with cleaned number', (tester) async {
        // Use iOS platform to skip Permission.phone check (Android-only).
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await CommunicationService.makePhoneCall(
                      '(555) 123-4567',
                      context,
                    );
                  },
                  child: const Text('Call'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Call'));
        await tester.pumpAndSettle();
        // No error snackbar should be visible.
        expect(find.text('Cannot launch phone app'), findsNothing);
      });

      testWidgets('shows error when canLaunch returns false', (tester) async {
        // Override mock to return false for canLaunch.
        const channels = [
          'plugins.flutter.io/url_launcher',
          'plugins.flutter.io/url_launcher_android',
          'plugins.flutter.io/url_launcher_ios',
          'plugins.flutter.io/url_launcher_linux',
          'plugins.flutter.io/url_launcher_macos',
          'plugins.flutter.io/url_launcher_windows',
        ];
        for (final name in channels) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(MethodChannel(name), (call) async {
            if (call.method == 'canLaunch') return false;
            if (call.method == 'launch') return false;
            if (call.method == 'launchUrl') return false;
            return null;
          });
        }

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await CommunicationService.makePhoneCall('1234567890', context);
                    },
                    child: const Text('Call'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Call'));
        await tester.pumpAndSettle();
        expect(find.text('Cannot launch phone app'), findsOneWidget);
      });
    });

    // ---------------------------------------------------------------
    // sendSMS
    // ---------------------------------------------------------------
    group('sendSMS', () {
      testWidgets('launches SMS app without message body', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await CommunicationService.sendSMS('5551234567', context);
                  },
                  child: const Text('SMS'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        expect(find.text('Cannot launch SMS app'), findsNothing);
      });

      testWidgets('launches SMS app with message body', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await CommunicationService.sendSMS(
                      '5551234567',
                      context,
                      message: 'Hello there!',
                    );
                  },
                  child: const Text('SMS'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        expect(find.text('Cannot launch SMS app'), findsNothing);
      });

      testWidgets('shows error when SMS canLaunch returns false', (tester) async {
        const channels = [
          'plugins.flutter.io/url_launcher',
          'plugins.flutter.io/url_launcher_android',
          'plugins.flutter.io/url_launcher_ios',
          'plugins.flutter.io/url_launcher_linux',
          'plugins.flutter.io/url_launcher_macos',
          'plugins.flutter.io/url_launcher_windows',
        ];
        for (final name in channels) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(MethodChannel(name), (call) async {
            if (call.method == 'canLaunch') return false;
            if (call.method == 'launch') return false;
            if (call.method == 'launchUrl') return false;
            return null;
          });
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await CommunicationService.sendSMS('5551234567', context);
                    },
                    child: const Text('SMS'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        expect(find.text('Cannot launch SMS app'), findsOneWidget);
      });

      testWidgets('cleans phone number for SMS', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await CommunicationService.sendSMS(
                      '(555) 123-4567',
                      context,
                    );
                  },
                  child: const Text('SMS'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        // Should succeed (no error).
        expect(find.text('Cannot launch SMS app'), findsNothing);
        expect(find.textContaining('Failed to send SMS'), findsNothing);
      });

      testWidgets('handles empty message body same as no body', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await CommunicationService.sendSMS(
                      '5551234567',
                      context,
                      message: '',
                    );
                  },
                  child: const Text('SMS'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('SMS'));
        await tester.pumpAndSettle();
        expect(find.text('Cannot launch SMS app'), findsNothing);
      });
    });

    // ---------------------------------------------------------------
    // CommunicationService is instantiable (static-only class)
    // ---------------------------------------------------------------
    test('CommunicationService can be instantiated', () {
      // It's a static-only class but should still be constructable.
      final service = CommunicationService();
      expect(service, isNotNull);
    });
  });
}
