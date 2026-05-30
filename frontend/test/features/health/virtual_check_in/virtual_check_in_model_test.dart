// Tests for VirtualCheckIn model and enums
// (lib/features/health/virtual_check_in/models/virtual_check_in.dart).
// Pure-Dart data class — no platform channels or network I/O.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/health/virtual_check_in/models/virtual_check_in.dart';

void main() {
  group('CheckInType enum', () {
    test('has routine, followUp, and urgent values', () {
      expect(CheckInType.values, contains(CheckInType.routine));
      expect(CheckInType.values, contains(CheckInType.followUp));
      expect(CheckInType.values, contains(CheckInType.urgent));
    });
  });

  group('CheckInStatus enum', () {
    test('has completed, missed, and cancelled values', () {
      expect(CheckInStatus.values, contains(CheckInStatus.completed));
      expect(CheckInStatus.values, contains(CheckInStatus.missed));
      expect(CheckInStatus.values, contains(CheckInStatus.cancelled));
    });
  });

  group('VirtualCheckIn constructor', () {
    test('stores all fields correctly', () {
      // Verifies that the constructor assigns each field.
      final startedAt = DateTime(2025, 6, 15, 10, 30);
      final nextCheckIn = DateTime(2025, 6, 22, 10, 30);
      final checkIn = VirtualCheckIn(
        id: 'vc-001',
        type: CheckInType.routine,
        clinicianName: 'Dr. Smith',
        startedAt: startedAt,
        durationMinutes: 15,
        status: CheckInStatus.completed,
        moodLabel: 'Good',
        nextCheckIn: nextCheckIn,
        summary: 'Patient is doing well.',
      );

      expect(checkIn.id, 'vc-001');
      expect(checkIn.type, CheckInType.routine);
      expect(checkIn.clinicianName, 'Dr. Smith');
      expect(checkIn.startedAt, startedAt);
      expect(checkIn.durationMinutes, 15);
      expect(checkIn.status, CheckInStatus.completed);
      expect(checkIn.moodLabel, 'Good');
      expect(checkIn.nextCheckIn, nextCheckIn);
      expect(checkIn.summary, 'Patient is doing well.');
    });

    test('supports followUp type and missed status', () {
      // Verifies alternative enum values are stored correctly.
      final checkIn = VirtualCheckIn(
        id: 'vc-002',
        type: CheckInType.followUp,
        clinicianName: 'Dr. Jones',
        startedAt: DateTime(2025, 3, 1),
        durationMinutes: 30,
        status: CheckInStatus.missed,
        moodLabel: 'Poor',
        nextCheckIn: DateTime(2025, 3, 8),
        summary: 'Missed session.',
      );

      expect(checkIn.type, CheckInType.followUp);
      expect(checkIn.status, CheckInStatus.missed);
    });

    test('supports urgent type and cancelled status', () {
      // Verifies urgent and cancelled enum values are stored correctly.
      final checkIn = VirtualCheckIn(
        id: 'vc-003',
        type: CheckInType.urgent,
        clinicianName: 'Dr. Lee',
        startedAt: DateTime(2025, 4, 10),
        durationMinutes: 45,
        status: CheckInStatus.cancelled,
        moodLabel: 'Fair',
        nextCheckIn: DateTime(2025, 4, 17),
        summary: 'Cancelled by patient.',
      );

      expect(checkIn.type, CheckInType.urgent);
      expect(checkIn.status, CheckInStatus.cancelled);
      expect(checkIn.durationMinutes, 45);
    });
  });
}
