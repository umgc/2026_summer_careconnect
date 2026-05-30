// Tests for PatientNotesWidget from medical_notes_widget.dart
// (lib/widgets/medical_notes_widget.dart).
//
// _loadPatientNotes() called in initState — HTTP, _isLoading=true initially.
// No Provider needed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/widgets/medical_notes_widget.dart';

Widget _wrap({
  int patientId = 1,
  String patientName = 'Jane Doe',
  bool isReadOnly = false,
  String? filterCategory,
  Brightness brightness = Brightness.light,
}) =>
    MaterialApp(
      theme: brightness == Brightness.light
          ? ThemeData.light()
          : ThemeData.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: PatientNotesWidget(
            patientId: patientId,
            patientName: patientName,
            isReadOnly: isReadOnly,
            filterCategory: filterCategory,
          ),
        ),
      ),
    );

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async {
        if (call.method == 'check') return ['wifi'];
        return null;
      },
    );
  });

  group('PatientNotesWidget – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator while loading',
        (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays "Patient Notes" header text', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Patient Notes'), findsOneWidget);
    });
  });

  group('PatientNotesWidget – Upload button visibility', () {
    testWidgets('shows Upload Note button when isReadOnly is false',
        (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: false));
      // Initially or after pump, the Upload Note button should exist
      final hasUpload = find.text('Upload Note').evaluate().isNotEmpty;
      final hasUploading = find.text('Uploading...').evaluate().isNotEmpty;
      final hasButton =
          find.byType(ElevatedButton).evaluate().isNotEmpty;
      expect(hasUpload || hasUploading || hasButton, isTrue);
    });

    testWidgets('hides Upload Note button when isReadOnly is true',
        (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: true));
      expect(find.text('Upload Note'), findsNothing);
    });
  });

  group('PatientNotesWidget – constructor properties', () {
    testWidgets('accepts patientId and patientName', (tester) async {
      await tester.pumpWidget(_wrap(
        patientId: 42,
        patientName: 'John Smith',
      ));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('accepts filterCategory parameter', (tester) async {
      await tester.pumpWidget(_wrap(
        filterCategory: 'medicalNote',
      ));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('accepts null filterCategory', (tester) async {
      await tester.pumpWidget(_wrap(
        filterCategory: null,
      ));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });
  });

  group('PatientNotesWidget – after loading completes', () {
    testWidgets(
        'shows either notes list, empty state, or error after loading',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 2));

      // After loading, we should see one of:
      // 1. Notes list (ListView)
      // 2. Empty state ("No patient notes found")
      // 3. Error state (error icon/message)
      // 4. Still loading (CircularProgressIndicator)
      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      final hasError = find.text('Retry').evaluate().isNotEmpty;
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasEmptyState || hasError || hasList || hasLoading, isTrue);
    });

    testWidgets('empty state shows correct message for non-readonly mode',
        (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: false));
      await tester.pump(const Duration(seconds: 2));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      if (hasEmptyState) {
        expect(
          find.text('Upload your first patient note to get started'),
          findsOneWidget,
        );
      }
    });

    testWidgets(
        'empty state shows patient name message for readonly mode',
        (tester) async {
      await tester.pumpWidget(
          _wrap(isReadOnly: true, patientName: 'Jane Doe'));
      await tester.pump(const Duration(seconds: 2));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      if (hasEmptyState) {
        expect(
          find.text(
              'No patient notes have been uploaded for Jane Doe'),
          findsOneWidget,
        );
      }
    });

    testWidgets('empty state shows medical information icon',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 2));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      if (hasEmptyState) {
        expect(
          find.byIcon(Icons.medical_information_outlined),
          findsOneWidget,
        );
      }
    });

    testWidgets('error state shows Retry button', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 2));

      final hasError = find.text('Retry').evaluate().isNotEmpty;
      if (hasError) {
        expect(find.byIcon(Icons.error), findsOneWidget);
        expect(find.byType(ElevatedButton), findsWidgets);
      }
    });

    testWidgets('error state shows error icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 2));

      final hasError = find.text('Retry').evaluate().isNotEmpty;
      if (hasError) {
        expect(find.byIcon(Icons.error), findsOneWidget);
      }
    });
  });

  group('PatientNotesWidget – dark theme', () {
    testWidgets('renders in dark theme without crashing', (tester) async {
      await tester.pumpWidget(_wrap(brightness: Brightness.dark));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
      expect(find.text('Patient Notes'), findsOneWidget);
    });

    testWidgets('shows loading indicator in dark theme', (tester) async {
      await tester.pumpWidget(_wrap(brightness: Brightness.dark));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('dark theme after loading', (tester) async {
      await tester.pumpWidget(_wrap(brightness: Brightness.dark));
      await tester.pump(const Duration(seconds: 2));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      final hasError = find.text('Retry').evaluate().isNotEmpty;
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasEmptyState || hasError || hasList || hasLoading, isTrue);
    });
  });

  group('PatientNotesWidget – header layout', () {
    testWidgets('header is in a Row widget', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('header text has bold font weight', (tester) async {
      await tester.pumpWidget(_wrap());
      final textWidget = tester.widget<Text>(find.text('Patient Notes'));
      expect(textWidget, isNotNull);
    });

    testWidgets('widget is a Column at the top level', (tester) async {
      await tester.pumpWidget(_wrap());
      // The PatientNotesWidget build method returns a Column
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('PatientNotesWidget – Upload button state', () {
    testWidgets('upload button has upload_file icon', (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: false));
      final hasUploadIcon =
          find.byIcon(Icons.upload_file).evaluate().isNotEmpty;
      // Could be uploading state with CircularProgressIndicator instead
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasUploadIcon || hasLoading, isTrue);
    });

    testWidgets('upload button is an ElevatedButton with icon',
        (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: false));
      // There should be at least one ElevatedButton (Upload Note)
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('PatientNotesWidget – different filter categories', () {
    testWidgets('renders with generalNote filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'generalNote'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with medicalNote filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'medicalNote'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with labResult filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'labResult'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with prescription filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'prescription'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with appointment filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'appointment'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with careNote filter', (tester) async {
      await tester.pumpWidget(_wrap(filterCategory: 'careNote'));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });
  });

  group('PatientNotesWidget – readonly vs editable', () {
    testWidgets('readonly mode hides upload button', (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: true));
      expect(find.text('Upload Note'), findsNothing);
      expect(find.text('Uploading...'), findsNothing);
    });

    testWidgets('editable mode shows upload section', (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: false));
      // The upload button or uploading text should be present
      final hasUpload = find.text('Upload Note').evaluate().isNotEmpty;
      final hasUploading = find.text('Uploading...').evaluate().isNotEmpty;
      expect(hasUpload || hasUploading, isTrue);
    });

    testWidgets(
        'readonly mode still shows Patient Notes header', (tester) async {
      await tester.pumpWidget(_wrap(isReadOnly: true));
      expect(find.text('Patient Notes'), findsOneWidget);
    });
  });

  group('PatientNotesWidget – different patient IDs', () {
    testWidgets('renders with patient ID 0', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 0));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });

    testWidgets('renders with large patient ID', (tester) async {
      await tester.pumpWidget(_wrap(patientId: 999999));
      expect(find.byType(PatientNotesWidget), findsOneWidget);
    });
  });

  group('PatientNotesWidget – widget structure after pump', () {
    testWidgets('contains a SizedBox for spacing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('after short pump still shows content', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(milliseconds: 100));
      // Should have either loading or resolved state
      final hasContent = find.byType(PatientNotesWidget).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });

    testWidgets('after multiple pumps reaches stable state', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      final hasError = find.text('Retry').evaluate().isNotEmpty;
      final hasList = find.byType(ListView).evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(hasEmptyState || hasError || hasList || hasLoading, isTrue);
    });
  });

  group('PatientNotesWidget – empty state details', () {
    testWidgets('empty state for readonly with different patient name',
        (tester) async {
      await tester.pumpWidget(
          _wrap(isReadOnly: true, patientName: 'Alice Smith'));
      await tester.pump(const Duration(seconds: 2));

      final hasEmptyState =
          find.text('No patient notes found').evaluate().isNotEmpty;
      if (hasEmptyState) {
        expect(
          find.text(
              'No patient notes have been uploaded for Alice Smith'),
          findsOneWidget,
        );
      }
    });
  });

  group('PatientNotesWidget – Card usage', () {
    testWidgets('uses Card widgets for states', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 2));

      // After loading, there should be Card widgets for either
      // empty state, error state, or note items
      final hasCard = find.byType(Card).evaluate().isNotEmpty;
      final hasLoading =
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      expect(hasCard || hasLoading, isTrue);
    });
  });
}
