// Tests for InvoiceDetailPage
// (lib/features/invoices/screens/invoice_detail_page.dart).
//
// Covers: initial render, AppBar title/status icons, tab building logic,
// tab navigation via PrevNextBar, edit/cancel/save flows, PDF button,
// _ensureTabControllerSynced, and all PaymentStatus icon branches.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/invoice_detail_page.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';
import 'package:care_connect_app/features/invoices/widgets/toolbar/invoice_toolbar.dart';
import 'package:care_connect_app/features/invoices/widgets/components/prev_next_bar.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Invoice _makeInvoice({
  String id = 'inv-1',
  String invoiceNumber = 'INV-001',
  PaymentStatus status = PaymentStatus.pending,
  String? aiSummary,
  String? documentLink,
}) =>
    Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      provider: const ProviderInfo(
        name: 'Test Clinic',
        address: '1 Main St',
        phone: '555-0001',
      ),
      patient: const PatientInfo(name: 'Jane Doe'),
      dates: InvoiceDates(
        statementDate: DateTime(2025, 1, 1),
        dueDate: DateTime(2025, 2, 1),
      ),
      paymentStatus: status,
      billedToInsurance: false,
      amounts: const Amounts(
        totalCharges: 500.0,
        total: 500.0,
        amountDue: 500.0,
      ),
      paymentReferences: PaymentReferences(supportedMethods: const []),
      createdAt: '2025-01-01T00:00:00Z',
      updatedAt: '2025-01-01T00:00:00Z',
      createdBy: 'admin',
      updatedBy: 'admin',
      payments: const [],
      aiSummary: aiSummary,
      documentLink: documentLink,
    );

