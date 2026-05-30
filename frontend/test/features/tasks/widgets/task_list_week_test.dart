// Tests for TaskListWeek widget
// (lib/features/tasks/presentation/widgets/task_list_week.dart).
//
// TaskListWeek is structurally identical to TaskListDay but groups tasks
// across a week and adds date info to each subtitle.
// updateCompletion is injectable — tests pass a no-op to avoid API calls.

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/task_list_week.dart';
import 'package:care_connect_app/features/tasks/models/task_model.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

final _date = DateTime(2025, 6, 15);

Task _makeTask({
  String name = 'Test Task',
  bool isComplete = false,
  int? patientId,
  DateTime? date,
}) =>
    Task(
      id: 1,
      name: name,
      description: '',
      date: date ?? _date,
      isComplete: isComplete,
      taskType: 'appointment',
      assignedPatientId: patientId,
    );

CalendarEventData<Task> _toEvent(Task task) => CalendarEventData<Task>(
      title: task.name,
      date: task.date,
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

  group('TaskListWeek – empty events', () {
    testWidgets('shows "No tasks this week" when events is empty',
        (tester) async {
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('No tasks this week'), findsOneWidget);
    });

    testWidgets('does NOT render ListView for empty events', (tester) async {
      await tester.pumpWidget(_wrap(TaskListWeek(
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

  group('TaskListWeek – with events', () {
    testWidgets('renders without crashing', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.byType(TaskListWeek), findsOneWidget);
    });

    testWidgets('shows task name', (tester) async {
      final task = _makeTask(name: 'Doctor Appointment');
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Doctor Appointment'), findsOneWidget);
    });

    testWidgets('shows "All day" for task with no time', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.textContaining('All day'), findsOneWidget);
    });

    testWidgets('shows edit and delete buttons', (tester) async {
      final task = _makeTask();
      await tester.pumpWidget(_wrap(TaskListWeek(
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

    testWidgets('shows "Mark as Complete" for incomplete task', (tester) async {
      final task = _makeTask(isComplete: false);
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Mark as Complete'), findsOneWidget);
    });

    testWidgets('shows "Completed" for complete task', (tester) async {
      final task = _makeTask(isComplete: true);
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('invokes onEdit callback', (tester) async {
      Task? edited;
      final task = _makeTask(name: 'Edit Target');
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (t) => edited = t,
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.edit));
      expect(edited?.name, 'Edit Target');
    });

    testWidgets('invokes onDelete callback', (tester) async {
      Task? deleted;
      final task = _makeTask(name: 'Delete Target');
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (t) => deleted = t,
        updateCompletion: _noOp,
      )));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete));
      expect(deleted?.name, 'Delete Target');
    });

    testWidgets('renders two tasks from different days', (tester) async {
      final t1 = _makeTask(name: 'Monday Task', date: DateTime(2025, 6, 16));
      final t2 = _makeTask(name: 'Friday Task', date: DateTime(2025, 6, 20));
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(t1), _toEvent(t2)],
        patientNames: {},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.text('Monday Task'), findsOneWidget);
      expect(find.text('Friday Task'), findsOneWidget);
    });

    testWidgets('shows patient name when patientId matches', (tester) async {
      final task = _makeTask(patientId: 7);
      await tester.pumpWidget(_wrap(TaskListWeek(
        events: [_toEvent(task)],
        patientNames: {7: 'Bob'},
        onEdit: (_) {},
        onDelete: (_) {},
        updateCompletion: _noOp,
      )));
      await tester.pump();
      expect(find.textContaining('Bob'), findsOneWidget);
    });
  });
}
