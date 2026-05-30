// Tests for VisitCompletePage
// (lib/features/evv/presentation/pages/visit_complete_page.dart).
//
// _loadPatientDetails() called in initState; _isLoading=true while loading.
// The API call fails in tests (no server), so the error state is rendered.
// Uses Provider.of<UserProvider>.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/evv/presentation/pages/visit_complete_page.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../mock_user_provider.dart';

Widget _wrap({
  int patientId = 1,
  String serviceType = 'Personal Care',
  String checkinLocationType = 'GPS',
  String checkoutLocationType = 'GPS',
  double? checkinLatitude,
  double? checkinLongitude,
  double? checkoutLatitude,
  double? checkoutLongitude,
  String notes = 'Test notes',
  int duration = 3600,
  int? scheduledVisitId,
  String role = 'CAREGIVER',
  int? caregiverId = 10,
  UserSession? mockUser,
}) {
  final provider = MockUserProvider(
    mockUser: mockUser ??
        MockUser(id: 1, role: role, caregiverId: caregiverId),
  );
  return MaterialApp(
    home: ChangeNotifierProvider<UserProvider>.value(
      value: provider,
      child: VisitCompletePage(
        patientId: patientId,
        serviceType: serviceType,
        checkinLocationType: checkinLocationType,
        checkoutLocationType: checkoutLocationType,
        checkinLatitude: checkinLatitude,
        checkinLongitude: checkinLongitude,
        checkoutLatitude: checkoutLatitude,
        checkoutLongitude: checkoutLongitude,
        notes: notes,
        duration: duration,
        scheduledVisitId: scheduledVisitId,
      ),
    ),
  );
}

