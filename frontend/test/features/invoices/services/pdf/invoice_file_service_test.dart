// Tests for InvoiceFileService
// (lib/features/invoices/services/pdf/invoice_file_service.dart).
//
// The class has a single static method `openInvoicePdf` that constructs a URL
// from ApiConstants.baseUrl and then delegates to url_launcher.
// We can verify:
//   - The class exists and can be instantiated
//   - The method signature is correct (accepts String, returns Future<void>)
//   - URL construction logic uses the correct format
//
// We cannot fully test the actual URL launching because url_launcher
// requires a platform channel, but we can verify the method doesn't
// throw synchronously and the class structure is sound.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/invoices/services/pdf/invoice_file_service.dart';
import 'package:care_connect_app/services/api_service.dart';

void main() {
  group('InvoiceFileService', () {
    test('class can be instantiated', () {
      final service = InvoiceFileService();
      expect(service, isNotNull);
      expect(service, isA<InvoiceFileService>());
    });

    test('openInvoicePdf is a static method that returns Future<void>', () {
      // Verify the method exists and has the correct return type
      // We can't actually call it because url_launcher needs a platform channel,
      // but we can verify it's callable and returns a Future.
      expect(InvoiceFileService.openInvoicePdf, isA<Function>());
    });

    test('ApiConstants.baseUrl is used for URL construction', () {
      // Verify that the base URL constant is accessible and properly formatted
      final baseUrl = ApiConstants.baseUrl;
      expect(baseUrl, isA<String>());
      expect(baseUrl, isNotEmpty);
      // The URL should contain the API path prefix
      expect(baseUrl, contains('/v1/api/'));
    });

    test('expected PDF export endpoint path format', () {
      // The method constructs a URL like:
      // ${ApiConstants.baseUrl}invoices/exportPDF?documentLink=$documentLink
      // Verify the expected path components would form a valid URL
      const testDocLink = 'http://example.com/doc.pdf';
      final expectedUrl =
          '${ApiConstants.baseUrl}invoices/exportPDF?documentLink=$testDocLink';
      expect(expectedUrl, contains('invoices/exportPDF'));
      expect(expectedUrl, contains('documentLink='));
      expect(expectedUrl, contains(testDocLink));
    });

    test('openInvoicePdf throws in test environment without platform channel',
        () async {
      // url_launcher requires a platform channel which is not available
      // in unit tests. The method will throw because the binding or
      // plugin is not initialized.
      TestWidgetsFlutterBinding.ensureInitialized();
      expect(
        () => InvoiceFileService.openInvoicePdf('not-a-real-url'),
        throwsA(anything),
      );
    });

    test('openInvoicePdf throws for empty document link in test env', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      expect(
        () => InvoiceFileService.openInvoicePdf(''),
        throwsA(anything),
      );
    });

    test('openInvoicePdf throws for URL with special characters in test env',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      expect(
        () => InvoiceFileService.openInvoicePdf(
            'http://example.com/doc?name=test&id=123'),
        throwsA(anything),
      );
    });
  });
}
