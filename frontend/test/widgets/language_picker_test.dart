// Tests for LanguagePicker
// (lib/widgets/language/language_picker.dart).
//
// The show() method opens a bottom sheet and requires a live BuildContext
// with a LocaleProvider — tested separately below.
// The labelFor() method is a pure static function, fully testable here.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/widgets/language/language_picker.dart';
import 'package:care_connect_app/providers/locale_provider.dart';
import 'package:care_connect_app/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  // ──────────────────────────────────────────────────────────────
  // LanguagePicker.labelFor — pure static function
  // ──────────────────────────────────────────────────────────────

  group('LanguagePicker.labelFor', () {
    test('returns English for en locale', () {
      expect(LanguagePicker.labelFor(const Locale('en')), 'English');
    });

    test('returns Spanish label for es locale', () {
      expect(LanguagePicker.labelFor(const Locale('es')), contains('Spanish'));
    });

    test('returns French label for fr locale', () {
      expect(LanguagePicker.labelFor(const Locale('fr')), contains('French'));
    });

    test('returns Urdu label for ur locale', () {
      expect(LanguagePicker.labelFor(const Locale('ur')), contains('Urdu'));
    });

    test('returns Arabic label for ar locale', () {
      expect(LanguagePicker.labelFor(const Locale('ar')), contains('Arabic'));
    });

    test('returns Amharic label for am locale', () {
      expect(LanguagePicker.labelFor(const Locale('am')), contains('Amharic'));
    });

    test('returns Nepali label for ne locale', () {
      expect(LanguagePicker.labelFor(const Locale('ne')), contains('Nepali'));
    });

    test('returns Hindi label for hi locale', () {
      expect(LanguagePicker.labelFor(const Locale('hi')), contains('Hindi'));
    });

    test('returns Farsi label for fa locale', () {
      expect(LanguagePicker.labelFor(const Locale('fa')), contains('Farsi'));
    });

    test('returns Chinese label for zh locale', () {
      expect(LanguagePicker.labelFor(const Locale('zh')), contains('Chinese'));
    });

    test('returns Portuguese label for pt locale', () {
      expect(LanguagePicker.labelFor(const Locale('pt')), contains('Portuguese'));
    });

    test('returns Bengali label for bn locale', () {
      expect(LanguagePicker.labelFor(const Locale('bn')), contains('Bengali'));
    });

    test('returns Russian label for ru locale', () {
      expect(LanguagePicker.labelFor(const Locale('ru')), contains('Russian'));
    });

    test('returns Japanese label for ja locale', () {
      expect(LanguagePicker.labelFor(const Locale('ja')), contains('Japanese'));
    });

    test('falls back to language tag for unknown locale', () {
      // Verifies that an unknown locale returns its language tag string.
      final locale = const Locale('xx');
      expect(LanguagePicker.labelFor(locale), locale.toLanguageTag());
    });
  });

  // ──────────────────────────────────────────────────────────────
  // LanguagePicker.show — widget test (bottom sheet content)
  // ──────────────────────────────────────────────────────────────

  group('LanguagePicker.show', () {
    testWidgets('opens a bottom sheet with a ListView', (tester) async {
      // Verifies that show() renders a bottom sheet containing a ListView.
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => LanguagePicker.show(ctx),
            child: const Text('Open'),
          );
        }),
      ));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('bottom sheet contains System Default option', (tester) async {
      // Verifies that the "System default" item is shown in the picker.
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => LanguagePicker.show(ctx),
            child: const Text('Open'),
          );
        }),
      ));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The first item is the "System default" tile.
      expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
    });

    testWidgets('bottom sheet contains translate icon for locales', (tester) async {
      // Verifies that locale items use the translate icon.
      await tester.pumpWidget(_wrap(
        Builder(builder: (ctx) {
          return ElevatedButton(
            onPressed: () => LanguagePicker.show(ctx),
            child: const Text('Open'),
          );
        }),
      ));
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // There should be at least one translate icon (one per supported locale).
      expect(find.byIcon(Icons.translate), findsWidgets);
    });
  });
}
