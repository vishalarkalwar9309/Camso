import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:camso_mobile/core/localization/app_strings.dart';
import 'package:camso_mobile/screens/language_screen.dart';
import 'package:camso_mobile/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Localization & AppState Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Normalizes valid languages and falls back gracefully for invalid codes', () {
      expect(AppState.normalizeLanguage('en'), 'en');
      expect(AppState.normalizeLanguage('fr'), 'fr');
      expect(AppState.normalizeLanguage('de'), 'de');
      expect(AppState.normalizeLanguage('it'), 'it');

      // Locale tags with region
      expect(AppState.normalizeLanguage('fr-FR'), 'fr');
      expect(AppState.normalizeLanguage('de_DE'), 'de');
      expect(AppState.normalizeLanguage('EN-US'), 'en');

      // Invalid / edge cases
      expect(AppState.normalizeLanguage(null), 'en');
      expect(AppState.normalizeLanguage(''), 'en');
      expect(AppState.normalizeLanguage('es'), 'en');
      expect(AppState.normalizeLanguage('unknown_LANG'), 'en');
    });

    test('AppStrings translates keys correctly across supported languages', () {
      // English
      expect(AppStrings.tr('nav_home', 'en'), 'Home');
      expect(AppStrings.tr('prof_language', 'en'), 'Language');

      // French
      expect(AppStrings.tr('nav_home', 'fr'), 'Accueil');
      expect(AppStrings.tr('prof_language', 'fr'), 'Langue');

      // German
      expect(AppStrings.tr('nav_home', 'de'), 'Startseite');
      expect(AppStrings.tr('prof_language', 'de'), 'Sprache');

      // Italian
      expect(AppStrings.tr('nav_home', 'it'), 'Home');
      expect(AppStrings.tr('prof_language', 'it'), 'Lingua');

      // Missing translation fallback to English or key
      expect(AppStrings.tr('non_existent_key_12345', 'fr'), 'non_existent_key_12345');
    });

    test('AppState setLanguage updates active language and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();

      expect(appState.language, 'en');
      expect(appState.tr('nav_home'), 'Home');

      // Switch to French
      appState.setLanguage('fr');
      expect(appState.language, 'fr');
      expect(appState.tr('nav_home'), 'Accueil');

      // Wait a moment for async SharedPreferences write
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppState.languageKey), 'fr');

      // Switching to invalid language normalizes to 'en'
      appState.setLanguage('invalid_lang');
      expect(appState.language, 'en');
      expect(appState.tr('nav_home'), 'Home');
    });

    testWidgets('LanguageScreen renders safely and switches language on tap without white screen', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: LanguageScreen(),
          ),
        ),
      );

      // Verify screen renders with language options
      expect(find.text('LANGUAGE'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('French'), findsOneWidget);
      expect(find.text('German'), findsOneWidget);
      expect(find.text('Italian'), findsOneWidget);

      // Tap French
      await tester.tap(find.text('French'));
      await tester.pumpAndSettle();

      // Verify AppState updated to 'fr'
      expect(appState.language, 'fr');
      expect(appState.tr('nav_home'), 'Accueil');

      // Header updates dynamically via state.tr('header_language')
      expect(find.text('LANGUE'), findsOneWidget);

      // Verify session is preserved (user is not logged out)
      expect(appState.session, isNotNull);
    });
  });
}
