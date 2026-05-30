// Tests for NotificationsPanel widget and NotificationItem model
// (lib/widgets/notification_panel_widget.dart).
//
// Pure StatefulWidget — no API calls or Provider dependencies.
// NotificationItem is a plain Dart data class; NotificationsPanel renders
// a collapsible list of notification cards.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/notification_panel_widget.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

// Convenience builders
NotificationItem _urgent({String title = 'Urgent message', String? cta}) =>
    NotificationItem(
      kind: NotificationKind.urgent,
      title: title,
      ctaLabel: cta,
    );

NotificationItem _reminder({String title = 'Reminder', String? subtitle}) =>
    NotificationItem(
      kind: NotificationKind.reminder,
      title: title,
      subtitle: subtitle,
    );

void main() {
  group('NotificationsPanel – empty state', () {
    testWidgets('renders without crashing with empty list', (tester) async {
      // Verifies the widget builds when the notifications list is empty.
      await tester.pumpWidget(_wrap(const NotificationsPanel(notifications: [])));
      expect(find.byType(NotificationsPanel), findsOneWidget);
    });

    testWidgets('shows default heading "Notifications"', (tester) async {
      // The default heading label must be visible.
      await tester.pumpWidget(_wrap(const NotificationsPanel(notifications: [])));
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows custom heading', (tester) async {
      // A custom heading label should replace the default one.
      await tester.pumpWidget(_wrap(const NotificationsPanel(
        notifications: [],
        heading: 'Alerts',
      )));
      expect(find.text('Alerts'), findsOneWidget);
    });

    testWidgets('shows "No notifications to show." when list is empty',
        (tester) async {
      // Empty panel must display the empty-state message.
      await tester.pumpWidget(_wrap(const NotificationsPanel(notifications: [])));
      await tester.pump(); // let AnimatedCrossFade settle
      expect(find.text('No notifications to show.'), findsOneWidget);
    });

    testWidgets('shows notifications_none icon', (tester) async {
      // The header bell icon should always be visible.
      await tester.pumpWidget(_wrap(const NotificationsPanel(notifications: [])));
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });
  });

  group('NotificationsPanel – with items', () {
    testWidgets('renders without crashing with multiple notifications',
        (tester) async {
      // Verifies the panel builds when given a list of notifications.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          _urgent(title: 'BP too high'),
          _reminder(title: 'Take medication'),
        ],
      )));
      expect(find.byType(NotificationsPanel), findsOneWidget);
    });

    testWidgets('shows notification titles', (tester) async {
      // Each notification title must appear in the panel.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          _urgent(title: 'BP too high'),
          _reminder(title: 'Take medication'),
        ],
      )));
      await tester.pump();
      expect(find.text('BP too high'), findsOneWidget);
      expect(find.text('Take medication'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      // A subtitle string must appear under the notification title.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          _reminder(title: 'Reminder', subtitle: 'Please take aspirin'),
        ],
      )));
      await tester.pump();
      expect(find.text('Please take aspirin'), findsOneWidget);
    });

    testWidgets('shows CTA button when ctaLabel provided', (tester) async {
      // An ElevatedButton must appear when ctaLabel is non-empty.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent(cta: 'View Now')],
      )));
      await tester.pump();
      expect(find.text('View Now'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('CTA button callback fires on tap', (tester) async {
      // Tapping the CTA button must invoke the onTapCTA callback.
      var tapped = false;
      final item = NotificationItem(
        kind: NotificationKind.urgent,
        title: 'High BP',
        ctaLabel: 'Dismiss',
        onTapCTA: () => tapped = true,
      );
      await tester.pumpWidget(
          _wrap(NotificationsPanel(notifications: [item])));
      await tester.pump();
      await tester.tap(find.text('Dismiss'));
      expect(tapped, isTrue);
    });

    testWidgets('does not show CTA button when ctaLabel is null',
        (tester) async {
      // Without a ctaLabel, no ElevatedButton should appear.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_reminder()],
      )));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('NotificationsPanel – expand/collapse', () {
    testWidgets('shows "Hide" toggle when expanded', (tester) async {
      // When initiallyExpanded=true (default), the toggle label is "Hide".
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent()],
        initiallyExpanded: true,
      )));
      expect(find.text('Hide'), findsOneWidget);
    });

    testWidgets('shows "Show" toggle when collapsed', (tester) async {
      // When initiallyExpanded=false, the toggle label is "Show".
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent()],
        initiallyExpanded: false,
      )));
      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('tapping toggle hides notifications', (tester) async {
      // Tapping "Hide" collapses the panel and changes label to "Show".
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent(title: 'Check vitals')],
        initiallyExpanded: true,
      )));
      await tester.pump();

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('tapping toggle twice restores "Hide" label', (tester) async {
      // Toggling twice must return the panel to the expanded state.
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent()],
        initiallyExpanded: true,
      )));
      await tester.pump();

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Hide'), findsOneWidget);
    });
  });

  group('NotificationKind', () {
    test('enum has urgent, important, reminder values', () {
      // Verifies the three expected enum variants exist.
      expect(NotificationKind.values, contains(NotificationKind.urgent));
      expect(NotificationKind.values, contains(NotificationKind.important));
      expect(NotificationKind.values, contains(NotificationKind.reminder));
    });

    test('NotificationItem stores kind, title, subtitle, ctaLabel', () {
      // Verifies that all fields are accessible via the constructor.
      const item = NotificationItem(
        kind: NotificationKind.important,
        title: 'Test',
        subtitle: 'Sub',
        ctaLabel: 'Act',
      );
      expect(item.kind, NotificationKind.important);
      expect(item.title, 'Test');
      expect(item.subtitle, 'Sub');
      expect(item.ctaLabel, 'Act');
    });

    test('NotificationItem onTapCTA defaults to null', () {
      const item = NotificationItem(
        kind: NotificationKind.reminder,
        title: 'No CTA',
      );
      expect(item.onTapCTA, isNull);
      expect(item.subtitle, isNull);
      expect(item.ctaLabel, isNull);
    });
  });

  group('NotificationsPanel – notification kinds styling', () {
    testWidgets('renders important notification with warning icon', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          const NotificationItem(kind: NotificationKind.important, title: 'Important item'),
        ],
      )));
      await tester.pump();
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Important item'), findsOneWidget);
    });

    testWidgets('renders reminder notification', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_reminder(title: 'Take pills')],
      )));
      await tester.pump();
      expect(find.text('Take pills'), findsOneWidget);
    });

    testWidgets('renders three notifications', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          _urgent(title: 'Alert 1'),
          const NotificationItem(kind: NotificationKind.important, title: 'Alert 2'),
          _reminder(title: 'Alert 3'),
        ],
      )));
      await tester.pump();
      expect(find.text('Alert 1'), findsOneWidget);
      expect(find.text('Alert 2'), findsOneWidget);
      expect(find.text('Alert 3'), findsOneWidget);
    });

    testWidgets('shows up arrow icon when expanded', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent()],
        initiallyExpanded: true,
      )));
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('shows down arrow icon when collapsed', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [_urgent()],
        initiallyExpanded: false,
      )));
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('does not show CTA for empty ctaLabel string', (tester) async {
      await tester.pumpWidget(_wrap(NotificationsPanel(
        notifications: [
          const NotificationItem(
            kind: NotificationKind.urgent,
            title: 'Test',
            ctaLabel: '   ',
          ),
        ],
      )));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
