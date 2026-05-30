# Unit Testing Guide — CareConnect Flutter Frontend

This guide covers how to write, structure, and run unit tests for the Flutter
frontend at `frontend/`. It is written against the libraries and conventions
already present in `pubspec.yaml` and the existing test suite.

---

## Table of Contents

1. [Stack at a Glance](#1-stack-at-a-glance)
2. [Running Tests](#2-running-tests)
3. [Choosing the Right Test Style](#3-choosing-the-right-test-style)
4. [Test File Conventions](#4-test-file-conventions)
5. [Shared Test Utilities](#5-shared-test-utilities)
6. [Writing a Pure Unit Test](#6-writing-a-pure-unit-test)
7. [Writing a Widget Test](#7-writing-a-widget-test)
8. [Mocking Patterns](#8-mocking-patterns)
9. [Testing with Providers](#9-testing-with-providers)
10. [Testing with GoRouter Navigation](#10-testing-with-gorouter-navigation)
11. [Testing Async Operations](#11-testing-async-operations)
12. [HTTP and Network Mocking](#12-http-and-network-mocking)
13. [Platform Channel Mocking](#13-platform-channel-mocking)
14. [Assertion Patterns](#14-assertion-patterns)
15. [Setup and Teardown](#15-setup-and-teardown)
16. [Commenting Conventions](#16-commenting-conventions)
17. [Integration / E2E Tests](#17-integration--e2e-tests)
18. [Common Pitfalls](#18-common-pitfalls)

---

## 1. Stack at a Glance

| Library | Version | Purpose |
|---|---|---|
| **flutter_test** | SDK | Test runner, `test()`, `testWidgets()`, `expect()`, finders |
| **integration_test** | SDK | End-to-end tests on real devices/emulators |
| **mockito** | 5.5.1 | Creating mock objects with `when()` / `verify()` |
| **build_runner** | 2.4.9 | Code generation for Mockito `@GenerateMocks` |
| **http** | 1.5.0 | HTTP client (mocked via `MockClient` or `HttpOverrides`) |
| **provider** | (bundled) | State management — mocked in widget tests |
| **go_router** | (bundled) | Navigation — stubbed with minimal route tables |

You do **not** need to add any of these to `pubspec.yaml`; they are already on
the test classpath.

---

## 2. Running Tests

Run the full test suite from `frontend/`:

```bash
flutter test
```

Run a single test file:

```bash
flutter test test/permission_test.dart
```

Run tests matching a name pattern:

```bash
flutter test --name "Permission Enum"
```

Run with verbose output:

```bash
flutter test --reporter expanded
```

Run code analysis (linting):

```bash
flutter analyze
```

---

## 3. Choosing the Right Test Style

Pick the **narrowest** style that verifies what you need:

```
Model / utility / enum logic  →  Pure unit test              (fastest, no widgets)
Single widget rendering        →  testWidgets + pumpWidget    (widget tree only)
Widget with providers/router   →  testWidgets + custom _wrap  (provider + router slice)
Full app E2E flow              →  integration_test            (slowest — real device)
```

Most tests in this codebase use one of the first three styles. Full integration
tests live under `integration_test/` and require either a running backend or
fake transports.

---

## 4. Test File Conventions

### Naming

All test files use the `*_test.dart` suffix. No `*.spec.dart` files are used.

### Directory Structure

```
frontend/test/
├── test_support/              # Shared fixtures, helpers, bindings
│   ├── fixtures.dart          # Fake user sessions, JSON payloads
│   ├── pump_app.dart          # pumpCareConnectApp() widget wrapper
│   └── local_db_test_bindings.dart  # Platform channel mocks
├── features/                  # Feature tests mirror src structure
│   ├── auth/                  #   login_page_test.dart, etc.
│   ├── dashboard/
│   ├── tasks/
│   ├── health/
│   ├── invoices/
│   └── ...
├── services/                  # Service layer tests (34+ files)
├── providers/                 # Provider tests
├── models/                    # Model/data structure tests
├── config/                    # Configuration tests
├── pages/                     # Page-level widget tests
└── [individual test files]    # Top-level tests
```

**Convention**: feature tests go under `test/features/<feature>/` mirroring the
`lib/features/` source layout. Service tests go under `test/services/`.

### Test class name

Mirror the production file name with a `_test` suffix:
`login_page.dart` → `login_page_test.dart`

---

## 5. Shared Test Utilities

All shared helpers live in `test/test_support/`. Use these instead of
duplicating setup across tests.

### fixtures.dart — Fake Data Builders

```dart
import 'test_support/fixtures.dart';

// Baseline patient session for authenticated UI tests
final user = fakePatientUser();                    // name: 'Test Patient'
final user2 = fakePatientUser(name: 'Jane Doe');   // custom name
final noName = fakePatientUser(includeName: false); // null name

// Baseline caregiver session for role-specific tests
final caregiver = fakeCaregiverUser();

// Canonical JSON payloads for parsing/serialization tests
final authPayload = fakeAuthJson();
final patientPayload = fakePatientJson();  // {'firstName': 'Jane', 'lastName': 'Smith'}
```

### pump_app.dart — Widget Bootstrap Helper

```dart
import 'test_support/pump_app.dart';

testWidgets('renders greeting', (tester) async {
  await pumpCareConnectApp(
    tester,
    const GreetingWidget(),
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
    ],
  );
  expect(find.text('Hello'), findsOneWidget);
});
```

`pumpCareConnectApp()` wraps the widget in `MultiProvider` → `MaterialApp` →
`Scaffold` so you don't duplicate that boilerplate.

### local_db_test_bindings.dart — Platform Channel Mocking

```dart
import 'test_support/local_db_test_bindings.dart';

setUpAll(() async {
  await LocalDbTestBindings.install();   // mocks secure storage + path provider
});

setUp(() async {
  await LocalDbTestBindings.reset();     // clears data between tests
});

tearDownAll(() async {
  await LocalDbTestBindings.uninstall(); // removes handlers, cleans temp dirs
});
```

If your test file does **not** need shared fixtures, you can create mocks
inline — but always check `test_support/` first to avoid duplication.

---

## 6. Writing a Pure Unit Test

Use this style for models, enums, utilities, and any class with no widget
dependencies.

```dart
// test/permission_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/models/permission.dart';

void main() {
  group('Permission Enum Tests', () {
    test('Permission.fromString parses correctly', () {
      expect(Permission.fromString('VIEW_ALL_USERS'), Permission.viewAllUsers);
      expect(Permission.fromString('CREATE_PATIENTS'), Permission.createPatients);
    });

    test('Permission.fromString throws on invalid permission', () {
      expect(() => Permission.fromString('INVALID'), throwsArgumentError);
    });

    test('displayName formats correctly', () {
      expect(Permission.viewAllUsers.displayName, 'View All Users');
    });

    test('toBackendString returns SCREAMING_SNAKE_CASE', () {
      expect(Permission.viewAllUsers.toBackendString(), 'VIEW_ALL_USERS');
    });
  });
}
```

Key points:
- Use `group()` to organize related tests.
- One `expect()` per logical assertion (multiple related `expect()`s in one
  `test()` are fine).
- No `testWidgets` needed — plain `test()` is enough.

---

## 7. Writing a Widget Test

Use `testWidgets()` when you need to render Flutter widgets and interact with
the widget tree.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('MyWidget', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Hello'))),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('tap increments counter', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CounterWidget()));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // rebuild after state change
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

### Pumping strategies

| Method | When to use |
|---|---|
| `tester.pump()` | Trigger a single frame rebuild |
| `tester.pump(Duration(ms: 100))` | Advance a specific amount of time |
| `tester.pumpAndSettle()` | Wait until all animations/timers complete |
| Multiple `pump()` calls | Progressive loading with controlled timing |

### Scrolling off-screen elements into view

```dart
await tester.ensureVisible(find.byIcon(Icons.visibility_outlined));
await tester.pump();
await tester.tap(find.byIcon(Icons.visibility_outlined));
```

---

## 8. Mocking Patterns

### Mockito class mocks

The most common pattern — create a mock class that implements the interface:

```dart
import 'package:mockito/mockito.dart';

class MockUserProvider extends Mock implements UserProvider {}

final mockProvider = MockUserProvider();
when(mockProvider.user).thenReturn(fakePatientUser());
```

### Manual / inheritance-based mocks

When you need real behavior with selective overrides:

```dart
class MockUserProvider extends UserProvider {
  UserSession? _mockUser;

  MockUserProvider({UserSession? mockUser}) {
    _mockUser = mockUser ?? fakePatientUser();
  }

  @override
  UserSession? get user => _mockUser;
}
```

### Fake transport objects

For testing offline/retry/delivery logic without real network:

```dart
class _FakeTransport {
  bool online = false;
  final List<String> deliveredContents = [];

  Future<bool> send(MessageDto message) async {
    if (!online) return false;
    deliveredContents.add(message.content);
    return true;
  }
}
```

---

## 9. Testing with Providers

Widgets that depend on `Provider` must be wrapped in a provider tree. Two
approaches are used:

### Inline provider setup

```dart
testWidgets('displays user name', (tester) async {
  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.user).thenReturn(fakePatientUser(name: 'John Doe'));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: Consumer<UserProvider>(
            builder: (context, provider, _) {
              return Text(provider.user?.name ?? 'Patient');
            },
          ),
        ),
      ),
    ),
  );

  expect(find.text('John Doe'), findsOneWidget);
});
```

### Using pumpCareConnectApp helper

```dart
await pumpCareConnectApp(
  tester,
  const MyWidget(),
  providers: [
    ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
  ],
);
```

---

## 10. Testing with GoRouter Navigation

Pages that call `GoRouter.of(context)` require `MaterialApp.router` with a
`GoRouter` configuration. Create a minimal route table and a `_wrap()` helper:

```dart
GoRouter _makeRouter({String? userType}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => LoginPage(userType: userType)),
      GoRoute(path: '/dashboard', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/signup', builder: (_, __) => const Scaffold()),
    ],
  );
}

Widget _wrap({String? userType}) {
  final router = _makeRouter(userType: userType);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

testWidgets('shows sign-in title', (tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pump();
  expect(find.text('Sign in to your account'), findsOneWidget);
});
```

Stub routes with `const Scaffold()` — you only need the real page under test.

---

## 11. Testing Async Operations

### Async service methods

```dart
test('login handles network errors', () async {
  expect(() async {
    try {
      await AuthService.login('test@example.com', 'password');
    } catch (e) {
      expect(e, isA<Exception>());
    }
  }, returnsNormally);
});
```

### Async widget loading

```dart
testWidgets('widget renders after async load', (tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle(); // waits for futures and animations
  expect(find.text('Loaded'), findsOneWidget);
});
```

### Controlled progressive pumping

For tests that need precise timing control:

```dart
Future<void> _pumpLoaded(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
```

---

## 12. HTTP and Network Mocking

### Using http.testing.MockClient

For services that accept an injectable HTTP client:

```dart
import 'package:http/testing.dart' as http_testing;

ApiService.debugSetHttpClient(
  http_testing.MockClient((request) async {
    if (request.url.path.endsWith('/telemetry')) {
      return http.Response(jsonEncode({'status': 'ok'}), 200);
    }
    return http.Response('', 404);
  }),
);
```

### Using HttpOverrides (for static clients)

When the service uses a static `http.Client` that can't be injected:

```dart
class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

setUpAll(() {
  HttpOverrides.global = _FakeHttpOverrides();
});
```

This intercepts all HTTP traffic created through `dart:io`, including calls
made by the `http` package's `IOClient`.

### Shared mutable spec pattern

Control response behavior per-test with a shared spec:

```dart
class _FakeSpec {
  const _FakeSpec(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

_FakeSpec _activeSpec = const _FakeSpec(200, '{}');

// In each test:
test('handles 404', () async {
  _activeSpec = const _FakeSpec(404, '{"error": "not found"}');
  // ... call service and assert ...
});
```

---

## 13. Platform Channel Mocking

Flutter plugins communicate over platform channels. In tests, these channels
have no native implementation, so they must be mocked.

### Secure Storage and Path Provider

Use the shared `LocalDbTestBindings`:

```dart
import 'test_support/local_db_test_bindings.dart';

setUpAll(() async => await LocalDbTestBindings.install());
tearDownAll(() async => await LocalDbTestBindings.uninstall());
```

### Manual channel mocking

For other plugins:

```dart
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(
  const MethodChannel('plugins.example.com/my_plugin'),
  (MethodCall call) async {
    switch (call.method) {
      case 'getData': return '{"key": "value"}';
      default: return null;
    }
  },
);
```

---

## 14. Assertion Patterns

### Widget finders

```dart
expect(find.text('John Doe'), findsOneWidget);
expect(find.byType(Scaffold), findsOneWidget);
expect(find.text('Admin Content'), findsNothing);
expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
```

### Value assertions

```dart
expect(userSession.id, 1);
expect(userSession.role, 'PATIENT');
expect(headers['Content-Type'], 'application/json');
```

### Type and null assertions

```dart
expect(headers, isA<Map<String, String>>());
expect(match, isNotNull);
expect(value, isTrue);
expect(value, isFalse);
```

### Collection assertions

```dart
expect(rows.length, equals(2));
expect(deliveredContents, ['offline first', 'offline second']);
expect(restoredAfterSend, isEmpty);
expect(restoredAfterSend, hasLength(2));
```

### String matchers

```dart
expect(authHeader, startsWith('Bearer '));
expect(ApiConstants.auth, contains('/v1/api/auth'));
expect(ApiConstants.auth, endsWith('/v1/api/auth'));
```

### Exception assertions

```dart
expect(() => Permission.fromString('INVALID'), throwsArgumentError);
expect(() => service.process(null), throwsA(isA<StateError>()));
```

---

## 15. Setup and Teardown

### Standard lifecycle

```dart
void main() {
  group('FeatureName', () {
    setUpAll(() async {
      // One-time setup before all tests in this group
      TestWidgetsFlutterBinding.ensureInitialized();
      await LocalDbTestBindings.install();
    });

    setUp(() async {
      // Runs before each test
      secureStorage.clear();
    });

    tearDown(() {
      // Runs after each test
      ApiService.debugResetHttpClient();
    });

    tearDownAll(() async {
      // One-time cleanup after all tests
      await LocalDbTestBindings.uninstall();
    });

    test('test name', () { /* ... */ });
  });
}
```

### Suppressing layout overflow errors

Some widgets intentionally overflow in test viewports. Suppress only overflow
noise (not real errors) using `addTearDown` for automatic cleanup:

```dart
void _suppressOverflow() {
  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

testWidgets('page renders', (tester) async {
  _suppressOverflow();
  await tester.pumpWidget(_wrap());
  // ...
});
```

---

## 16. Commenting Conventions

These conventions come from `TESTING_NORMS.md` in the project root.

### File-level comment

Explain what the test suite validates and why dependencies are mocked:

```dart
// Tests for LoginPage — the main login screen.
// LoginPage calls GoRouter.of(context) in build(), so MaterialApp.router
// with a GoRouter configuration is required for all tests.
```

### Function-level comment

Explain scenario and defaults of helper functions:

```dart
/// Returns a baseline patient session used by most authenticated UI tests.
///
/// Use this when testing patient-facing widgets that depend on a logged-in user.
UserSession fakePatientUser({String? name, bool includeName = true}) { ... }
```

### Test-body comments

Use `Arrange`, `Act`, `Assert` for non-trivial tests:

```dart
test('identifies queueable HTTP methods', () {
  // Arrange
  final service = OfflineQueueService();

  // Act
  final result = service.isQueueableMethod('POST');

  // Assert
  expect(result, isTrue);
});
```

For simple tests, inline comments noting **what** is being verified are
sufficient:

```dart
testWidgets('shows Sign In button', (tester) async {
  // The primary submit button is labeled "Sign In".
  _suppressOverflow();
  await tester.pumpWidget(_wrap());
  await tester.pump();
  expect(find.text('Sign In'), findsOneWidget);
});
```

---

## 17. Integration / E2E Tests

Integration tests live under `frontend/integration_test/` and use
`IntegrationTestWidgetsFlutterBinding`.

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Chat messaging E2E flow', () {
    testWidgets('offline messages persist and deliver after reconnect',
        (tester) async {
      final transport = _FakeTransport();

      // Queue messages while offline
      transport.online = false;
      await manager.persistToDisk(key, pending);

      // Reconnect and verify delivery
      transport.online = true;
      await retryAllPending(send: transport.send);
      expect(transport.deliveredContents, ['msg1', 'msg2']);
    });
  });
}
```

Run integration tests on a device:

```bash
flutter test integration_test/chat_messaging_e2e_test.dart \
  --dart-define=CC_BASE_URL_WEB=http://localhost:8081 \
  -d <device-id>
```

Annotate backend requirements at the top of integration test files:

```dart
// REQUIRES: backend running at localhost:8081
// — or —
// OFFLINE: no backend needed
```

---

## 18. Common Pitfalls

**MissingPluginException**
Plugin calls (secure storage, camera, path provider) throw in the test
environment. Either use `LocalDbTestBindings.install()` or mock the specific
platform channel. If a test doesn't need the plugin result, catch and ignore.

**GoRouter context errors**
If a widget calls `GoRouter.of(context)`, you must use `MaterialApp.router`
with a `GoRouter` config — not `MaterialApp` with `home:`. Create a
`_makeRouter()` / `_wrap()` helper.

**pumpAndSettle timeout**
`pumpAndSettle()` waits for all animations and timers. If a widget has an
infinite animation (loading spinner), it will time out. Use `pump()` with an
explicit duration instead.

**Overflow errors in tests**
Some widgets overflow in the 800x600 default test viewport. Use
`_suppressOverflow()` to filter these — but only for known layout issues, not
to hide real bugs.

**Unused mockito stubs**
Mockito strict mode fails tests with unused stubs. Move stubs that aren't
needed by every test into the specific test body, or use `lenient()` for
shared `setUp()` stubs.

**Static/singleton service state leaking between tests**
Services with static state (like `ApiService`) can leak between tests. Always
reset in `tearDown()`:

```dart
tearDown(() {
  ApiService.debugResetHttpClient();
});
```

**SharedPreferences in tests**
Set mock values before the test runs:

```dart
SharedPreferences.setMockInitialValues({});
```

---

## Core Rules (from TESTING_NORMS.md)

1. **Prefer shared fixtures** over inline ad-hoc object setup — use
   `test_support/fixtures.dart`.
2. **No live DB/network dependencies** in unit tests.
3. **Keep production code untouched** unless a minimal, behavior-neutral seam
   is required.
4. **Document non-obvious test setup** with concise comments.
5. **If a fixture doesn't exist**, add it to `test_support/` rather than
   duplicating inline setup across test files.
