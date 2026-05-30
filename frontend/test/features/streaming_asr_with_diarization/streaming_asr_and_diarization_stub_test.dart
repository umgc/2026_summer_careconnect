// Tests for StreamingAsrAndDiarizationScreen stub
// (lib/features/streaming_asr_with_diarization/streaming_asr_and_diarization_stub.dart).
// The stub renders a Text widget explaining the feature is unavailable on web.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/streaming_asr_with_diarization/streaming_asr_and_diarization_stub.dart';

void main() {
  testWidgets('renders unavailable message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreamingAsrAndDiarizationScreen(),
        ),
      ),
    );
    expect(
      find.textContaining('not available'),
      findsOneWidget,
    );
  });

  testWidgets('accepts optional patientId and callbacks', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreamingAsrAndDiarizationScreen(
            patientId: 'p-123',
            onUploadSuccess: (_) {},
            onUploadError: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(StreamingAsrAndDiarizationScreen), findsOneWidget);
  });

  testWidgets('renders a Center widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreamingAsrAndDiarizationScreen()),
      ),
    );
    expect(find.byType(Center), findsWidgets);
  });

  testWidgets('renders a Padding widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreamingAsrAndDiarizationScreen()),
      ),
    );
    expect(find.byType(Padding), findsWidgets);
  });

  testWidgets('renders a Text widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreamingAsrAndDiarizationScreen()),
      ),
    );
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('message mentions Web', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreamingAsrAndDiarizationScreen()),
      ),
    );
    expect(find.textContaining('Web'), findsOneWidget);
  });

  testWidgets('renders without callbacks', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreamingAsrAndDiarizationScreen(patientId: 'abc'),
        ),
      ),
    );
    expect(find.byType(StreamingAsrAndDiarizationScreen), findsOneWidget);
  });
}
