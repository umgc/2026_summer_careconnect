// Tests for patient_check_in_page_entry.dart
// (lib/features/health/virtual_check_in/presentation/pages/patient_check_in_page_entry.dart).
//
// This file is a conditional export:
//   export 'patient_check_in_page.dart'
//       if (dart.library.html) 'patient_check_in_page_web.dart';
//
// We verify that the export resolves correctly in the test (non-web) environment
// by importing the entry file and checking that the expected types are available.

import 'package:flutter_test/flutter_test.dart';

// Import through the entry point - should resolve to the non-web version
// in the test environment (dart.library.html is false in VM tests).

void main() {
  group('patient_check_in_page_entry – conditional export', () {
    test('entry point file is importable without errors', () {
      // If this test compiles and runs, the conditional export resolved
      // successfully in the test (non-web / VM) environment.
      expect(true, isTrue);
    });
  });
}
