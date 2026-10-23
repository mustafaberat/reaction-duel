/// Dino Pals design shots. Real screens, FakeClock + seeded RNG.
///
/// Run: `flutter test tool/capture_kids_themes.dart`
/// Out: play/design-options/c/*.png — 1080×2340, Turkish locale.
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

const Size _physical = Size(1080, 2340);
const double _dpr = 2.75;
const double _statusBar = 28;
const double _homeIndicator = 18;
const String _outRoot = 'play/design-options/c';

const List<double> _howToKeyFrames = [0.3, 0.55, 0.52, 0.72, 0.3];

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

    await _captureTheme(tester);
  }, timeout: const Timeout(Duration(minutes: 8)));
}

Future<void> _captureTheme(WidgetTester tester) async {
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
  const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
  final targetConfig = classicConfig.copyWith(
    rules: const DuelSettings(mode: DuelMode.targetColor, target: SignalColor.blue),
  );

  Future<void> shot(String name, Widget home) async {
    await _capture(tester, services, name, home);
  }

  await settings.setMatch(classicConfig);
  await shot('01-home', const HomeScreen(playLoopProgress: 0.84));
  await shot('02-match-setup', const MatchSetupScreen());
  await shot('03-settings', const SettingsScreen());

  for (var i = 0; i < HowStep.values.length; i++) {
    await shot(
      '04-howto-step${i + 1}',
      HowToPlayScreen(initialStep: i, includeDecoyStep: true, frozenProgress: _howToKeyFrames[i]),
    );
  }

  await shot('05-duel-ready', _duel(classicConfig, _Scene.ready));
  await shot('06-duel-waiting', _duel(classicConfig, _Scene.waiting));
  await shot('07-duel-go', _duel(classicConfig, _Scene.signal));
  await shot('08-duel-midtap', _duel(classicConfig, _Scene.midtap));
  await shot('09-duel-foul', _duel(classicConfig, _Scene.foul));
  await shot('10-duel-scored', _duel(classicConfig, _Scene.scored));
  await shot('11-duel-pause', _duel(classicConfig, _Scene.paused));

  final endEngine = _engineFor(classicConfig, _Scene.matchEnd);
  await stats.recordMatch(endEngine.state);
  await shot(
    '12-match-end',
    DuelScreen(config: classicConfig, engine: endEngine, driveTimers: false, showCoach: false),
  );

  await settings.setMatch(targetConfig);
  await shot('13-target-setup', const MatchSetupScreen());
  await shot('14-duel-decoy', _duel(targetConfig, _Scene.decoy));
  await settings.setMatch(classicConfig);
  await shot('15-duel-coach', _duel(classicConfig, _Scene.coach, coach: true));
  await shot('16-home-play-loop', const HomeScreen(playLoopProgress: 0.5));
}

enum _Scene { ready, waiting, signal, midtap, foul, scored, decoy, matchEnd, paused, coach }

Widget _duel(MatchConfig config, _Scene scene, {bool coach = false}) {
  return DuelScreen(
    config: config,
    engine: _engineFor(config, scene),
    driveTimers: false,
    showCoach: coach,
    frozenBursts: scene == _Scene.midtap
        ? const [
            (Player.p1, TapBurstSpec(dx: 0.3, dy: 0.62, progress: 0.38, winning: true)),
            (Player.p1, TapBurstSpec(dx: 0.58, dy: 0.5, progress: 0.22, winning: true)),
            (Player.p2, TapBurstSpec(dx: 0.4, dy: 0.6, progress: 0.48)),
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
  String name,
  Widget home,
) async {
  tester.view.physicalSize = _physical;
  tester.view.devicePixelRatio = _dpr;
  tester.view.padding = const FakeViewPadding(
    top: _statusBar * _dpr,
    bottom: _homeIndicator * _dpr,
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
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File('$_outRoot/$name.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String path) async => ByteData.sublistView(await File(path).readAsBytes());

  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = FontLoader('MaterialIcons')
    ..addFont(bytes('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'));
  await icons.load();

  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      loader.addFont(bytes('assets/fonts/$f'));
    }
    await loader.load();
  }

  await family('Inter', ['Inter-Regular.ttf', 'Inter-Medium.ttf', 'Inter-SemiBold.ttf', 'Inter-Bold.ttf']);
  await family('LuckiestGuy', ['LuckiestGuy-Regular.ttf']);
  await family('LilitaOne', ['LilitaOne-Regular.ttf']);
}
