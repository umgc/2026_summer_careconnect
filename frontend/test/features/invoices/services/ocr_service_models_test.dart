// Tests for OCR service model classes
// (lib/features/invoices/services/ocr_service.dart).
// Tests BBox, OcrLine, OcrQr, OcrRichResult factory constructors only.
// OcrService.analyzeImages uses a MethodChannel and is skipped.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/services/ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BBox', () {
    test('stores l, t, w, h', () {
      const b = BBox(l: 1.0, t: 2.0, w: 3.0, h: 4.0);
      expect(b.l, 1.0);
      expect(b.t, 2.0);
      expect(b.w, 3.0);
      expect(b.h, 4.0);
    });

    test('BBox.from parses map with num values', () {
      final b = BBox.from({'l': 10, 't': 20, 'w': 30, 'h': 40});
      expect(b.l, 10.0);
      expect(b.t, 20.0);
      expect(b.w, 30.0);
      expect(b.h, 40.0);
    });

    test('BBox.from parses map with double values', () {
      final b = BBox.from({'l': 1.5, 't': 2.5, 'w': 3.5, 'h': 4.5});
      expect(b.l, 1.5);
      expect(b.t, 2.5);
    });
  });

  group('OcrLine', () {
    test('stores text and box', () {
      const b = BBox(l: 0, t: 0, w: 100, h: 20);
      final line = OcrLine(text: 'Hello', box: b);
      expect(line.text, 'Hello');
      expect(line.box.w, 100.0);
    });

    test('OcrLine.from parses text and box from map', () {
      final line = OcrLine.from({
        'text': 'Invoice',
        'box': {'l': 5, 't': 10, 'w': 80, 'h': 15},
      });
      expect(line.text, 'Invoice');
      expect(line.box.l, 5.0);
      expect(line.box.h, 15.0);
    });

    test('OcrLine.from uses empty string when text is null', () {
      final line = OcrLine.from({
        'text': null,
        'box': {'l': 0, 't': 0, 'w': 1, 'h': 1},
      });
      expect(line.text, '');
    });
  });

  group('OcrQr', () {
    test('stores value and optional box', () {
      final qr = OcrQr(value: 'https://example.com');
      expect(qr.value, 'https://example.com');
      expect(qr.box, isNull);
    });

    test('OcrQr.from parses value without box', () {
      final qr = OcrQr.from({'value': 'ABC123', 'box': null});
      expect(qr.value, 'ABC123');
      expect(qr.box, isNull);
    });

    test('OcrQr.from parses value with box', () {
      final qr = OcrQr.from({
        'value': 'QR-DATA',
        'box': {'l': 0, 't': 0, 'w': 50, 'h': 50},
      });
      expect(qr.value, 'QR-DATA');
      expect(qr.box, isNotNull);
      expect(qr.box!.w, 50.0);
    });

    test('OcrQr.from uses empty string when value is null', () {
      final qr = OcrQr.from({'value': null, 'box': null});
      expect(qr.value, '');
    });
  });

  group('OcrRichResult', () {
    test('stores path, text, lines, qrcodes', () {
      final result = OcrRichResult(
        path: '/tmp/img.jpg',
        text: 'full text',
        lines: [],
        qrcodes: [],
      );
      expect(result.path, '/tmp/img.jpg');
      expect(result.text, 'full text');
      expect(result.lines, isEmpty);
      expect(result.qrcodes, isEmpty);
    });

    test('OcrRichResult.from parses full map', () {
      final result = OcrRichResult.from({
        'path': '/docs/scan.png',
        'text': 'OCR output',
        'lines': [
          {
            'text': 'Line one',
            'box': {'l': 0, 't': 0, 'w': 100, 'h': 12},
          },
        ],
        'qrcodes': [
          {'value': 'QR-VAL', 'box': null},
        ],
      });
      expect(result.path, '/docs/scan.png');
      expect(result.text, 'OCR output');
      expect(result.lines.length, 1);
      expect(result.lines[0].text, 'Line one');
      expect(result.qrcodes.length, 1);
      expect(result.qrcodes[0].value, 'QR-VAL');
    });

    test('OcrRichResult.from handles null lines and qrcodes', () {
      final result = OcrRichResult.from({
        'path': '/a.png',
        'text': null,
        'lines': null,
        'qrcodes': null,
      });
      expect(result.text, '');
      expect(result.lines, isEmpty);
      expect(result.qrcodes, isEmpty);
    });

    test('OcrRichResult.from handles empty lines and qrcodes lists', () {
      final result = OcrRichResult.from({
        'path': '/b.png',
        'text': 'some text',
        'lines': <Map<dynamic, dynamic>>[],
        'qrcodes': <Map<dynamic, dynamic>>[],
      });
      expect(result.text, 'some text');
      expect(result.lines, isEmpty);
      expect(result.qrcodes, isEmpty);
    });

    test('OcrRichResult.from with multiple lines and qrcodes', () {
      final result = OcrRichResult.from({
        'path': '/multi.png',
        'text': 'line1 line2',
        'lines': [
          {'text': 'line1', 'box': {'l': 0, 't': 0, 'w': 50, 'h': 10}},
          {'text': 'line2', 'box': {'l': 0, 't': 15, 'w': 50, 'h': 10}},
        ],
        'qrcodes': [
          {'value': 'QR1', 'box': {'l': 0, 't': 0, 'w': 30, 'h': 30}},
          {'value': 'QR2', 'box': null},
        ],
      });
      expect(result.lines.length, 2);
      expect(result.lines[1].text, 'line2');
      expect(result.qrcodes.length, 2);
      expect(result.qrcodes[0].box, isNotNull);
      expect(result.qrcodes[1].box, isNull);
    });
  });

  group('BBox – edge cases', () {
    test('BBox.from with zero values', () {
      final b = BBox.from({'l': 0, 't': 0, 'w': 0, 'h': 0});
      expect(b.l, 0.0);
      expect(b.w, 0.0);
    });

    test('BBox.from with large values', () {
      final b = BBox.from({'l': 9999.99, 't': 8888.88, 'w': 7777.77, 'h': 6666.66});
      expect(b.l, 9999.99);
      expect(b.h, 6666.66);
    });
  });

  group('OcrQr – edge cases', () {
    test('OcrQr with box stores box correctly', () {
      const box = BBox(l: 1, t: 2, w: 3, h: 4);
      final qr = OcrQr(value: 'test', box: box);
      expect(qr.box, isNotNull);
      expect(qr.box!.l, 1.0);
    });

    test('OcrQr.from without box key in map', () {
      final qr = OcrQr.from({'value': 'nobox'});
      expect(qr.value, 'nobox');
      expect(qr.box, isNull);
    });
  });

  group('OcrService.analyzeImages – MethodChannel mock', () {
    const channel = MethodChannel('care_connect/ocr');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'analyze') {
          return <dynamic>[
            <dynamic, dynamic>{
              'path': '/tmp/test.jpg',
              'text': 'Hello World',
              'lines': <dynamic>[
                <dynamic, dynamic>{
                  'text': 'Hello',
                  'box': <dynamic, dynamic>{'l': 0, 't': 0, 'w': 50, 'h': 10},
                },
                <dynamic, dynamic>{
                  'text': 'World',
                  'box': <dynamic, dynamic>{'l': 0, 't': 15, 'w': 50, 'h': 10},
                },
              ],
              'qrcodes': <dynamic>[
                <dynamic, dynamic>{'value': 'QR123', 'box': null},
              ],
            },
          ];
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('returns parsed OcrRichResult list', () async {
      final results = await OcrService.analyzeImages([]);
      expect(results.length, 1);
      expect(results[0].path, '/tmp/test.jpg');
      expect(results[0].text, 'Hello World');
      expect(results[0].lines.length, 2);
      expect(results[0].lines[0].text, 'Hello');
      expect(results[0].qrcodes.length, 1);
      expect(results[0].qrcodes[0].value, 'QR123');
    });

    test('returns empty list when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);
      final results = await OcrService.analyzeImages([]);
      expect(results, isEmpty);
    });

    test('returns empty list when channel returns empty list', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => <dynamic>[]);
      final results = await OcrService.analyzeImages([]);
      expect(results, isEmpty);
    });
  });
}
