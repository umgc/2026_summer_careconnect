// Tests for ChatPage user interactions (menu, dialogs, snackbars).
// Complements the existing chat_page_test.dart which covers initial render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/social/in-app-chat/pages/chat-page.dart';

Widget _wrap() => const MaterialApp(
      home: ChatPage(contactName: 'Dr. Smith', contactRole: 'Doctor'),
    );

void main() {
  group('ChatPage – phone action button', () {
    testWidgets('tapping phone icon shows snackbar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.phone));
      await tester.pump(); // trigger snackbar

      expect(find.text('Audio call not implemented yet'), findsOneWidget);
    });
  });

  group('ChatPage – video action button', () {
    testWidgets('tapping videocam icon shows snackbar', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.videocam));
      await tester.pump(); // trigger snackbar

      expect(find.text('Video call not implemented yet'), findsOneWidget);
    });
  });

  group('ChatPage – popup menu', () {
    testWidgets('tapping more_vert shows menu items', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Delete chat'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('AI Service'), findsOneWidget);
    });

    testWidgets('tapping Delete chat opens delete dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete chat'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Chat'), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to delete this chat? This action cannot be undone.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      // The Delete button inside the dialog
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancel button in delete dialog dismisses it', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete chat'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(
        find.text(
            'Are you sure you want to delete this chat? This action cannot be undone.'),
        findsNothing,
      );
    });

    testWidgets('delete button in delete dialog shows snackbar',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete chat'));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Chat deleted'), findsOneWidget);
    });

    testWidgets('tapping Search opens search dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Search Messages'), findsOneWidget);
      expect(
          find.text('Search in this conversation...'), findsOneWidget);
    });

    testWidgets('cancel button in search dialog dismisses it',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Search Messages'), findsNothing);
    });

    testWidgets('search button in search dialog shows snackbar',
        (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Open search dialog
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // There are two "Search" texts now: dialog title area and button.
      // Tap the Search button inside the dialog actions.
      final searchButtons = find.widgetWithText(TextButton, 'Search');
      await tester.tap(searchButtons);
      await tester.pumpAndSettle();

      expect(find.text('Search functionality not implemented yet'),
          findsOneWidget);
    });

    testWidgets('tapping AI Service opens AI dialog', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('AI Service'));
      await tester.pumpAndSettle();

      expect(find.text('AI Service'), findsOneWidget);
      expect(
        find.text('Would you like to open the AI chat assistant?'),
        findsOneWidget,
      );
      expect(find.text('Open AI Chat'), findsOneWidget);
    });

    testWidgets('cancel button in AI dialog dismisses it', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('AI Service'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text('Would you like to open the AI chat assistant?'),
        findsNothing,
      );
    });
  });

  group('ChatPage – popup menu icons', () {
    testWidgets('delete menu item shows delete icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('search menu item shows search icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('AI menu item shows smart_toy icon', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    });
  });
}
