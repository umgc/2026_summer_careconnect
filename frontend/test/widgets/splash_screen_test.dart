// Tests for SplashScreen widget
// (lib/widgets/splash_screen.dart).
// Pure StatelessWidget — no platform channels, no network I/O.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows CareConnect text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.text('CareConnect'), findsOneWidget);
    });

    testWidgets('shows tagline text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.text('Connecting Care, Empowering Lives'), findsOneWidget);
    });

    testWidgets('shows initializing services text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.text('Initializing services...'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows health_and_safety icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });
  });
}
