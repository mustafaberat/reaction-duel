/// Design review screenshots of the real screens at phone size.
///
/// Run: `flutter test tool/capture_design_shots.dart`
/// Out: design/shots/*.png — 1080×2340 (393×851 logical @ 2.75).
///
/// Engine state is driven with a [FakeClock] + seeded RNG, never real timers.
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
import 'package:shared_preferences/shared_preferences.dart';

const Size _physical = Size(1080, 2340);
const double _dpr = 2.75;
const double _statusBar = 28;
const double _homeIndicator = 18;
const String _outDir = 'design/shots';

/// How-to demo loop positions that best show each step.
const List<double> _howToKeyFrames = [0.3, 0.55, 0.52, 0.72, 0.3];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture design shots', (tester) async {
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
    const classicConfig = MatchConfig(p1Name: 'Deniz', p2Name: 'Mert');
    final targetConfig = classicConfig.copyWith(
      rules: const DuelSettings(mode: DuelMode.targetColor, target: SignalColor.blue),
    );

    Future<void> shot(String name, Widget home, {Future<void> Function()? after}) async {
      await _capture(tester, services, name, home, after: after);
    }

    // --- Turkish ---
    await settings.setMatch(classicConfig);
    await shot('01-home', const HomeScreen());
    await shot('02-match-setup', const MatchSetupScreen());

    await shot('03-duel-waiting', _duel(classicConfig, _Scene.waiting));
    await shot('04-duel-signal', _duel(classicConfig, _Scene.signal));
    await shot('05-duel-foul', _duel(classicConfig, _Scene.foul));
    await shot('06-duel-scored', _duel(classicConfig, _Scene.scored));

    await settings.setMatch(targetConfig);
    await shot('07-target-color-setup', const MatchSetupScreen());
    await shot('08-target-color-decoy', _duel(targetConfig, _Scene.decoy));

    // --- English ---
    await settings.setLanguage('en');
    await shot('01-home-en', const HomeScreen());
    await shot(
      '04-duel-signal-en',
      _duel(classicConfig.copyWith(p1Name: 'Alex', p2Name: 'Sam'), _Scene.signal),
    );
    await settings.setLanguage('tr');

    await settings.setMatch(classicConfig);
    final endEngine = _engineFor(classicConfig, _Scene.matchEnd);
    await stats.recordMatch(endEngine.state);
    await shot(
      '09-match-end',
      DuelScreen(config: classicConfig, engine: endEngine, driveTimers: false, showCoach: false),
    );

    for (var i = 0; i < HowStep.values.length; i++) {
      await shot(
        '10-howto-step${i + 1}',
        HowToPlayScreen(initialStep: i, includeDecoyStep: true, frozenProgress: _howToKeyFrames[i]),
      );
    }

    await shot('11-settings', const SettingsScreen());
    await shot('12-pause', _duel(classicConfig, _Scene.paused));
    await shot('13-duel-coach', _duel(classicConfig, _Scene.coach, coach: true));
  }, timeout: const Timeout(Duration(minutes: 5)));
}

enum _Scene { waiting, signal, foul, scored, decoy, matchEnd, paused, coach }

Widget _duel(MatchConfig config, _Scene scene, {bool coach = false}) {
  return DuelScreen(
    config: config,
    engine: _engineFor(config, scene),
    driveTimers: false,
    showCoach: coach,
  );
}

/// Deterministic engine positioned at [scene].
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

  // 1–1 baseline.
  win(Player.p1, 231, 284);
  win(Player.p2, 268, 305);

  switch (scene) {
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
    case _Scene.coach:
      break;
  }
  return engine;
}

Future<void> _capture(
  WidgetTester tester,
  AppServices services,
  String name,
  Widget home, {
  Future<void> Function()? after,
}) async {
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
  if (after != null) await after();
  await tester.pump(const Duration(milliseconds: 60));

  final bytes = await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final file = File('$_outDir/$name.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

Future<void> _loadFonts() async {
  Future<ByteData> bytes(String path) async => ByteData.sublistView(await File(path).readAsBytes());

  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = FontLoader('MaterialIcons')
    ..addFont(bytes('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'));
  await icons.load();

  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    inter.addFont(bytes('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();

  final sora = FontLoader('Sora');
  for (final w in ['SemiBold', 'Bold', 'ExtraBold']) {
    sora.addFont(bytes('assets/fonts/Sora-$w.ttf'));
  }
  await sora.load();
}
