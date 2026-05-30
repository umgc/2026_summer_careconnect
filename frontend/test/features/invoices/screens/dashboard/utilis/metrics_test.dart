// Tests for invoice dashboard Metrics model and computeMetrics()
// (lib/features/invoices/screens/dashboard/utilis/metrics.dart)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/utilis/metrics.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';

// Minimal Invoice builder for tests
Invoice _makeInvoice({
  required PaymentStatus status,
  double? amountDue,
  double? total,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return Invoice(
    id: 'test-${now.millisecondsSinceEpoch}',
    invoiceNumber: 'INV-001',
    provider: const ProviderInfo(name: 'Provider', address: 'Addr', phone: '555'),
    patient: const PatientInfo(name: 'Patient'),
    dates: InvoiceDates(
      statementDate: now,
      dueDate: dueDate ?? now.add(const Duration(days: 30)),
    ),
    paymentStatus: status,
    billedToInsurance: false,
    amounts: Amounts(amountDue: amountDue, total: total),
    paymentReferences: PaymentReferences(supportedMethods: const []),
    createdAt: now.toIso8601String(),
    updatedAt: now.toIso8601String(),
    createdBy: 'test',
    updatedBy: 'test',
    payments: const [],
  );
}

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // Metrics constructor
  // ───────────────────────────────────────────────────────────────────────────
  group('Metrics', () {
    test('constructor stores all fields', () {
      const m = Metrics(
        totalCount: 5,
        totalAmount: 500.0,
        pendingAmount: 200.0,
        overdueCount: 2,
        paidAmount: 300.0,
      );
      expect(m.totalCount, 5);
      expect(m.totalAmount, 500.0);
      expect(m.pendingAmount, 200.0);
      expect(m.overdueCount, 2);
      expect(m.paidAmount, 300.0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // computeMetrics()
  // ───────────────────────────────────────────────────────────────────────────
  group('computeMetrics()', () {
    test('returns zeros for empty list', () {
      final m = computeMetrics([]);
      expect(m.totalCount, 0);
      expect(m.totalAmount, 0.0);
      expect(m.pendingAmount, 0.0);
      expect(m.overdueCount, 0);
      expect(m.paidAmount, 0.0);
    });

    test('counts total invoices', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 200),
      ];
      expect(computeMetrics(invoices).totalCount, 2);
    });

    test('sums totalAmount using amountDue when available', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 250),
      ];
      expect(computeMetrics(invoices).totalAmount, 350.0);
    });

    test('falls back to total when amountDue is null', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, total: 150),
      ];
      expect(computeMetrics(invoices).totalAmount, 150.0);
    });

    test('uses 0 when both amountDue and total are null', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending),
      ];
      expect(computeMetrics(invoices).totalAmount, 0.0);
    });

    test('sums pendingAmount for pending invoices only', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 200),
        _makeInvoice(status: PaymentStatus.pending, amountDue: 50),
      ];
      expect(computeMetrics(invoices).pendingAmount, 150.0);
    });

    test('counts overdueCount for non-paid invoices with past dueDate', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100, dueDate: pastDate),
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100, dueDate: futureDate),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 100, dueDate: pastDate),
      ];
      // Only the first is overdue (past due and not paid)
      expect(computeMetrics(invoices).overdueCount, 1);
    });

    test('paid invoices with past dueDate do not count as overdue', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 10));
      final invoices = [
        _makeInvoice(status: PaymentStatus.paid, amountDue: 100, dueDate: pastDate),
      ];
      expect(computeMetrics(invoices).overdueCount, 0);
    });

    test('sums paidAmount for paid invoices only', () {
      final invoices = [
        _makeInvoice(status: PaymentStatus.paid, amountDue: 300),
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 200),
      ];
      expect(computeMetrics(invoices).paidAmount, 500.0);
    });

    test('mixed statuses compute correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));
      final invoices = [
        _makeInvoice(status: PaymentStatus.pending, amountDue: 100, dueDate: pastDate),
        _makeInvoice(status: PaymentStatus.paid, amountDue: 400),
        _makeInvoice(status: PaymentStatus.overdue, amountDue: 200, dueDate: pastDate),
      ];
      final m = computeMetrics(invoices);
      expect(m.totalCount, 3);
      expect(m.totalAmount, 700.0);
      expect(m.pendingAmount, 100.0); // only pending status
      expect(m.overdueCount, 2);     // pending+overdue both have past due date
      expect(m.paidAmount, 400.0);
    });
  });
}
