// Tests for ResponsivePageWrapper and ResponsiveScaffold widgets
// (lib/widgets/responsive_page_wrapper.dart).
//
// Both are pure StatelessWidgets — no Provider, no API calls.
// ResponsivePageWrapper wraps its child in a Scaffold with optional
// customAppBar, drawer, and floatingActionButton.
// ResponsiveScaffold is a convenience wrapper around ResponsivePageWrapper
// that builds an AppBar and (optionally) a CommonDrawer.
//
// CommonDrawer requires Provider<UserProvider>, so ResponsiveScaffold tests
// that use currentRoute are intentionally omitted to keep tests provider-free.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/responsive_page_wrapper.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('ResponsivePageWrapper', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the widget builds without error.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        child: Text('Hello'),
      )));
      expect(find.byType(ResponsivePageWrapper), findsOneWidget);
    });

    testWidgets('shows child widget', (tester) async {
      // The child content must be visible in the body.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        child: Text('Child Content'),
      )));
      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('no appBar by default (customAppBar omitted)', (tester) async {
      // When no customAppBar is supplied, no AppBar is rendered.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        child: SizedBox(),
      )));
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('shows customAppBar when provided', (tester) async {
      // A custom PreferredSizeWidget supplied via customAppBar must appear.
      await tester.pumpWidget(_wrap(ResponsivePageWrapper(
        customAppBar: AppBar(title: const Text('Custom Title')),
        child: const SizedBox(),
      )));
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('shows floatingActionButton when provided', (tester) async {
      // A FAB supplied to the wrapper must be rendered.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.add),
        ),
        child: SizedBox(),
      )));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('no FAB when floatingActionButton is omitted', (tester) async {
      // Without a FAB, none should appear.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        child: SizedBox(),
      )));
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('contains a Scaffold', (tester) async {
      // ResponsivePageWrapper always renders a Scaffold root.
      await tester.pumpWidget(_wrap(const ResponsivePageWrapper(
        child: SizedBox(),
      )));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('ResponsiveScaffold', () {
    testWidgets('renders without crashing', (tester) async {
      // Verifies the scaffold builds without error.
      await tester.pumpWidget(_wrap(const ResponsiveScaffold(
        title: 'Test Page',
        body: Text('Body Text'),
      )));
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
    });

    testWidgets('shows title in AppBar', (tester) async {
      // The title string must appear in the rendered AppBar.
      await tester.pumpWidget(_wrap(const ResponsiveScaffold(
        title: 'My Page',
        body: SizedBox(),
      )));
      expect(find.text('My Page'), findsOneWidget);
    });

    testWidgets('shows body widget', (tester) async {
      // The body content must be rendered inside the scaffold.
      await tester.pumpWidget(_wrap(const ResponsiveScaffold(
        title: '',
        body: Text('Page Body'),
      )));
      expect(find.text('Page Body'), findsOneWidget);
    });

    testWidgets('shows AppBar', (tester) async {
      // ResponsiveScaffold always creates an AppBar.
      await tester.pumpWidget(_wrap(const ResponsiveScaffold(
        title: 'Has AppBar',
        body: SizedBox(),
      )));
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows floatingActionButton when provided', (tester) async {
      // A FAB passed to ResponsiveScaffold must appear.
      await tester.pumpWidget(_wrap(const ResponsiveScaffold(
        title: '',
        body: SizedBox(),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.edit),
        ),
      )));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('uses customAppBar when provided instead of default',
        (tester) async {
      // When customAppBar is set it replaces the default title-based AppBar.
      await tester.pumpWidget(_wrap(ResponsiveScaffold(
        title: 'Ignored Title',
        body: const SizedBox(),
        customAppBar: AppBar(title: const Text('Custom')),
      )));
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
