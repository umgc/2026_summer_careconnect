// Tests for DefaultAppHeader widget
// (lib/widgets/default_app_header.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/default_app_header.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(appBar: child as PreferredSizeWidget));

void main() {
  group('DefaultAppHeader', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const DefaultAppHeader()));
      expect(find.byType(DefaultAppHeader), findsOneWidget);
    });

    testWidgets('shows settings icon', (tester) async {
      await tester.pumpWidget(_wrap(const DefaultAppHeader()));
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('does not show back button by default', (tester) async {
      await tester.pumpWidget(_wrap(const DefaultAppHeader()));
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('shows back button when showBackButton=true', (tester) async {
      await tester.pumpWidget(_wrap(const DefaultAppHeader(showBackButton: true)));
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('has preferredSize equal to kToolbarHeight', (tester) async {
      const header = DefaultAppHeader();
      expect(header.preferredSize, const Size.fromHeight(kToolbarHeight));
    });

    testWidgets('renders AppBar widget', (tester) async {
      await tester.pumpWidget(_wrap(const DefaultAppHeader()));
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
