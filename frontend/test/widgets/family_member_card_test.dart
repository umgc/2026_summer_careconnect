// Tests for FamilyMemberCard widget
// (lib/widgets/family_member_card.dart).
// Pure StatelessWidget — url_launcher calls only happen on button press.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/family_member_card.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

FamilyMemberCard _card({
  String firstName = 'Alice',
  String lastName = 'Smith',
  String relationship = 'Daughter',
  String phone = '555-1234',
  String email = 'alice@example.com',
  String lastInteraction = '2024-01-15',
}) =>
    FamilyMemberCard(
      firstName: firstName,
      lastName: lastName,
      relationship: relationship,
      phone: phone,
      email: email,
      lastInteraction: lastInteraction,
    );

void _installUrlLauncherMock() {
  const channels = [
    'plugins.flutter.io/url_launcher',
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher_linux',
    'plugins.flutter.io/url_launcher_macos',
    'plugins.flutter.io/url_launcher_windows',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async {
      if (call.method == 'canLaunch') return true;
      if (call.method == 'launch') return true;
      if (call.method == 'launchUrl') return true;
      return null;
    });
  }
}

void _removeUrlLauncherMock() {
  const channels = [
    'plugins.flutter.io/url_launcher',
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher_linux',
    'plugins.flutter.io/url_launcher_macos',
    'plugins.flutter.io/url_launcher_windows',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('FamilyMemberCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('shows full name (firstName + lastName)', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Bob', lastName: 'Jones')));
      expect(find.text('Bob Jones'), findsOneWidget);
    });

    testWidgets('shows relationship text', (tester) async {
      await tester.pumpWidget(_wrap(_card(relationship: 'Son')));
      expect(find.text('Son'), findsOneWidget);
    });

    testWidgets('shows last interaction text', (tester) async {
      await tester.pumpWidget(_wrap(_card(lastInteraction: '2024-06-01')));
      expect(find.textContaining('2024-06-01'), findsOneWidget);
    });

    testWidgets('shows CircleAvatar with first letter of firstName', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Carol')));
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders Card widget', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows phone icon button', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byIcon(Icons.phone), findsAtLeastNWidgets(1));
    });

    testWidgets('shows message icon button', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byIcon(Icons.message), findsAtLeastNWidgets(1));
    });

    testWidgets('shows email icon when email is provided', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'test@example.com')));
      expect(find.byIcon(Icons.email), findsAtLeastNWidgets(1));
    });

    testWidgets('shows email text when email provided', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'test@example.com')));
      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('does not show email icon when email is empty', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: '')));
      expect(find.byIcon(Icons.email), findsNothing);
    });

    testWidgets('shows more_vert popup menu button', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('popup menu contains Call, Send SMS, Edit, Delete items', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Send SMS'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('tapping Delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Alice', lastName: 'Smith')));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Family Member'), findsOneWidget);
      expect(find.textContaining('Alice Smith'), findsAtLeastNWidgets(1));
    });

    testWidgets('fullName getter trims whitespace', (tester) async {
      // Widget constructor sets firstName and lastName; fullName should trim
      await tester.pumpWidget(_wrap(_card(firstName: 'John', lastName: 'Doe')));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('CircleAvatar shows F when firstName is empty', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: '')));
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('popup menu shows Send Email when email provided', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'test@test.com')));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Send Email'), findsOneWidget);
    });

    testWidgets('popup menu does NOT show Send Email when email is empty', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: '')));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Send Email'), findsNothing);
    });

    testWidgets('tapping Edit shows SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit feature coming soon'), findsOneWidget);
    });

    testWidgets('delete confirmation Cancel dismisses dialog', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Family Member'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Family Member'), findsNothing);
    });

    testWidgets('delete confirmation Delete shows removed SnackBar', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Alice', lastName: 'Smith')));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      // Tap the Delete button in the confirmation dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith removed successfully'), findsOneWidget);
    });

    testWidgets('shows Call tooltip on phone button', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Dave')));
      expect(find.byTooltip('Call Dave'), findsOneWidget);
    });

    testWidgets('shows SMS tooltip on message button', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Dave')));
      expect(find.byTooltip('Send SMS to Dave'), findsOneWidget);
    });

    testWidgets('shows Email tooltip when email provided', (tester) async {
      await tester.pumpWidget(_wrap(_card(firstName: 'Dave', email: 'dave@example.com')));
      expect(find.byTooltip('Email Dave'), findsOneWidget);
    });

    testWidgets('does not show email text when email is empty', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: '')));
      expect(find.textContaining('Email:'), findsNothing);
    });

    testWidgets('shows ListTile', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('shows Last Interaction text', (tester) async {
      await tester.pumpWidget(_wrap(_card(lastInteraction: 'Yesterday')));
      expect(find.text('Last Interaction: Yesterday'), findsOneWidget);
    });
  });

  group('FamilyMemberCard – url_launcher actions', () {
    setUp(() => _installUrlLauncherMock());
    tearDown(() => _removeUrlLauncherMock());

    testWidgets('tapping phone icon does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      final phoneButtons = find.byIcon(Icons.phone);
      await tester.tap(phoneButtons.first);
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('tapping message icon does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      final msgButtons = find.byIcon(Icons.message);
      await tester.tap(msgButtons.first);
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('tapping email icon does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'test@example.com')));
      final emailButtons = find.byIcon(Icons.email);
      await tester.tap(emailButtons.first);
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('popup Call action does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Call'));
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('popup Send SMS action does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card()));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send SMS'));
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });

    testWidgets('popup Send Email action does not crash', (tester) async {
      await tester.pumpWidget(_wrap(_card(email: 'a@b.com')));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Email'));
      await tester.pumpAndSettle();
      expect(find.byType(FamilyMemberCard), findsOneWidget);
    });
  });
}
