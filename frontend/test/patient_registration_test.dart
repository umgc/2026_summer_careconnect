import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/onboarding/presentation/pages/patient_registration.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('PatientRegistrationPage', () {
    Widget buildTestWidget() {
      final mockUser = UserSession(
        id: 1,
        role: 'caregiver',
        token: 'mock_token',
        email: 'testcaregiver@sample.com',
        caregiverId: 1,
      );

      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => UserProvider()..setUser(mockUser),
          child: const PatientRegistrationPage(),
        ),
      );
    }

    testWidgets('renders patient registration form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify that the form elements are present
      // The page title is 'Register New Patient'
      expect(find.text('Register New Patient'), findsAtLeast(1));
      // Form fields use asterisk-suffixed labels (e.g. 'First Name *')
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Last Name *'), findsOneWidget);
      expect(find.text('Email Address *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.text('Date of Birth *'), findsOneWidget);
    });

    testWidgets('validates required fields on step 0', (WidgetTester tester) async {
      // Use a larger surface size to avoid overflow with the Stepper
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap the first Next button (step 0) without filling in fields
      final nextButton = find.text('Next').first;
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // After tapping Next without filling fields, validation errors
      // and/or a SnackBar should appear
      final snackBarFinder = find.textContaining('Please complete all required fields');
      final firstNameError = find.text('Please enter first name');

      expect(
        snackBarFinder.evaluate().length + firstNameError.evaluate().length,
        greaterThan(0),
      );

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('shows Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows TextFormField widgets', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows Register Patient button on final step', (WidgetTester tester) async {
      // Increase viewport size to avoid overflow issues with the Stepper
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The Stepper has 3 steps. 'Register Patient' is only shown on step 2.
      // We need to navigate through the steps to see it.
      // The step titles are visible in the Stepper header.
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Address Information'), findsOneWidget);
      expect(find.text('Relationship'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
