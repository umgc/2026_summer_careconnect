// Tests for MyApp from lib/screens/preview_main.dart.
//
// MyApp is a simple StatelessWidget wrapping PatientReportsScreen in a
// MaterialApp. No providers or API calls required.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/screens/preview_main.dart';
import 'package:care_connect_app/screens/patient_reports.dart';

void main() {
  group('MyApp (preview_main) – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('wraps content in MaterialApp', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('hides debug banner', (tester) async {
      await tester.pumpWidget(const MyApp());
      final materialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('home is PatientReportsScreen', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(PatientReportsScreen), findsOneWidget);
    });

    testWidgets('shows Scaffold from PatientReportsScreen', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows AppBar with My Reports title', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('My Reports'), findsOneWidget);
    });

    testWidgets('body is scrollable', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
