// Tests for medication tracker widgets:
// - MedicationAppHeader (medication-header.dart) — PreferredSizeWidget
// - MedicationCard (medication-card.dart) — StatefulWidget, no HTTP in build

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-header.dart';
import 'package:care_connect_app/features/health/medication-tracker/widgets/medication-card.dart';
import 'package:care_connect_app/features/health/medication-tracker/models/medication-model.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../../mock_user_provider.dart';

Medication _makeMedication() => Medication(
      id: 1,
      medicationName: 'Aspirin',
      dosage: '100mg',
      frequency: 'Daily',
      route: 'Oral',
      isActive: true,
      status: MedicationStatus.upcoming,
    );

Widget _wrapHeader() => MaterialApp(
      home: Scaffold(
        appBar: MedicationAppHeader(onAddPressed: () {}),
        body: const SizedBox(),
      ),
    );

Widget _wrapCard() {
  final provider = MockUserProvider(
    mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
  );
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: Scaffold(
        body: MedicationCard(
          medication: _makeMedication(),
          onStatusChanged: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  group('MedicationAppHeader widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrapHeader());
      expect(find.byType(MedicationAppHeader), findsOneWidget);
    });

    testWidgets('shows "Add" button', (tester) async {
      await tester.pumpWidget(_wrapHeader());
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('shows add icon', (tester) async {
      await tester.pumpWidget(_wrapHeader());
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('MedicationCard widget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byType(MedicationCard), findsOneWidget);
    });

    testWidgets('shows medication name', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.text('Aspirin'), findsOneWidget);
    });

    testWidgets('shows dosage', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('100mg'), findsOneWidget);
    });

    testWidgets('shows frequency', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('Daily'), findsOneWidget);
    });

    testWidgets('shows route info', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('Route: Oral'), findsOneWidget);
    });

    testWidgets('shows next dose text', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('Next dose:'), findsOneWidget);
    });

    testWidgets('shows access_time icon', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows info_outline icon', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows delete icon for active non-prescription', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows "Remove medication" tooltip', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byTooltip('Remove medication'), findsOneWidget);
    });

    testWidgets('hides delete icon for prescription medication', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Prescription Med',
        dosage: '50mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: true,
        medicationType: MedicationType.PRESCRIPTION,
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: MedicationCard(medication: med, onStatusChanged: (_) {}),
          ),
        ),
      ));
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('hides delete icon for inactive medication', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Inactive Med',
        dosage: '25mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: false,
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: SingleChildScrollView(
              child: MedicationCard(medication: med, onStatusChanged: (_) {}),
            ),
          ),
        ),
      ));
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows pending removal banner for inactive medication',
        (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Pending Med',
        dosage: '10mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: false,
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: SingleChildScrollView(
              child: MedicationCard(medication: med, onStatusChanged: (_) {}),
            ),
          ),
        ),
      ));
      expect(find.byIcon(Icons.pending_outlined), findsOneWidget);
      expect(find.textContaining('pending caregiver approval'), findsOneWidget);
    });

    testWidgets('shows prescribed by when provided', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Prescribed Med',
        dosage: '20mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: true,
        prescribedBy: 'Dr. Smith',
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: MedicationCard(medication: med, onStatusChanged: (_) {}),
          ),
        ),
      ));
      expect(find.textContaining('Prescribed by: Dr. Smith'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('hides prescribed by when null', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('Prescribed by'), findsNothing);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('shows notes when provided', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Noted Med',
        dosage: '5mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: true,
        notes: 'Take with food',
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: MedicationCard(medication: med, onStatusChanged: (_) {}),
          ),
        ),
      ));
      expect(find.text('Take with food'), findsOneWidget);
      expect(find.byIcon(Icons.note_outlined), findsOneWidget);
    });

    testWidgets('hides notes when null', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.byIcon(Icons.note_outlined), findsNothing);
    });

    testWidgets('hides notes when empty string', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Empty Notes Med',
        dosage: '5mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: true,
        notes: '',
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: MedicationCard(medication: med, onStatusChanged: (_) {}),
          ),
        ),
      ));
      expect(find.byIcon(Icons.note_outlined), findsNothing);
    });

    testWidgets('shows "Not specified" when nextDose is null', (tester) async {
      await tester.pumpWidget(_wrapCard());
      expect(find.textContaining('Not specified'), findsOneWidget);
    });

    testWidgets('shows custom nextDose text', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1),
      );
      final med = const Medication(
        id: 1,
        medicationName: 'Timed Med',
        dosage: '10mg',
        frequency: 'Daily',
        route: 'Oral',
        isActive: true,
        nextDose: '8:00 AM',
      );
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: Scaffold(
            body: MedicationCard(medication: med, onStatusChanged: (_) {}),
          ),
        ),
      ));
      expect(find.textContaining('8:00 AM'), findsOneWidget);
    });

    testWidgets('tapping delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_wrapCard());
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text('Remove Medication'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to remove Aspirin'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('Cancel dismisses delete confirmation', (tester) async {
      await tester.pumpWidget(_wrapCard());
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Medication'), findsNothing);
    });
  });
}
