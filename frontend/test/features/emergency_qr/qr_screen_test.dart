// Tests for QrScreen
// (lib/features/emergency_qr/qr_screen.dart).
//
// QrScreen is a StatelessWidget — no Provider, no API calls.
// Tests cover initial render with various payload configurations.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/emergency_qr/qr_screen.dart';

Widget _wrap({
  String payload = 'EMERGENCY TEST DATA',
  String? emergencyId,
  int? patientId,
}) =>
    MaterialApp(
      home: QrScreen(
        payload: payload,
        emergencyId: emergencyId,
        patientId: patientId,
      ),
    );

void main() {
  group('QrScreen – initial render (no emergencyId)', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(QrScreen), findsOneWidget);
    });

    testWidgets('shows "Emergency Information" in AppBar', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Emergency Information'), findsOneWidget);
    });

    testWidgets('shows a Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('does NOT show PDF button when emergencyId is null',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('View Emergency PDF'), findsNothing);
    });
  });

  group('QrScreen – with emergencyId', () {
    testWidgets('renders without crashing when emergencyId is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.byType(QrScreen), findsOneWidget);
    });

    testWidgets('shows AppBar with emergencyId provided', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.text('Emergency Information'), findsOneWidget);
    });

    testWidgets('shows "View Emergency PDF" button when emergencyId is set',
        (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.text('View Emergency PDF'), findsOneWidget);
    });

    testWidgets('shows PDF icon when emergencyId is set', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('shows "Download Emergency PDF" button', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.text('Download Emergency PDF'), findsOneWidget);
    });

    testWidgets('shows download icon', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('shows "Share Emergency Info" button', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.text('Share Emergency Info'), findsOneWidget);
    });

    testWidgets('shows share icon', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('shows "Print Emergency PDF" button', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.text('Print Emergency PDF'), findsOneWidget);
    });

    testWidgets('shows print icon', (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      expect(find.byIcon(Icons.print), findsOneWidget);
    });

    testWidgets('shows multiple ElevatedButtons when emergencyId is set',
        (tester) async {
      await tester.pumpWidget(_wrap(emergencyId: 'emg-123'));
      // View PDF + Download + Share + Print = 4 buttons
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });
  });

  group('QrScreen – no emergencyId buttons hidden', () {
    testWidgets('does NOT show Download button without emergencyId',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Download Emergency PDF'), findsNothing);
    });

    testWidgets('does NOT show Share button without emergencyId',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Share Emergency Info'), findsNothing);
    });

    testWidgets('does NOT show Print button without emergencyId',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Print Emergency PDF'), findsNothing);
    });

    testWidgets('shows no ElevatedButton without emergencyId',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });
}
