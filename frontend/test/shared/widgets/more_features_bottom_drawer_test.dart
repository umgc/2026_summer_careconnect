// Tests for MoreFeaturesBottomDrawer and FeatureItem
// (lib/shared/widgets/more_features_bottom_drawer.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/shared/widgets/more_features_bottom_drawer.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

List<FeatureItem> _makeFeatures(int count) => List.generate(
      count,
      (i) => FeatureItem(
        icon: Icons.star,
        title: 'Feature $i',
        subtitle: 'Subtitle $i',
        onTap: () {},
      ),
    );

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // FeatureItem
  // ───────────────────────────────────────────────────────────────────────────
  group('FeatureItem', () {
    test('stores all required fields', () {
      bool tapped = false;
      final item = FeatureItem(
        icon: Icons.home,
        iconColor: Colors.blue,
        title: 'Home',
        subtitle: 'Go home',
        onTap: () => tapped = true,
      );
      expect(item.icon, Icons.home);
      expect(item.iconColor, Colors.blue);
      expect(item.title, 'Home');
      expect(item.subtitle, 'Go home');
      item.onTap();
      expect(tapped, isTrue);
    });

    test('iconColor defaults to null', () {
      final item = FeatureItem(
        icon: Icons.home,
        title: 'Home',
        subtitle: 'Subtitle',
        onTap: () {},
      );
      expect(item.iconColor, isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // MoreFeaturesBottomDrawer
  // ───────────────────────────────────────────────────────────────────────────
  group('MoreFeaturesBottomDrawer', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(1)),
      ));
      expect(find.byType(MoreFeaturesBottomDrawer), findsOneWidget);
    });

    testWidgets('shows default title "Additional Features"', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(0)),
      ));
      expect(find.text('Additional Features'), findsOneWidget);
    });

    testWidgets('shows custom title when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(
          features: _makeFeatures(0),
          title: 'More Options',
        ),
      ));
      expect(find.text('More Options'), findsOneWidget);
    });

    testWidgets('shows Close button', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(0)),
      ));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('shows feature title for each item', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(2)),
      ));
      expect(find.text('Feature 0'), findsOneWidget);
      expect(find.text('Feature 1'), findsOneWidget);
    });

    testWidgets('shows feature subtitle for each item', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(2)),
      ));
      expect(find.text('Subtitle 0'), findsOneWidget);
      expect(find.text('Subtitle 1'), findsOneWidget);
    });

    testWidgets('calls onTap when feature item tapped', (tester) async {
      bool tapped = false;
      final features = [
        FeatureItem(
          icon: Icons.star,
          title: 'Star Feature',
          subtitle: 'Desc',
          onTap: () => tapped = true,
        ),
      ];
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: features),
      ));
      await tester.tap(find.text('Star Feature'));
      expect(tapped, isTrue);
    });

    testWidgets('shows arrow_forward_ios icon for each feature', (tester) async {
      await tester.pumpWidget(_wrap(
        MoreFeaturesBottomDrawer(features: _makeFeatures(2)),
      ));
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(2));
    });

    testWidgets('renders with empty feature list', (tester) async {
      await tester.pumpWidget(_wrap(
        const MoreFeaturesBottomDrawer(features: []),
      ));
      expect(find.byType(MoreFeaturesBottomDrawer), findsOneWidget);
    });
  });
}
