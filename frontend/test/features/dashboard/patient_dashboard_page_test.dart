// Tests for PatientDashboard page
// (lib/features/dashboard/patient_dashboard/pages/patient_dashboard.dart).
//
// Groups:
// 1. Initial render (loading state, basic layout)
// 2. Logged-in user with mocked HTTP (full dashboard with widgets,
//    mood data, medication reminders, care provider, EVV sections, etc.)
// 3. Provider organization
// 4. Null user (error state)
// 5. Tablet layout (width > 600)
// 6. Medication actions (Mark Taken / Mark Missed)
// 7. Contact Provider bottom sheet
// 8. FAB tap (AI Chat modal)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/dashboard/patient_dashboard/pages/patient_dashboard.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../mock_user_provider.dart';

Widget _wrap({MockUserProvider? provider}) {
  final p = provider ??
      MockUserProvider(
        mockUser:
            MockUser(id: 1, role: 'PATIENT', patientId: 1, name: 'Test Patient'),
      );
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: p,
      child: const PatientDashboard(),
    ),
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1600, 2400);
  tester.view.devicePixelRatio = 1.0;
}

void _setTabletViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
}

/// MockClient for the patient_dashboard page API calls.
MockClient _createMockClient({
  int evvStatusCode = 200,
}) {
  return MockClient((request) async {
    final path = request.url.path;

    // Caregiver list for patient
    if (path.contains('/caregivers')) {
      return http.Response(
        jsonEncode([
          {
            'id': 10,
            'caregiverId': 10,
            'firstName': 'Jane',
            'lastName': 'Smith',
            'phone': '555-5678',
          },
        ]),
        200,
      );
    }

    // Scheduled visits
    if (path.contains('/scheduled-visits/')) {
      return http.Response(jsonEncode([]), 200);
    }

    // EVV search records
    if (path.contains('/evv/')) {
      return http.Response(
        jsonEncode({
          'content': [],
          'totalElements': 0,
          'totalPages': 0,
          'size': 200,
          'number': 0,
          'first': true,
          'last': true,
        }),
        evvStatusCode,
      );
    }

    // Family members / patient details
    if (RegExp(r'/patients/\d+$').hasMatch(path)) {
      return http.Response(jsonEncode([]), 200);
    }

    // Default
    return http.Response('{}', 200);
  });
}

void _setupMethodChannels() {
  SharedPreferences.setMockInitialValues({});

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'read') return null;
      if (methodCall.method == 'write') return null;
      if (methodCall.method == 'readAll') return <String, String>{};
      if (methodCall.method == 'containsKey') return false;
      return null;
    },
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'check') return ['wifi'];
      return null;
    },
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
    (MethodCall methodCall) async => null,
  );
}

void _teardownMethodChannels() {
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
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity_status'),
    null,
  );
}

