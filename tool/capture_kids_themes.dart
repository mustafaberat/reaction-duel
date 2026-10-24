/// Dino Pals design shots. Real screens, FakeClock + seeded RNG.
///
/// Run: `flutter test tool/capture_kids_themes.dart`
/// Out:
///   play/design-options/c/*.png — 375×667 logical @ dpr 2, Turkish
///   play/design-options/small/*.png — 320×568 home, how-to, duel, match end
///   play/locale-check/{lang}-NN.png — home, how-to, match end per locale
// ignore_for_file: invalid_use_of_visible_for_testing_member
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/screens/how_to_play_screen.dart';
import 'package:reaction_duel/screens/match_setup_screen.dart';
import 'package:reaction_duel/screens/settings_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:reaction_duel/theme/tap_burst.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ShotSize {
  const _ShotSize(this.logical);

  final Size logical;
  final double dpr = 2;
  final double statusBar = 20;
  final double homeIndicator = 0;

  Size get physical => Size(logical.width * dpr, logical.height * dpr);
}

const _se = _ShotSize(Size(375, 667));
const _tiny = _ShotSize(Size(320, 568));
const String _outRoot = 'play/design-options/c';
const String _outSmall = 'play/design-options/small';
const String _outLocale = 'play/locale-check';
const String _outRr18 = 'play/design-options/rr18';

/// ~250 ms into the 900 ms tap burst — dirt airborne, footprint readable.
const double _tapMid = 250 / 900;

