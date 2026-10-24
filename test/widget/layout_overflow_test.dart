import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/engine/clock.dart';
import 'package:reaction_duel/engine/duel_engine.dart';
import 'package:reaction_duel/engine/duel_settings.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/engine/rng.dart';
import 'package:reaction_duel/engine/signal_palette.dart';
import 'package:reaction_duel/game/duel_screen.dart';
import 'package:reaction_duel/l10n/app_localizations.dart';
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/screens/how_to_play_screen.dart';
import 'package:reaction_duel/screens/match_setup_screen.dart';
import 'package:reaction_duel/screens/settings_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _services({String language = 'tr'}) async {
  SharedPreferences.setMockInitialValues({
    PrefsKeys.language: language,
    PrefsKeys.onboardingDone: true,
    PrefsKeys.bestReactionMs: 187,
    PrefsKeys.totalMatches: 12,
  });
  PackageInfo.setMockInitialValues(
    appName: AppIdentity.appName,
    packageName: AppIdentity.packageId,
    version: '0.1.0',
    buildNumber: '1',
    buildSignature: '',
  );
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
  WidgetTester tester,
  AppServices services,
  Widget home,
) async {
  await tester.pumpWidget(ReactionDuelApp(services: services, home: home));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

enum _Scene { ready, waiting, signal, foul, scored, decoy, matchEnd, paused }

DuelEngine _engine(_Scene scene) {
  final clock = FakeClock();
  final target = scene == _Scene.decoy;
  final engine = DuelEngine(
    clock: clock,
    rng: SeededRng(target ? 4 : 21),
    settings: target
        ? const DuelSettings(
            mode: DuelMode.targetColor,
            target: SignalColor.blue,
          )
        : const DuelSettings(),
  )..start();

  void runTo(DuelPhase phase) {
    for (var i = 0; i < 40 && engine.state.phase != phase; i++) {
      final deadline = engine.nextDeadline;
      if (deadline == null) return;
      clock.set(deadline);
      engine.tick();
    }
  }

  void win(Player p, int ms, int otherMs) {
    runTo(DuelPhase.signal);
    final s = engine.state.signalAt!;
    engine.tap(p, at: s + Duration(milliseconds: ms));
    engine.tap(p.other, at: s + Duration(milliseconds: otherMs));
  }

  if (scene == _Scene.ready) return engine;
  win(Player.p1, 231, 284);
  win(Player.p2, 268, 305);
  switch (scene) {
    case _Scene.ready:
      break;
    case _Scene.waiting:
      runTo(DuelPhase.waiting);
    case _Scene.signal:
      runTo(DuelPhase.signal);
    case _Scene.foul:
      runTo(DuelPhase.waiting);
      engine.tap(Player.p1);
    case _Scene.scored:
      win(Player.p1, 243, 298);
    case _Scene.decoy:
      for (var i = 0; i < 20; i++) {
        runTo(DuelPhase.waiting);
        if (engine.plannedDecoys.isNotEmpty) break;
        runTo(DuelPhase.noContest);
      }
      runTo(DuelPhase.decoy);
    case _Scene.matchEnd:
      runTo(DuelPhase.waiting);
      engine.tap(Player.p2);
      win(Player.p1, 219, 251);
      win(Player.p1, 204, 262);
    case _Scene.paused:
      win(Player.p1, 226, 290);
      runTo(DuelPhase.waiting);
      engine.pause();
  }
  return engine;
}

Widget _duel(_Scene scene) {
  const config = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  return DuelScreen(
    config: scene == _Scene.decoy
        ? config.copyWith(
            rules: const DuelSettings(
              mode: DuelMode.targetColor,
              target: SignalColor.blue,
            ),
          )
        : config,
    engine: _engine(scene),
    driveTimers: false,
    showCoach: false,
  );
}

void main() {
  const phones = [
    Size(320, 568),
    Size(360, 640),
    Size(375, 667),
    Size(390, 844),
    Size(412, 915),
    Size(768, 1024),
  ];

  for (final size in phones) {
    group('${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('home', (tester) async {
        _size(tester, size);
        await _pump(
          tester,
          await _services(),
          const HomeScreen(playLoopProgress: 0.84),
        );
      });

      testWidgets('settings', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), const SettingsScreen());
      });

      testWidgets('how-to', (tester) async {
        _size(tester, size);
        await _pump(
          tester,
          await _services(),
          const HowToPlayScreen(
            initialStep: 0,
            includeDecoyStep: true,
            frozenProgress: 0.3,
          ),
        );
        if (size.width <= 375 && size.height <= 667) {
          for (final label in ['Atla', 'İleri']) {
            final finder = find.text(label);
            expect(finder, findsOneWidget);
            expect(
              tester.getSize(finder).height,
              greaterThanOrEqualTo(14),
              reason: '$label readable at ${size.width}x${size.height}',
            );
          }
        }
      });

      testWidgets('setup', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), const MatchSetupScreen());
      });

      testWidgets('duel ready', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.ready));
      });

      testWidgets('duel waiting', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.waiting));
      });

      testWidgets('duel signal', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.signal));
      });

      testWidgets('duel foul', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.foul));
      });

      testWidgets('duel scored', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.scored));
      });

      testWidgets('duel pause', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.paused));
      });

      testWidgets('match end', (tester) async {
        _size(tester, size);
        await _pump(tester, await _services(), _duel(_Scene.matchEnd));
        final score = find.text('3 – 1');
        expect(score, findsOneWidget);
        expect(tester.getSize(score).height, greaterThanOrEqualTo(24));
        expect(find.text('En iyi'), findsOneWidget);
        expect(find.text('Ortalama'), findsOneWidget);
        expect(find.text('Faul'), findsOneWidget);
        expect(find.text('Seri'), findsOneWidget);
        expect(find.text('Rövanş'), findsOneWidget);
        expect(find.text('Ayarları değiştir'), findsOneWidget);
        expect(find.text('Ana sayfa'), findsOneWidget);
      });
    });
  }

  for (final size in const [Size(320, 568), Size(375, 667)]) {
    testWidgets('how-to last-step labels readable at ${size.width.toInt()}', (
      tester,
    ) async {
      _size(tester, size);
      await _pump(
        tester,
        await _services(),
        const HowToPlayScreen(
          initialStep: 4,
          includeDecoyStep: true,
          frozenProgress: 0.3,
        ),
      );
      for (final label in ['Kapat', 'Şimdi oyna']) {
        final finder = find.text(label);
        expect(finder, findsOneWidget);
        expect(
          tester.getSize(finder).height,
          greaterThanOrEqualTo(14),
          reason: '$label readable at ${size.width}x${size.height}',
        );
      }
    });
  }

  testWidgets('match end stats stay on screen at 375', (tester) async {
    _size(tester, const Size(375, 667));
    await _pump(tester, await _services(), _duel(_Scene.matchEnd));
    final screen = tester.getRect(find.byType(DuelScreen));
    final rematch = find.text('Rövanş');
    expect(rematch, findsOneWidget);
    final rematchTop = tester.getRect(rematch).top;
    for (final label in ['En iyi', 'Ortalama', 'Faul', 'Seri']) {
      final finder = find.text(label);
      expect(finder, findsOneWidget);
      final rect = tester.getRect(finder);
      expect(rect.height, greaterThan(10), reason: '$label stayed readable');
      expect(rect.bottom, lessThanOrEqualTo(rematchTop));
      expect(rect.top, greaterThanOrEqualTo(screen.top));
    }
  });

  for (final lang in ['de', 'fr', 'pt']) {
    testWidgets('long locale $lang at 320', (tester) async {
      _size(tester, const Size(320, 568));
      tester.platformDispatcher.localeTestValue = Locale(lang);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final services = await _services(language: lang);
      await _pump(tester, services, const HomeScreen(playLoopProgress: 0.84));
      await _pump(
        tester,
        services,
        const HowToPlayScreen(
          initialStep: 0,
          includeDecoyStep: true,
          frozenProgress: 0.3,
        ),
      );
      await _pump(tester, services, _duel(_Scene.matchEnd));
      expect(find.text('Play'), findsNothing);
      expect(find.text('3 – 1'), findsOneWidget);
    });
  }

  testWidgets('locale switch renders own strings', (tester) async {
    _size(tester, const Size(375, 667));
    final services = await _services(language: 'en');
    await _pump(tester, services, const HomeScreen(playLoopProgress: 0.84));
    expect(find.text('Play'), findsOneWidget);

    await services.settings.setLanguage('de');
    tester.platformDispatcher.localeTestValue = const Locale('de');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpAndSettle();
    expect(find.text('Spielen'), findsOneWidget);
    expect(find.text('Play'), findsNothing);

    await services.settings.setLanguage('ja');
    tester.platformDispatcher.localeTestValue = const Locale('ja');
    await tester.pumpAndSettle();
    expect(find.text('プレイ'), findsOneWidget);

    await services.settings.setLanguage('zh');
    tester.platformDispatcher.localeTestValue = const Locale('zh');
    await tester.pumpAndSettle();
    expect(find.text('开始'), findsWidgets);
  });

  testWidgets('home renders bannerOverride in the bottom slot', (tester) async {
    _size(tester, const Size(375, 667));
    const banner = SizedBox(
      key: ValueKey<String>('banner-override'),
      width: 320,
      height: 50,
    );
    await _pump(
      tester,
      await _services(),
      const HomeScreen(playLoopProgress: 0.84, bannerOverride: banner),
    );

    expect(
      find.byKey(const ValueKey<String>('banner-override')),
      findsOneWidget,
    );
    final slot = tester.getRect(
      find.byKey(const ValueKey<String>('banner-override')),
    );
    final home = tester.getRect(find.byType(HomeScreen));
    expect(slot.width, 320);
    expect(slot.height, 50);
    expect(slot.bottom, closeTo(home.bottom, 0.5));

    final play = tester.getRect(find.text('Oyna'));
    expect(slot.top, greaterThan(play.bottom));
    final settings = tester.getRect(find.text('Ayarlar'));
    expect(slot.top, greaterThan(settings.bottom));
  });

  testWidgets('_HomeBanner renders nothing when no ad is loaded', (
    tester,
  ) async {
    _size(tester, const Size(375, 667));
    final services = await _services();
    expect(services.ads.banner.value, isNull);
    await _pump(tester, services, const HomeScreen(playLoopProgress: 0.84));
    expect(find.byType(AdWidget), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('home-banner'))),
      Size.zero,
    );
  });

  const banner = SizedBox(
    key: ValueKey<String>('banner-override'),
    width: 320,
    height: 50,
  );
  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in const [Size(320, 568), Size(375, 667)]) {
      final label =
          '${locale.languageCode} ${size.width.toInt()}x${size.height.toInt()}';
      testWidgets('home $label with 320x50 banner does not overflow', (
        tester,
      ) async {
        _size(tester, size);
        tester.platformDispatcher.localeTestValue = locale;
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        await _pump(
          tester,
          await _services(language: locale.languageCode),
          const HomeScreen(playLoopProgress: 0.84, bannerOverride: banner),
        );
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('banner-override')),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byKey(const ValueKey<String>('banner-override'))),
          const Size(320, 50),
        );
      });
    }
  }
}
