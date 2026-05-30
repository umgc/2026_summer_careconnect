// Tests for AppBarActions widget
// (lib/widgets/app_bar_actions.dart).
// Pure StatelessWidget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/app_bar_actions.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(appBar: AppBar(actions: [child])));

void main() {
  group('AppBarActions', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const AppBarActions()));
      expect(find.byType(AppBarActions), findsOneWidget);
    });

    testWidgets('renders with no additional actions', (tester) async {
      await tester.pumpWidget(_wrap(const AppBarActions()));
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('renders additional actions when provided', (tester) async {
      await tester.pumpWidget(_wrap(AppBarActions(
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      )));
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders multiple additional actions', (tester) async {
      await tester.pumpWidget(_wrap(AppBarActions(
        additionalActions: [
          const Icon(Icons.notifications),
          const Icon(Icons.search),
        ],
      )));
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('does not render extra widgets when additionalActions is null', (tester) async {
      await tester.pumpWidget(_wrap(const AppBarActions(additionalActions: null)));
      expect(find.byIcon(Icons.settings), findsNothing);
    });
  });
}
