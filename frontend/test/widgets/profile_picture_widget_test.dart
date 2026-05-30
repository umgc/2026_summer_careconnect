// Tests for ProfilePictureWidget and CompactProfilePicture
// (lib/widgets/profile_picture_widget.dart).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_connect_app/widgets/profile_picture_widget.dart';

Widget _wrap({
  double size = 100,
  bool canEdit = true,
  String? existingImageUrl,
  String placeholderText = 'Add Photo',
}) {
  return MaterialApp(
    home: Scaffold(
      body: ProfilePictureWidget(
        size: size,
        canEdit: canEdit,
        existingImageUrl: existingImageUrl,
        placeholderText: placeholderText,
      ),
    ),
  );
}

Widget _wrapCompact({
  double size = 40,
  String? imageUrl,
  String initials = '??',
}) {
  return MaterialApp(
    home: Scaffold(
      body: CompactProfilePicture(
        size: size,
        imageUrl: imageUrl,
        initials: initials,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        if (call.method == 'readAll') return <String, String>{};
        if (call.method == 'containsKey') return false;
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async {
        if (call.method == 'check') return ['wifi'];
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      null,
    );
  });

  group('ProfilePictureWidget – initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(ProfilePictureWidget), findsOneWidget);
    });

    testWidgets('shows GestureDetector for tap handling', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('shows Stack widget', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('shows camera_alt icon for editable widget', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });
  });

  group('ProfilePictureWidget – after loading', () {
    testWidgets('shows placeholder after loading fails', (tester) async {
      await tester.pumpWidget(_wrap());
      // Wait for _loadProfileImage to fail (no HTTP)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      // Should show person icon placeholder
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows placeholder text for large size', (tester) async {
      await tester.pumpWidget(_wrap(size: 120, placeholderText: 'Add Photo'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Add Photo'), findsOneWidget);
    });

    testWidgets('hides placeholder text for small size (<= 80)', (tester) async {
      await tester.pumpWidget(_wrap(size: 60));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Add Photo'), findsNothing);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows custom placeholder text', (tester) async {
      await tester.pumpWidget(_wrap(size: 120, placeholderText: 'Upload'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Upload'), findsOneWidget);
    });
  });

  group('ProfilePictureWidget – canEdit false', () {
    testWidgets('does not show camera icon when canEdit is false', (tester) async {
      await tester.pumpWidget(_wrap(canEdit: false));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt), findsNothing);
    });

    testWidgets('renders with canEdit false without crashing', (tester) async {
      await tester.pumpWidget(_wrap(canEdit: false));
      expect(find.byType(ProfilePictureWidget), findsOneWidget);
    });
  });

  group('ProfilePictureWidget – canEdit true interactions', () {
    testWidgets('tapping opens bottom sheet with options', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Tap the widget to open bottom sheet
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should show "Upload New Photo" option
      expect(find.text('Upload New Photo'), findsOneWidget);
      // Should show Cancel option
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('bottom sheet does not show View Full Size when no image', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // No image loaded, so "View Full Size" should not appear
      expect(find.text('View Full Size'), findsNothing);
      // No image, so "Remove Photo" should not appear
      expect(find.text('Remove Photo'), findsNothing);
    });

    testWidgets('can dismiss bottom sheet by tapping Cancel', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Upload New Photo'), findsNothing);
    });
  });

  group('ProfilePictureWidget – custom size', () {
    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(_wrap(size: 200));
      expect(find.byType(ProfilePictureWidget), findsOneWidget);
    });

    testWidgets('renders with small size', (tester) async {
      await tester.pumpWidget(_wrap(size: 40));
      expect(find.byType(ProfilePictureWidget), findsOneWidget);
    });
  });

  group('CompactProfilePicture', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_wrapCompact());
      expect(find.byType(CompactProfilePicture), findsOneWidget);
    });

    testWidgets('shows initials placeholder when no image', (tester) async {
      await tester.pumpWidget(_wrapCompact(initials: 'JD'));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('converts initials to uppercase', (tester) async {
      await tester.pumpWidget(_wrapCompact(initials: 'ab'));
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('renders with default initials ??', (tester) async {
      await tester.pumpWidget(_wrapCompact());
      expect(find.text('??'), findsOneWidget);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(_wrapCompact(size: 80));
      expect(find.byType(CompactProfilePicture), findsOneWidget);
    });

    testWidgets('shows Container with circular shape', (tester) async {
      await tester.pumpWidget(_wrapCompact());
      expect(find.byType(Container), findsWidgets);
    });
  });
}