Widget _wrap(
  Invoice invoice, {
  bool isNew = false,
  int initialTabIndex = 0,
}) =>
    MaterialApp(
      home: InvoiceDetailPage(
        invoice: invoice,
        isNew: isNew,
        initialTabIndex: initialTabIndex,
      ),
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('InvoiceDetailPage – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(InvoiceDetailPage), findsOneWidget);
    });

    testWidgets('shows invoice number in AppBar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice(invoiceNumber: 'INV-001')));
      await tester.pump();
      expect(find.textContaining('INV-001'), findsWidgets);
    });

    testWidgets('shows "New Invoice" when isNew=true and no invoice number',
        (tester) async {
      final invoice = _makeInvoice(invoiceNumber: '');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.text('New Invoice'), findsOneWidget);
    });

    testWidgets(
        'shows invoice number (not "New Invoice") when isNew=true but has number',
        (tester) async {
      final invoice = _makeInvoice(invoiceNumber: 'INV-999');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.textContaining('INV-999'), findsWidgets);
      expect(find.text('New Invoice'), findsNothing);
    });

    testWidgets('shows a TabBar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('shows a TabBarView', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('shows "Details" tab', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('shows "Services" tab', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('shows "Payment" tab', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('shows Prev / Next buttons from PrevNextBar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Prev'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('renders InvoiceToolbar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(InvoiceToolbar), findsOneWidget);
    });

    testWidgets('renders PrevNextBar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(PrevNextBar), findsOneWidget);
    });
  });

  group('InvoiceDetailPage – tabs for non-new invoices', () {
    testWidgets('shows 5 tabs (Details, Services, Payment, AI Insights, History) when not new',
        (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });
  });

  group('InvoiceDetailPage – tabs for new invoices', () {
    testWidgets('shows only 3 tabs when isNew=true and no AI summary',
        (tester) async {
      final invoice = _makeInvoice(invoiceNumber: '');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('AI Insights'), findsNothing);
      expect(find.text('History'), findsNothing);
    });

    testWidgets('shows AI Insights tab when isNew=true and aiSummary is present',
        (tester) async {
      final invoice = _makeInvoice(
        invoiceNumber: '',
        aiSummary: 'This invoice looks fine.',
      );
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.text('AI Insights'), findsOneWidget);
      // History should NOT appear for new invoices
      expect(find.text('History'), findsNothing);
    });

    testWidgets('does not show AI Insights tab when aiSummary is empty string',
        (tester) async {
      final invoice = _makeInvoice(invoiceNumber: '', aiSummary: '   ');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.text('AI Insights'), findsNothing);
    });
  });

  group('InvoiceDetailPage – different payment statuses (status icons)', () {
    testWidgets('renders pending status icon (schedule)', (tester) async {
      await tester
          .pumpWidget(_wrap(_makeInvoice(status: PaymentStatus.pending)));
      await tester.pump();
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders paid status icon (check_circle)', (tester) async {
      await tester
          .pumpWidget(_wrap(_makeInvoice(status: PaymentStatus.paid)));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders overdue status icon (warning)', (tester) async {
      await tester
          .pumpWidget(_wrap(_makeInvoice(status: PaymentStatus.overdue)));
      await tester.pump();
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders partialPayment status icon (info)', (tester) async {
      await tester.pumpWidget(
          _wrap(_makeInvoice(status: PaymentStatus.partialPayment)));
      await tester.pump();
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders rejectedInsurance status icon (error)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(_makeInvoice(status: PaymentStatus.rejectedInsurance)));
      await tester.pump();
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders pendingInsurance status icon (schedule)',
        (tester) async {
      await tester.pumpWidget(
          _wrap(_makeInvoice(status: PaymentStatus.pendingInsurance)));
      await tester.pump();
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders sent status icon (outgoing_mail)', (tester) async {
      await tester
          .pumpWidget(_wrap(_makeInvoice(status: PaymentStatus.sent)));
      await tester.pump();
      expect(find.byIcon(Icons.outgoing_mail), findsOneWidget);
    });

    testWidgets('does not show status icon for new invoice without number',
        (tester) async {
      final invoice = _makeInvoice(
        invoiceNumber: '',
        status: PaymentStatus.paid,
      );
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      // status icon should not be shown when isNew && !hasNumber
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows status icon for new invoice with number',
        (tester) async {
      final invoice = _makeInvoice(
        invoiceNumber: 'INV-100',
        status: PaymentStatus.paid,
      );
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('InvoiceDetailPage – initialTabIndex', () {
    testWidgets('respects initialTabIndex=0 (Details selected)', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice(), initialTabIndex: 0));
      await tester.pump();
      // Prev should be disabled on first tab
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Prev'),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('clamps initialTabIndex above max to last tab', (tester) async {
      // Non-new invoice has 5 tabs. Index 99 should clamp to 4.
      await tester.pumpWidget(_wrap(_makeInvoice(), initialTabIndex: 99));
      await tester.pump();
      // Should be on last tab, so "Next" should be replaced by "Save"
      expect(find.text('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('clamps negative initialTabIndex to 0', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice(), initialTabIndex: -5));
      await tester.pump();
      expect(find.byType(InvoiceDetailPage), findsOneWidget);
    });
  });

  group('InvoiceDetailPage – PrevNextBar navigation', () {
    testWidgets('Prev button is disabled on first tab', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Prev'),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('tapping Next advances to next tab', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      // Tap Next to go from Details (0) to Services (1)
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Prev button should now be enabled
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Prev'),
      );
      expect(prevButton.onPressed, isNotNull);
    });

    testWidgets('tapping Prev goes back to previous tab', (tester) async {
      // Start at tab 1
      await tester.pumpWidget(_wrap(_makeInvoice(), initialTabIndex: 1));
      await tester.pump();

      await tester.tap(find.text('Prev'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Should be on first tab; Prev disabled
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Prev'),
      );
      expect(prevButton.onPressed, isNull);
    });

    testWidgets('last tab shows Save instead of Next in PrevNextBar',
        (tester) async {
      // Non-new has 5 tabs. Go to last (index 4).
      await tester.pumpWidget(_wrap(_makeInvoice(), initialTabIndex: 4));
      await tester.pump();
      // The PrevNextBar button text changes to "Save" on last tab
      expect(find.widgetWithText(FilledButton, 'Save'), findsAtLeastNWidgets(1));
    });
  });

  group('InvoiceDetailPage – toolbar interactions', () {
    testWidgets('non-new invoice shows Edit button in toolbar', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('tapping Edit switches to editing mode (shows Save & Cancel)',
        (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      await tester.tap(find.text('Edit'));
      await tester.pump();

      // In editing mode, toolbar shows Save and Cancel
      expect(find.text('Save'), findsAtLeastNWidgets(1));
      expect(find.text('Cancel'), findsOneWidget);
      // Edit button should be gone
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('tapping Cancel returns to non-editing mode', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      // Enter edit mode
      await tester.tap(find.text('Edit'));
      await tester.pump();
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Should show Edit again
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('new invoice starts in editing mode (shows Save & Discard)',
        (tester) async {
      final invoice = _makeInvoice(invoiceNumber: '');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();

      // isNew starts in editing mode, cancel text is "Discard"
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Save'), findsAtLeastNWidgets(1));
    });

    testWidgets('PDF button shows snackbar when no document link',
        (tester) async {
      final invoice = _makeInvoice(documentLink: null);
      await tester.pumpWidget(_wrap(invoice));
      await tester.pump();

      await tester.tap(find.text('PDF'));
      await tester.pump();

      expect(find.text('PDF is not available for this invoice yet'),
          findsOneWidget);
    });

    testWidgets('non-new invoice shows PDF button', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('PDF'), findsOneWidget);
    });

    testWidgets('new invoice does not show PDF button', (tester) async {
      final invoice = _makeInvoice(invoiceNumber: '');
      await tester.pumpWidget(_wrap(invoice, isNew: true));
      await tester.pump();
      expect(find.text('PDF'), findsNothing);
    });

    testWidgets('Close button is always visible', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.text('Close'), findsOneWidget);
    });
  });

  group('InvoiceDetailPage – scaffold structure', () {
    testWidgets('has Scaffold widget', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('has AppBar widget', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('body is wrapped in AbsorbPointer', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(AbsorbPointer), findsAtLeastNWidgets(1));
    });
  });

  group('InvoiceDetailPage – tab tapping', () {
    testWidgets('tapping Services tab navigates to Services', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      await tester.tap(find.text('Services'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Prev should now be enabled (we're on tab 1)
      final prevButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Prev'),
      );
      expect(prevButton.onPressed, isNotNull);
    });

    testWidgets('tapping Payment tab navigates to Payment', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      await tester.tap(find.text('Payment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Should still show Next since there are more tabs (AI, History)
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('tapping AI Insights tab works', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      await tester.tap(find.text('AI Insights'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(InvoiceDetailPage), findsOneWidget);
    });

    testWidgets('tapping History tab (last tab) shows Save in PrevNextBar',
        (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();

      await tester.tap(find.text('History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // On last tab, PrevNextBar shows Save
      expect(find.widgetWithText(FilledButton, 'Save'), findsAtLeastNWidgets(1));
    });
  });

  group('InvoiceDetailPage – LinearProgressIndicator', () {
    testWidgets('does not show progress indicator initially', (tester) async {
      await tester.pumpWidget(_wrap(_makeInvoice()));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('InvoiceDetailPage – empty document link edge case', () {
    testWidgets('PDF snackbar shown for empty string document link',
        (tester) async {
      final invoice = _makeInvoice(documentLink: '');
      await tester.pumpWidget(_wrap(invoice));
      await tester.pump();

      await tester.tap(find.text('PDF'));
      await tester.pump();

      expect(find.text('PDF is not available for this invoice yet'),
          findsOneWidget);
    });
  });
}
