// Tests for AchievementDetailScreen widget
// (lib/features/gamification/presentation/pages/achievement_detail_screen.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/gamification/presentation/pages/achievement_detail_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('AchievementDetailScreen', () {
    testWidgets('renders without crashing with empty list', (tester) async {
      await tester.pumpWidget(_wrap(
        const AchievementDetailScreen(achievements: []),
      ));
      expect(find.byType(AchievementDetailScreen), findsOneWidget);
    });

    testWidgets('shows "Achievements" AppBar title', (tester) async {
      await tester.pumpWidget(_wrap(
        const AchievementDetailScreen(achievements: []),
      ));
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('shows achievement title', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'First Check-In', 'description': 'Complete your first check-in', 'unlocked': true},
        ]),
      ));
      expect(find.text('First Check-In'), findsOneWidget);
    });

    testWidgets('shows achievement description', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'First Check-In', 'description': 'Complete your first check-in', 'unlocked': true},
        ]),
      ));
      expect(find.text('Complete your first check-in'), findsOneWidget);
    });

    testWidgets('shows check_circle icon for unlocked achievement (bool true)', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Unlocked', 'description': 'Desc', 'unlocked': true},
        ]),
      ));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows lock_outline icon for locked achievement (bool false)', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Locked', 'description': 'Desc', 'unlocked': false},
        ]),
      ));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('treats string "true" as unlocked', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'String True', 'description': 'Desc', 'unlocked': 'true'},
        ]),
      ));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('treats integer 1 as unlocked', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Int One', 'description': 'Desc', 'unlocked': 1},
        ]),
      ));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('treats integer 0 as locked', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Int Zero', 'description': 'Desc', 'unlocked': 0},
        ]),
      ));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows default description when description is null', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'No Desc', 'unlocked': false},
        ]),
      ));
      expect(find.text('No description available'), findsOneWidget);
    });

    testWidgets('shows default badge_icon "🏆" when badge_icon is null', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'No Badge', 'description': 'Desc', 'unlocked': false},
        ]),
      ));
      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('shows custom badge_icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Star', 'description': 'Desc', 'unlocked': true, 'badge_icon': '⭐'},
        ]),
      ));
      expect(find.text('⭐'), findsOneWidget);
    });

    testWidgets('shows multiple achievements', (tester) async {
      await tester.pumpWidget(_wrap(
        AchievementDetailScreen(achievements: [
          {'title': 'Achievement A', 'description': 'Desc A', 'unlocked': true},
          {'title': 'Achievement B', 'description': 'Desc B', 'unlocked': false},
          {'title': 'Achievement C', 'description': 'Desc C', 'unlocked': false},
        ]),
      ));
      expect(find.text('Achievement A'), findsOneWidget);
      expect(find.text('Achievement B'), findsOneWidget);
      expect(find.text('Achievement C'), findsOneWidget);
    });
  });
}
