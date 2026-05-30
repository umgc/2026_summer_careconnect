// Tests for OverdueBlock and OverdueTile widgets
// (lib/features/invoices/screens/dashboard/widgets/overdue_block.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/widgets/overdue_block.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';

// Minimal Invoice builder for tests
Invoice _makeInvoice({
  required String id,
  required String providerName,
  required PaymentStatus status,
  required DateTime dueDate,
  double amountDue = 100.0,
}) {
  final now = DateTime.now();
  return Invoice(
    id: id,
    invoiceNumber: 'INV-$id',
    provider: ProviderInfo(name: providerName, address: 'Addr', phone: '555'),
    patient: const PatientInfo(name: 'Patient'),
    dates: InvoiceDates(
      statementDate: now,
      dueDate: dueDate,
    ),
    paymentStatus: status,
    billedToInsurance: false,
    amounts: Amounts(amountDue: amountDue),
    paymentReferences: PaymentReferences(supportedMethods: const []),
    createdAt: now.toIso8601String(),
    updatedAt: now.toIso8601String(),
    createdBy: 'test',
    updatedBy: 'test',
    payments: const [],
  );
}

final _pastDate = DateTime.now().subtract(const Duration(days: 10));
final _futureDate = DateTime.now().add(const Duration(days: 10));

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // OverdueBlock – empty / loading states
  // ───────────────────────────────────────────────────────────────────────────
  group('OverdueBlock – loading state', () {
    testWidgets('renders without crashing when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const OverdueBlock(invoices: [], loading: true),
      ));
      expect(find.byType(OverdueBlock), findsOneWidget);
    });

    testWidgets('shows "Urgent Attention Required" header', (tester) async {
      await tester.pumpWidget(_wrap(
        const OverdueBlock(invoices: [], loading: true),
      ));
      expect(find.text('Urgent Attention Required'), findsOneWidget);
    });

    testWidgets('shows warning_amber_rounded icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const OverdueBlock(invoices: [], loading: true),
      ));
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('OverdueBlock – empty state (no overdue invoices)', () {
    testWidgets('shows "No invoices found." when no overdue invoices', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Dr. Smith',
          status: PaymentStatus.paid,
          dueDate: _pastDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.text('No invoices found.'), findsOneWidget);
    });

    testWidgets('shows "No invoices found." for empty list', (tester) async {
      await tester.pumpWidget(_wrap(
        const OverdueBlock(invoices: [], loading: false),
      ));
      expect(find.text('No invoices found.'), findsOneWidget);
    });

    testWidgets('does not show overdue tile for future-due non-paid invoice', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Future Provider',
          status: PaymentStatus.pending,
          dueDate: _futureDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.text('Future Provider'), findsNothing);
      expect(find.text('No invoices found.'), findsOneWidget);
    });
  });

  group('OverdueBlock – with overdue invoices', () {
    testWidgets('renders without crashing with overdue invoices', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'City Clinic',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.byType(OverdueBlock), findsOneWidget);
    });

    testWidgets('shows provider name for overdue invoice', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'City Clinic',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.text('City Clinic'), findsOneWidget);
    });

    testWidgets('shows "Overdue Bills" count label', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Provider A',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.textContaining('Overdue Bills'), findsOneWidget);
    });

    testWidgets('shows View button for each overdue invoice', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Provider A',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
        _makeInvoice(
          id: '2',
          providerName: 'Provider B',
          status: PaymentStatus.overdue,
          dueDate: _pastDate,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.text('View'), findsNWidgets(2));
    });

    testWidgets('limits display to 5 invoices maximum', (tester) async {
      final invoices = List.generate(
        7,
        (i) => _makeInvoice(
          id: '$i',
          providerName: 'Provider $i',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
      );
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      // Should show "View all" button when more than 5
      expect(find.text('View all'), findsOneWidget);
      // Max 5 shown
      expect(find.text('View'), findsNWidgets(5));
    });

    testWidgets('does not show "View all" when 5 or fewer overdue', (tester) async {
      final invoices = List.generate(
        3,
        (i) => _makeInvoice(
          id: '$i',
          providerName: 'Provider $i',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
        ),
      );
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.text('View all'), findsNothing);
    });

    testWidgets('shows amount for overdue invoice', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Provider A',
          status: PaymentStatus.pending,
          dueDate: _pastDate,
          amountDue: 250.0,
        ),
      ];
      await tester.pumpWidget(_wrap(
        OverdueBlock(invoices: invoices, loading: false),
      ));
      expect(find.textContaining('250.00'), findsOneWidget);
    });
  });
}
