// Tests for FilterResult, DesktopTable, and MobileCard
// (lib/features/invoices/models/filter_result.dart).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';
import 'package:care_connect_app/features/invoices/models/filter_result.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Invoice _makeInvoice({
  PaymentStatus status = PaymentStatus.pending,
  DateTime? dueDate,
}) {
  return Invoice(
    id: 'INV-001',
    invoiceNumber: 'INV-001',
    provider: const ProviderInfo(
        name: 'Test Clinic', address: '1 Main St', phone: '555-0001'),
    patient: const PatientInfo(name: 'John Doe'),
    dates: InvoiceDates(
      statementDate: DateTime(2025, 1, 1),
      dueDate: dueDate ?? DateTime(2025, 2, 1),
    ),
    paymentStatus: status,
    billedToInsurance: false,
    amounts: const Amounts(totalCharges: 200.0, total: 200.0, amountDue: 200.0),
    paymentReferences: PaymentReferences(supportedMethods: const []),
    createdAt: '2025-01-01T00:00:00Z',
    updatedAt: '2025-01-01T00:00:00Z',
    createdBy: 'admin',
    updatedBy: 'admin',
    payments: const [],
  );
}

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('FilterResult', () {
    test('constructor stores all fields', () {
      final now = DateTime(2025, 6, 1);
      final later = DateTime(2025, 6, 30);
      final range = DateTimeRange(start: now, end: later);
      final result = FilterResult(
        sort: 'date_desc',
        search: 'clinic',
        status: {PaymentStatus.pending, PaymentStatus.paid},
        provider: 'Clinic A',
        patient: 'Patient B',
        serviceRange: range,
        dueRange: range,
        amountRange: const RangeValues(0, 1000),
      );
      expect(result.sort, 'date_desc');
      expect(result.search, 'clinic');
      expect(result.status, contains(PaymentStatus.pending));
      expect(result.status, contains(PaymentStatus.paid));
      expect(result.provider, 'Clinic A');
      expect(result.patient, 'Patient B');
      expect(result.serviceRange, range);
      expect(result.dueRange, range);
      expect(result.amountRange, const RangeValues(0, 1000));
    });

    test('optional fields default to null', () {
      final result = FilterResult(
        sort: 'date_asc',
        search: '',
        status: const {},
      );
      expect(result.provider, isNull);
      expect(result.patient, isNull);
      expect(result.serviceRange, isNull);
      expect(result.dueRange, isNull);
      expect(result.amountRange, isNull);
    });
  });

  group('DesktopTable', () {
    // Use wide viewport so DataTable columns don't overflow.
    testWidgets('renders without crashing', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [_makeInvoice()],
        onView: (_) {},
        onPay: (_) {},
      )));
      expect(find.byType(DesktopTable), findsOneWidget);
    });

    testWidgets('shows column headers', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [],
        onView: (_) {},
        onPay: (_) {},
      )));
      expect(find.text('Invoice #'), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('shows invoice data in row', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [_makeInvoice()],
        onView: (_) {},
        onPay: (_) {},
      )));
      expect(find.text('INV-001'), findsAtLeastNWidgets(1));
      expect(find.text('Test Clinic'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows visibility and payment icons', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [_makeInvoice()],
        onView: (_) {},
        onPay: (_) {},
      )));
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
    });

    testWidgets('tapping view calls onView', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Invoice? viewed;
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [_makeInvoice()],
        onView: (inv) => viewed = inv,
        onPay: (_) {},
      )));
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(viewed, isNotNull);
    });

    testWidgets('tapping pay calls onPay', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Invoice? paid;
      await tester.pumpWidget(_wrap(DesktopTable(
        invoices: [_makeInvoice()],
        onView: (_) {},
        onPay: (inv) => paid = inv,
      )));
      await tester.tap(find.byIcon(Icons.payment));
      await tester.pump();
      expect(paid, isNotNull);
    });
  });

  group('MobileCard', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.byType(MobileCard), findsOneWidget);
    });

    testWidgets('shows invoice id', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('INV-001'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows provider name', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('Test Clinic'), findsOneWidget);
    });

    testWidgets('shows patient name in details', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows amount formatted as dollars', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('\$200.00'), findsOneWidget);
    });

    testWidgets('shows View and Pay buttons', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Pay'), findsOneWidget);
    });

    testWidgets('shows Overdue pill for past due unpaid invoice', (tester) async {
      // Due date in the past → overdue
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(
          status: PaymentStatus.pending,
          dueDate: DateTime(2020, 1, 1), // far in the past
        ),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('Overdue'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Rejected pill for rejectedInsurance status', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(
          status: PaymentStatus.rejectedInsurance,
          dueDate: DateTime(2030, 1, 1), // not overdue
        ),
        onView: () {},
        onPay: () {},
      )));
      expect(find.text('Rejected'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Insurance button when onInsurance provided', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
        onInsurance: () {},
      )));
      expect(find.text('Insurance'), findsOneWidget);
    });

    testWidgets('hides Insurance button when onInsurance is null', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
        onInsurance: null,
      )));
      expect(find.text('Insurance'), findsNothing);
    });

    testWidgets('shows PDF icon when onPdf provided', (tester) async {
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () {},
        onPdf: () {},
      )));
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('tapping View calls onView', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () => called = true,
        onPay: () {},
      )));
      await tester.tap(find.text('View'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('tapping Pay calls onPay', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(MobileCard(
        invoice: _makeInvoice(),
        onView: () {},
        onPay: () => called = true,
      )));
      await tester.tap(find.text('Pay'));
      await tester.pump();
      expect(called, isTrue);
    });
  });
}
