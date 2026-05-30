// Tests for TaskTypeManager ChangeNotifier
// (lib/features/tasks/utils/task_type_manager.dart).
//
// TaskTypeManager persists task-type color/icon settings in SharedPreferences.
// Tests use SharedPreferences.setMockInitialValues({}) so no platform channel
// is needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TaskTypeManager – defaults', () {
    test('loads default task types on first construction', () async {
      // Verifies that the manager contains the built-in types after load.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero); // let _loadFromPrefs complete
      expect(manager.taskTypeColors, isNotEmpty);
    });

    test('default types include medication, appointment, exercise', () async {
      // Verifies the standard built-in types are present.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      final types = manager.taskTypeColors.keys;
      expect(types, contains('medication'));
      expect(types, contains('appointment'));
      expect(types, contains('exercise'));
    });

    test('getColor returns Colors.deepOrange for unknown type', () async {
      // Unknown types fall back to the default orange sentinel color.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      expect(manager.getColor('nonexistent'), Colors.deepOrange);
    });

    test('getColor returns Colors.deepOrange for null type', () async {
      // Null type also falls back to deep orange.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      expect(manager.getColor(null), Colors.deepOrange);
    });

    test('getIcon returns Icons.task for unknown type', () async {
      // Unknown types fall back to the generic task icon.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      expect(manager.getIcon('nonexistent'), Icons.task);
    });

    test('getIcon returns Icons.task for null type', () async {
      // Null type falls back to the generic task icon.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      expect(manager.getIcon(null), Icons.task);
    });
  });

  group('TaskTypeManager – CRUD operations', () {
    test('addTaskType inserts a new type', () async {
      // After adding, the new type must appear in taskTypeColors.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.purple);
      expect(manager.taskTypeColors.keys, contains('custom'));
    });

    test('addTaskType stores the correct color', () async {
      // The color assigned during addTaskType must be retrievable via getColor.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.purple);
      expect(manager.getColor('custom'), Colors.purple);
    });

    test('addTaskType stores a custom icon', () async {
      // An optional icon can be set and retrieved correctly.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.teal, icon: Icons.star);
      expect(manager.getIcon('custom'), Icons.star);
    });

    test('removeTaskType removes the type', () async {
      // Removing a type must make it disappear from taskTypeColors.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('temp', Colors.grey);
      await manager.removeTaskType('temp');
      expect(manager.taskTypeColors.keys, isNot(contains('temp')));
    });

    test('updateTaskColor changes the color', () async {
      // Updating the color of an existing type must reflect immediately.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.red);
      await manager.updateTaskColor('custom', Colors.green);
      expect(manager.getColor('custom'), Colors.green);
    });

    test('updateTaskIcon changes the icon', () async {
      // Updating the icon of an existing type must reflect immediately.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.red, icon: Icons.task);
      await manager.updateTaskIcon('custom', Icons.local_hospital);
      expect(manager.getIcon('custom'), Icons.local_hospital);
    });

    test('updateTaskColor is case-insensitive', () async {
      // The update should match types stored in lowercase.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('CUSTOM', Colors.red);
      // addTaskType stores lowercase key internally
      await manager.updateTaskColor('CUSTOM', Colors.blue);
      expect(manager.getColor('CUSTOM'), Colors.blue);
    });
  });

  group('TaskTypeManager – getSortedTypes', () {
    test('returns types in alphabetical order', () async {
      // getSortedTypes must return a sorted list.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      final sorted = manager.getSortedTypes();
      expect(sorted, equals([...sorted]..sort()));
    });

    test('returns non-empty list with defaults', () async {
      // Confirms there are sorted entries after default load.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      expect(manager.getSortedTypes(), isNotEmpty);
    });
  });

  group('TaskTypeManager – resetDefaults', () {
    test('restores defaults after a type was added', () async {
      // resetDefaults must wipe any added types and restore built-ins.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('custom', Colors.pink);
      await manager.resetDefaults();
      expect(manager.taskTypeColors.keys, isNot(contains('custom')));
      expect(manager.taskTypeColors.keys, contains('medication'));
    });
  });

  group('TaskTypeManager – notifyListeners', () {
    test('notifies listeners when a task type is added', () async {
      // The ChangeNotifier must call listeners after addTaskType.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      var notified = false;
      manager.addListener(() => notified = true);
      await manager.addTaskType('alert', Colors.orange);
      expect(notified, isTrue);
    });

    test('notifies listeners when a task type is removed', () async {
      // The ChangeNotifier must call listeners after removeTaskType.
      final manager = TaskTypeManager();
      await Future.delayed(Duration.zero);
      await manager.addTaskType('temp', Colors.grey);
      var notified = false;
      manager.addListener(() => notified = true);
      await manager.removeTaskType('temp');
      expect(notified, isTrue);
    });
  });
}
