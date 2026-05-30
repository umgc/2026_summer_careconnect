// Tests for FiltersPanel
// (lib/features/tasks/presentation/widgets/filters_panel.dart).
//
// StatelessWidget — uses UserProvider and TaskTypeManager in build().
// No HTTP calls.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/tasks/presentation/widgets/filters_panel.dart';
import 'package:care_connect_app/features/tasks/utils/task_type_manager.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../../mock_user_provider.dart';

class _NullUserProvider extends MockUserProvider {
  _NullUserProvider() : super(mockUser: null);

  @override
  UserSession? get user => null;
}

Widget _wrap({bool expanded = false}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: _NullUserProvider()),
      ChangeNotifierProvider<TaskTypeManager>(create: (_) => TaskTypeManager()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: FiltersPanel(
          expanded: expanded,
          patientNames: const {},
          selectedTypes: const {},
          selectedPatients: const {},
          onClear: () {},
          onTypeToggled: (_) {},
          onPatientToggled: (_) {},
          onToggleExpanded: () {},
          onTodayPressed: () {},
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FiltersPanel – initial render', () {
    testWidgets('renders without crashing (collapsed)', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FiltersPanel), findsOneWidget);
    });

    testWidgets('shows Filters label', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('shows expand icon when collapsed', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows expand_more icon when expanded', (tester) async {
      await tester.pumpWidget(_wrap(expanded: true));
      await tester.pump();
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('shows Filters text label', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('shows Today button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
