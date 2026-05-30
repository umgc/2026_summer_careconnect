// Tests for AchievementDetailScreen widget
// (lib/features/gamification/presentation/pages/achievement_detail_screen.dart).
// Pure StatelessWidget — no platform channels or network I/O.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/gamification/presentation/pages/achievement_detail_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

Map<String, dynamic> _achievement({
  String? badgeIcon,
  String? title,
  String? description,
  dynamic unlocked = false,
}) =>
    {
      if (badgeIcon != null) 'badge_icon': badgeIcon,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'unlocked': unlocked,
    };

void main() {
  group('AchievementDetailScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'First Step')],
      )));
      expect(find.byType(AchievementDetailScreen), findsOneWidget);
    });

    testWidgets('shows Achievements app bar title', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [],
      )));
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('shows achievement title', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'First Step')],
      )));
      expect(find.text('First Step'), findsOneWidget);
    });

    testWidgets('shows achievement description', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [
          _achievement(
            title: 'Streak',
            description: 'Complete 7 days in a row',
          ),
        ],
      )));
      expect(find.text('Complete 7 days in a row'), findsOneWidget);
    });

    testWidgets('shows No description available when description absent', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'Mystery')],
      )));
      expect(find.text('No description available'), findsOneWidget);
    });

    testWidgets('shows default badge icon when badge_icon absent', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'No Icon')],
      )));
      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('shows custom badge icon', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'Star', badgeIcon: '⭐')],
      )));
      expect(find.text('⭐'), findsOneWidget);
    });

    testWidgets('shows check_circle icon for unlocked achievement (bool true)', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'Done', unlocked: true)],
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows lock_outline icon for locked achievement', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'Locked', unlocked: false)],
      )));
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('handles unlocked as string "true"', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'String True', unlocked: 'true')],
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('handles unlocked as int 1', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [_achievement(title: 'Int One', unlocked: 1)],
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders multiple achievements', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [
          _achievement(title: 'Achievement 1'),
          _achievement(title: 'Achievement 2'),
          _achievement(title: 'Achievement 3'),
        ],
      )));
      expect(find.text('Achievement 1'), findsOneWidget);
      expect(find.text('Achievement 2'), findsOneWidget);
      expect(find.text('Achievement 3'), findsOneWidget);
    });

    testWidgets('renders empty list without crashing', (tester) async {
      await tester.pumpWidget(_wrap(AchievementDetailScreen(
        achievements: [],
      )));
      expect(find.text('Achievements'), findsOneWidget);
    });
  });
}