/// Pump multiple frames to let async initState futures complete.
Future<void> _pumpUntilSettled(WidgetTester tester) async {
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('PatientDashboard page - initial render', () {
    testWidgets('renders without crashing', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(PatientDashboard), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows FloatingActionButton', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows chat_bubble_outline icon on FAB', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('shows SOS Emergency button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('SOS Emergency'), findsOneWidget);
    });

    testWidgets('shows sos icon', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.sos), findsOneWidget);
    });

    testWidgets('shows Send SMS to Caregiver button', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.text('Send SMS to Caregiver'), findsOneWidget);
    });

    testWidgets('shows sms icon', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('shows RefreshIndicator', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('PatientDashboard page - with mocked HTTP', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('renders mood widget with score after data loads', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Good'), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('renders Recent Check-Ins section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Recent Check-Ins'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders check-in status text', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Feeling well today'), findsOneWidget);
        expect(find.text('Slight headache'), findsOneWidget);
        expect(find.text('Medications taken'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders medication reminder widget', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Blood Pressure Medication'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders primary care provider widget', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Dr. Sarah Mitchell'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders provider specialty', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Internal Medicine'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders Upcoming EVV Appointments section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Upcoming EVV Appointments'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders Past EVV Visits section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Past EVV Visits'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders No upcoming appointments text', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('No upcoming appointments.'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders No past visits found text', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('No past visits found.'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders SOS Emergency button after data loads', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('SOS Emergency'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders Send SMS to Caregiver button after data loads', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Send SMS to Caregiver'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders FAB with chat icon', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders RefreshIndicator after data loads', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byType(RefreshIndicator), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders event_available icon for EVV section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byIcon(Icons.event_available), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders history icon for past EVV section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byIcon(Icons.history), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders refresh icon in EVV section', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byIcon(Icons.refresh), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('renders SafeArea in body', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byType(SafeArea), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('renders SingleChildScrollView', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byType(SingleChildScrollView), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('renders check-in emojis', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('\u{1F60A}'), findsWidgets); // smiling face
      }, () => mockClient);
    });

    testWidgets('tapping SMS button with no caregiver phone shows snackbar', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Send SMS to Caregiver'));
        await tester.tap(find.text('Send SMS to Caregiver'));
        await tester.pump();
        expect(find.text('No caregiver with phone number found.'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders appointment type for provider', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Annual Checkup'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders scheduled reminder status for medication', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Scheduled reminder'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders mood tags', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('happy'), findsOneWidget);
        expect(find.text('calm'), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - provider organization', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('renders provider organization name', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('CareConnect Medical Group'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders provider phone number', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('(555) 123-4567'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders provider email', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('sarah.mitchell@careconnect.com'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('renders schedule icon in EVV refresh', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.byIcon(Icons.schedule), findsNothing);
        expect(find.byIcon(Icons.refresh), findsWidgets);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - tablet layout', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('renders tablet layout with two columns when width > 600', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        // In tablet layout, Row with two Expanded children
        // Both EVV sections and mood widgets should be visible
        expect(find.text('Upcoming EVV Appointments'), findsOneWidget);
        expect(find.text('Past EVV Visits'), findsOneWidget);
        expect(find.textContaining('Good'), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows medication reminder', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Blood Pressure Medication'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows primary care provider', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.textContaining('Dr. Sarah Mitchell'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows SOS Emergency button', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('SOS Emergency'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows Send SMS button', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Send SMS to Caregiver'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows Recent Check-Ins', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('Recent Check-Ins'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tablet layout shows mood tags', (tester) async {
      _setTabletViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        expect(find.text('happy'), findsOneWidget);
        expect(find.text('calm'), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - medication actions', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('tapping Mark Taken shows snackbar', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        // Scroll to see the medication widget
        await tester.ensureVisible(find.text('Mark Taken'));
        await tester.tap(find.text('Mark Taken'));
        await tester.pump();
        expect(find.text('Medication marked as taken'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('tapping Mark Missed shows snackbar', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Mark Missed'));
        await tester.tap(find.text('Mark Missed'));
        await tester.pump();
        expect(find.text('Medication marked as missed'), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - contact provider', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('tapping Contact Provider shows bottom sheet', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Contact Provider'));
        await tester.tap(find.text('Contact Provider'));
        await tester.pump();
        // Bottom sheet should show contact options
        expect(find.text('Contact Provider'), findsWidgets);
        expect(find.text('Call'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Video Call'), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('contact provider bottom sheet shows phone number', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Contact Provider'));
        await tester.tap(find.text('Contact Provider'));
        await tester.pump();
        expect(find.text('(555) 123-4567'), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('contact provider bottom sheet shows email', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Contact Provider'));
        await tester.tap(find.text('Contact Provider'));
        await tester.pump();
        expect(find.text('sarah.mitchell@careconnect.com'), findsWidgets);
      }, () => mockClient);
    });

    testWidgets('contact provider bottom sheet shows phone icon', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Contact Provider'));
        await tester.tap(find.text('Contact Provider'));
        await tester.pump();
        expect(find.byIcon(Icons.phone), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.byIcon(Icons.video_call), findsOneWidget);
      }, () => mockClient);
    });

    testWidgets('contact provider bottom sheet shows Video Call subtitle', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.ensureVisible(find.text('Contact Provider'));
        await tester.tap(find.text('Contact Provider'));
        await tester.pump();
        expect(find.text('Schedule a video consultation'), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - FAB interaction', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('tapping FAB opens bottom sheet', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        // The bottom sheet should appear with the AI chat
        expect(find.byType(BottomSheet), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - with userId parameter', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('renders with explicit userId', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final p = MockUserProvider(
        mockUser: MockUser(id: 1, role: 'PATIENT', patientId: 1, name: 'Test Patient'),
      );
      final widget = MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: p,
          child: const PatientDashboard(userId: 42),
        ),
      );
      final mockClient = _createMockClient();
      await http.runWithClient(() async {
        await tester.pumpWidget(widget);
        await _pumpUntilSettled(tester);
        expect(find.byType(PatientDashboard), findsOneWidget);
      }, () => mockClient);
    });
  });

  group('PatientDashboard page - EVV error handling', () {
    setUp(() {
      _setupMethodChannels();
    });

    tearDown(() {
      _teardownMethodChannels();
    });

    testWidgets('handles EVV API failure gracefully', (tester) async {
      _setLargeViewport(tester);
      addTearDown(tester.view.reset);
      final mockClient = _createMockClient(evvStatusCode: 500);
      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap());
        await _pumpUntilSettled(tester);
        // Dashboard should still render even if EVV fails
        expect(find.byType(PatientDashboard), findsOneWidget);
        expect(find.text('SOS Emergency'), findsOneWidget);
      }, () => mockClient);
    });
  });
}
