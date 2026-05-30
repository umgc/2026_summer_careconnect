// Tests for VideoCallTestPage
// (lib/pages/video_call_test_page.dart).
//
// VideoCallTestPage sets a default channel name in initState but makes no API
// calls. Tests cover initial render and UI element presence.
//
// The page body is a Column that overflows the default test viewport (800x600),
// so tests set a taller surface size (1200px) to avoid overflow errors.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/pages/video_call_test_page.dart';

Widget _wrap() => const MaterialApp(home: VideoCallTestPage());

void main() {
  // Give the viewport enough height to fit the full page content.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('VideoCallTestPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.byType(VideoCallTestPage), findsOneWidget);
    });

    testWidgets('shows "CareConnect Video Call Test" in AppBar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.text('CareConnect Video Call Test'), findsOneWidget);
    });

    testWidgets('shows channel name TextField', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('channel TextField has a default value', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      final textField = tester.widget<TextField>(find.byType(TextField));
      // initState sets a default "test_channel_<timestamp>".
      expect(textField.controller?.text, startsWith('test_channel_'));
    });

    testWidgets('shows "Start Video Call" button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.text('Start Video Call'), findsOneWidget);
    });

    testWidgets('shows "Start Audio Call" button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.text('Start Audio Call'), findsOneWidget);
    });

    testWidgets('shows video_call icon', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.video_call), findsOneWidget);
    });

    testWidgets('shows call icon', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.byIcon(Icons.call), findsOneWidget);
    });

    testWidgets('shows a Scaffold', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
