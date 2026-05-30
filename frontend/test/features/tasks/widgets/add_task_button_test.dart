// Tests for AddTaskButton widget
// (lib/features/tasks/presentation/widgets/add_task_button.dart).
//
// Pure StatelessWidget — no platform channels, network I/O, or Provider.
// Renders an ElevatedButton.icon on wide screens and an IconButton on compact
// screens (< 500 px wide).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/add_task_button.dart';

Widget _wrap(Widget child, {double width = 800}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Scaffold(
          body: SizedBox(
            width: width,
            child: child,
          ),
        ),
      ),
    );

void main() {
  group('AddTaskButton – wide screen (≥ 500 px)', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget builds without error on a wide screen.
      await tester.pumpWidget(_wrap(AddTaskButton(onPressed: () {})));
      expect(find.byType(AddTaskButton), findsOneWidget);
    });

    testWidgets('shows "Add Task" label on wide screen', (tester) async {
      // Wide screens should show the full labelled ElevatedButton.icon.
      await tester.pumpWidget(_wrap(AddTaskButton(onPressed: () {})));
      expect(find.text('Add Task'), findsOneWidget);
    });

    testWidgets('shows add icon on wide screen', (tester) async {
      // The add icon is part of the ElevatedButton.icon on wide screens.
      await tester.pumpWidget(_wrap(AddTaskButton(onPressed: () {})));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows ElevatedButton on wide screen', (tester) async {
      // Wide screens use ElevatedButton (not plain IconButton).
      await tester.pumpWidget(_wrap(AddTaskButton(onPressed: () {})));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('invokes callback when tapped on wide screen', (tester) async {
      // Verifies the onPressed callback fires on tap.
      var tapped = false;
      await tester.pumpWidget(_wrap(AddTaskButton(onPressed: () {
        tapped = true;
      })));
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });

  group('AddTaskButton – compact screen (< 500 px)', () {
    testWidgets('renders without crashing on compact screen', (tester) async {
      // Verifies the widget builds on a phone-width screen.
      await tester.pumpWidget(_wrap(
        AddTaskButton(onPressed: () {}),
        width: 400,
      ));
      expect(find.byType(AddTaskButton), findsOneWidget);
    });

    testWidgets('shows IconButton on compact screen', (tester) async {
      // Compact screens should use a plain IconButton to save space.
      await tester.pumpWidget(_wrap(
        AddTaskButton(onPressed: () {}),
        width: 400,
      ));
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('does NOT show "Add Task" label on compact screen',
        (tester) async {
      // Compact screens must NOT show the text label.
      await tester.pumpWidget(_wrap(
        AddTaskButton(onPressed: () {}),
        width: 400,
      ));
      expect(find.text('Add Task'), findsNothing);
    });

    testWidgets('invokes callback when tapped on compact screen',
        (tester) async {
      // Verifies the onPressed callback fires on compact screen too.
      var tapped = false;
      await tester.pumpWidget(_wrap(
        AddTaskButton(onPressed: () {
          tapped = true;
        }),
        width: 400,
      ));
      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });
  });
}
