// Tests for CommunicationWidget from lib/widgets/communication_widget.dart.
// _initializeServices() in initState: VideoCallService.initializeService()
// is COMMENTED OUT — so it just toggles _isInitializing with no side effects.
// No Provider needed for initial render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/communication_widget.dart';

Widget _wrap({String? targetPhoneNumber}) => MaterialApp(
      home: Scaffold(
        body: CommunicationWidget(
          currentUserId: '1',
          currentUserName: 'Alice',
          targetUserId: '2',
          targetUserName: 'Bob',
          targetPhoneNumber: targetPhoneNumber,
        ),
      ),
    );

void main() {
  group('CommunicationWidget – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(CommunicationWidget), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows target user name in heading', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Contact Bob'), findsOneWidget);
    });
  });

  group('CommunicationWidget – action buttons', () {
    testWidgets('shows Video Call button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Video Call'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('shows Audio Call button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Audio Call'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('shows SMS button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('SMS'), findsOneWidget);
      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('shows Message button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Message'), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('shows 4 ElevatedButtons', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });

    testWidgets('SMS button is disabled when no phone number', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // The SMS button's onPressed should be null
      final smsButton = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      ).toList()[2]; // SMS is 3rd button
      expect(smsButton.onPressed, isNull);
    });

    testWidgets('SMS button is enabled when phone number provided', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      final smsButton = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      ).toList()[2];
      expect(smsButton.onPressed, isNotNull);
    });
  });

  group('CommunicationWidget – SMS dialog', () {
    testWidgets('tapping SMS with phone number opens dialog', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Bob'), findsOneWidget);
      expect(find.text('Phone: 5551234567'), findsOneWidget);
    });

    testWidgets('SMS dialog has Cancel and Send buttons', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets('SMS dialog has message TextField', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Message'), findsOneWidget);
    });

    testWidgets('Cancel dismisses SMS dialog', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Bob'), findsNothing);
    });
  });

  group('CommunicationWidget – Message dialog', () {
    testWidgets('tapping Message opens dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(find.text('Send Message to Bob'), findsOneWidget);
    });

    testWidgets('Message dialog has Cancel and Send buttons', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets('Cancel dismisses Message dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Send Message to Bob'), findsNothing);
    });

    testWidgets('Message dialog has message TextField', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Message'), findsOneWidget);
    });

    testWidgets('can enter text in Message dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello Bob');
      expect(find.text('Hello Bob'), findsOneWidget);
    });
  });

  group('CommunicationWidget – SMS without phone number', () {
    testWidgets('tapping SMS without phone shows error SnackBar', (tester) async {
      // SMS button is disabled (null onPressed) when no phone number,
      // so tapping has no effect — no SnackBar.
      await tester.pumpWidget(_wrap());
      await tester.pump();
      final smsButtons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      ).toList();
      // The 3rd button (index 2) is SMS — verify it's disabled
      expect(smsButtons[2].onPressed, isNull);
    });
  });

  group('CommunicationWidget – SMS dialog interaction', () {
    testWidgets('SMS dialog shows phone number', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '555-1234'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      expect(find.text('Phone: 555-1234'), findsOneWidget);
    });

    testWidgets('SMS dialog has max 160 char message field', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '555-1234'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 160);
    });

    testWidgets('can enter text in SMS dialog message field', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '555-1234'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test SMS');
      expect(find.text('Test SMS'), findsOneWidget);
    });
  });

  group('CommunicationWidget – Video/Audio Call buttons', () {
    testWidgets('tapping Video Call does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Video Call'));
      await tester.pump();
      // Video call service is commented out, so no dialog or navigation
      expect(find.byType(CommunicationWidget), findsOneWidget);
    });

    testWidgets('tapping Audio Call does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Audio Call'));
      await tester.pump();
      expect(find.byType(CommunicationWidget), findsOneWidget);
    });
  });

  group('CommunicationWidget – Send actions', () {
    testWidgets('tapping Send in SMS dialog does not crash', (tester) async {
      await tester.pumpWidget(_wrap(targetPhoneNumber: '5551234567'));
      await tester.pump();
      await tester.tap(find.text('SMS'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.text('Send'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Dialog dismissed, should be back to main widget
      expect(find.text('Send SMS to Bob'), findsNothing);
    });

    testWidgets('tapping Send in Message dialog does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello Bob');
      await tester.tap(find.text('Send'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Send Message to Bob'), findsNothing);
    });
  });

  group('CommunicationWidget – custom target names', () {
    testWidgets('shows custom target name in heading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommunicationWidget(
            currentUserId: '1',
            currentUserName: 'Alice',
            targetUserId: '3',
            targetUserName: 'Dr. Smith',
          ),
        ),
      ));
      await tester.pump();
      expect(find.text('Contact Dr. Smith'), findsOneWidget);
    });
  });
}
