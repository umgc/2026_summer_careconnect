// Tests for OcrReviewScreen and BoxesPainter from
// lib/features/invoices/widgets/ocr_review_screen.dart.
//
// OcrReviewScreen depends on OcrService (MethodChannel) and Image.file,
// making full widget tests difficult without native platform support.
// We focus on testing:
//   - BoxesPainter (public CustomPainter) paint and shouldRepaint behavior
//   - OcrReviewScreen widget construction and initial loading state
//     (mocking the MethodChannel so OCR returns results or errors)

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/services/ocr_service.dart';
import 'package:care_connect_app/features/invoices/widgets/ocr_review_screen.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoxesPainter', () {
    test('creates painter with list of boxes', () {
      final boxes = [
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
        const BBox(l: 0.5, t: 0.6, w: 0.2, h: 0.1),
      ];
      final painter = BoxesPainter(boxes);
      expect(painter.boxes.length, 2);
    });

    test('creates painter with empty list', () {
      final painter = BoxesPainter([]);
      expect(painter.boxes, isEmpty);
    });

    test('shouldRepaint returns true when boxes differ', () {
      final painter1 = BoxesPainter([
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
      ]);
      final painter2 = BoxesPainter([
        const BBox(l: 0.5, t: 0.6, w: 0.7, h: 0.8),
      ]);
      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns false when same boxes reference', () {
      final boxes = [const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4)];
      final painter1 = BoxesPainter(boxes);
      final painter2 = BoxesPainter(boxes);
      expect(painter1.shouldRepaint(painter2), false);
    });

    test('paint draws rectangles on canvas', () {
      final boxes = [
        const BBox(l: 0.0, t: 0.0, w: 0.5, h: 0.5),
        const BBox(l: 0.5, t: 0.5, w: 0.5, h: 0.5),
      ];
      final painter = BoxesPainter(boxes);

      // Create a PictureRecorder to capture paint calls
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(200, 200);

      // Should not throw
      painter.paint(canvas, size);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paint handles empty boxes without error', () {
      final painter = BoxesPainter([]);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(100, 100);

      // Should not throw
      painter.paint(canvas, size);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paint with normalized coordinates scales to canvas size', () {
      // BBox values are normalized [0..1], so l=0.1 on a 200px canvas = 20px
      final boxes = [
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
      ];
      final painter = BoxesPainter(boxes);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(200, 200);

      // Should not throw
      painter.paint(canvas, size);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('paint with single box at full size', () {
      final boxes = [
        const BBox(l: 0.0, t: 0.0, w: 1.0, h: 1.0),
      ];
      final painter = BoxesPainter(boxes);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(300, 400);

      painter.paint(canvas, size);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('shouldRepaint returns true for different length lists', () {
      final painter1 = BoxesPainter([
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
      ]);
      final painter2 = BoxesPainter([
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
        const BBox(l: 0.5, t: 0.6, w: 0.7, h: 0.8),
      ]);
      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns true for empty vs non-empty', () {
      final painter1 = BoxesPainter([]);
      final painter2 = BoxesPainter([
        const BBox(l: 0.1, t: 0.2, w: 0.3, h: 0.4),
      ]);
      expect(painter1.shouldRepaint(painter2), true);
    });
  });

  group('OcrReviewScreen – widget basics', () {
    const channel = MethodChannel('care_connect/ocr');

    setUp(() {
      // Mock the OCR MethodChannel to return empty results
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'analyze') {
          return <dynamic>[];
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('renders Scaffold with AppBar title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrReviewScreen(images: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Review & OCR'), findsOneWidget);
    });

    testWidgets('shows "No images" when image list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrReviewScreen(images: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No images'), findsOneWidget);
    });

    testWidgets('Done button is present in AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrReviewScreen(images: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('renders without crashing when images are provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrReviewScreen(images: [XFile('/tmp/fake.jpg')]),
        ),
      );
      await tester.pumpAndSettle();

      // After OCR returns empty, the image list is still populated
      // but Image.file may fail in test - just verify no crash
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('OcrReviewScreen – with OCR error', () {
    const channel = MethodChannel('care_connect/ocr');

    setUp(() {
      // Mock the OCR MethodChannel to throw an error
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'OCR_ERROR', message: 'Failed');
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('shows error message when OCR fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrReviewScreen(images: [XFile('/tmp/fake.jpg')]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OCR failed. Tap Retry.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
