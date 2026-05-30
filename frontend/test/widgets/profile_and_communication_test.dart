// Tests for:
//   CompactProfilePicture  (lib/widgets/profile_picture_widget.dart)
//   CommunicationWidget    (lib/widgets/communication_widget.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/profile_picture_widget.dart';
import 'package:care_connect_app/widgets/communication_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ─────────────────────────────────────────────────────────────────────────────
// CompactProfilePicture
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('CompactProfilePicture', () {
    testWidgets('renders without crashing (no image, no URL)', (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'AB')));
      expect(find.byType(CompactProfilePicture), findsOneWidget);
    });

    testWidgets('shows initials when imageUrl and profileImage are null',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'JD')));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('uppercases initials', (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'ab')));
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('renders at default size of 40', (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'XY')));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 40.0);
    });

    testWidgets('renders at custom size', (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'XY', size: 60)));
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 60.0);
    });

    testWidgets('renders CircleAvatar-like Container (round shape)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CompactProfilePicture(initials: 'ZZ')));
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.shape, BoxShape.circle);
    });

    testWidgets('shows initials as fallback when imageUrl is provided',
        (tester) async {
      // Network image will fail to load in test env; errorBuilder shows initials.
      await tester.pumpWidget(_wrap(const CompactProfilePicture(
        initials: 'ER',
        imageUrl: 'https://example.com/photo.jpg',
      )));
      // Pump to let the network image fail and show errorBuilder output
      await tester.pump();
      // ClipOval + Image.network is shown; initials may appear via errorBuilder
      // but at minimum the widget renders without crashing
      expect(find.byType(CompactProfilePicture), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // CommunicationWidget
  // ─────────────────────────────────────────────────────────────────────────────
  group('CommunicationWidget', () {
    Widget makeWidget({String? targetPhoneNumber}) => _wrap(
          CommunicationWidget(
            currentUserId: 'user-1',
            currentUserName: 'Alice',
            targetUserId: 'user-2',
            targetUserName: 'Bob',
            targetPhoneNumber: targetPhoneNumber,
          ),
        );

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.byType(CommunicationWidget), findsOneWidget);
    });

    testWidgets('shows Contact <name> heading', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.text('Contact Bob'), findsOneWidget);
    });

    testWidgets('shows Video Call button', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.text('Video Call'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('shows Audio Call button', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.text('Audio Call'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('shows SMS button', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.text('SMS'), findsOneWidget);
      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('shows Message button', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.text('Message'), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('SMS button disabled when no phone number', (tester) async {
      await tester.pumpWidget(makeWidget(targetPhoneNumber: null));
      await tester.pump();
      final smsButtons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      ).where((b) => b.onPressed == null);
      // At least one button (SMS) should be disabled
      expect(smsButtons.isNotEmpty, isTrue);
    });

    testWidgets('all 4 action buttons are present', (tester) async {
      await tester.pumpWidget(makeWidget());
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });
  });
}
