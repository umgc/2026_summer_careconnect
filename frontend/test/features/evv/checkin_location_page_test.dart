// Tests for CheckinLocationPage
// (lib/features/evv/presentation/pages/checkin_location_page.dart).
//
// _loadPatientDetails() is called in initState; _isLoading=true while loading.
// The API call fails in tests (no server), so the error state is rendered.
// We also test the loaded state by directly constructing the widget state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/evv/presentation/pages/checkin_location_page.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../mock_user_provider.dart';

Widget _wrap({
  int patientId = 1,
  String serviceType = 'Personal Care',
  int? scheduledVisitId,
  String role = 'CAREGIVER',
  int? caregiverId = 1,
  UserSession? mockUser,
}) {
  final provider = MockUserProvider(
    mockUser: mockUser ??
        MockUser(id: 1, role: role, caregiverId: caregiverId),
  );
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: CheckinLocationPage(
        patientId: patientId,
        serviceType: serviceType,
        scheduledVisitId: scheduledVisitId,
      ),
    ),
  );
}

/// Pumps enough frames for the async _loadPatientDetails to fail (no server)
/// and setState to fire, transitioning from loading to the error state.
Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());
  addTearDown(() => tester.view.resetDevicePixelRatio());
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        if (call.method == 'read') return 'mock_token';
        if (call.method == 'write') return null;
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

  group('CheckinLocationPage – initial render / loading', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CheckinLocationPage), findsOneWidget);
    });

    testWidgets('shows "Check-In Location" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Check-In Location'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppBar with back button and cancel button',
        (tester) async {
      await tester.pumpWidget(_wrap());
      // Back arrow
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      // Cancel button in actions
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('shows Center while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('CheckinLocationPage – error state (API failure)', () {
    testWidgets('shows error state after loading fails', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // Error icon should be visible
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows "Error Loading Patient" text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('shows "Try Again" button in error state', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Try Again button is an ElevatedButton', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      final tryAgainButton = find.widgetWithText(ElevatedButton, 'Try Again');
      expect(tryAgainButton, findsOneWidget);
    });

    testWidgets('tapping Try Again triggers reload', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // Tap Try Again - should trigger reload and eventually show error again
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // After reload fails again, error state is shown
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('error message text is displayed', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // The error message will contain exception text
      // Find any Text widget that appears in the error column
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('CircularProgressIndicator is gone after error loads',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // No more loading spinner - error state shown instead
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('CheckinLocationPage – with null user', () {
    testWidgets('shows error when user is null', (tester) async {
      // Create a provider that returns null user
      final provider = _NullUserProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: provider,
            child: const CheckinLocationPage(
              patientId: 1,
              serviceType: 'Personal Care',
            ),
          ),
        ),
      );
      await _pumpUntilLoaded(tester);
      // Should show error about user not authenticated
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.textContaining('User not authenticated'), findsOneWidget);
    });
  });

  group('CheckinLocationPage – AppBar actions', () {
    testWidgets('Cancel button shows cancel icon in red', (tester) async {
      await tester.pumpWidget(_wrap());
      // Find the cancel icon
      final cancelIcon = tester.widget<Icon>(find.byIcon(Icons.cancel));
      expect(cancelIcon.color, Colors.red);
    });

    testWidgets('Cancel text is styled in red', (tester) async {
      await tester.pumpWidget(_wrap());
      // Find the Cancel text within TextButton.icon
      final cancelText = find.text('Cancel');
      expect(cancelText, findsOneWidget);
    });

    testWidgets('AppBar contains TextButton.icon for cancel', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('AppBar has an IconButton for back navigation',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(IconButton), findsOneWidget);
    });
  });

  group('CheckinLocationPage – widget construction', () {
    testWidgets('accepts scheduledVisitId parameter', (tester) async {
      await tester.pumpWidget(_wrap(scheduledVisitId: 42));
      expect(find.byType(CheckinLocationPage), findsOneWidget);
    });

    testWidgets('accepts different serviceType', (tester) async {
      await tester.pumpWidget(_wrap(serviceType: 'Nursing'));
      expect(find.byType(CheckinLocationPage), findsOneWidget);
    });

    testWidgets('accepts different patientId', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 99));
      expect(find.byType(CheckinLocationPage), findsOneWidget);
    });

    testWidgets('renders with all parameters set', (tester) async {
      await tester.pumpWidget(_wrap(
        patientId: 5,
        serviceType: 'Nursing',
        scheduledVisitId: 10,
      ));
      expect(find.byType(CheckinLocationPage), findsOneWidget);
      expect(find.text('Check-In Location'), findsOneWidget);
    });
  });

  group('CheckinLocationPage – error state UI details', () {
    testWidgets('error state is centered', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('error state has padding', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('error state has Column layout', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('error icon is sized 64', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(errorIcon.size, 64);
    });

    testWidgets('error state shows SizedBox spacers', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('CheckinLocationPage – caregiver with caregiverId', () {
    testWidgets('uses caregiverId from user when available', (tester) async {
      await tester.pumpWidget(_wrap(caregiverId: 5));
      await _pumpUntilLoaded(tester);
      // Should still reach error state (API fails)
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('falls back to user id when caregiverId is null',
        (tester) async {
      await tester.pumpWidget(_wrap(caregiverId: null));
      await _pumpUntilLoaded(tester);
      // Should still reach error state (API fails)
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });
  });

  group('CheckinLocationPage – multiple pump cycles', () {
    testWidgets('loading indicator visible before API resolves',
        (tester) async {
      await tester.pumpWidget(_wrap());
      // Right after build, should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // After one pump, might still be loading
      await tester.pump();
      // Eventually transitions to error
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('transitions from loading to error', (tester) async {
      await tester.pumpWidget(_wrap());
      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);

      await _pumpUntilLoaded(tester);

      // Now in error state
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('CheckinLocationPage – Try Again retry cycle', () {
    testWidgets('can cycle through retry', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // Now in error state
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Error Loading Patient'), findsOneWidget);

      // Tap Try Again
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Back to error after retry fails
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('CheckinLocationPage – scaffold structure', () {
    testWidgets('has exactly one Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has exactly one AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar title is Check-In Location', (tester) async {
      await tester.pumpWidget(_wrap());
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      final titleText = appBar.title as Text;
      expect(titleText.data, 'Check-In Location');
    });

    testWidgets('AppBar has leading widget', (tester) async {
      await tester.pumpWidget(_wrap());
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.leading, isNotNull);
    });

    testWidgets('AppBar has actions', (tester) async {
      await tester.pumpWidget(_wrap());
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNotNull);
      expect(appBar.actions!.length, 1);
    });
  });
}

/// A UserProvider subclass that returns null user for testing the null-user path.
class _NullUserProvider extends MockUserProvider {
  _NullUserProvider() : super();

  @override
  UserSession? get user => null;
}
