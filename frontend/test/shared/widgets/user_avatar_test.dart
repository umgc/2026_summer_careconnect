// Tests for UserAvatar widget
// (lib/shared/widgets/user_avatar.dart)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/shared/widgets/user_avatar.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('UserAvatar', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('shows person icon when imageUrl is null', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows person icon when imageUrl is empty string', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: '')));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows CircleAvatar widget', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('uses default radius of 20', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null)));
      final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
      expect(avatar.radius, 20);
    });

    testWidgets('uses custom radius', (tester) async {
      await tester.pumpWidget(_wrap(const UserAvatar(imageUrl: null, radius: 35)));
      final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
      expect(avatar.radius, 35);
    });
  });

  group('UserAvatar – with imageUrl (URL resolution)', () {
    testWidgets('renders CircleAvatar with backgroundImage for full https URL', (tester) async {
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('NetworkImage') ||
            details.toString().contains('HTTP') ||
            details.toString().contains('Connection')) { return; }
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(_wrap(
        const UserAvatar(imageUrl: 'https://example.com/avatar.png'),
      ));
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isA<NetworkImage>());
      final networkImage = avatar.backgroundImage as NetworkImage;
      expect(networkImage.url, 'https://example.com/avatar.png');
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('prepends base URL for relative path', (tester) async {
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('NetworkImage') ||
            details.toString().contains('HTTP') ||
            details.toString().contains('Connection')) { return; }
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(_wrap(
        const UserAvatar(imageUrl: '/uploads/avatar.png'),
      ));
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isA<NetworkImage>());
      final networkImage = avatar.backgroundImage as NetworkImage;
      expect(networkImage.url, contains('/uploads/avatar.png'));
      expect(networkImage.url, isNot('/uploads/avatar.png'));
    });

    testWidgets('uses http:// URL as-is', (tester) async {
      final origOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.toString().contains('NetworkImage') ||
            details.toString().contains('HTTP') ||
            details.toString().contains('Connection')) { return; }
        origOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = origOnError);

      await tester.pumpWidget(_wrap(
        const UserAvatar(imageUrl: 'http://localhost:8080/img.jpg'),
      ));
      await tester.pump();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      final networkImage = avatar.backgroundImage as NetworkImage;
      expect(networkImage.url, 'http://localhost:8080/img.jpg');
    });
  });
}
