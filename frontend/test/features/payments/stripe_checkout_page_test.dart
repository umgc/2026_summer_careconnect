// Tests for StripeCheckoutPage
// (lib/features/payments/presentation/pages/stripe_checkout_page.dart).
//
// StripeCheckoutPage receives a PackageModel and renders payment UI.
// No API calls in initState — _pay() only fires on button press.
// Tests cover initial render with a sample package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/payments/presentation/pages/stripe_checkout_page.dart';
import 'package:care_connect_app/features/payments/models/package_model.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

PackageModel _makePackage({
  String name = 'Basic Plan',
  String description = 'Essential care features',
  int priceCents = 999,
  String id = 'pkg-1',
}) =>
    PackageModel(
      name: name,
      description: description,
      priceCents: priceCents,
      id: id,
    );

Widget _wrap({PackageModel? pkg, String? userId}) => MaterialApp(
      home: StripeCheckoutPage(
        package: pkg ?? _makePackage(),
        userId: userId ?? '42',
      ),
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('StripeCheckoutPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(StripeCheckoutPage), findsOneWidget);
    });

    testWidgets('shows package name in AppBar', (tester) async {
      await tester.pumpWidget(_wrap(pkg: _makePackage(name: 'Pro Plan')));
      expect(find.textContaining('Pro Plan'), findsWidgets);
    });

    testWidgets('shows package name in body', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Basic Plan'), findsWidgets);
    });

    testWidgets('shows package description', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Essential care features'), findsOneWidget);
    });

    testWidgets('shows formatted price', (tester) async {
      // priceCents=999 → "$9.99 / mo"
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('9.99'), findsOneWidget);
    });

    testWidgets('shows "Pay with Stripe" button', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.text('Pay with Stripe'), findsOneWidget);
    });

    testWidgets('"Pay with Stripe" button is enabled initially', (tester) async {
      await tester.pumpWidget(_wrap());
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Pay with Stripe'),
      );
      // _isProcessing=false → onPressed is not null.
      expect(button.onPressed, isNotNull);
    });

    testWidgets('does NOT show CircularProgressIndicator initially',
        (tester) async {
      // _isProcessing=false → no spinner.
      await tester.pumpWidget(_wrap());
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('does NOT show status text initially', (tester) async {
      // _status=null → no status message displayed.
      await tester.pumpWidget(_wrap());
      expect(find.textContaining('successful'), findsNothing);
    });

    testWidgets('shows a Scaffold', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('StripeCheckoutPage – package with different prices', () {
    testWidgets('shows correct price for Premium plan', (tester) async {
      await tester.pumpWidget(_wrap(
        pkg: _makePackage(name: 'Premium', priceCents: 2999),
      ));
      expect(find.textContaining('29.99'), findsOneWidget);
    });

    testWidgets('shows correct price for free plan', (tester) async {
      await tester.pumpWidget(_wrap(
        pkg: _makePackage(name: 'Free', priceCents: 0),
      ));
      expect(find.textContaining('0.00'), findsOneWidget);
    });
  });
}
