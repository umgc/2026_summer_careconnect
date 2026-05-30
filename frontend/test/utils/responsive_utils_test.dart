// Tests for ResponsiveUtils and ResponsiveContext extension
// (lib/utils/responsive_utils.dart).
//
// Pure MediaQuery-based static methods — testable by controlling
// tester.view.physicalSize to simulate different device widths.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/utils/responsive_utils.dart';

// Helper: build a widget that captures results via callback
Widget _buildWithContext(void Function(BuildContext) capture) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        capture(context);
        return const SizedBox();
      },
    ),
  );
}

void main() {
  group('ResponsiveUtils.getDeviceType', () {
    testWidgets('returns mobile for width < 600', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      DeviceType? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getDeviceType(ctx);
      }));
      expect(result, DeviceType.mobile);
    });

    testWidgets('returns tablet for width 600–899', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      DeviceType? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getDeviceType(ctx);
      }));
      expect(result, DeviceType.tablet);
    });

    testWidgets('returns desktop for width 900–1199', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      DeviceType? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getDeviceType(ctx);
      }));
      expect(result, DeviceType.desktop);
    });

    testWidgets('returns largeDesktop for width >= 1200', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      DeviceType? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getDeviceType(ctx);
      }));
      expect(result, DeviceType.largeDesktop);
    });
  });

  group('ResponsiveUtils.getGridColumnCount', () {
    testWidgets('returns 1 column for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getGridColumnCount(ctx);
      }));
      expect(result, 1);
    });

    testWidgets('returns 2 columns for tablet', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getGridColumnCount(ctx);
      }));
      expect(result, 2);
    });

    testWidgets('returns 3 columns for desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getGridColumnCount(ctx);
      }));
      expect(result, 3);
    });

    testWidgets('returns 4 columns for largeDesktop', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getGridColumnCount(ctx);
      }));
      expect(result, 4);
    });
  });

  group('ResponsiveUtils.getHorizontalMargin', () {
    testWidgets('returns 16.0 for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getHorizontalMargin(ctx);
      }));
      expect(result, 16.0);
    });

    testWidgets('returns 5% of width for tablet', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getHorizontalMargin(ctx);
      }));
      expect(result, closeTo(700 * 0.05, 0.1));
    });

    testWidgets('returns 8% of width for desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getHorizontalMargin(ctx);
      }));
      expect(result, closeTo(1000 * 0.08, 0.1));
    });
  });

  group('ResponsiveUtils.shouldConstrainWidth', () {
    testWidgets('returns false for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.shouldConstrainWidth(ctx);
      }));
      expect(result, isFalse);
    });

    testWidgets('returns true for desktop', (tester) async {
      tester.view.physicalSize = const Size(1300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.shouldConstrainWidth(ctx);
      }));
      expect(result, isTrue);
    });
  });

  group('ResponsiveUtils.getResponsiveFontSize', () {
    testWidgets('returns base size for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getResponsiveFontSize(ctx, baseFontSize: 14.0);
      }));
      expect(result, 14.0);
    });

    testWidgets('returns larger size for tablet', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getResponsiveFontSize(ctx, baseFontSize: 14.0);
      }));
      expect(result, greaterThan(14.0));
    });
  });

  group('ResponsiveUtils.constrainedWidthContainer', () {
    testWidgets('wraps in Center+Container on desktop', (tester) async {
      tester.view.physicalSize = const Size(1300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ResponsiveUtils.constrainedWidthContainer(
            context: context,
            child: const Text('content'),
          ),
        ),
      ));
      expect(find.byType(Center), findsWidgets);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('returns child directly on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ResponsiveUtils.constrainedWidthContainer(
            context: context,
            child: const Text('content'),
          ),
        ),
      ));
      expect(find.text('content'), findsOneWidget);
    });
  });

  group('ResponsiveContext extension', () {
    testWidgets('isMobile is true on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? isMobile;
      await tester.pumpWidget(_buildWithContext((ctx) {
        isMobile = ctx.isMobile;
      }));
      expect(isMobile, isTrue);
    });

    testWidgets('isDesktopOrLarger is true on desktop viewport', (tester) async {
      tester.view.physicalSize = const Size(1300, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? isDesktopOrLarger;
      await tester.pumpWidget(_buildWithContext((ctx) {
        isDesktopOrLarger = ctx.isDesktopOrLarger;
      }));
      expect(isDesktopOrLarger, isTrue);
    });

    testWidgets('gridColumns matches getGridColumnCount', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int? columns;
      await tester.pumpWidget(_buildWithContext((ctx) {
        columns = ctx.gridColumns;
      }));
      expect(columns, 2);
    });

    testWidgets('responsiveValue returns mobile value on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(
          mobile: 'mobile',
          tablet: 'tablet',
          desktop: 'desktop',
        );
      }));
      expect(value, 'mobile');
    });

    testWidgets('responsiveValue falls back to mobile when tablet/desktop null', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(mobile: 'fallback');
      }));
      expect(value, 'fallback');
    });

    testWidgets('responsiveValue returns desktop value on desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(
          mobile: 'mobile',
          tablet: 'tablet',
          desktop: 'desktop',
        );
      }));
      expect(value, 'desktop');
    });

    testWidgets('responsiveValue returns largeDesktop value on large screens', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(
          mobile: 'mobile',
          largeDesktop: 'xlarge',
        );
      }));
      expect(value, 'xlarge');
    });

    testWidgets('responsiveValue falls back to tablet then mobile on desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(
          mobile: 'mobile',
          tablet: 'tablet',
        );
      }));
      expect(value, 'tablet');
    });

    testWidgets('responsiveValue falls back through chain on largeDesktop', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      String? value;
      await tester.pumpWidget(_buildWithContext((ctx) {
        value = ctx.responsiveValue<String>(
          mobile: 'mobile',
          desktop: 'desktop',
        );
      }));
      expect(value, 'desktop');
    });

    testWidgets('isTablet is true on tablet viewport', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? isTablet;
      await tester.pumpWidget(_buildWithContext((ctx) {
        isTablet = ctx.isTablet;
      }));
      expect(isTablet, isTrue);
    });

    testWidgets('isDesktop is true on desktop viewport', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? isDesktop;
      await tester.pumpWidget(_buildWithContext((ctx) {
        isDesktop = ctx.isDesktop;
      }));
      expect(isDesktop, isTrue);
    });

    testWidgets('isLargeDesktop is true on large desktop viewport', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? isLargeDesktop;
      await tester.pumpWidget(_buildWithContext((ctx) {
        isLargeDesktop = ctx.isLargeDesktop;
      }));
      expect(isLargeDesktop, isTrue);
    });

    testWidgets('isMobileOrTablet is true on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ctx.isMobileOrTablet;
      }));
      expect(result, isTrue);
    });

    testWidgets('isMobileOrTablet is false on desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ctx.isMobileOrTablet;
      }));
      expect(result, isFalse);
    });

    testWidgets('horizontalMargin returns value via extension', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? margin;
      await tester.pumpWidget(_buildWithContext((ctx) {
        margin = ctx.horizontalMargin;
      }));
      expect(margin, 16.0);
    });

    testWidgets('responsivePadding returns EdgeInsets via extension', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      EdgeInsets? padding;
      await tester.pumpWidget(_buildWithContext((ctx) {
        padding = ctx.responsivePadding;
      }));
      expect(padding, isNotNull);
      expect(padding!.left, 16.0);
      expect(padding!.top, 16.0);
    });

    testWidgets('responsiveContainer wraps child', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => context.responsiveContainer(
            child: const Text('wrapped'),
          ),
        ),
      ));
      expect(find.text('wrapped'), findsOneWidget);
    });

    testWidgets('responsiveFontSize returns value via extension', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? fontSize;
      await tester.pumpWidget(_buildWithContext((ctx) {
        fontSize = ctx.responsiveFontSize(base: 16.0);
      }));
      expect(fontSize, 16.0);
    });

    testWidgets('shouldConstrainWidth returns false via extension on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ctx.shouldConstrainWidth;
      }));
      expect(result, isFalse);
    });
  });

  group('ResponsiveUtils.getCardWidth', () {
    testWidgets('returns 85% of width for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getCardWidth(ctx);
      }));
      expect(result, closeTo(400 * 0.85, 0.1));
    });

    testWidgets('returns default width for tablet', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getCardWidth(ctx);
      }));
      expect(result, 400.0);
    });

    testWidgets('returns custom default width', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getCardWidth(ctx, defaultWidth: 500);
      }));
      expect(result, 500.0);
    });
  });

  group('ResponsiveUtils.getPagePadding', () {
    testWidgets('returns 16 vertical padding for mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      EdgeInsets? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getPagePadding(ctx);
      }));
      expect(result!.top, 16.0);
      expect(result!.left, 16.0);
    });

    testWidgets('returns 24 vertical padding for desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      EdgeInsets? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getPagePadding(ctx);
      }));
      expect(result!.top, 24.0);
    });

    testWidgets('returns 24 vertical padding for largeDesktop', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      EdgeInsets? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getPagePadding(ctx);
      }));
      expect(result!.top, 24.0);
    });
  });

  group('ResponsiveUtils.getHorizontalMargin – largeDesktop', () {
    testWidgets('centers content on very large screens', (tester) async {
      tester.view.physicalSize = const Size(1800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getHorizontalMargin(ctx);
      }));
      // (1800 - 1400) / 2 = 200
      expect(result, closeTo(200.0, 0.1));
    });

    testWidgets('uses 10% margin when centered would be negative', (tester) async {
      // Width 1440 is >= largeDesktopBreakpoint but very close to maxContentWidth
      tester.view.physicalSize = const Size(1440, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getHorizontalMargin(ctx);
      }));
      // (1440 - 1400) / 2 = 20, which is > 0, so use that
      expect(result, closeTo(20.0, 0.1));
    });
  });

  group('ResponsiveUtils.getResponsiveFontSize – all device types', () {
    testWidgets('returns scaled size for desktop', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getResponsiveFontSize(ctx, baseFontSize: 14.0, scaleFactor: 0.2);
      }));
      // desktop: 14 * (1 + 0.2) = 16.8
      expect(result, closeTo(16.8, 0.01));
    });

    testWidgets('returns scaled size for largeDesktop', (tester) async {
      tester.view.physicalSize = const Size(1500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      double? result;
      await tester.pumpWidget(_buildWithContext((ctx) {
        result = ResponsiveUtils.getResponsiveFontSize(ctx, baseFontSize: 14.0, scaleFactor: 0.2);
      }));
      // largeDesktop: 14 * (1 + 0.2 * 1.5) = 14 * 1.3 = 18.2
      expect(result, closeTo(18.2, 0.01));
    });
  });

  group('DeviceType enum', () {
    test('has exactly 4 values', () {
      expect(DeviceType.values.length, 4);
    });
  });
}