const List<double> _howToKeyFrames = [0.3, 0.55, 0.52, 0.72, 0.3];
const List<String> _locales = [
  'de',
  'en',
  'es',
  'fr',
  'it',
  'ja',
  'ko',
  'pt',
  'tr',
  'zh',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture Dino Pals screens', (tester) async {
    await tester.runAsync(_loadFonts);
    PackageInfo.setMockInitialValues(
      appName: AppIdentity.appName,
      packageName: AppIdentity.packageId,
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      PrefsKeys.language: 'tr',
      PrefsKeys.onboardingDone: true,
      PrefsKeys.bestReactionMs: 187,
      PrefsKeys.totalMatches: 12,
    });
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    final stats = StatsService(prefs);
    final services = AppServices(settings: settings, stats: stats);

    await settings.setLanguage('tr');
    await _captureTheme(tester, services);
    await _captureSmall(tester, services);
    await _captureRr18(tester, services);
    await _captureLocales(tester, services);
  }, timeout: const Timeout(Duration(minutes: 16)));

  testWidgets('capture home preview sizes', (tester) async {
    await tester.runAsync(_loadFonts);
    PackageInfo.setMockInitialValues(
      appName: AppIdentity.appName,
      packageName: AppIdentity.packageId,
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      PrefsKeys.language: 'tr',
      PrefsKeys.onboardingDone: true,
      PrefsKeys.bestReactionMs: 187,
      PrefsKeys.totalMatches: 12,
    });
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    final stats = StatsService(prefs);
    final services = AppServices(settings: settings, stats: stats);
    await settings.setLanguage('tr');
    await _capture(
      tester,
      services,
      '$_outRoot/01-home.png',
      const HomeScreen(playLoopProgress: 0.84),
    );
    await _capture(
      tester,
      services,
      '$_outSmall/01-home.png',
      const HomeScreen(playLoopProgress: 0.84),
      size: _tiny,
    );
    await _capture(
      tester,
      services,
      '$_outRoot/16-home-play-loop.png',
      const HomeScreen(playLoopProgress: 0.46),
    );
    for (final shot in [
      ('home-wait', 0.08),
      ('home-go', 0.28),
      ('home-press', 0.46),
      ('home-result', 0.84),
    ]) {
      await _capture(
        tester,
        services,
        '$_outRoot/${shot.$1}.png',
        HomeScreen(playLoopProgress: shot.$2),
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  testWidgets('capture rr18 tap and match-end', (tester) async {
    await tester.runAsync(_loadFonts);
    PackageInfo.setMockInitialValues(
      appName: AppIdentity.appName,
      packageName: AppIdentity.packageId,
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      PrefsKeys.language: 'tr',
      PrefsKeys.onboardingDone: true,
      PrefsKeys.bestReactionMs: 187,
      PrefsKeys.totalMatches: 12,
    });
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    final stats = StatsService(prefs);
    final services = AppServices(settings: settings, stats: stats);
    await settings.setLanguage('tr');
    await _captureRr18(tester, services);
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _captureTheme(WidgetTester tester, AppServices services) async {
  const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  final targetConfig = classicConfig.copyWith(
    rules: const DuelSettings(
      mode: DuelMode.targetColor,
      target: SignalColor.blue,
    ),
  );

  Future<void> shot(String name, Widget home) async {
    await _capture(tester, services, '$_outRoot/$name.png', home);
  }

  await services.settings.setMatch(classicConfig);
  await shot('01-home', const HomeScreen(playLoopProgress: 0.84));
  await shot('home-wait', const HomeScreen(playLoopProgress: 0.08));
  await shot('home-go', const HomeScreen(playLoopProgress: 0.28));
  await shot('home-press', const HomeScreen(playLoopProgress: 0.46));
  await shot('home-result', const HomeScreen(playLoopProgress: 0.84));
  await shot('02-match-setup', const MatchSetupScreen());
  await shot('03-settings', const SettingsScreen());

  for (var i = 0; i < HowStep.values.length; i++) {
    await shot(
      '04-howto-step${i + 1}',
      HowToPlayScreen(
        initialStep: i,
        includeDecoyStep: true,
        frozenProgress: _howToKeyFrames[i],
      ),
    );
  }

  await shot('05-duel-ready', _duel(classicConfig, _Scene.ready));
  await shot('06-duel-waiting', _duel(classicConfig, _Scene.waiting));
  await shot('07-duel-go', _duel(classicConfig, _Scene.signal));
  await shot('08-duel-midtap', _duel(classicConfig, _Scene.midtap));
  await shot('09-duel-foul', _duel(classicConfig, _Scene.foul));
  await shot('10-duel-scored', _duel(classicConfig, _Scene.scored));
  await shot('11-duel-pause', _duel(classicConfig, _Scene.paused));

  Future<void> matchEnd(_Scene scene, String name) async {
    final engine = _engineFor(classicConfig, scene);
    await services.stats.recordMatch(engine.state);
    await shot(
      name,
      DuelScreen(
        config: classicConfig,
        engine: engine,
        driveTimers: false,
        showCoach: false,
      ),
    );
  }

  await matchEnd(_Scene.matchEnd, '12-match-end');
  await matchEnd(_Scene.matchEndBlue, '12-match-end-p2');

  await services.settings.setMatch(targetConfig);
  await shot('13-target-setup', const MatchSetupScreen());
  await shot('14-duel-decoy', _duel(targetConfig, _Scene.decoy));
  await services.settings.setMatch(classicConfig);
  await shot('15-duel-coach', _duel(classicConfig, _Scene.coach, coach: true));
  await shot('16-home-play-loop', const HomeScreen(playLoopProgress: 0.5));
}

Future<void> _captureSmall(WidgetTester tester, AppServices services) async {
  await services.settings.setLanguage('tr');
  const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  await services.settings.setMatch(classicConfig);

  Future<void> shot(String name, Widget home) async {
    await _capture(tester, services, '$_outSmall/$name.png', home, size: _tiny);
  }

  await shot('01-home', const HomeScreen(playLoopProgress: 0.84));

  for (var i = 0; i < HowStep.values.length; i++) {
    await shot(
      '04-howto-step${i + 1}',
      HowToPlayScreen(
        initialStep: i,
        includeDecoyStep: true,
        frozenProgress: _howToKeyFrames[i],
      ),
    );
  }

  await shot('05-duel-ready', _duel(classicConfig, _Scene.ready));
  await shot('06-duel-waiting', _duel(classicConfig, _Scene.waiting));
  await shot('07-duel-go', _duel(classicConfig, _Scene.signal));
  await shot('09-duel-foul', _duel(classicConfig, _Scene.foul));
  await shot('10-duel-scored', _duel(classicConfig, _Scene.scored));

  Future<void> matchEnd(_Scene scene, String name) async {
    final engine = _engineFor(classicConfig, scene);
    await services.stats.recordMatch(engine.state);
    await shot(
      name,
      DuelScreen(
        config: classicConfig,
        engine: engine,
        driveTimers: false,
        showCoach: false,
      ),
    );
  }

  await matchEnd(_Scene.matchEnd, '12-match-end');
  await matchEnd(_Scene.matchEndBlue, '12-match-end-p2');
}

Future<void> _captureRr18(WidgetTester tester, AppServices services) async {
  await services.settings.setLanguage('tr');
  const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  await services.settings.setMatch(classicConfig);

  Future<void> shot(String name, Widget home, {_ShotSize size = _se}) async {
    await _capture(tester, services, '$_outRr18/$name.png', home, size: size);
  }

  await shot(
    'tap-close',
    DuelScreen(
      config: classicConfig,
      engine: _engineFor(classicConfig, _Scene.midtap),
      driveTimers: false,
      showCoach: false,
      frozenBursts: const [
        (
          Player.p1,
          TapBurstSpec(
            dx: 0.34,
            dy: 0.68,
            progress: _tapMid,
            winning: true,
            player: Player.p1,
          ),
        ),
        (
          Player.p2,
          TapBurstSpec(
            dx: 0.62,
            dy: 0.66,
            progress: _tapMid,
            player: Player.p2,
          ),
        ),
      ],
    ),
  );
  await shot(
    'tap-green',
    DuelScreen(
      config: classicConfig,
      engine: _engineFor(classicConfig, _Scene.midtap),
      driveTimers: false,
      showCoach: false,
      frozenBursts: const [
        (
          Player.p1,
          TapBurstSpec(
            dx: 0.38,
            dy: 0.66,
            progress: _tapMid,
            winning: true,
            player: Player.p1,
          ),
        ),
      ],
    ),
  );
  await shot(
    'tap-blue',
    DuelScreen(
      config: classicConfig,
      engine: _engineFor(classicConfig, _Scene.midtap),
      driveTimers: false,
      showCoach: false,
      frozenBursts: const [
        (
          Player.p2,
          TapBurstSpec(
            dx: 0.4,
            dy: 0.64,
            progress: _tapMid,
            winning: true,
            player: Player.p2,
          ),
        ),
      ],
    ),
  );

  final endEngine = _engineFor(classicConfig, _Scene.matchEnd);
  await services.stats.recordMatch(endEngine.state);
  final end = DuelScreen(
    config: classicConfig,
    engine: endEngine,
    driveTimers: false,
    showCoach: false,
  );
  await shot('match-end', end);
  await shot('match-end-320', end, size: _tiny);

  final endBlue = _engineFor(classicConfig, _Scene.matchEndBlue);
  await services.stats.recordMatch(endBlue.state);
  final endBlueScreen = DuelScreen(
    config: classicConfig,
    engine: endBlue,
    driveTimers: false,
    showCoach: false,
  );
  await shot('match-end-blue', endBlueScreen);
  await shot('match-end-blue-320', endBlueScreen, size: _tiny);
}

Future<void> _captureLocales(WidgetTester tester, AppServices services) async {
  const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  await services.settings.setMatch(classicConfig);
  for (final lang in _locales) {
    await services.settings.setLanguage(lang);
    tester.platformDispatcher.localeTestValue = Locale(lang);

    await _capture(
      tester,
      services,
      '$_outLocale/$lang-01.png',
      const HomeScreen(playLoopProgress: 0.84),
    );
    await _capture(
      tester,
      services,
      '$_outLocale/$lang-02.png',
      const HowToPlayScreen(
        initialStep: 0,
        includeDecoyStep: true,
        frozenProgress: 0.3,
      ),
    );
    final endEngine = _engineFor(classicConfig, _Scene.matchEnd);
    await services.stats.recordMatch(endEngine.state);
    await _capture(
      tester,
      services,
      '$_outLocale/$lang-03.png',
      DuelScreen(
        config: classicConfig,
        engine: endEngine,
        driveTimers: false,
        showCoach: false,
      ),
    );
  }
  tester.platformDispatcher.clearLocaleTestValue();
}

enum _Scene {
  ready,
  waiting,
  signal,
  midtap,
  foul,
  scored,
  decoy,
  matchEnd,
  matchEndBlue,
  paused,
  coach,
}

Widget _duel(MatchConfig config, _Scene scene, {bool coach = false}) {
  return DuelScreen(
    config: config,
    engine: _engineFor(config, scene),
    driveTimers: false,
    showCoach: coach,
    frozenBursts: scene == _Scene.midtap
        ? const [
            (
              Player.p1,
              TapBurstSpec(
                dx: 0.3,
                dy: 0.62,
                progress: 0.38,
                winning: true,
                player: Player.p1,
              ),
            ),
            (
              Player.p1,
              TapBurstSpec(
                dx: 0.58,
                dy: 0.5,
                progress: 0.22,
                winning: true,
                player: Player.p1,
              ),
            ),
            (
              Player.p2,
              TapBurstSpec(dx: 0.4, dy: 0.6, progress: 0.48, player: Player.p2),
            ),
          ]
        : const [],
  );
}

DuelEngine _engineFor(MatchConfig config, _Scene scene) {
  final clock = FakeClock();
  final engine = DuelEngine(
    clock: clock,
    rng: SeededRng(scene == _Scene.decoy ? 4 : 21),
    settings: config.rules,
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

  if (scene == _Scene.coach) {
    runTo(DuelPhase.waiting);
    return engine;
  }

  if (scene == _Scene.ready) {
    return engine;
  }

  // 1–1 baseline, then a third point so mid-tap shows a leader.
  win(Player.p1, 231, 284);
  win(Player.p2, 268, 305);

  switch (scene) {
    case _Scene.ready:
      break;
    case _Scene.waiting:
      runTo(DuelPhase.waiting);
    case _Scene.signal:
      runTo(DuelPhase.signal);
    case _Scene.midtap:
      win(Player.p1, 198, 276);
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
    case _Scene.matchEndBlue:
      win(Player.p2, 219, 251);
      win(Player.p2, 204, 262);
    case _Scene.paused:
      win(Player.p1, 226, 290);
      runTo(DuelPhase.waiting);
      engine.pause();
    case _Scene.coach:
      break;
  }
  return engine;
}

Future<void> _capture(
  WidgetTester tester,
  AppServices services,
  String path,
  Widget home, {
  _ShotSize size = _se,
}) async {
  tester.view.physicalSize = size.physical;
  tester.view.devicePixelRatio = size.dpr;
  tester.view.padding = FakeViewPadding(
    top: size.statusBar * size.dpr,
    bottom: size.homeIndicator * size.dpr,
  );
  tester.view.viewPadding = tester.view.padding;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: ReactionDuelApp(services: services, home: home),
    ),
  );
  for (var i = 0; i < 16; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
  await tester.pump(const Duration(milliseconds: 60));

  final bytes = await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: size.dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      bytes(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ),
    );
  await icons.load();

  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(bytes('assets/fonts/$f'));
    }
    await loader.load();
  }

  await family('Baloo2', ['Baloo2-Bold.ttf', 'Baloo2-ExtraBold.ttf']);
  await family('Nunito', [
    'Nunito-Regular.ttf',
    'Nunito-SemiBold.ttf',
    'Nunito-Bold.ttf',
  ]);
  await family('ZenMaruGothic', ['ZenMaruGothic-Bold.ttf']);
  await family('Jua', ['Jua-Regular.ttf']);
  await family('ZCOOLKuaiLe', ['ZCOOLKuaiLe-Regular.ttf']);
}
