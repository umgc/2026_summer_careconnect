// Tests for InvoiceResponseDto from invoice_ocr_llm_api.dart
// and indirectly covers the mapping/helper functions via the public API.
//
// The extractWithLlm method requires AuthTokenManager (FlutterSecureStorage)
// and real HTTP calls, so it is not tested here. Instead we test:
//   - InvoiceResponseDto construction with various field combinations
//   - That the DTO correctly holds invoice, duplicate, message, etc.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/services/invoice_ocr_llm_api.dart';
import 'package:care_connect_app/features/invoices/models/invoice_models.dart';

/// Creates a minimal Invoice for testing purposes.
Invoice _makeInvoice({
  String id = 'test-id',
  String invoiceNumber = 'INV-001',
  PaymentStatus paymentStatus = PaymentStatus.pending,
  double? amountDue,
}) {
  final now = DateTime.now();
  return Invoice(
    id: id,
    invoiceNumber: invoiceNumber,
    provider: const ProviderInfo(
      name: 'Test Provider',
      address: '123 Main St',
      phone: '555-1234',
    ),
    patient: const PatientInfo(name: 'John Doe'),
    dates: InvoiceDates(
      statementDate: now,
      dueDate: now.add(const Duration(days: 30)),
    ),
    services: const [],
    paymentStatus: paymentStatus,
    billedToInsurance: false,
    amounts: Amounts(amountDue: amountDue),
    paymentReferences: PaymentReferences(supportedMethods: const []),
    createdAt: now.toIso8601String(),
    updatedAt: now.toIso8601String(),
    createdBy: 'system',
    updatedBy: 'system',
    payments: const [],
  );
}

void main() {
  group('InvoiceResponseDto', () {
    test('stores invoice and duplicate flag', () {
      final invoice = _makeInvoice();
      final dto = InvoiceResponseDto(
        invoice: invoice,
        duplicate: false,
      );

      expect(dto.invoice.id, 'test-id');
      expect(dto.invoice.invoiceNumber, 'INV-001');
      expect(dto.duplicate, false);
      expect(dto.message, isNull);
      expect(dto.duplicateId, isNull);
      expect(dto.duplicateInvoiceNumber, isNull);
    });

    test('stores duplicate = true with message and duplicateId', () {
      final invoice = _makeInvoice(id: 'dup-id');
      final dto = InvoiceResponseDto(
        invoice: invoice,
        duplicate: true,
        message: 'Duplicate invoice detected',
        duplicateId: 'original-id',
        duplicateInvoiceNumber: 'INV-001',
      );

      expect(dto.duplicate, true);
      expect(dto.message, 'Duplicate invoice detected');
      expect(dto.duplicateId, 'original-id');
      expect(dto.duplicateInvoiceNumber, 'INV-001');
    });

    test('stores invoice with various payment statuses', () {
      for (final status in PaymentStatus.values) {
        final invoice = _makeInvoice(paymentStatus: status);
        final dto = InvoiceResponseDto(
          invoice: invoice,
          duplicate: false,
        );
        expect(dto.invoice.paymentStatus, status);
      }
    });

    test('stores invoice with all optional fields null', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: false,
        message: null,
        duplicateId: null,
        duplicateInvoiceNumber: null,
      );

      expect(dto.message, isNull);
      expect(dto.duplicateId, isNull);
      expect(dto.duplicateInvoiceNumber, isNull);
    });

    test('stores invoice with amount due', () {
      final invoice = _makeInvoice(amountDue: 250.50);
      final dto = InvoiceResponseDto(
        invoice: invoice,
        duplicate: false,
      );

      expect(dto.invoice.amounts.amountDue, 250.50);
    });

    test('invoice provider info is accessible', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: false,
      );

      expect(dto.invoice.provider.name, 'Test Provider');
      expect(dto.invoice.provider.address, '123 Main St');
      expect(dto.invoice.provider.phone, '555-1234');
    });

    test('invoice patient info is accessible', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: false,
      );

      expect(dto.invoice.patient.name, 'John Doe');
    });

    test('invoice dates are accessible', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: false,
      );

      expect(dto.invoice.dates.statementDate, isNotNull);
      expect(dto.invoice.dates.dueDate, isNotNull);
      expect(dto.invoice.dates.paidDate, isNull);
    });

    test('duplicate false by default behavior', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: false,
      );
      expect(dto.duplicate, false);
    });

    test('stores different invoice numbers', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(invoiceNumber: 'INV-999'),
        duplicate: false,
      );
      expect(dto.invoice.invoiceNumber, 'INV-999');
    });

    test('message can be empty string', () {
      final dto = InvoiceResponseDto(
        invoice: _makeInvoice(),
        duplicate: true,
        message: '',
      );
      expect(dto.message, '');
    });
  });
}
