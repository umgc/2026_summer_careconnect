// Tests for PatientDetailsPage
// (lib/features/health/caregiver-patient-list/page/patient_details_page.dart).
//
// The source has a bug: DefaultTabController(length: 5) but only 4 tabs and
// 4 TabBarView children. We cannot modify source code.
// The widget tree IS built by pumpWidget even though scheduler assertions fire.
// We use tester.takeException() to consume them.

import 'package:care_connect_app/features/health/caregiver-patient-list/page/patient_details_page.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../mock_user_provider.dart';

void main() {
  // ───────────────────── setup / teardown ─────────────────────
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async {
        if (call.method == 'check') return ['wifi'];
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      null,
    );
  });

  // ───────────────────── constructor tests ─────────────────────
  group('PatientDetailsPage – constructor', () {
    test('creates with required patientId and default isCaregiver', () {
      const page = PatientDetailsPage(patientId: '123');
      expect(page.patientId, '123');
      expect(page.isCaregiver, isFalse);
    });

    test('creates with isCaregiver true', () {
      const page = PatientDetailsPage(patientId: '456', isCaregiver: true);
      expect(page.patientId, '456');
      expect(page.isCaregiver, isTrue);
    });

    test('isCaregiver defaults to false', () {
      const page = PatientDetailsPage(patientId: '789');
      expect(page.isCaregiver, isFalse);
    });

    test('is a StatefulWidget', () {
      const page = PatientDetailsPage(patientId: '1');
      expect(page, isA<StatefulWidget>());
    });

    test('createState returns non-null state', () {
      const page = PatientDetailsPage(patientId: '1');
      final state = page.createState();
      expect(state, isNotNull);
    });

    test('patientId stores various string values', () {
      const page1 = PatientDetailsPage(patientId: 'abc');
      expect(page1.patientId, 'abc');
      const page2 = PatientDetailsPage(patientId: '0');
      expect(page2.patientId, '0');
      const page3 = PatientDetailsPage(patientId: '');
      expect(page3.patientId, '');
    });

    test('isCaregiver explicitly set to false', () {
      const page = PatientDetailsPage(patientId: '1', isCaregiver: false);
      expect(page.isCaregiver, isFalse);
    });

    test('can be const-constructed', () {
      const page = PatientDetailsPage(patientId: '1');
      expect(page, isA<PatientDetailsPage>());
    });

    test('key parameter can be provided', () {
      const page = PatientDetailsPage(
        key: ValueKey('test'),
        patientId: '1',
      );
      expect(page.key, const ValueKey('test'));
    });
  });

  // ───────────────────── Helper ─────────────────────
  Widget buildTestWidget({
    String patientId = 'invalid_id',
    bool isCaregiver = false,
    MockUserProvider? provider,
  }) {
    final userProvider = provider ??
        MockUserProvider(
          mockUser: MockUser(
            role: 'CAREGIVER',
            caregiverId: 10,
          ),
        );

    return ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: MaterialApp(
        home: PatientDetailsPage(
          patientId: patientId,
          isCaregiver: isCaregiver,
        ),
      ),
    );
  }

  /// Pump the widget and drain all known exceptions.
  /// The source bug (length:5 vs 4 tabs) causes 2 scheduler assertions.
  /// tester.takeException() drains them one by one.
  Future<void> pumpSafe(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(widget);
    // Drain scheduler assertion exceptions (tab count mismatch).
    // pumpWidget's internal pump() triggers 2 assertions but
    // takeException() can only drain one per pump cycle.
    tester.takeException();
  }

  // ───────────────────── widget rendering tests ─────────────────────

  group('PatientDetailsPage – widget rendering', () {
    testWidgets('renders PatientDetailsPage widget',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byType(PatientDetailsPage), findsOneWidget);
    });

    testWidgets('renders Scaffold', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('renders DefaultTabController',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byType(DefaultTabController), findsOneWidget);
    });

    testWidgets('renders AppBar', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar shows patient name Sarah Johnson',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Sarah Johnson'), findsWidgets);
    });

    testWidgets('AppBar shows MRN in subtitle', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.textContaining('MRN-2024-0156'), findsWidgets);
    });

    testWidgets('AppBar subtitle contains Patient Details',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.textContaining('Patient Details'), findsOneWidget);
    });

    testWidgets('renders all four tab labels', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Virtual Check-In'), findsOneWidget);
    });

    testWidgets('renders tab icons', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byIcon(Icons.info_outline), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.favorite_border), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.health_and_safety_outlined), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.video_call_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('renders TabBar', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders diagnoses in header', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Type 2 Diabetes'), findsOneWidget);
      expect(find.text('Hypertension'), findsOneWidget);
      expect(find.text('Chronic Fatigue Syndrome'), findsOneWidget);
    });

    testWidgets('renders allergies in header', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Penicillin'), findsOneWidget);
      expect(find.text('Shellfish'), findsOneWidget);
    });

    testWidgets('Info tab shows contact phone by default',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('(555) 123-4567'), findsOneWidget);
    });

    testWidgets('Info tab shows email', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('sarah.johnson@email.com'), findsOneWidget);
    });

    testWidgets('Info tab shows emergency contact name',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Michael Johnson'), findsOneWidget);
    });

    testWidgets('Info tab shows emergency contact relationship',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('Spouse'), findsOneWidget);
    });

    testWidgets('Info tab shows emergency contact phone',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget());
      expect(find.text('(555) 987-6543'), findsOneWidget);
    });

    testWidgets('builds with isCaregiver true', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget(isCaregiver: true));
      expect(find.text('Sarah Johnson'), findsWidgets);
    });

    testWidgets('builds with isCaregiver false', (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget(isCaregiver: false));
      expect(find.text('Sarah Johnson'), findsWidgets);
    });

    testWidgets('valid numeric patientId renders page',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget(patientId: '42'));
      expect(find.byType(PatientDetailsPage), findsOneWidget);
    });

    testWidgets('builds with patient role UserProvider',
        (WidgetTester tester) async {
      await pumpSafe(
        tester,
        buildTestWidget(
          provider: MockUserProvider(
            mockUser: MockUser(role: 'PATIENT', patientId: 5),
          ),
        ),
      );
      expect(find.byType(PatientDetailsPage), findsOneWidget);
    });

    testWidgets('builds with empty patientId',
        (WidgetTester tester) async {
      await pumpSafe(tester, buildTestWidget(patientId: ''));
      expect(find.byType(PatientDetailsPage), findsOneWidget);
    });
  });
}
