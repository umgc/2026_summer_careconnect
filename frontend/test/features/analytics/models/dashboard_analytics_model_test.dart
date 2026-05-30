// Tests for DashboardAnalytics model
// (lib/features/analytics/models/dashboard_analytics_model.dart).
//
// DashboardAnalytics.fromJson parses optional numeric fields via ?.toDouble(),
// optional List<double> arrays, and optional DateTime strings.
// All branches are exercised in a pure-Dart unit test — no platform channels.

import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/analytics/models/dashboard_analytics_model.dart';

void main() {
  group('DashboardAnalytics.fromJson', () {
    test('parses all fields when fully populated', () {
      // Verifies the happy-path where every field is present in the JSON.
      final json = {
        'adherenceRate': 0.95,
        'avgHeartRate': 72.5,
        'avgSpo2': 98.0,
        'avgSystolic': 120.0,
        'avgDiastolic': 80.0,
        'avgWeight': 70.5,
        'avgMood': 7.0,
        'avgPain': 3.0,
        'moodValues': [6.0, 7.0, 8.0],
        'painValues': [2.0, 3.0, 4.0],
        'periodStart': '2025-01-01T00:00:00.000',
        'periodEnd': '2025-01-31T23:59:59.000',
      };
      final model = DashboardAnalytics.fromJson(json);

      expect(model.adherenceRate, closeTo(0.95, 0.001));
      expect(model.avgHeartRate, closeTo(72.5, 0.001));
      expect(model.avgSpo2, closeTo(98.0, 0.001));
      expect(model.avgSystolic, closeTo(120.0, 0.001));
      expect(model.avgDiastolic, closeTo(80.0, 0.001));
      expect(model.avgWeight, closeTo(70.5, 0.001));
      expect(model.avgMoodValue, closeTo(7.0, 0.001));
      expect(model.avgPainValue, closeTo(3.0, 0.001));
      expect(model.moodValues, [6.0, 7.0, 8.0]);
      expect(model.painValues, [2.0, 3.0, 4.0]);
      expect(model.periodStart, DateTime.parse('2025-01-01T00:00:00.000'));
      expect(model.periodEnd, DateTime.parse('2025-01-31T23:59:59.000'));
    });

    test('returns null fields when JSON values are null', () {
      // Verifies that missing/null JSON values produce null model fields.
      final model = DashboardAnalytics.fromJson({});

      expect(model.adherenceRate, isNull);
      expect(model.avgHeartRate, isNull);
      expect(model.avgSpo2, isNull);
      expect(model.avgSystolic, isNull);
      expect(model.avgDiastolic, isNull);
      expect(model.avgWeight, isNull);
      expect(model.avgMoodValue, isNull);
      expect(model.avgPainValue, isNull);
      expect(model.moodValues, isNull);
      expect(model.painValues, isNull);
      expect(model.periodStart, isNull);
      expect(model.periodEnd, isNull);
    });

    test('moodValues list is parsed from integer elements', () {
      // Verifies List<double>.from() works when the JSON array has ints.
      final model = DashboardAnalytics.fromJson({
        'moodValues': [5, 6, 7],
      });
      expect(model.moodValues, [5.0, 6.0, 7.0]);
    });

    test('painValues list is parsed from integer elements', () {
      // Same as above but for painValues.
      final model = DashboardAnalytics.fromJson({
        'painValues': [1, 2],
      });
      expect(model.painValues, [1.0, 2.0]);
    });

    test('periodStart and periodEnd parse valid ISO-8601 strings', () {
      // Verifies DateTime.parse is called for non-null period strings.
      final model = DashboardAnalytics.fromJson({
        'periodStart': '2025-06-01T00:00:00.000Z',
        'periodEnd': '2025-06-30T23:59:59.999Z',
      });
      expect(model.periodStart!.year, 2025);
      expect(model.periodStart!.month, 6);
      expect(model.periodEnd!.day, 30);
    });

    test('constructor stores values as provided', () {
      // Verifies the positional constructor fields are accessible.
      final model = DashboardAnalytics(
        adherenceRate: 0.8,
        avgHeartRate: 65.0,
        periodStart: DateTime(2025, 3, 1),
      );
      expect(model.adherenceRate, 0.8);
      expect(model.avgHeartRate, 65.0);
      expect(model.periodStart!.month, 3);
    });
  });
}
