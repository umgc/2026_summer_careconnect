import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/caregiver_dashboard.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('CaregiverDashboard', () {
    testWidgets('renders caregiver dashboard', (WidgetTester tester) async {
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'CAREGIVER',
        token: 'mock_token',
        caregiverId: 1,
      );

      final provider = UserProvider()..setUser(mockUser);

      final router = GoRouter(
        initialLocation: '/dash',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold()),
          GoRoute(
            path: '/dash',
            builder: (_, __) => const CaregiverDashboard(),
          ),
          GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
          GoRoute(
            path: '/analytics',
            builder: (_, __) =>
                const Scaffold(body: Text('Analytics Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Use pump instead of pumpAndSettle to avoid timeout from ongoing
      // WebSocket/notification timers
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CaregiverDashboard), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('CaregiverDashboard can be constructed', (
      WidgetTester tester,
    ) async {
      const dashboard = CaregiverDashboard();
      expect(dashboard, isA<CaregiverDashboard>());
    });
  });
}
