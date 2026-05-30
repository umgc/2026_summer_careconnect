// Tests for utility widgets:
//   UserAvatar         (lib/widgets/user_avatar.dart)
//   AppBarHelper       (lib/widgets/app_bar_helper.dart)
//   ResponsivePageWrapper / ResponsiveScaffold
//                      (lib/widgets/responsive_page_wrapper.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/user_avatar.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/responsive_page_wrapper.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ─────────────────────────────────────────────────────────────────────────────
// UserAvatar
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('UserAvatar', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('shows person icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows person icon when imageUrl is empty', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: '')));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders CircleAvatar', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('uses custom radius', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null, radius: 30)));
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 30.0);
    });

    testWidgets('default radius is 20', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 20.0);
    });

  });

  // ─────────────────────────────────────────────────────────────────────────────
  // AppBarHelper
  // ─────────────────────────────────────────────────────────────────────────────
  group('AppBarHelper.createAppBar', () {
    testWidgets('creates AppBar with given title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              appBar: AppBarHelper.createAppBar(ctx, title: 'Test Title'),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('shows back arrow icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              appBar: AppBarHelper.createAppBar(ctx, title: 'X'),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('includes additional actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              appBar: AppBarHelper.createAppBar(
                ctx,
                title: 'X',
                additionalActions: [
                  const Icon(Icons.search, key: Key('search-icon')),
                ],
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('search-icon')), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // ResponsivePageWrapper
  // ─────────────────────────────────────────────────────────────────────────────
  group('ResponsivePageWrapper', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsivePageWrapper(child: Text('Hello')),
        ),
      );
      expect(find.byType(ResponsivePageWrapper), findsOneWidget);
    });

    testWidgets('shows child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsivePageWrapper(child: Text('Child Content')),
        ),
      );
      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('shows customAppBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsivePageWrapper(
            customAppBar: AppBar(title: const Text('Custom Bar')),
            child: const Text('Body'),
          ),
        ),
      );
      expect(find.text('Custom Bar'), findsOneWidget);
    });

    testWidgets('shows floatingActionButton when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsivePageWrapper(
            floatingActionButton:
                const FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
            child: const SizedBox(),
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // ResponsiveScaffold
  // ─────────────────────────────────────────────────────────────────────────────
  group('ResponsiveScaffold', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveScaffold(title: 'Page', body: Text('Content')),
        ),
      );
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
    });

    testWidgets('shows title in AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveScaffold(title: 'My Page'),
        ),
      );
      expect(find.text('My Page'), findsOneWidget);
    });

    testWidgets('shows body content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveScaffold(body: Text('Page Body')),
        ),
      );
      expect(find.text('Page Body'), findsOneWidget);
    });

    testWidgets('renders with empty body when body is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveScaffold(title: 'Empty'),
        ),
      );
      expect(find.byType(ResponsiveScaffold), findsOneWidget);
    });

    testWidgets('shows floatingActionButton when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.edit),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
