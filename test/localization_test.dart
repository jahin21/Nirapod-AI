import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nirapod_ai/services/app_translations.dart';
import 'package:nirapod_ai/services/language_controller.dart';
import 'package:nirapod_ai/widgets/localized_text.dart';

void main() {
  tearDown(() => AppLanguageController.language.value = 'en');

  test('every centralized string has Malay and Bangla text', () {
    for (final entry in additionalTranslations.entries) {
      expect(entry.value['ms']?.trim(), isNotEmpty, reason: entry.key);
      expect(entry.value['bn']?.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('dynamic labels do not expose interpolation syntax', () {
    AppLanguageController.language.value = 'ms';
    final malay = AppLanguageController.translate(
      'Repeat Wi-Fi Inspection (4)',
    );
    expect(malay, contains('4'), reason: malay);
    expect(malay, isNot(contains(r'${')), reason: malay);

    AppLanguageController.language.value = 'bn';
    final bangla = AppLanguageController.translate(
      'Repeat Bluetooth Inspection (3)',
    );
    expect(bangla, contains('3'), reason: bangla);
    expect(bangla, isNot(contains(r'${')), reason: bangla);
    expect(bangla.runes.any((rune) => rune >= 0x0980 && rune <= 0x09ff), isTrue,
        reason: bangla);
  });

  testWidgets('mounted labels update immediately when language changes',
      (tester) async {
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: AppLanguageController.language,
        builder: (context, child) => MaterialApp(
          locale: AppLanguageController.locale,
          supportedLocales: AppLanguageController.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(body: LocalizedText('Profile')),
        ),
      ),
    );
    expect(find.text('Profile'), findsOneWidget);

    AppLanguageController.language.value = 'bn';
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data!.runes.any((rune) => rune >= 0x0980 && rune <= 0x09ff),
      ),
      findsOneWidget,
    );
  });
}
