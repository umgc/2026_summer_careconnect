// Tests for ChatPage from
// lib/features/social/in-app-chat/pages/chat-page.dart.
// Uses flutter_chat_ui InMemoryChatController — no HTTP in initState.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/social/in-app-chat/pages/chat-page.dart';

Widget _wrap() => const MaterialApp(
      home: ChatPage(contactName: 'Dr. Smith', contactRole: 'Doctor'),
    );

void main() {
  group('ChatPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(ChatPage), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows contact name in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.textContaining('Dr. Smith'), findsOneWidget);
    });

    testWidgets('shows contact role in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Doctor'), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows back arrow button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows phone action button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('shows video call action button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('shows more_vert menu button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('shows person icon in CircleAvatar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows CircleAvatar in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('ChatPage – with different contact', () {
    testWidgets('shows custom contact name', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ChatPage(contactName: 'Nurse Jane', contactRole: 'Nurse'),
      ));
      await tester.pump();
      expect(find.textContaining('Nurse Jane'), findsOneWidget);
    });

    testWidgets('shows custom contact role', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: ChatPage(contactName: 'Nurse Jane', contactRole: 'Nurse'),
      ));
      await tester.pump();
      expect(find.text('Nurse'), findsOneWidget);
    });
  });
}
