// Tests for TaskListDay widget
// (lib/features/tasks/presentation/widgets/task_list_day.dart).
//
// TaskListDay is a StatelessWidget that reads TaskTypeManager from context.
// The updateCompletion dependency is injectable — tests pass a no-op lambda
// to avoid any API calls.
//
// Tests wrap with ChangeNotifierProvider<TaskTypeManager> and use
// SharedPreferences.setMockInitialValues({}) so no platform channel is needed.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/task_list_day.dart';
import 'package:care_connect_app/features/tasks/models/task_model.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

final _date = DateTime(2025, 6, 15);

Task _makeTask({
  String name = 'Test Task',
  bool isComplete = false,
  int? patientId,
  TimeOfDay? time,
}) =>
    Task(
      id: 1,
      name: name,
      description: '',
      date: _date,
      isComplete: isComplete,
      taskType: 'medication',
      assignedPatientId: patientId,
      timeOfDay: time,
    );

CalendarEventData<Task> _toEvent(Task task) => CalendarEventData<Task>(
      title: task.name,
      date: _date,
      event: task,
    );

Widget _wrap(Widget child) {
  final manager = TaskTypeManager();
  return MaterialApp(
    home: ChangeNotifierProvider<TaskTypeManager>.value(
      value: manager,
      child: Scaffold(body: child),
    ),
  );
}

Future<void> _noOp(int id, bool complete) async {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TaskListDay – empty events', () {
    testWidgets('shows "No tasks for this day" when events is empty',
        (tester) async {
      // Empty list must render the placeholder text.
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('No tasks for this day'), findsOneWidget);
    });

    testWidgets('does NOT show ListView when events is empty', (tester) async {
      // No ListView should be built for empty events.
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.byType(ListView), findsNothing);
    });
  });

  group('TaskListDay – with events', () {
    testWidgets('renders without crashing', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.byType(TaskListDay), findsOneWidget);
    });

    testWidgets('shows task name in the list', (tester) async {
      final task = _makeTask(name: 'Morning Medication');
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Morning Medication'), findsOneWidget);
    });

    testWidgets('shows "All day" when task has no time', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('All day'), findsOneWidget);
    });

    testWidgets('shows edit and delete IconButtons', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('shows "Mark as Complete" button for incomplete task',
        (tester) async {
      final task = _makeTask(isComplete: false);
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Mark as Complete'), findsOneWidget);
    });

    testWidgets('shows "Completed" button for complete task', (tester) async {
      final task = _makeTask(isComplete: true);
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('invokes onEdit callback when edit button tapped',
        (tester) async {
      Task? editedTask;
      final task = _makeTask(name: 'Edit Me');
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (t) => editedTask = t,
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit));
      expect(editedTask?.name, 'Edit Me');
    });

    testWidgets('invokes onDelete callback when delete button tapped',
        (tester) async {
      Task? deletedTask;
      final task = _makeTask(name: 'Delete Me');
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (t) => deletedTask = t,
        updateCompletion: _noOp,
      )));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      expect(deletedTask?.name, 'Delete Me');
    });

    testWidgets('renders multiple tasks', (tester) async {
      final t1 = _makeTask(name: 'Alpha Task');
      final t2 = _makeTask(name: 'Beta Task');
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(t1), _toEvent(t2)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Alpha Task'), findsOneWidget);
      expect(find.text('Beta Task'), findsOneWidget);
    });

    testWidgets('shows assigned patient name when patientId matches',
        (tester) async {
      final task = _makeTask(patientId: 42);
      await tester.pumpWidget(_wrap(TaskListDay(
        events: [_toEvent(task)],
        patientNames: {42: 'Alice'},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.textContaining('Alice'), findsOneWidget);
    });
  });
}
