// Tests for invoice detail sections:
//   DetailsSection  (lib/.../widgets/sections/details_section.dart)
//   ServicesSection (lib/.../widgets/sections/services_section.dart)
//   PaymentSection  (lib/.../widgets/sections/payment_section.dart)
//
// All three are pure StatelessWidgets — no API calls, no navigation on render.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';
import 'package:care_connect_app/features/invoices/widgets/sections/details_section.dart';
import 'package:care_connect_app/features/invoices/widgets/sections/services_section.dart';
import 'package:care_connect_app/features/invoices/widgets/sections/payment_section.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Invoice _makeInvoice({
  List<ServiceLine>? services,
  PaymentStatus status = PaymentStatus.pending,
}) =>
    Invoice(
      id: 'INV-001',
      invoiceNumber: 'INV-001',
      provider: const ProviderInfo(
        name: 'City Medical Center',
        address: '100 Health Ave',
        phone: '555-1234',
      ),
      patient: const PatientInfo(name: 'John Doe'),
      dates: InvoiceDates(
        statementDate: DateTime(2025, 1, 1),
        dueDate: DateTime(2025, 2, 1),
      ),
      paymentStatus: status,
      billedToInsurance: false,
      amounts: const Amounts(
        totalCharges: 300.0,
        total: 300.0,
        amountDue: 300.0,
      ),
      paymentReferences: PaymentReferences(supportedMethods: const []),
      createdAt: '2025-01-01T00:00:00Z',
      updatedAt: '2025-01-01T00:00:00Z',
      createdBy: 'admin',
      updatedBy: 'admin',
      payments: const [],
      services: services,
    );

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

// ─── DetailsSection ──────────────────────────────────────────────────────────

void main() {
  group('DetailsSection', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(DetailsSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(DetailsSection), findsOneWidget);
    });

    testWidgets('shows provider name', (tester) async {
      await tester.pumpWidget(_wrap(DetailsSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('City Medical Center'), findsWidgets);
    });

    testWidgets('shows patient name', (tester) async {
      await tester.pumpWidget(_wrap(DetailsSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('John Doe'), findsWidgets);
    });

    testWidgets('shows text fields in edit mode', (tester) async {
      // When isEditing=true, input fields are shown for editing.
      await tester.pumpWidget(_wrap(DetailsSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byType(TextField), findsWidgets);
    });
  });

  // ─── ServicesSection ───────────────────────────────────────────────────────

  group('ServicesSection', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(ServicesSection), findsOneWidget);
    });

    testWidgets('shows "Services & Charges" heading', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Services & Charges'), findsOneWidget);
    });

    testWidgets('shows total amount', (tester) async {
      // Amounts.totalCharges=300.0 should appear in the summary rows.
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('300'), findsWidgets);
    });

    testWidgets('renders service line descriptions when services provided',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Office Visit', charge: 150.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Office Visit'), findsOneWidget);
    });

    testWidgets('shows Add button in edit mode', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ─── PaymentSection ────────────────────────────────────────────────────────

  group('PaymentSection', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(PaymentSection), findsOneWidget);
    });

    testWidgets('renders without crashing with paid status', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.paid),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(PaymentSection), findsOneWidget);
    });

    testWidgets('shows "Payment Options" heading', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Payment Options'), findsOneWidget);
    });
  });
}
