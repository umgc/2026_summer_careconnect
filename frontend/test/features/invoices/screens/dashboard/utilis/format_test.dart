// Tests for invoice dashboard utility functions
// (lib/features/invoices/screens/dashboard/utilis/format.dart)

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/utilis/format.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // currency()
  // ───────────────────────────────────────────────────────────────────────────
  group('currency()', () {
    test('formats integer as dollars with two decimals', () {
      expect(currency(100), '\$100.00');
    });

    test('formats zero', () {
      expect(currency(0), '\$0.00');
    });

    test('formats a double with two decimal places', () {
      expect(currency(9.99), '\$9.99');
    });

    test('formats a value with many decimal places', () {
      expect(currency(1.1), '\$1.10');
    });

    test('formats a large value', () {
      expect(currency(12345.67), '\$12345.67');
    });

    test('formats a negative value', () {
      expect(currency(-50), '\$-50.00');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // fmt()
  // ───────────────────────────────────────────────────────────────────────────
  group('fmt()', () {
    test('returns date portion only (yyyy-MM-dd)', () {
      final d = DateTime(2024, 6, 15, 14, 30, 0);
      // Local toString starts with yyyy-MM-dd
      expect(fmt(d), startsWith('2024-06-15'));
      expect(fmt(d).contains(' '), isFalse);
    });

    test('pads month and day with leading zero', () {
      final d = DateTime(2024, 1, 5);
      expect(fmt(d), '2024-01-05');
    });

    test('handles end of year', () {
      final d = DateTime(2023, 12, 31);
      expect(fmt(d), '2023-12-31');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // monthShort()
  // ───────────────────────────────────────────────────────────────────────────
  group('monthShort()', () {
    final expected = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr',
      5: 'May', 6: 'Jun', 7: 'Jul', 8: 'Aug',
      9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
    };

    for (final entry in expected.entries) {
      test('month ${entry.key} returns ${entry.value}', () {
        expect(monthShort(entry.key), entry.value);
      });
    }
  });

  // ───────────────────────────────────────────────────────────────────────────
  // labelForStatus()
  // ───────────────────────────────────────────────────────────────────────────
  group('labelForStatus()', () {
    test('pending → "Pending"', () {
      expect(labelForStatus(PaymentStatus.pending), 'Pending');
    });

    test('overdue → "Overdue"', () {
      expect(labelForStatus(PaymentStatus.overdue), 'Overdue');
    });

    test('pendingInsurance → "Pending Insurance"', () {
      expect(labelForStatus(PaymentStatus.pendingInsurance), 'Pending Insurance');
    });

    test('sent → "Sent"', () {
      expect(labelForStatus(PaymentStatus.sent), 'Sent');
    });

    test('paid → "Paid"', () {
      expect(labelForStatus(PaymentStatus.paid), 'Paid');
    });

    test('partialPayment → "Partial Payment"', () {
      expect(labelForStatus(PaymentStatus.partialPayment), 'Partial Payment');
    });

    test('rejectedInsurance → "Rejected Insurance"', () {
      expect(labelForStatus(PaymentStatus.rejectedInsurance), 'Rejected Insurance');
    });
  });
}
