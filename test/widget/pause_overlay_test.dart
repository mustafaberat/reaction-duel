import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/config/tokens.dart';
import 'package:reaction_duel/game/pause_overlay.dart';
import 'package:reaction_duel/l10n/app_localizations.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:reaction_duel/theme/dino_art.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _services({String language = 'tr'}) async {
  SharedPreferences.setMockInitialValues({PrefsKeys.language: language});
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsService(prefs);
  await settings.setLanguage(language);
  return AppServices(settings: settings, stats: StatsService(prefs));
}

void _size(WidgetTester tester, Size logical) {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(logical.width * dpr, logical.height * dpr);
  tester.view.padding = FakeViewPadding(top: 20 * dpr);
  tester.view.viewPadding = tester.view.padding;
  addTearDown(tester.view.reset);
}

Future<void> _pump(
  WidgetTester tester, {
  required AppServices services,
  required PauseOverlay home,
  String language = 'tr',
}) async {
  tester.platformDispatcher.localeTestValue = Locale(language);
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  await tester.pumpWidget(ReactionDuelApp(services: services, home: home));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

PauseOverlay _overlay({
  VoidCallback? onResume,
  VoidCallback? onRestart,
  VoidCallback? onHome,
  bool reduceMotion = false,
  double? frozenProgress,
}) {
  return PauseOverlay(
    onResume: onResume ?? () {},
    onRestart: onRestart ?? () {},
    onHome: onHome ?? () {},
    reduceMotion: reduceMotion,
    frozenProgress: frozenProgress,
  );
}

List<DinoPainter> _painters(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((w) => w.painter)
      .whereType<DinoPainter>()
      .toList();
}

void main() {
  testWidgets('pause is a single centred card with both sleepy dinos', (
    tester,
  ) async {
    _size(tester, const Size(375, 667));
    await _pump(
      tester,
      services: await _services(),
      home: _overlay(reduceMotion: true),
    );

    expect(find.byKey(const ValueKey('pause-card')), findsOneWidget);
    expect(find.byType(RotatedBox), findsNothing);
    expect(find.text('Duraklatıldı'), findsOneWidget);
    expect(find.byType(DinoArt), findsNWidgets(2));

    final paints = _painters(tester);
    expect(paints, hasLength(2));
    expect(paints.every((p) => p.mood == CharacterMood.sleepy), isTrue);
    expect(
      paints.map((p) => p.kind),
      containsAll([DinoKind.trex, DinoKind.tri]),
    );
    expect(
      paints.singleWhere((p) => p.kind == DinoKind.trex).palette.body,
      DinoPalette.trex.body,
    );
    expect(
      paints.singleWhere((p) => p.kind == DinoKind.tri).palette.body,
      DinoPalette.tri.body,
    );
    expect(find.text('Z'), findsNWidgets(2));
  });

  testWidgets('resume, restart and home exist once and fire', (tester) async {
    _size(tester, const Size(375, 667));
    var resume = 0;
    var restart = 0;
    var home = 0;
    await _pump(
      tester,
      services: await _services(),
      home: _overlay(
        onResume: () => resume++,
        onRestart: () => restart++,
        onHome: () => home++,
        reduceMotion: true,
      ),
    );

    expect(find.text('Devam'), findsOneWidget);
    expect(find.text('Yeniden başlat'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsOneWidget);

    await tester.tap(find.text('Devam'));
    await tester.pump();
    expect(resume, 1);
    expect(restart, 0);
    expect(home, 0);

    await tester.tap(find.text('Yeniden başlat'));
    await tester.pump();
    expect(restart, 1);

    await tester.tap(find.text('Ana sayfa'));
    await tester.pump();
    expect(home, 1);
  });

  testWidgets('reduce motion keeps sleepy dinos and static Zzz', (
    tester,
  ) async {
    _size(tester, const Size(375, 667));
    await _pump(
      tester,
      services: await _services(),
      home: _overlay(reduceMotion: true),
    );
    final before = _painters(tester);
    expect(before.every((p) => p.mood == CharacterMood.sleepy), isTrue);
    expect(find.text('Z'), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
    final after = _painters(tester);
    expect(after.every((p) => p.mood == CharacterMood.sleepy), isTrue);
    expect(find.text('Z'), findsNWidgets(2));
  });

  for (final size in const [Size(320, 568), Size(375, 667)]) {
    for (final locale in AppLocalizations.supportedLocales) {
      final lang = locale.languageCode;
      testWidgets(
        'no overflow at ${size.width.toInt()}x${size.height.toInt()} for $lang',
        (tester) async {
          _size(tester, size);
          final services = await _services(language: lang);
          await _pump(
            tester,
            services: services,
            language: lang,
            home: _overlay(reduceMotion: true),
          );
          expect(find.byKey(const ValueKey('pause-card')), findsOneWidget);
          expect(find.byType(DinoArt), findsNWidgets(2));
          expect(
            _painters(tester).every((p) => p.mood == CharacterMood.sleepy),
            isTrue,
          );
          expect(find.byType(RotatedBox), findsNothing);
        },
      );
    }
  }
}
