// Tests for Legend widget
// (lib/features/tasks/presentation/widgets/legend.dart).
//
// Legend is a pure display widget that reads TaskTypeManager from context
// via context.watch<TaskTypeManager>().  No API calls, no navigation.
//
// Tests wrap the widget with ChangeNotifierProvider<TaskTypeManager> and
// use SharedPreferences.setMockInitialValues({}) so no platform channel
// is needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/legend.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

Widget _wrap(Widget child) {
  final manager = TaskTypeManager();
  return MaterialApp(
    home: ChangeNotifierProvider<TaskTypeManager>.value(
      value: manager,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Legend – default render', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget builds without error.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump(); // let TaskTypeManager._loadFromPrefs complete
      expect(find.byType(Legend), findsOneWidget);
    });

    testWidgets('shows "Task Types" header text', (tester) async {
      // The header label must be visible.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      expect(find.text('Task Types'), findsOneWidget);
    });

    testWidgets('renders a Card', (tester) async {
      // Legend wraps its content in a Card.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows Divider below header', (tester) async {
      // A Divider separates the header from the task-type items.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows manage IconButton when showManageButton is true',
        (tester) async {
      // Default showManageButton=true renders an edit IconButton.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('hides manage button when showManageButton is false',
        (tester) async {
      // When showManageButton=false the edit icon must not appear.
      await tester.pumpWidget(_wrap(const Legend(showManageButton: false)));
      await tester.pump();
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('invokes onManage callback when manage button tapped',
        (tester) async {
      // Tapping the edit icon should fire the onManage callback.
      var called = false;
      await tester.pumpWidget(_wrap(Legend(onManage: () => called = true)));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit));
      expect(called, isTrue);
    });

    testWidgets('manage button tooltip is "Manage Task Types"', (tester) async {
      // The IconButton tooltip must match the expected string.
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      final tooltip = tester.widget<Tooltip>(
        find.ancestor(
          of: find.byIcon(Icons.edit),
          matching: find.byType(Tooltip),
        ),
      );
      expect(tooltip.message, 'Manage Task Types');
    });
  });

  group('Legend – onTypeTap / onTypeLongPress', () {
    testWidgets('wraps items in InkWell when onTypeTap provided',
        (tester) async {
      // When onTypeTap is supplied, each type item is wrapped in InkWell.
      await tester
          .pumpWidget(_wrap(Legend(onTypeTap: (type) {})));
      await tester.pump();
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('renders more InkWells when callbacks provided than without',
        (tester) async {
      // With callbacks each type item is wrapped in InkWell, so there are more
      // InkWells than in the no-callback case (which only has the IconButton).
      await tester.pumpWidget(_wrap(const Legend()));
      await tester.pump();
      final countWithout = tester.widgetList(find.byType(InkWell)).length;

      await tester.pumpWidget(_wrap(Legend(onTypeTap: (_) {})));
      await tester.pump();
      final countWith = tester.widgetList(find.byType(InkWell)).length;

      expect(countWith, greaterThan(countWithout));
    });
  });
}
