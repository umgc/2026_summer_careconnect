// Tests for CallNotificationStatusIndicator widget
// (lib/widgets/call_notification_status_indicator.dart)
// Reads only a static bool from CallNotificationService — no API calls.
// CallNotificationService._isConnected defaults to false in tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/call_notification_status_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CallNotificationStatusIndicator', () {
    testWidgets('renders without crashing (isInitialized=false)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: false)));
      expect(
          find.byType(CallNotificationStatusIndicator), findsOneWidget);
    });

    testWidgets('shows "Initializing..." when isInitialized is false',
        (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: false)));
      expect(find.text('Initializing...'), findsOneWidget);
    });

    testWidgets(
        'shows "Connecting..." when initialized but not connected',
        (tester) async {
      // CallNotificationService._isConnected defaults to false in test env.
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: true)));
      expect(find.text('Connecting...'), findsOneWidget);
    });

    testWidgets('renders a Row with a status dot and text', (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: true)));
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('renders Container with circular status dot', (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: false)));
      // The indicator contains at least two Container widgets
      // (outer pill + inner circle)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows Text widget for status label', (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: false)));
      // Should show "Initializing..." text
      final textWidget = tester.widget<Text>(find.text('Initializing...'));
      expect(textWidget.style?.fontSize, 12);
    });

    testWidgets('shows Text widget for connecting label', (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: true)));
      final textWidget = tester.widget<Text>(find.text('Connecting...'));
      expect(textWidget.style?.fontSize, 12);
    });

    testWidgets('status text has fontWeight w500', (tester) async {
      await tester.pumpWidget(
          _wrap(const CallNotificationStatusIndicator(isInitialized: true)));
      final textWidget = tester.widget<Text>(find.text('Connecting...'));
      expect(textWidget.style?.fontWeight, FontWeight.w500);
    });
  });
}
