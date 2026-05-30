// Tests for AIConfigurationPage
// (lib/pages/ai_configuration_page.dart).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/pages/ai_configuration_page.dart';
import 'package:care_connect_app/providers/user_provider.dart';

import '../mock_user_provider.dart';

Widget _wrap({String role = 'PATIENT'}) {
  final provider = MockUserProvider(mockUser: MockUser(id: 1, role: role));
  final router = GoRouter(
    initialLocation: '/ai-config',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold()),
      GoRoute(
        path: '/ai-config',
        builder: (_, __) => const AIConfigurationPage(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
    ],
  );
  return ChangeNotifierProvider<UserProvider>.value(
    value: provider,
    child: MaterialApp.router(routerConfig: router),
  );
}

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

  group('AIConfigurationPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AIConfigurationPage), findsOneWidget);
    });

    testWidgets('shows "AI Configuration" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('AI Configuration'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('shows AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows Cancel and Save buttons in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('AIConfigurationPage – after loading completes', () {
    Future<void> pumpAndWaitForLoad(WidgetTester tester) async {
      await tester.pumpWidget(_wrap());
      // The _loadConfiguration() will fail (no HTTP server) but the finally
      // block sets _isLoading = false, so the form renders.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }

    testWidgets('shows info card text after loading', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(
        find.textContaining('Configure your AI assistant'),
        findsOneWidget,
      );
    });

    testWidgets('shows AI Provider section heading', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('AI Provider'), findsOneWidget);
    });

    testWidgets('shows Personality section heading', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Personality'), findsOneWidget);
    });

    testWidgets('shows Features section heading', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Features'), findsOneWidget);
    });

    testWidgets('shows Voice Interaction switch', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Voice Interaction'), findsOneWidget);
      expect(find.text('Enable voice-based conversations'), findsOneWidget);
    });

    testWidgets('shows Emotional Support switch', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Emotional Support'), findsOneWidget);
    });

    testWidgets('shows Medication Reminders switch', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Medication Reminders'), findsOneWidget);
    });

    testWidgets('shows Emergency Detection switch', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.text('Emergency Detection'), findsOneWidget);
    });

    testWidgets('shows Switch widgets for feature toggles', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.byType(Switch), findsAtLeastNWidgets(4));
    });

    testWidgets('can toggle Voice Interaction switch', (tester) async {
      await pumpAndWaitForLoad(tester);
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(1));
      await tester.tap(switches.first);
      await tester.pump();
      expect(find.byType(Switch), findsAtLeastNWidgets(1));
    });

    testWidgets('shows info icon', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows section icons', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.byIcon(Icons.android), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('shows DropdownButtonFormField for provider', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(
        find.byType(DropdownButtonFormField<String>),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('shows SingleChildScrollView for form', (tester) async {
      await pumpAndWaitForLoad(tester);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('AIConfigurationPage – no user redirect', () {
    testWidgets('shows loading spinner and redirects when no user', (tester) async {
      final provider = UserProvider();
      final router = GoRouter(
        initialLocation: '/ai-config',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Scaffold()),
          GoRoute(
            path: '/ai-config',
            builder: (_, __) => const AIConfigurationPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const Scaffold(body: Text('Login Page')),
          ),
        ],
      );
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: provider,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      // When user is null, microtask redirects to /login
      await tester.pump();
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
