// Tests for EventTile widget
// (lib/features/tasks/presentation/widgets/event_tile.dart).
//
// EventTile is a pure StatelessWidget — reads TaskTypeManager via
// context.select<TaskTypeManager, Color>() to resolve the task colour.
// No API calls, no navigation.
//
// Tests wrap with ChangeNotifierProvider<TaskTypeManager> and use
// SharedPreferences.setMockInitialValues({}) so no platform channel is needed.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/event_tile.dart';
import 'package:care_connect_app/features/tasks/models/task_model.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

final _date = DateTime(2025, 6, 15);
final _task = Task(
  name: 'Morning Medication',
  description: '',
  date: _date,
  isComplete: false,
  taskType: 'medication',
);
final _event = CalendarEventData<Task>(
  title: 'Morning Medication',
  date: _date,
  event: _task,
);

Widget _wrap(Widget child) {
  final manager = TaskTypeManager();
  return MaterialApp(
    home: ChangeNotifierProvider<TaskTypeManager>.value(
      value: manager,
      child: Scaffold(
        body: SizedBox(width: 300, height: 80, child: child),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EventTile – empty events', () {
    testWidgets('renders SizedBox.shrink when events is empty', (tester) async {
      // An empty event list must render an empty (zero-size) widget.
      await tester.pumpWidget(_wrap(const EventTile(events: [])));
      await tester.pump();
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Container), findsNothing);
    });
  });

  group('EventTile – with events', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget builds without error when an event is provided.
      await tester.pumpWidget(_wrap(EventTile(events: [_event])));
      await tester.pump();
      expect(find.byType(EventTile), findsOneWidget);
    });

    testWidgets('shows task name', (tester) async {
      // The task name must appear in the tile.
      await tester.pumpWidget(_wrap(EventTile(events: [_event])));
      await tester.pump();
      expect(find.text('Morning Medication'), findsOneWidget);
    });

    testWidgets('renders a Container with decoration', (tester) async {
      // EventTile uses a decorated Container as its root.
      await tester.pumpWidget(_wrap(EventTile(events: [_event])));
      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows only the first event when multiple provided',
        (tester) async {
      // EventTile always displays only the first event in the list.
      final task2 = Task(
        name: 'Evening Walk',
        description: '',
        date: _date,
        isComplete: false,
        taskType: 'exercise',
      );
      final event2 = CalendarEventData<Task>(
        title: 'Evening Walk',
        date: _date,
        event: task2,
      );
      await tester.pumpWidget(_wrap(EventTile(events: [_event, event2])));
      await tester.pump();
      expect(find.text('Morning Medication'), findsOneWidget);
      expect(find.text('Evening Walk'), findsNothing);
    });

    testWidgets('shows text with ellipsis overflow', (tester) async {
      // The task name Text widget uses overflow: ellipsis.
      await tester.pumpWidget(_wrap(EventTile(events: [_event])));
      await tester.pump();
      final textWidget = tester.widget<Text>(find.text('Morning Medication'));
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
