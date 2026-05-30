// Tests for invoice dashboard activity/chart widgets and helper widgets:
//   RecentActivityCard, PaymentProgressCard, PaymentStatusChartCard,
//   MonthlyInvoiceTrendsCard, Insight, AmountBadge, LegendDot, BlockLoading
// (lib/features/invoices/screens/dashboard/widgets/activity_and_charts.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/widgets/activity_and_charts.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/utilis/metrics.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';

// Minimal Invoice builder
Invoice _makeInvoice({
  required String id,
  required String providerName,
  required PaymentStatus status,
  double amountDue = 100.0,
  DateTime? statementDate,
}) {
  final now = DateTime.now();
  return Invoice(
    id: id,
    invoiceNumber: 'INV-$id',
    provider: ProviderInfo(name: providerName, address: 'Addr', phone: '555'),
    patient: const PatientInfo(name: 'Patient'),
    dates: InvoiceDates(
      statementDate: statementDate ?? now,
      dueDate: now.add(const Duration(days: 30)),
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

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // BlockLoading
  // ───────────────────────────────────────────────────────────────────────────
  group('BlockLoading', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const BlockLoading(height: 100)));
      expect(find.byType(BlockLoading), findsOneWidget);
    });

    testWidgets('shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(const BlockLoading(height: 100)));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Insight
  // ───────────────────────────────────────────────────────────────────────────
  group('Insight', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const Insight(text: 'Contact insurance')));
      expect(find.byType(Insight), findsOneWidget);
    });

    testWidgets('shows the insight text', (tester) async {
      await tester.pumpWidget(_wrap(const Insight(text: 'Contact insurance')));
      expect(find.text('Contact insurance'), findsOneWidget);
    });

    testWidgets('shows check_circle_outline icon', (tester) async {
      await tester.pumpWidget(_wrap(const Insight(text: 'Tip')));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // AmountBadge
  // ───────────────────────────────────────────────────────────────────────────
  group('AmountBadge', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const AmountBadge(text: '\$250.00')));
      expect(find.byType(AmountBadge), findsOneWidget);
    });

    testWidgets('shows the amount text', (tester) async {
      await tester.pumpWidget(_wrap(const AmountBadge(text: '\$250.00')));
      expect(find.text('\$250.00'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // LegendDot
  // ───────────────────────────────────────────────────────────────────────────
  group('LegendDot', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        const LegendDot(color: Colors.green, label: 'Paid (3)'),
      ));
      expect(find.byType(LegendDot), findsOneWidget);
    });

    testWidgets('shows the label text', (tester) async {
      await tester.pumpWidget(_wrap(
        const LegendDot(color: Colors.orange, label: 'Pending (2)'),
      ));
      expect(find.text('Pending (2)'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // RecentActivityCard
  // ───────────────────────────────────────────────────────────────────────────
  group('RecentActivityCard', () {
    testWidgets('renders without crashing when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const RecentActivityCard(invoices: [], loading: true),
      ));
      expect(find.byType(RecentActivityCard), findsOneWidget);
    });

    testWidgets('shows "Recent Invoice Activity" header', (tester) async {
      await tester.pumpWidget(_wrap(
        const RecentActivityCard(invoices: [], loading: false),
      ));
      expect(find.text('Recent Invoice Activity'), findsOneWidget);
    });

    testWidgets('shows "No recent activity." when empty', (tester) async {
      await tester.pumpWidget(_wrap(
        const RecentActivityCard(invoices: [], loading: false),
      ));
      expect(find.text('No recent activity.'), findsOneWidget);
    });

    testWidgets('shows provider name for invoice', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'City Hospital',
          status: PaymentStatus.pending,
        ),
      ];
      await tester.pumpWidget(_wrap(
        RecentActivityCard(invoices: invoices, loading: false),
      ));
      expect(find.text('City Hospital'), findsOneWidget);
    });

    testWidgets('shows update icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const RecentActivityCard(invoices: [], loading: false),
      ));
      expect(find.byIcon(Icons.update), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PaymentProgressCard
  // ───────────────────────────────────────────────────────────────────────────
  group('PaymentProgressCard', () {
    const emptyMetrics = Metrics(
      totalCount: 0,
      totalAmount: 0,
      pendingAmount: 0,
      overdueCount: 0,
      paidAmount: 0,
    );

    testWidgets('renders without crashing when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: true),
      ));
      expect(find.byType(PaymentProgressCard), findsOneWidget);
    });

    testWidgets('shows "Payment Progress" header', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.text('Payment Progress'), findsOneWidget);
    });

    testWidgets('shows "Paid Invoices" label', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.text('Paid Invoices'), findsOneWidget);
    });

    testWidgets('shows "Paid" and "Remaining" labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
    });

    testWidgets('shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows "0%" when nothing is paid', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('shows insight tips', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentProgressCard(metrics: emptyMetrics, loading: false),
      ));
      expect(find.text('Contact insurance for claim status'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PaymentStatusChartCard
  // ───────────────────────────────────────────────────────────────────────────
  group('PaymentStatusChartCard', () {
    testWidgets('renders without crashing when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentStatusChartCard(invoices: [], loading: true),
      ));
      expect(find.byType(PaymentStatusChartCard), findsOneWidget);
    });

    testWidgets('shows "Payment Status Distribution" header', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentStatusChartCard(invoices: [], loading: false),
      ));
      expect(find.text('Payment Status Distribution'), findsOneWidget);
    });

    testWidgets('shows pie_chart icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentStatusChartCard(invoices: [], loading: false),
      ));
      expect(find.byIcon(Icons.pie_chart), findsOneWidget);
    });

    testWidgets('shows legend labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentStatusChartCard(invoices: [], loading: false),
      ));
      expect(find.textContaining('Paid'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Pending'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Rejected'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows "Total:" label', (tester) async {
      await tester.pumpWidget(_wrap(
        const PaymentStatusChartCard(invoices: [], loading: false),
      ));
      expect(find.textContaining('Total:'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // MonthlyInvoiceTrendsCard
  // ───────────────────────────────────────────────────────────────────────────
  group('MonthlyInvoiceTrendsCard', () {
    testWidgets('renders without crashing when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        const MonthlyInvoiceTrendsCard(invoices: [], loading: true),
      ));
      expect(find.byType(MonthlyInvoiceTrendsCard), findsOneWidget);
    });

    testWidgets('shows "Monthly Invoice Trends" header', (tester) async {
      await tester.pumpWidget(_wrap(
        const MonthlyInvoiceTrendsCard(invoices: [], loading: false),
      ));
      expect(find.text('Monthly Invoice Trends'), findsOneWidget);
    });

    testWidgets('shows bar_chart icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const MonthlyInvoiceTrendsCard(invoices: [], loading: false),
      ));
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('renders without crashing with invoices', (tester) async {
      final invoices = [
        _makeInvoice(
          id: '1',
          providerName: 'Provider A',
          status: PaymentStatus.paid,
          statementDate: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(_wrap(
        MonthlyInvoiceTrendsCard(invoices: invoices, loading: false),
      ));
      expect(find.byType(MonthlyInvoiceTrendsCard), findsOneWidget);
    });
  });
}