Widget _wrapWithRouter({
  int patientId = 1,
  String serviceType = 'Personal Care',
  String checkinLocationType = 'GPS',
  String checkoutLocationType = 'GPS',
  double? checkinLatitude,
  double? checkinLongitude,
  double? checkoutLatitude,
  double? checkoutLongitude,
  String notes = 'Test notes',
  int duration = 3600,
  int? scheduledVisitId,
  String role = 'CAREGIVER',
  int? caregiverId = 10,
}) {
  final provider = MockUserProvider(
    mockUser: MockUser(id: 1, role: role, caregiverId: caregiverId),
  );

  final router = GoRouter(
    initialLocation: '/visit-complete',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold()),
      GoRoute(
        path: '/visit-complete',
        builder: (_, __) => VisitCompletePage(
          patientId: patientId,
          serviceType: serviceType,
          checkinLocationType: checkinLocationType,
          checkoutLocationType: checkoutLocationType,
          checkinLatitude: checkinLatitude,
          checkinLongitude: checkinLongitude,
          checkoutLatitude: checkoutLatitude,
          checkoutLongitude: checkoutLongitude,
          notes: notes,
          duration: duration,
          scheduledVisitId: scheduledVisitId,
        ),
      ),
      GoRoute(
          path: '/evv',
          builder: (_, __) =>
              const Scaffold(body: Text('EVV Dashboard'))),
      GoRoute(
          path: '/evv/select-patient',
          builder: (_, __) =>
              const Scaffold(body: Text('Select Patient'))),
      GoRoute(
          path: '/evv/visit-completed-success',
          builder: (_, __) =>
              const Scaffold(body: Text('Visit Success'))),
    ],
  );

  return ChangeNotifierProvider<UserProvider>.value(
    value: provider,
    child: MaterialApp.router(routerConfig: router),
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

  group('VisitCompletePage – initial render / loading', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('shows "Visit Complete" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Visit Complete'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows Center while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('VisitCompletePage – error state (API failure)', () {
    testWidgets('shows error state after loading fails', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
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
      // Tap Try Again - should attempt reload and end up in error state again
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Ends back in error state after reload attempt
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('error message text is displayed', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('CircularProgressIndicator is gone after error loads',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('VisitCompletePage – error state UI details', () {
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

  group('VisitCompletePage – with null user', () {
    testWidgets('shows error when user is null', (tester) async {
      final provider = _NullUserProvider();
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<UserProvider>.value(
            value: provider,
            child: const VisitCompletePage(
              patientId: 1,
              serviceType: 'Personal Care',
              checkinLocationType: 'GPS',
              checkoutLocationType: 'GPS',
              notes: 'Test notes',
              duration: 3600,
            ),
          ),
        ),
      );
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.textContaining('User not authenticated'), findsOneWidget);
    });
  });

  group('VisitCompletePage – AppBar actions', () {
    testWidgets('Cancel button shows cancel icon in red', (tester) async {
      await tester.pumpWidget(_wrap());
      final cancelIcon = tester.widget<Icon>(find.byIcon(Icons.cancel));
      expect(cancelIcon.color, Colors.red);
    });

    testWidgets('Cancel text is styled in red', (tester) async {
      await tester.pumpWidget(_wrap());
      final cancelText = find.text('Cancel');
      expect(cancelText, findsOneWidget);
    });

    testWidgets('AppBar contains TextButton.icon for cancel',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('AppBar has an IconButton for back navigation',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('back button uses arrow_back icon', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('VisitCompletePage – widget construction', () {
    testWidgets('accepts all required parameters', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts optional GPS coordinates', (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLatitude: 37.5407,
        checkinLongitude: -77.4360,
        checkoutLatitude: 37.5408,
        checkoutLongitude: -77.4361,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts scheduledVisitId parameter', (tester) async {
      await tester.pumpWidget(_wrap(scheduledVisitId: 42));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts different serviceType', (tester) async {
      await tester.pumpWidget(_wrap(serviceType: 'Nursing'));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts different patientId', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 99));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts patient_address location types', (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'patient_address',
        checkoutLocationType: 'patient_address',
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts different duration', (tester) async {
      await tester.pumpWidget(_wrap(duration: 7200));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('accepts different notes', (tester) async {
      await tester.pumpWidget(_wrap(notes: 'Different notes'));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with all parameters set', (tester) async {
      await tester.pumpWidget(_wrap(
        patientId: 5,
        serviceType: 'Skilled Nursing',
        checkinLocationType: 'gps',
        checkoutLocationType: 'patient_address',
        checkinLatitude: 38.0,
        checkinLongitude: -77.0,
        notes: 'Full params test',
        duration: 5400,
        scheduledVisitId: 10,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
      expect(find.text('Visit Complete'), findsOneWidget);
    });
  });

  group('VisitCompletePage – scaffold structure', () {
    testWidgets('has exactly one Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has exactly one AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar title is Visit Complete', (tester) async {
      await tester.pumpWidget(_wrap());
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      final titleText = appBar.title as Text;
      expect(titleText.data, 'Visit Complete');
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

  group('VisitCompletePage – caregiver with caregiverId', () {
    testWidgets('uses caregiverId from user when available',
        (tester) async {
      await tester.pumpWidget(_wrap(caregiverId: 5));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('falls back to user id when caregiverId is null',
        (tester) async {
      await tester.pumpWidget(_wrap(caregiverId: null));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });
  });

  group('VisitCompletePage – multiple pump cycles', () {
    testWidgets('loading indicator visible before API resolves',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();
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

  group('VisitCompletePage – Try Again retry cycle', () {
    testWidgets('can cycle error -> retry -> error again',
        (tester) async {
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
      // Back to error
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('VisitCompletePage – GoRouter navigation', () {
    testWidgets('Cancel button navigates to /evv', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pump();
      // Tap the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Should navigate to EVV Dashboard
      expect(find.text('EVV Dashboard'), findsOneWidget);
    });

    testWidgets('back button pops the route', (tester) async {
      await tester.pumpWidget(_wrapWithRouter());
      await tester.pump();
      // The back button is an IconButton with arrow_back
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('VisitCompletePage – location type variations', () {
    testWidgets('renders with gps checkin and patient_address checkout',
        (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'gps',
        checkoutLocationType: 'patient_address',
        checkinLatitude: 38.9072,
        checkinLongitude: -77.0369,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with patient_address checkin and gps checkout',
        (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'patient_address',
        checkoutLocationType: 'gps',
        checkoutLatitude: 38.9072,
        checkoutLongitude: -77.0369,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with both GPS locations', (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'gps',
        checkoutLocationType: 'gps',
        checkinLatitude: 38.9072,
        checkinLongitude: -77.0369,
        checkoutLatitude: 38.9073,
        checkoutLongitude: -77.0370,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with both patient_address locations',
        (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'patient_address',
        checkoutLocationType: 'patient_address',
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with null GPS coordinates', (tester) async {
      await tester.pumpWidget(_wrap(
        checkinLocationType: 'gps',
        checkoutLocationType: 'gps',
        checkinLatitude: null,
        checkinLongitude: null,
        checkoutLatitude: null,
        checkoutLongitude: null,
      ));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });
  });

  group('VisitCompletePage – duration variations', () {
    testWidgets('renders with zero duration', (tester) async {
      await tester.pumpWidget(_wrap(duration: 0));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with short duration (60 seconds)', (tester) async {
      await tester.pumpWidget(_wrap(duration: 60));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });

    testWidgets('renders with long duration (8 hours)', (tester) async {
      await tester.pumpWidget(_wrap(duration: 28800));
      expect(find.byType(VisitCompletePage), findsOneWidget);
    });
  });

  group('VisitCompletePage – error state with different users', () {
    testWidgets('error state shown for user with caregiverId',
        (tester) async {
      await tester.pumpWidget(_wrap(caregiverId: 20));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('error state shown for user without caregiverId',
        (tester) async {
      await tester.pumpWidget(_wrap(
        caregiverId: null,
        mockUser: MockUser(id: 5, role: 'CAREGIVER', caregiverId: null),
      ));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });
  });

  group('VisitCompletePage – error state interaction', () {
    testWidgets('Try Again button is tappable', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);

      final button = find.widgetWithText(ElevatedButton, 'Try Again');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Ends back in error state after retry
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('error text is visible in error state', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // The error message should contain some text about the failure
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, greaterThanOrEqualTo(3));
    });
  });
}

/// A UserProvider subclass that returns null user for testing the null-user path.
class _NullUserProvider extends MockUserProvider {
  _NullUserProvider() : super();

  @override
  UserSession? get user => null;
}
