import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';
import 'package:care_connect_app/features/invoices/widgets/sections/services_section.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Invoice _makeInvoice({
  List<ServiceLine>? services,
  PaymentStatus status = PaymentStatus.pending,
  double totalCharges = 300.0,
  double? totalAdjustments,
  double total = 300.0,
  double amountDue = 300.0,
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
      amounts: Amounts(
        totalCharges: totalCharges,
        totalAdjustments: totalAdjustments,
        total: total,
        amountDue: amountDue,
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
      home: Scaffold(body: SizedBox(width: 800, height: 800, child: child)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
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

    testWidgets('shows total charges amount', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(totalCharges: 500.0, total: 500.0),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('500.00'), findsWidgets);
    });

    testWidgets('shows Total Charges label', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Total Charges'), findsOneWidget);
    });

    testWidgets('shows Total Due label', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Total Due'), findsOneWidget);
    });

    testWidgets('shows service line description', (tester) async {
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

    testWidgets('shows "Service" as default when description is null',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Service'), findsOneWidget);
    });

    testWidgets('shows service code', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(
          description: 'Visit',
          serviceCode: 'CPT-99213',
          charge: 100.0,
        ),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('CPT-99213'), findsOneWidget);
    });

    testWidgets('shows dash for null service code', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('Service Code: -'), findsOneWidget);
    });

    testWidgets('shows service date when provided', (tester) async {
      final invoice = _makeInvoice(services: [
        ServiceLine(
          description: 'Visit',
          serviceDate: DateTime(2025, 3, 15),
          charge: 100.0,
        ),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('2025-03-15'), findsOneWidget);
    });

    testWidgets('does not show service date when null', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('Service Date:'), findsNothing);
    });

    testWidgets('shows Total Charge for service line', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 200.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Total Charge'), findsOneWidget);
      expect(find.textContaining('200.00'), findsWidgets);
    });

    testWidgets('shows Insurance Paid when adjustments present',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(
          description: 'Visit',
          charge: 200.0,
          insuranceAdjustments: 50.0,
        ),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Insurance Paid'), findsOneWidget);
      expect(find.textContaining('50.00'), findsWidgets);
    });

    testWidgets('does not show Insurance Paid when adjustments null',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 200.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Insurance Paid'), findsNothing);
    });

    testWidgets('shows Insurance Adjustments row when totalAdjustments > 0',
        (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(totalAdjustments: 75.0),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Insurance Adjustments'), findsOneWidget);
    });

    testWidgets('hides Insurance Adjustments row when totalAdjustments is 0',
        (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(totalAdjustments: 0),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Insurance Adjustments'), findsNothing);
    });

    testWidgets('shows Add button in edit mode', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('hides Add button when not editing', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('shows edit and delete icons for service in edit mode',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('hides edit and delete icons when not editing', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('tapping Add opens Edit Service dialog', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('Edit Service'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Service Code'), findsOneWidget);
      expect(find.text('Charge'), findsOneWidget);
      expect(find.text('Insurance Paid'), findsOneWidget);
    });

    testWidgets('Edit Service dialog can be cancelled', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(updated, isNull);
    });

    testWidgets('Edit Service dialog can save new service', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter data
      final descField = find.widgetWithText(TextField, 'Description');
      await tester.enterText(descField, 'New Service');

      final chargeField = find.widgetWithText(TextField, 'Charge');
      await tester.enterText(chargeField, '250.00');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.services.length, 1);
      expect(updated!.services.first.description, 'New Service');
      expect(updated!.services.first.charge, 250.0);
    });

    testWidgets('tapping edit icon opens Edit Service dialog with data',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(
          description: 'Office Visit',
          serviceCode: 'CPT-99213',
          charge: 150.0,
          insuranceAdjustments: 30.0,
        ),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (_) {},
      )));
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Service'), findsOneWidget);
      // Check pre-filled values
      expect(find.text('Office Visit'), findsWidgets);
    });

    testWidgets('tapping delete icon shows confirmation dialog',
        (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (_) {},
      )));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Remove service'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this service line?'),
        findsOneWidget,
      );
    });

    testWidgets('confirming delete removes the service', (tester) async {
      Invoice? updated;
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.services, isEmpty);
    });

    testWidgets('cancelling delete keeps the service', (tester) async {
      Invoice? updated;
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(updated, isNull);
    });

    testWidgets('shows multiple service lines', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Office Visit', charge: 150.0),
        const ServiceLine(description: 'Lab Work', charge: 200.0),
        const ServiceLine(description: 'X-Ray', charge: 350.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Office Visit'), findsOneWidget);
      expect(find.text('Lab Work'), findsOneWidget);
      // X-Ray might need scrolling
    });

    testWidgets('renders with empty services list', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: _makeInvoice(services: []),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Services & Charges'), findsOneWidget);
      expect(find.text('Total Due'), findsOneWidget);
    });

    testWidgets('shows dash for null charge', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit'),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      // null charge shows '-'
      expect(find.text('-'), findsWidgets);
    });

    testWidgets('Dismissible is present in edit mode', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('Dismissible is NOT present in view mode', (tester) async {
      final invoice = _makeInvoice(services: [
        const ServiceLine(description: 'Visit', charge: 100.0),
      ]);
      await tester.pumpWidget(_wrap(ServicesSection(
        value: invoice,
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('shows null totalCharges as dash', (tester) async {
      await tester.pumpWidget(_wrap(ServicesSection(
        value: Invoice(
          id: 'INV-001',
          invoiceNumber: 'INV-001',
          provider: const ProviderInfo(
            name: 'Clinic',
            address: 'Addr',
            phone: '555',
          ),
          patient: const PatientInfo(name: 'Pat'),
          dates: InvoiceDates(
            statementDate: DateTime(2025, 1, 1),
            dueDate: DateTime(2025, 2, 1),
          ),
          paymentStatus: PaymentStatus.pending,
          billedToInsurance: false,
          amounts: const Amounts(),
          paymentReferences: PaymentReferences(supportedMethods: const []),
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
          createdBy: 'admin',
          updatedBy: 'admin',
          payments: const [],
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      // null values should show '-'
      expect(find.text('-'), findsWidgets);
    });
  });
}
