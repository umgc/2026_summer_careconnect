// Tests for symptom tracker widgets:
// - AllergyCard (allergies_card.dart) — pure StatelessWidget
// - SymptomTab (symptom_tab.dart) — fetches data in initState
// - AllergiesTab (allergies_tab.dart) — fetches data in initState

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/allergies_card.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/symptom_tab.dart';
import 'package:care_connect_app/features/health/symptom-tracker/widgets/allergies_tab.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../../mock_user_provider.dart';

Widget _wrapWidget(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

Widget _wrapWithProvider(Widget child) {
  final provider = MockUserProvider(
    mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
  );
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AllergyCard widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrapWidget(AllergyCard(
        drug: 'Penicillin',
        reaction: 'Hives',
        severity: 'Severe',
        note: 'Avoid all penicillin-based antibiotics',
        onDelete: () {},
      )));
      expect(find.byType(AllergyCard), findsOneWidget);
    });

    testWidgets('shows drug name', (tester) async {
      await tester.pumpWidget(_wrapWidget(AllergyCard(
        drug: 'Penicillin',
        reaction: 'Hives',
        severity: 'Severe',
        note: 'Test note',
        onDelete: () {},
      )));
      expect(find.text('Penicillin'), findsOneWidget);
    });

    testWidgets('shows reaction', (tester) async {
      await tester.pumpWidget(_wrapWidget(AllergyCard(
        drug: 'Aspirin',
        reaction: 'Rash',
        severity: 'Mild',
        note: '',
        onDelete: () {},
      )));
      expect(find.textContaining('Rash'), findsOneWidget);
    });

    testWidgets('shows delete icon button', (tester) async {
      await tester.pumpWidget(_wrapWidget(AllergyCard(
        drug: 'Drug',
        reaction: 'Reaction',
        severity: 'Mild',
        note: '',
        onDelete: () {},
      )));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('SymptomTab widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(const SymptomTab(patientId: '1')),
      );
      expect(find.byType(SymptomTab), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(const SymptomTab(patientId: '1')),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('AllergiesTab widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(const AllergiesTab(patientId: '1')),
      );
      expect(find.byType(AllergiesTab), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(const AllergiesTab(patientId: '1')),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
