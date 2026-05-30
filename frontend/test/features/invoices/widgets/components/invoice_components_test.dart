// Tests for small, pure invoice component widgets:
//   KeyValueRow  (components/key_value_row.dart)
//   PrevNextBar  (components/prev_next_bar.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/widgets/components/key_value_row.dart';
import 'package:care_connect_app/features/invoices/widgets/components/prev_next_bar.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

// ─────────────────────────────────────────────────────────────────────────────
// KeyValueRow
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  group('KeyValueRow', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const KeyValueRow('Label', 'Value')));
      expect(find.byType(KeyValueRow), findsOneWidget);
    });

    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(_wrap(const KeyValueRow('Invoice Date', '2024-06-15')));
      expect(find.text('Invoice Date'), findsOneWidget);
    });

    testWidgets('shows value text', (tester) async {
      await tester.pumpWidget(_wrap(const KeyValueRow('Invoice Date', '2024-06-15')));
      expect(find.text('2024-06-15'), findsOneWidget);
    });

    testWidgets('renders with success = true without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        const KeyValueRow('Status', 'Paid', success: true),
      ));
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('renders with allowWrap = true without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        const KeyValueRow('Notes', 'Long text content here', allowWrap: true),
      ));
      expect(find.text('Notes'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PrevNextBar
  // ───────────────────────────────────────────────────────────────────────────
  group('PrevNextBar', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.byType(PrevNextBar), findsOneWidget);
    });

    testWidgets('shows "Prev" button', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.text('Prev'), findsOneWidget);
    });

    testWidgets('shows "Next" button when isLast is false', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: false,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('shows "Save" button when isLast is true', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: true,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('shows save icon when isLast is true', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: true,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('shows chevron_right icon when isLast is false', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows chevron_left icon', (tester) async {
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () {},
      )));
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('calls onPrev when Prev tapped and canPrev is true', (tester) async {
      bool prevCalled = false;
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: true,
        isLast: false,
        onPrev: () => prevCalled = true,
        onNextOrSave: () {},
      )));
      await tester.tap(find.text('Prev'));
      expect(prevCalled, isTrue);
    });

    testWidgets('Prev button disabled when canPrev is false', (tester) async {
      bool prevCalled = false;
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: false,
        isLast: false,
        onPrev: () => prevCalled = true,
        onNextOrSave: () {},
      )));
      await tester.tap(find.text('Prev'));
      expect(prevCalled, isFalse);
    });

    testWidgets('calls onNextOrSave when Next tapped', (tester) async {
      bool nextCalled = false;
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: false,
        isLast: false,
        onPrev: () {},
        onNextOrSave: () => nextCalled = true,
      )));
      await tester.tap(find.text('Next'));
      expect(nextCalled, isTrue);
    });

    testWidgets('calls onNextOrSave when Save tapped', (tester) async {
      bool saveCalled = false;
      await tester.pumpWidget(_wrap(PrevNextBar(
        canPrev: false,
        isLast: true,
        onPrev: () {},
        onNextOrSave: () => saveCalled = true,
      )));
      await tester.tap(find.text('Save'));
      expect(saveCalled, isTrue);
    });
  });
}
