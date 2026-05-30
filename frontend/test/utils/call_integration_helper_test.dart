// Tests for CallIntegrationHelper (lib/utils/call_integration_helper.dart).
//
// Covers:
//   - createPatientActionButtons widget rendering & tooltips
//   - createCaregiverActionButtons widget rendering & tooltips
//   - createSOSButton rendering & SOS dialog
//   - showSOSDialog emergency type listing & cancel
//   - _showSMSDialog (indirectly via SMS button taps) including send/cancel
//   - _extractPatientData / _extractCaregiverData (indirectly via SMS dialog
//     title which uses the extracted name)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/utils/call_integration_helper.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/providers/user_provider.dart';

Widget _wrapWithProvider(Widget child) {
  return ChangeNotifierProvider<UserProvider>(
    create: (_) => UserProvider(),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Wraps with MaterialApp + Scaffold + ScaffoldMessenger so snackbars work
Widget _wrapWithScaffold(Widget child) {
  return ChangeNotifierProvider<UserProvider>(
    create: (_) => UserProvider(),
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
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
  });

  // ---------------------------------------------------------------------------
  // createPatientActionButtons
  // ---------------------------------------------------------------------------
  group('createPatientActionButtons', () {
    testWidgets('renders video, audio, and sms icon buttons', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('renders exactly 3 IconButtons in a Row', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      // The top-level Row wrapping the 3 buttons
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsWidgets);
      expect(find.byType(IconButton), findsNWidgets(3));
    });

    testWidgets('icon buttons have correct tooltips', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      expect(find.byTooltip('Video Call'), findsOneWidget);
      expect(find.byTooltip('Audio Call'), findsOneWidget);
      expect(find.byTooltip('Send SMS'), findsOneWidget);
    });

    testWidgets('icon buttons have correct colors', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );

      // Check videocam icon color
      final videocamIcon =
          tester.widget<Icon>(find.byIcon(Icons.videocam));
      expect(videocamIcon.color, Colors.blue);

      // Check call icon color
      final callIcon = tester.widget<Icon>(find.byIcon(Icons.call));
      expect(callIcon.color, Colors.green);

      // Check sms icon color
      final smsIcon = tester.widget<Icon>(find.byIcon(Icons.sms));
      expect(smsIcon.color, Colors.orange);
    });

    testWidgets('SMS button opens dialog with patient name from direct map',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'John Doe'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to John Doe'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog uses firstName/lastName when name not provided (patient)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'firstName': 'Jane', 'lastName': 'Smith'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Jane Smith'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog uses nested patient key for extraction',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {
              'patient': {
                'id': 99,
                'firstName': 'Nested',
                'lastName': 'Patient',
                'email': 'np@test.com',
                'phone': '5551234567',
              },
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Nested Patient'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog shows Unknown Patient when null target',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: null,
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Unknown Patient'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog shows Unknown Patient when target is non-Map object',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: 'just a string',
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Unknown Patient'), findsOneWidget);
    });

    testWidgets('SMS dialog Cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to PT'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to PT'), findsNothing);
    });

    testWidgets('SMS dialog Send button with empty message does not close',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();

      // Tap Send without entering text
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Dialog should still be visible because message is empty
      expect(find.text('Send SMS to PT'), findsOneWidget);
    });

    testWidgets('SMS dialog Send button with whitespace-only does not close',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();

      // Enter whitespace only
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      // Dialog should still be open
      expect(find.text('Send SMS to PT'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog TextField has correct decoration', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();

      expect(find.text('Enter your message...'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // createCaregiverActionButtons
  // ---------------------------------------------------------------------------
  group('createCaregiverActionButtons', () {
    testWidgets('renders video, audio, and sms icon buttons', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'Caregiver B'},
          ),
        )),
      );
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('icon buttons have correct tooltips', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'Caregiver B'},
          ),
        )),
      );
      expect(find.byTooltip('Video Call'), findsOneWidget);
      expect(find.byTooltip('Audio Call'), findsOneWidget);
      expect(find.byTooltip('Send SMS'), findsOneWidget);
    });

    testWidgets('SMS button opens dialog with caregiver name from direct map',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'Dr. Smith'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Dr. Smith'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog uses firstName/lastName when name not provided (caregiver)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {
              'id': 20,
              'firstName': 'Alice',
              'lastName': 'Jones',
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Alice Jones'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog uses nested caregiver key for extraction',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {
              'caregiver': {
                'id': 55,
                'name': 'Nested CG',
                'email': 'ncg@test.com',
                'phone': '5559876543',
              },
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Nested CG'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog uses nested caregiver with firstName/lastName',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {
              'caregiver': {
                'id': 55,
                'firstName': 'Bob',
                'lastName': 'Caregiver',
              },
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Bob Caregiver'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog shows Unknown Caregiver when null target',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: null,
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Unknown Caregiver'), findsOneWidget);
    });

    testWidgets(
        'SMS dialog shows Unknown Caregiver when target is non-Map object',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: 42,
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to Unknown Caregiver'), findsOneWidget);
    });

    testWidgets('SMS dialog Cancel closes dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'CG'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to CG'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to CG'), findsNothing);
    });

    testWidgets('icon buttons have correct colors', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'CG'},
          ),
        )),
      );

      final videocamIcon =
          tester.widget<Icon>(find.byIcon(Icons.videocam));
      expect(videocamIcon.color, Colors.blue);

      final callIcon = tester.widget<Icon>(find.byIcon(Icons.call));
      expect(callIcon.color, Colors.green);

      final smsIcon = tester.widget<Icon>(find.byIcon(Icons.sms));
      expect(smsIcon.color, Colors.orange);
    });
  });

  // ---------------------------------------------------------------------------
  // createSOSButton
  // ---------------------------------------------------------------------------
  group('createSOSButton', () {
    testWidgets('renders SOS EMERGENCY button', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      expect(find.text('SOS EMERGENCY'), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
    });

    testWidgets('SOS button is an ElevatedButton', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('SOS button is wrapped in a Container with margin',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      // The widget returned is a Container
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.margin, const EdgeInsets.all(16));
    });

    testWidgets('tapping SOS button shows dialog with emergency types',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      await tester.tap(find.text('SOS EMERGENCY'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsOneWidget);
      expect(find.text('Fall Emergency'), findsOneWidget);
      expect(find.text('Medical Emergency'), findsOneWidget);
      expect(find.text('Panic/Anxiety'), findsOneWidget);
      expect(find.text('Other Emergency'), findsOneWidget);
    });

    testWidgets('SOS dialog shows descriptions for each emergency type',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      await tester.tap(find.text('SOS EMERGENCY'));
      await tester.pumpAndSettle();
      expect(
          find.text('Patient has fallen and needs assistance'), findsOneWidget);
      expect(
          find.text('Medical condition requiring immediate attention'),
          findsOneWidget);
      expect(find.text('Panic attack or severe anxiety episode'),
          findsOneWidget);
      expect(find.text('Other type of emergency situation'), findsOneWidget);
    });

    testWidgets('SOS dialog shows correct icons', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      await tester.tap(find.text('SOS EMERGENCY'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.accessibility_new), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('SOS dialog Cancel button closes dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      await tester.tap(find.text('SOS EMERGENCY'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsNothing);
    });

    testWidgets('SOS dialog shows instruction text', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => CallIntegrationHelper.createSOSButton(
            context: ctx,
            currentPatient: {'id': 1, 'name': 'Patient'},
          ),
        )),
      );
      await tester.tap(find.text('SOS EMERGENCY'));
      await tester.pumpAndSettle();
      expect(find.text('Select the type of emergency:'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // showSOSDialog (static method, called directly)
  // ---------------------------------------------------------------------------
  group('showSOSDialog', () {
    testWidgets('shows dialog with all four emergency types',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => CallIntegrationHelper.showSOSDialog(
              context: ctx,
              currentPatient: {'id': 1, 'name': 'Test Patient'},
            ),
            child: const Text('Trigger'),
          ),
        )),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsOneWidget);
      expect(find.text('Fall Emergency'), findsOneWidget);
      expect(find.text('Medical Emergency'), findsOneWidget);
      expect(find.text('Panic/Anxiety'), findsOneWidget);
      expect(find.text('Other Emergency'), findsOneWidget);
    });

    testWidgets('cancel button closes the dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => CallIntegrationHelper.showSOSDialog(
              context: ctx,
              currentPatient: {'id': 1, 'name': 'Test Patient'},
            ),
            child: const Text('Trigger'),
          ),
        )),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('🚨 SOS Emergency'), findsNothing);
    });

    testWidgets('emergency types are rendered as ListTiles inside Cards',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProvider(Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => CallIntegrationHelper.showSOSDialog(
              context: ctx,
              currentPatient: {'id': 1, 'name': 'Test Patient'},
            ),
            child: const Text('Trigger'),
          ),
        )),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      // There should be 4 Cards (one per emergency type)
      expect(find.byType(Card), findsNWidgets(4));
      expect(find.byType(ListTile), findsNWidgets(4));
    });
  });

  // ---------------------------------------------------------------------------
  // _extractPatientData edge cases via SMS dialog title
  // ---------------------------------------------------------------------------
  group('_extractPatientData edge cases (via SMS dialog)', () {
    testWidgets('handles map with only id, no name fields',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 99},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      // When no name/firstName/lastName, the fallback combines empty strings
      // '' + '' = '' trimmed = '' which is falsy, so name fallback is ''
      // The dialog title includes whatever name is extracted
      expect(find.textContaining('Send SMS to'), findsOneWidget);
    });

    testWidgets('handles map with only firstName', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'firstName': 'OnlyFirst'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to OnlyFirst'), findsOneWidget);
    });

    testWidgets('handles map with only lastName', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'lastName': 'OnlyLast'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to OnlyLast'), findsOneWidget);
    });

    testWidgets('nested patient with only firstName', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {
              'patient': {'id': 5, 'firstName': 'NestedFirst'},
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to NestedFirst'), findsOneWidget);
    });

    testWidgets('nested patient with empty firstName and lastName',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {
              'patient': {'id': 5, 'firstName': '', 'lastName': ''},
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      // Trimmed empty string
      expect(find.textContaining('Send SMS to'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // _extractCaregiverData edge cases via SMS dialog title
  // ---------------------------------------------------------------------------
  group('_extractCaregiverData edge cases (via SMS dialog)', () {
    testWidgets('handles map with only firstName for caregiver',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient'},
            targetCaregiver: {'id': 20, 'firstName': 'CareFirst'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to CareFirst'), findsOneWidget);
    });

    testWidgets('handles map with only lastName for caregiver',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient'},
            targetCaregiver: {'id': 20, 'lastName': 'CareLast'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to CareLast'), findsOneWidget);
    });

    testWidgets('nested caregiver with only lastName', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient'},
            targetCaregiver: {
              'caregiver': {'id': 30, 'lastName': 'NestedLast'},
            },
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      expect(find.text('Send SMS to NestedLast'), findsOneWidget);
    });

    testWidgets('handles empty map for caregiver', (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient'},
            targetCaregiver: <String, dynamic>{},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();
      // Empty map still hits the direct map branch, resulting in empty name
      expect(find.textContaining('Send SMS to'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // SMS dialog interaction (Send button with valid text)
  // ---------------------------------------------------------------------------
  group('SMS dialog send behavior', () {
    testWidgets(
        'Send button with valid text closes dialog and shows snackbar (patient)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) => CallIntegrationHelper.createPatientActionButtons(
            context: ctx,
            currentCaregiver: {'id': 1, 'name': 'CG'},
            targetPatient: {'id': 2, 'name': 'PT'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello patient!');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Send SMS to PT'), findsNothing);
      // Snackbar should appear
      expect(find.text('SMS sent to PT'), findsOneWidget);
    });

    testWidgets(
        'Send button with valid text closes dialog and shows snackbar (caregiver)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScaffold(Builder(
          builder: (ctx) =>
              CallIntegrationHelper.createCaregiverActionButtons(
            context: ctx,
            currentPatient: {'id': 10, 'name': 'Patient A'},
            targetCaregiver: {'id': 20, 'name': 'CG'},
          ),
        )),
      );
      await tester.tap(find.byIcon(Icons.sms));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello caregiver!');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.text('Send SMS to CG'), findsNothing);
      expect(find.text('SMS sent to CG'), findsOneWidget);
    });
  });
}
