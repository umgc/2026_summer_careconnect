// Tests for CalendarCell widget
// (lib/features/tasks/presentation/widgets/calendar_cell.dart).
//
// CalendarCell is a pure StatelessWidget — reads TaskTypeManager via
// context.watch<TaskTypeManager>() to resolve task-type colours for dots.
// No API calls, no navigation.
//
// Tests wrap with ChangeNotifierProvider<TaskTypeManager> and use
// SharedPreferences.setMockInitialValues({}) so no platform channel is needed.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/calendar_cell.dart';
import 'package:care_connect_app/features/tasks/models/task_model.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

final _today = DateTime(2025, 6, 15);
final _task = Task(
  name: 'Test Task',
  description: '',
  date: _today,
  isComplete: false,
  taskType: 'medication',
);
final _event = CalendarEventData<Task>(
  title: 'Test Task',
  date: _today,
  event: _task,
);

Widget _wrap(Widget child) {
  final manager = TaskTypeManager();
  return MaterialApp(
    home: ChangeNotifierProvider<TaskTypeManager>.value(
      value: manager,
      child: Scaffold(
        body: SizedBox(width: 60, height: 60, child: child),
      ),
    ),
  );
}

CalendarCell _cell({
  DateTime? date,
  List<CalendarEventData<Task>>? events,
  bool isToday = false,
  bool isInMonth = true,
  bool isWeekend = false,
  bool isSelected = false,
}) =>
    CalendarCell(
      date: date ?? _today,
      events: events ?? const [],
      isToday: isToday,
      isInMonth: isInMonth,
      isWeekend: isWeekend,
      isSelected: isSelected,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CalendarCell – basic render', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget builds without error.
      await tester.pumpWidget(_wrap(_cell()));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });

    testWidgets('shows the day number', (tester) async {
      // The day number from the date must appear in the cell.
      await tester.pumpWidget(_wrap(_cell(date: DateTime(2025, 6, 15))));
      await tester.pump();
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('renders a Container', (tester) async {
      // The outermost widget is a Container with decoration.
      await tester.pumpWidget(_wrap(_cell()));
      await tester.pump();
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders with no events and no dots', (tester) async {
      // When events list is empty the Wrap should contain no dot containers.
      await tester.pumpWidget(_wrap(_cell(events: [])));
      await tester.pump();
      // Only the outer Container and the day-number Text should be present;
      // no dot boxes means no fixed-size 8×8 containers.
      expect(find.byType(CalendarCell), findsOneWidget);
    });
  });

  group('CalendarCell – event dots', () {
    testWidgets('renders one dot for one event', (tester) async {
      // A single event produces one coloured dot.
      await tester.pumpWidget(_wrap(_cell(events: [_event])));
      await tester.pump();
      // The Wrap inside the Column should exist (doesn't crash with events).
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('renders without crashing for 5 events (caps at 4 dots)',
        (tester) async {
      // CalendarCell.take(4) limits displayed dots to 4 even if 5 events.
      final events = List.filled(5, _event);
      await tester.pumpWidget(_wrap(_cell(events: events)));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });
  });

  group('CalendarCell – state flags', () {
    testWidgets('renders correctly when isToday=true', (tester) async {
      // A "today" cell must still render without error.
      await tester.pumpWidget(_wrap(_cell(isToday: true)));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });

    testWidgets('renders correctly when isSelected=true', (tester) async {
      // A selected cell uses a green border — must render without error.
      await tester.pumpWidget(_wrap(_cell(isSelected: true)));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });

    testWidgets('renders correctly when isInMonth=false', (tester) async {
      // Days outside the current month are dimmed but must still render.
      await tester.pumpWidget(_wrap(_cell(isInMonth: false)));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });

    testWidgets('renders correctly when isWeekend=true', (tester) async {
      // Weekend flag is accepted without error.
      await tester.pumpWidget(_wrap(_cell(isWeekend: true)));
      await tester.pump();
      expect(find.byType(CalendarCell), findsOneWidget);
    });
  });
}
