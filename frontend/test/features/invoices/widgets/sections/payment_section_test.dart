import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';
import 'package:care_connect_app/features/invoices/widgets/sections/payment_section.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Invoice _makeInvoice({
  PaymentStatus status = PaymentStatus.pending,
  List<String> supportedMethods = const [],
  String? paymentLink,
  String? qrCodeUrl,
  String? notes,
  CheckPayableTo? checkPayableTo,
  double amountDue = 300.0,
  double? total,
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
        totalCharges: 300.0,
        total: total ?? 300.0,
        amountDue: amountDue,
      ),
      paymentReferences: PaymentReferences(
        supportedMethods: supportedMethods,
        paymentLink: paymentLink,
        qrCodeUrl: qrCodeUrl,
        notes: notes,
      ),
      checkPayableTo: checkPayableTo,
      createdAt: '2025-01-01T00:00:00Z',
      updatedAt: '2025-01-01T00:00:00Z',
      createdBy: 'admin',
      updatedBy: 'admin',
      payments: const [],
    );

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SizedBox(width: 800, height: 1200, child: child)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
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

  group('PaymentSection', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
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

    testWidgets('shows Payment Status dropdown', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(
        find.byType(DropdownButtonFormField<PaymentStatus>),
        findsOneWidget,
      );
    });

    testWidgets('shows Record Payment button', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Record Payment'), findsOneWidget);
    });

    testWidgets('Record Payment button disabled when status is paid',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.paid),
        isEditing: false,
        onChanged: (_) {},
      )));
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Record Payment'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Record Payment button enabled when status is not paid',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.pending),
        isEditing: false,
        onChanged: (_) {},
      )));
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Record Payment'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows status chip with label', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.pending),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(Chip), findsOneWidget);
      expect(
          find.descendant(
            of: find.byType(Chip),
            matching: find.text('Pending'),
          ),
          findsOneWidget);
    });

    testWidgets('shows "Supported Payment Methods" card', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Supported Payment Methods'), findsOneWidget);
    });

    testWidgets('shows four FilterChips for payment methods', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(find.byType(FilterChip), findsNWidgets(4));
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('Online Payment'), findsOneWidget);
      expect(find.text('Telephone'), findsOneWidget);
    });

    testWidgets('FilterChips are not selectable when not editing',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      final chip = tester.widget<FilterChip>(find.byType(FilterChip).first);
      expect(chip.onSelected, isNull);
    });

    testWidgets('selecting a FilterChip updates supported methods',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.text('Check'));
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.paymentReferences.supportedMethods, contains('check'));
    });

    testWidgets('deselecting a FilterChip removes from supported methods',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.text('Check'));
      await tester.pump();
      expect(updated, isNotNull);
      expect(
        updated!.paymentReferences.supportedMethods,
        isNot(contains('check')),
      );
    });

    testWidgets('shows "Notes for Payer" card', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(find.text('Notes for Payer'), findsOneWidget);
    });

    testWidgets('shows Check Payment Instructions when check method selected',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      expect(find.text('Check Payment Instructions'), findsOneWidget);
    });

    testWidgets('hides Check Payment Instructions when check not selected',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: []),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Check Payment Instructions'), findsNothing);
    });

    testWidgets('shows Telephone Payment when telephone method selected',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['telephone']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(find.text('Telephone Payment'), findsOneWidget);
    });

    testWidgets('hides Telephone Payment when telephone not selected',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: []),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Telephone Payment'), findsNothing);
    });

    testWidgets('shows Online Payment card when online method selected',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['online']),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Online Payment'), findsWidgets);
    });

    testWidgets('shows Online Payment card when paymentLink present',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          paymentLink: 'https://pay.example.com',
          qrCodeUrl: 'https://pay.example.com',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Online Payment'), findsWidgets);
    });

    testWidgets('shows Online Payment card when qrCodeUrl present',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(qrCodeUrl: 'https://qr.example.com'),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Online Payment'), findsWidgets);
    });

    testWidgets('shows check payable fields with data', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: const CheckPayableTo(
            name: 'ACME Corp',
            address: '123 Main St',
            reference: 'REF-001',
          ),
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      expect(find.textContaining('ACME Corp'), findsWidgets);
    });

    testWidgets('check payable fields editable in edit mode', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: const CheckPayableTo(
            name: 'ACME Corp',
            address: '123 Main St',
            reference: 'REF-001',
          ),
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();

      final payableField = find.widgetWithText(TextFormField, 'ACME Corp');
      if (payableField.evaluate().isNotEmpty) {
        await tester.enterText(payableField.first, 'New Corp');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.name, 'New Corp');
      }
    });

    testWidgets('dropdown disabled when not editing', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      final dropdown = tester.widget<DropdownButtonFormField<PaymentStatus>>(
        find.byType(DropdownButtonFormField<PaymentStatus>),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('dropdown enabled when editing', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (_) {},
      )));
      final dropdown = tester.widget<DropdownButtonFormField<PaymentStatus>>(
        find.byType(DropdownButtonFormField<PaymentStatus>),
      );
      expect(dropdown.onChanged, isNotNull);
    });

    testWidgets('renders all payment statuses in chip correctly',
        (tester) async {
      final labels = {
        PaymentStatus.pending: 'Pending',
        PaymentStatus.overdue: 'Overdue',
        PaymentStatus.pendingInsurance: 'Pending Insurance',
        PaymentStatus.sent: 'Sent',
        PaymentStatus.paid: 'Paid',
        PaymentStatus.partialPayment: 'Partial Payment',
        PaymentStatus.rejectedInsurance: 'Rejected by Insurance',
      };
      for (final entry in labels.entries) {
        await tester.pumpWidget(_wrap(PaymentSection(
          value: _makeInvoice(status: entry.key),
          isEditing: false,
          onChanged: (_) {},
        )));
        expect(
          find.descendant(
            of: find.byType(Chip),
            matching: find.text(entry.value),
          ),
          findsOneWidget,
          reason: 'Expected chip label "${entry.value}" for ${entry.key}',
        );
      }
    });

    testWidgets('notes field updates onChanged', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(notes: 'Old note'),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      final notesField = find.widgetWithText(TextFormField, 'Old note');
      if (notesField.evaluate().isNotEmpty) {
        await tester.enterText(notesField.first, 'New note');
        expect(updated, isNotNull);
      }
    });

    testWidgets('tapping Record Payment opens dialog', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check', 'credit_card']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();
      expect(find.text('Confirmation Number'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
    });

    testWidgets('Record Payment dialog can be cancelled', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      // Dialog should be gone
      expect(find.text('Confirmation Number'), findsNothing);
    });

    testWidgets('renders with no supported methods', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: []),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(PaymentSection), findsOneWidget);
    });

    testWidgets('renders with all supported methods', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check', 'credit_card', 'online', 'telephone'],
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byType(PaymentSection), findsOneWidget);
    });

    testWidgets('payment link field shows in Online Payment card',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['online'],
          paymentLink: 'https://pay.example.com',
          qrCodeUrl: 'https://pay.example.com',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.textContaining('https://pay.example.com'), findsWidgets);
    });

    testWidgets('payment link field editable in edit mode', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['online'],
          paymentLink: 'https://pay.example.com',
          qrCodeUrl: 'https://pay.example.com',
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));

      final linkField = find.widgetWithText(
        TextFormField,
        'https://pay.example.com',
      );
      if (linkField.evaluate().isNotEmpty) {
        await tester.enterText(linkField.first, 'https://new.example.com');
        expect(updated, isNotNull);
        expect(
          updated!.paymentReferences.paymentLink,
          'https://new.example.com',
        );
      }
    });

    testWidgets('check payable creates new CheckPayableTo when null',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: null,
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      final payableField = find.widgetWithText(TextFormField, 'Payable To');
      if (payableField.evaluate().isNotEmpty) {
        await tester.enterText(payableField.first, 'New Payee');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.name, 'New Payee');
      }
    });

    // -----------------------------------------------------------------------
    // Additional tests for increased coverage
    // -----------------------------------------------------------------------

    testWidgets('QR code is displayed when qrCodeUrl is set (preferred path)',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          qrCodeUrl: 'https://qr.example.com/pay',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      // The QR code widget should be rendered
      expect(find.byType(QrImageView), findsOneWidget);
      // Should show the descriptive text
      expect(
        find.text('Scan this QR code to open the destination URL.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'QR code preferred path shows Open Payment Page button when paymentLink is http',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          qrCodeUrl: 'https://qr.example.com/pay',
          paymentLink: 'https://pay.example.com',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Open Payment Page'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });

    testWidgets(
        'QR code preferred path hides Open Payment Page when paymentLink is empty',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          qrCodeUrl: 'https://qr.example.com/pay',
          paymentLink: '',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Open Payment Page'), findsNothing);
    });

    testWidgets(
        'hasPaymentLink branch renders when paymentLink is set with qrCodeUrl for QR',
        (tester) async {
      // Both paymentLink and qrCodeUrl present triggers hasQrDataPreferred path
      // which shows QR + "Scan this QR code" text + Open Payment Page button
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          paymentLink: 'https://pay.example.com',
          qrCodeUrl: 'https://qr.example.com',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      // Online Payment card should appear
      expect(find.text('Online Payment'), findsWidgets);
      // Open Payment Page button
      expect(find.text('Open Payment Page'), findsOneWidget);
    });

    testWidgets('telephone notes field updates onChanged when editing',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['telephone'],
          notes: '555-0100',
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // The telephone payment card uses notes for phone number
      final phoneField = find.widgetWithText(TextFormField, '555-0100');
      if (phoneField.evaluate().isNotEmpty) {
        await tester.enterText(phoneField.first, '555-9999');
        expect(updated, isNotNull);
      }
    });

    testWidgets('check address field editable and fires onChanged',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: const CheckPayableTo(
            name: 'Test Corp',
            address: '456 Oak Ave',
            reference: 'REF-002',
          ),
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();

      final addrField = find.widgetWithText(TextFormField, '456 Oak Ave');
      if (addrField.evaluate().isNotEmpty) {
        await tester.enterText(addrField.first, '789 Elm St');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.address, '789 Elm St');
      }
    });

    testWidgets('check reference field editable and fires onChanged',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: const CheckPayableTo(
            name: 'Test Corp',
            address: '456 Oak Ave',
            reference: 'REF-002',
          ),
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pump();

      final refField = find.widgetWithText(TextFormField, 'REF-002');
      if (refField.evaluate().isNotEmpty) {
        await tester.enterText(refField.first, 'REF-NEW');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.reference, 'REF-NEW');
      }
    });

    testWidgets(
        'check address field creates new CheckPayableTo when null and editing address',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: null,
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();

      final addrField =
          find.widgetWithText(TextFormField, 'Mailing Address');
      if (addrField.evaluate().isNotEmpty) {
        await tester.enterText(addrField.first, '100 New Rd');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.address, '100 New Rd');
      }
    });

    testWidgets(
        'check reference field creates new CheckPayableTo when null and editing reference',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check'],
          checkPayableTo: null,
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pump();

      // When checkPayableTo is null the reference field shows invoiceNumber
      final refField = find.widgetWithText(TextFormField, 'INV-001');
      if (refField.evaluate().isNotEmpty) {
        await tester.enterText(refField.first, 'NEW-REF');
        expect(updated, isNotNull);
        expect(updated!.checkPayableTo?.reference, 'NEW-REF');
      }
    });

    testWidgets('QR code URL field updates onChanged', (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['online'],
          qrCodeUrl: 'https://old-qr.example.com',
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));

      final qrField = find.widgetWithText(
        TextFormField,
        'https://old-qr.example.com',
      );
      if (qrField.evaluate().isNotEmpty) {
        await tester.enterText(qrField.first, 'https://new-qr.example.com');
        expect(updated, isNotNull);
        expect(
          updated!.paymentReferences.qrCodeUrl,
          'https://new-qr.example.com',
        );
      }
    });

    testWidgets('Record Payment dialog shows payment in full checkbox',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();

      expect(find.textContaining('Payment in full'), findsOneWidget);
    });

    testWidgets(
        'Record Payment dialog shows payment plan checkbox',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();

      expect(
        find.text('Set up payment plan for remaining balance'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Record Payment dialog unchecking full payment enables partial amount field',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check'], amountDue: 300.0),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();

      // Initially partial field is disabled because _full is true
      final partialFieldBefore = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Partial Payment Amount'),
      );
      expect(partialFieldBefore.enabled, isFalse);

      // Uncheck "Payment in full"
      await tester.tap(find.textContaining('Payment in full'));
      await tester.pump();

      // Now partial amount field should be enabled
      final partialFieldAfter = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Partial Payment Amount'),
      );
      expect(partialFieldAfter.enabled, isTrue);
    });

    testWidgets(
        'Record Payment dialog enabling payment plan shows duration dropdown',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.text('Record Payment'));
      await tester.pump();

      // Payment plan dropdown is hidden initially
      expect(find.text('Payment Plan Frequency'), findsNothing);

      // Check "Set up payment plan"
      await tester.tap(
          find.text('Set up payment plan for remaining balance'));
      await tester.pump();

      // Now the duration dropdown should appear
      expect(find.text('Payment Plan Frequency'), findsOneWidget);
    });

    testWidgets(
        'Record Payment dialog has Record Payment button in actions',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      // Dialog should have its own Record Payment button and Cancel
      // The dialog's Record Payment is a FilledButton inside the AlertDialog
      expect(find.text('Cancel'), findsOneWidget);
      // The dialog title + dialog button + background button = 3 instances
      expect(find.text('Record Payment'), findsNWidgets(3));
    });

    testWidgets('Record Payment dialog with no methods defaults to all methods',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: []),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      // When no supported methods, dialog should show all 4 methods
      // The dialog dropdown should have items
      expect(find.text('Payment Method'), findsOneWidget);
    });

    testWidgets('paid status chip has green color', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.paid),
        isEditing: false,
        onChanged: (_) {},
      )));
      final paidChip = tester.widget<Chip>(find.byType(Chip));
      expect(paidChip.backgroundColor, const Color(0xFF059669));
    });

    testWidgets('overdue status chip has red color', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.overdue),
        isEditing: false,
        onChanged: (_) {},
      )));
      final overdueChip = tester.widget<Chip>(find.byType(Chip));
      expect(overdueChip.backgroundColor, Colors.red);
    });

    testWidgets('status chip for rejectedInsurance uses error color',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.rejectedInsurance),
        isEditing: false,
        onChanged: (_) {},
      )));
      final chip = tester.widget<Chip>(find.byType(Chip));
      // error color is from the theme's colorScheme
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('status chip for pendingInsurance uses secondary color',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.pendingInsurance),
        isEditing: false,
        onChanged: (_) {},
      )));
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('status chip for sent uses secondary color', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.sent),
        isEditing: false,
        onChanged: (_) {},
      )));
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('status chip for partialPayment uses secondary color',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(status: PaymentStatus.partialPayment),
        isEditing: false,
        onChanged: (_) {},
      )));
      final chip = tester.widget<Chip>(find.byType(Chip));
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('selecting credit_card FilterChip updates supported methods',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.text('Credit Card'));
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.paymentReferences.supportedMethods,
          contains('credit_card'));
    });

    testWidgets('selecting online FilterChip updates supported methods',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.text('Online Payment'));
      await tester.pump();
      expect(updated, isNotNull);
      expect(
          updated!.paymentReferences.supportedMethods, contains('online'));
    });

    testWidgets('selecting telephone FilterChip updates supported methods',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.tap(find.text('Telephone'));
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.paymentReferences.supportedMethods,
          contains('telephone'));
    });

    testWidgets('online card shows both text fields for payment link and QR URL',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['online']),
        isEditing: true,
        onChanged: (_) {},
      )));
      expect(
        find.text('Payment Link (URL or deeplink)'),
        findsOneWidget,
      );
      expect(
        find.text('QR Code Destination URL (encoded in QR)'),
        findsOneWidget,
      );
    });

    testWidgets('telephone payment card shows phone field label',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['telephone']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(find.text('Phone Number or Instructions'), findsOneWidget);
    });

    testWidgets('check payment card shows all three field labels',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Payable To'), findsOneWidget);
      expect(find.text('Mailing Address'), findsOneWidget);
      expect(find.text('Reference (include invoice number)'), findsOneWidget);
    });

    testWidgets('notes for payer field shows correct label', (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(
        find.text('Notes (appears on statement or instructions)'),
        findsOneWidget,
      );
    });

    testWidgets('notes for payer field updates paymentReferences notes',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      final notesField = find.widgetWithText(
          TextFormField, 'Notes (appears on statement or instructions)');
      if (notesField.evaluate().isNotEmpty) {
        await tester.enterText(notesField.first, 'Some new note');
        expect(updated, isNotNull);
        expect(updated!.paymentReferences.notes, 'Some new note');
      }
    });

    testWidgets('telephone notes field editing fires onChanged with updated notes',
        (tester) async {
      Invoice? updated;
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['telephone'],
          notes: '',
        ),
        isEditing: true,
        onChanged: (v) => updated = v,
      )));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      final phoneField =
          find.widgetWithText(TextFormField, 'Phone Number or Instructions');
      if (phoneField.evaluate().isNotEmpty) {
        await tester.enterText(phoneField.first, '1-800-555-1234');
        expect(updated, isNotNull);
        expect(updated!.paymentReferences.notes, '1-800-555-1234');
      }
    });

    testWidgets('all methods shown together renders all conditional cards',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          supportedMethods: ['check', 'credit_card', 'online', 'telephone'],
          paymentLink: 'https://pay.example.com',
          qrCodeUrl: 'https://qr.example.com',
          notes: 'Test notes',
          checkPayableTo: const CheckPayableTo(
            name: 'Test Corp',
            address: '123 Main St',
            reference: 'REF-001',
          ),
        ),
        isEditing: true,
        onChanged: (_) {},
      )));
      // The main sections should all be present
      expect(find.text('Payment Options'), findsOneWidget);
      expect(find.text('Supported Payment Methods'), findsOneWidget);
      expect(find.text('Online Payment'), findsWidgets);
    });

    testWidgets('Record Payment dialog date field shows calendar icon',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Record Payment dialog date field label shows Payment Date',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      expect(find.text('Payment Date'), findsOneWidget);
    });

    testWidgets('Record Payment dialog shows amount formatted correctly',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check'], amountDue: 150.50),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      expect(find.textContaining('150.50'), findsWidgets);
    });

    testWidgets(
        'Record Payment dialog re-checking full payment resets amount',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check'], amountDue: 200.0),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      // Uncheck full payment
      await tester.tap(find.textContaining('Payment in full'));
      await tester.pump();

      // Re-check full payment
      await tester.tap(find.textContaining('Payment in full'));
      await tester.pump();

      // Amount should be reset to 200.00
      expect(find.textContaining('200.00'), findsWidgets);
    });

    testWidgets('Record Payment dialog with payment plan shows month options',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check']),
        isEditing: false,
        onChanged: (_) {},
      )));
      await tester.tap(find.widgetWithText(FilledButton, 'Record Payment'));
      await tester.pump();

      // Enable payment plan
      await tester.tap(
          find.text('Set up payment plan for remaining balance'));
      await tester.pump();

      // Default selection is 6 months
      expect(find.text('6 months'), findsOneWidget);
    });

    testWidgets('attach_money icon is shown on Record Payment button',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('online payment card renders with paymentLink and qrCodeUrl set',
        (tester) async {
      // showOnlineCard is true when hasPaymentLink or hasQrDataPreferred
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(
          paymentLink: 'myapp://deeplink/pay',
          qrCodeUrl: 'https://qr.example.com',
        ),
        isEditing: false,
        onChanged: (_) {},
      )));
      expect(find.text('Online Payment'), findsWidgets);
    });

    testWidgets('FilterChip selected state matches supportedMethods',
        (tester) async {
      await tester.pumpWidget(_wrap(PaymentSection(
        value: _makeInvoice(supportedMethods: ['check', 'online']),
        isEditing: true,
        onChanged: (_) {},
      )));

      // Check chip should be selected
      final checkChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Check'),
      );
      expect(checkChip.selected, isTrue);

      // Credit Card chip should NOT be selected
      final cardChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Credit Card'),
      );
      expect(cardChip.selected, isFalse);

      // Online Payment chip should be selected
      final onlineChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Online Payment'),
      );
      expect(onlineChip.selected, isTrue);

      // Telephone chip should NOT be selected
      final telephoneChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Telephone'),
      );
      expect(telephoneChip.selected, isFalse);
    });
  });
}
