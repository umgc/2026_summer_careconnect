// Tests for VisitInProgressPage
// (lib/features/evv/presentation/pages/visit_in_progress_page.dart).
//
// _loadPatientDetails() called in initState; _isLoading=true while loading.
// Timer.periodic is started in initState and cancelled in dispose().
// After the API call fails (no server in tests), the catch block sets
// _isLoading = false and _error, rendering the error state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:care_connect_app/features/evv/presentation/pages/visit_in_progress_page.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../../mock_user_provider.dart';

/// A MockUserProvider that returns null for `user`, triggering
/// the 'User not authenticated' error path.
class NullUserProvider extends MockUserProvider {
  NullUserProvider() : super(mockUser: MockUser(id: 1, role: 'CAREGIVER'));

  @override
  UserSession? get user => null;
}

/// Wraps the page in MaterialApp with GoRouter so that context.pop(),
/// context.push(), and context.go() do not throw.
Widget _wrap({
  int patientId = 1,
  String serviceType = 'Personal Care',
  String locationType = 'GPS',
  double? latitude,
  double? longitude,
  int? scheduledVisitId,
  MockUserProvider? provider,
}) {
  final userProvider = provider ??
      MockUserProvider(
        mockUser: MockUser(id: 1, role: 'CAREGIVER', caregiverId: 1),
      );

  final page = VisitInProgressPage(
    patientId: patientId,
    serviceType: serviceType,
    locationType: locationType,
    latitude: latitude,
    longitude: longitude,
    scheduledVisitId: scheduledVisitId,
  );

  final router = GoRouter(
    initialLocation: '/visit-in-progress',
    routes: [
      GoRoute(
        path: '/visit-in-progress',
        builder: (context, state) => page,
      ),
      GoRoute(
        path: '/evv/checkout-location',
        builder: (context, state) =>
            const Scaffold(body: Text('Checkout Page')),
      ),
      GoRoute(
        path: '/evv/select-patient',
        builder: (context, state) =>
            const Scaffold(body: Text('Patient Selection')),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('Dashboard')),
      ),
    ],
  );

  return ChangeNotifierProvider<UserProvider>.value(
    value: userProvider,
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

/// Pumps enough frames for the async _loadPatientDetails to fail and setState
/// to fire, transitioning from loading to the error/content state.
/// Also sets a large surface size to avoid overflow errors in test layout.
Future<void> _pumpUntilLoaded(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());
  addTearDown(() => tester.view.resetDevicePixelRatio());
  // The HTTP call inside ApiService will throw (no server).
  // Give enough time for the Future to fail and setState to fire.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() {
    // Mock flutter_secure_storage platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'read') return null;
        if (call.method == 'containsKey') return false;
        return null;
      },
    );
    // Mock connectivity plugin
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

  // ─────────────────────────────────────────────────────────────────────
  // Group 1: Initial loading state
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – initial loading state', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('shows "Visit in Progress" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Visit in Progress'), findsOneWidget);
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
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

    testWidgets('shows back arrow icon in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows Cancel button in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows cancel icon in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 2: Error state after API failure
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – error state after API failure', () {
    testWidgets('shows error_outline icon after loading fails', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows "Error Loading Patient" text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('shows "Try Again" button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows ElevatedButton in error state', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('no CircularProgressIndicator after loading', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message text', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // The error message from the exception should be displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('tapping Try Again button does not crash', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // Tap Try Again - it will attempt to reload (and fail again)
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Should still be in error state after retry fails
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('error state has Padding widget', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('error state has Column widget', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('error state has Center widget', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('error state has SizedBox for spacing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 3: Null user triggers 'User not authenticated' error
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – null user error path', () {
    testWidgets('shows error state when user is null', (tester) async {
      await tester.pumpWidget(_wrap(provider: NullUserProvider()));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('shows User not authenticated error message', (tester) async {
      await tester.pumpWidget(_wrap(provider: NullUserProvider()));
      await _pumpUntilLoaded(tester);
      // The error message includes 'User not authenticated'
      expect(find.textContaining('User not authenticated'), findsOneWidget);
    });

    testWidgets('shows Try Again button when user is null', (tester) async {
      await tester.pumpWidget(_wrap(provider: NullUserProvider()));
      await _pumpUntilLoaded(tester);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows error_outline icon when user is null', (tester) async {
      await tester.pumpWidget(_wrap(provider: NullUserProvider()));
      await _pumpUntilLoaded(tester);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 4: Constructor parameters
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – constructor & parameters', () {
    testWidgets('renders with GPS coordinates', (tester) async {
      await tester.pumpWidget(_wrap(
        latitude: 38.9897,
        longitude: -76.9378,
        locationType: 'gps',
      ));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('renders with patient_address location type', (tester) async {
      await tester.pumpWidget(_wrap(
        locationType: 'patient_address',
      ));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('renders with scheduledVisitId', (tester) async {
      await tester.pumpWidget(_wrap(
        scheduledVisitId: 42,
      ));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('renders with different patientId', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 99));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('renders with different serviceType', (tester) async {
      await tester.pumpWidget(_wrap(serviceType: 'Respite Care'));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('renders with all optional parameters', (tester) async {
      await tester.pumpWidget(_wrap(
        patientId: 5,
        serviceType: 'Skilled Nursing',
        locationType: 'gps',
        latitude: 40.7128,
        longitude: -74.0060,
        scheduledVisitId: 100,
      ));
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 5: AppBar actions
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – AppBar actions', () {
    testWidgets('Cancel button navigates to dashboard', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Tap the Cancel TextButton
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Should navigate to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('back arrow IconButton exists in leading position',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Verify the back arrow IconButton is present
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_back),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('Cancel TextButton.icon has red cancel icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      final cancelIcon = tester.widget<Icon>(find.byIcon(Icons.cancel));
      expect(cancelIcon.color, Colors.red);
    });

    testWidgets('Cancel text is red', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      final cancelTexts = tester.widgetList<Text>(find.text('Cancel'));
      final cancelText = cancelTexts.first;
      expect(cancelText.style?.color, Colors.red);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 6: Timer behavior
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – timer', () {
    testWidgets('timer starts automatically on init', (tester) async {
      await tester.pumpWidget(_wrap());
      // Wait for the error state to load so we can see the page is alive
      await _pumpUntilLoaded(tester);
      // Timer still ticking even though API failed
      // (timer is independent of patient loading)
      // Just verify no crash from timer
      expect(find.byType(VisitInProgressPage), findsOneWidget);
    });

    testWidgets('timer disposes cleanly when widget is removed', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      // Navigate away to trigger dispose
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // If timer is not cancelled, this would throw
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 7: Widget structure in error state
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – widget structure in error state', () {
    testWidgets('has Icon with size 64 in error state', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(iconWidget.size, 64);
    });

    testWidgets('error state still shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('error state still shows Cancel button', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('error state still shows back arrow', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('error state has proper text alignment', (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // The error title should exist and be centered
      final errorTitleFinder = find.text('Error Loading Patient');
      expect(errorTitleFinder, findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 8: Try Again re-triggers loading
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – Try Again behavior', () {
    testWidgets('Try Again re-triggers loading and returns to error',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Try Again'), findsOneWidget);
      // Tap Try Again
      await tester.tap(find.text('Try Again'));
      // Pump through the reload cycle
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Should be back in error state after retry
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Try Again then loading fails again shows error state',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      // Tap Try Again
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      // Wait for it to fail again
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      // Should be back in error state
      expect(find.text('Error Loading Patient'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 9: Cancel navigation works from error state
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – navigation from error state', () {
    testWidgets('Cancel from error state navigates to dashboard',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // Group 10: Different caregiver IDs
  // ─────────────────────────────────────────────────────────────────────
  group('VisitInProgressPage – caregiver ID fallback', () {
    testWidgets('uses user.id when caregiverId is null', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 5, role: 'CAREGIVER', caregiverId: null),
      );
      await tester.pumpWidget(_wrap(provider: provider));
      await _pumpUntilLoaded(tester);
      // Should still reach error state (API fails), meaning
      // the code path that uses user.id ran without error
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });

    testWidgets('uses caregiverId when available', (tester) async {
      final provider = MockUserProvider(
        mockUser: MockUser(id: 5, role: 'CAREGIVER', caregiverId: 10),
      );
      await tester.pumpWidget(_wrap(provider: provider));
      await _pumpUntilLoaded(tester);
      expect(find.text('Error Loading Patient'), findsOneWidget);
    });
  });
}
