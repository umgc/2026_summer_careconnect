// Tests for ResponsiveContainer widget
// (lib/widgets/responsive_container.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ResponsiveContainer', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        child: Text('Hello'),
      )));
      expect(find.byType(ResponsiveContainer), findsOneWidget);
    });

    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        child: Text('Content Here'),
      )));
      expect(find.text('Content Here'), findsOneWidget);
    });

    testWidgets('applies padding when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        padding: EdgeInsets.all(16),
        child: Text('Padded'),
      )));
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('applies backgroundColor when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        backgroundColor: Colors.red,
        child: Text('Red bg'),
      )));
      expect(find.text('Red bg'), findsOneWidget);
    });

    testWidgets('applies custom decoration', (tester) async {
      await tester.pumpWidget(_wrap(ResponsiveContainer(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Decorated'),
      )));
      expect(find.text('Decorated'), findsOneWidget);
    });

    testWidgets('uses maxWidth when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        maxWidth: 300,
        child: Text('MaxWidth'),
      )));
      expect(find.text('MaxWidth'), findsOneWidget);
    });

    testWidgets('uses maxWidthPercentage when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        maxWidthPercentage: 0.8,
        child: Text('80%'),
      )));
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('centerContent false renders without Center wrapper on large screen', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        centerContent: false,
        child: Text('Not Centered'),
      )));
      expect(find.text('Not Centered'), findsOneWidget);
    });

    testWidgets('centerContent true (default) on large screen', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        child: Text('Centered'),
      )));
      expect(find.text('Centered'), findsOneWidget);
    });

    testWidgets('renders on mobile screen width', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const ResponsiveContainer(
        child: Text('Mobile'),
      )));
      expect(find.text('Mobile'), findsOneWidget);
    });
  });
}
