import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/engine/clock.dart';
import 'package:reaction_duel/engine/duel_engine.dart';
import 'package:reaction_duel/engine/duel_settings.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/engine/rng.dart';
import 'package:reaction_duel/game/duel_screen.dart';
import 'package:reaction_duel/game/half_pad.dart';
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:reaction_duel/theme/tap_burst.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _services(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  return AppServices(settings: SettingsService(p), stats: StatsService(p));
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('home renders in Turkish and opens match setup', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'tr'});
    await tester.pumpWidget(ReactionDuelApp(services: services, home: const HomeScreen()));
    await tester.pump();
    expect(find.text('Reaction Rivals'), findsOneWidget);
    await tester.tap(find.text('Oyna'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Maç ayarları'), findsOneWidget);
  });

  testWidgets('live language switch updates the UI', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'tr'});
    await tester.pumpWidget(ReactionDuelApp(services: services, home: const HomeScreen()));
    await tester.pump();
    await services.settings.setLanguage('en');
    await tester.pump();
    expect(find.text('Reaction Rivals'), findsOneWidget);
  });

  testWidgets('pointer down on a half during waiting is a foul', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'en', PrefsKeys.onboardingDone: true});
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    clock.set(engine.nextDeadline!);
    engine.tick();
    expect(engine.state.phase, DuelPhase.waiting);

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    await tester.pump();
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width / 2, size.height * 0.75));
    await tester.pump(const Duration(milliseconds: 300));

    expect(engine.state.phase, DuelPhase.foul);
    expect(engine.state.lastResult!.foulBy, Player.p1);
    expect(find.text('TOO EARLY!'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Rival tapped early'), findsOneWidget);
  });

  testWidgets('waiting shows WAIT to both players, signal shows GO! to both', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'en', PrefsKeys.onboardingDone: true});
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    clock.set(engine.nextDeadline!);
    engine.tick();

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    await tester.pump();
    expect(find.text('WAIT'), findsNWidgets(2));
    expect(find.text('GO!'), findsNothing);

    clock.set(engine.nextDeadline!);
    engine.tick();
    await tester.pump();
    expect(engine.state.phase, DuelPhase.signal);
    expect(find.text('GO!'), findsNWidgets(2));
    expect(find.text('WAIT'), findsNothing);
  });

  testWidgets('winner is shown on the next frame after the winning tap', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'en', PrefsKeys.onboardingDone: true});
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    for (var i = 0; i < 4 && engine.state.phase != DuelPhase.signal; i++) {
      clock.set(engine.nextDeadline!);
      engine.tick();
    }
    expect(engine.state.phase, DuelPhase.signal);
    final s = engine.state.signalAt!;

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine),
      ),
    );
    await tester.pump();

    clock.set(s + const Duration(milliseconds: 260));
    engine.tap(Player.p1, at: s + const Duration(milliseconds: 250));
    // One timer turn (the 1 ms tie window), then the very next frame.
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(engine.state.phase, DuelPhase.scored);
    expect(find.text('WINNER'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('250 ms'), findsWidgets);
    expect(find.text('TOO SLOW'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('app lifecycle pause cancels the round', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'en', PrefsKeys.onboardingDone: true});
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.state.phase, DuelPhase.paused);
    expect(find.text('Paused'), findsNWidgets(2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('early tap mark persists until next round; extra taps add no splash', (
    tester,
  ) async {
    _phone(tester);
    final services = await _services({
      PrefsKeys.language: 'en',
      PrefsKeys.onboardingDone: true,
    });
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    clock.set(engine.nextDeadline!);
    engine.tick();
    expect(engine.state.phase, DuelPhase.waiting);

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    await tester.pump();

    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final p1 = Offset(size.width / 2, size.height * 0.75);
    await tester.tapAt(p1);
    await tester.pump();
    expect(engine.state.phase, DuelPhase.foul);
    expect(_burstsOn(tester, Player.p1).where((b) => b.persist), hasLength(1));

    await tester.tapAt(p1 + const Offset(24, 16));
    await tester.tapAt(p1 + const Offset(-18, 10));
    await tester.pump();
    expect(engine.state.statsOf(Player.p1).fouls, 1);
    expect(engine.state.scores, [0, 1]);
    expect(_burstsOn(tester, Player.p1).where((b) => b.persist), hasLength(1));
    expect(_burstsOn(tester, Player.p2), isEmpty);

    await tester.pump(const Duration(seconds: 2));
    expect(_burstsOn(tester, Player.p1).where((b) => b.persist), hasLength(1));

    clock.set(engine.nextDeadline!);
    engine.tick();
    await tester.pump();
    expect(engine.state.phase, DuelPhase.waiting);
    expect(engine.state.hasTapped(Player.p1), isFalse);
    expect(_burstsOn(tester, Player.p1), isEmpty);
  });

  testWidgets('after GO extra taps on the same half are ignored; other half still plays', (
    tester,
  ) async {
    _phone(tester);
    final services = await _services({
      PrefsKeys.language: 'en',
      PrefsKeys.onboardingDone: true,
    });
    final clock = FakeClock();
    final engine = DuelEngine(
      clock: clock,
      rng: SeededRng(1),
      settings: const DuelSettings(guessGuard: false),
    )..start();
    clock.set(engine.nextDeadline!);
    engine.tick();
    expect(engine.state.phase, DuelPhase.waiting);

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    await tester.pump();

    clock.set(engine.nextDeadline!);
    engine.tick();
    await tester.pump();
    await tester.pump();
    expect(engine.state.phase, DuelPhase.signal);

    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final p1 = Offset(size.width / 2, size.height * 0.75);
    final p2 = Offset(size.width / 2, size.height * 0.25);

    await tester.tapAt(p1);
    await tester.pump();
    expect(engine.state.hasTapped(Player.p1), isTrue);
    expect(engine.state.hasTapped(Player.p2), isFalse);
    final first = _burstsOn(tester, Player.p1).length;
    expect(first, 1);

    await tester.tapAt(p1 + const Offset(20, 12));
    await tester.tapAt(p1 + const Offset(-16, 8));
    await tester.pump();
    expect(_burstsOn(tester, Player.p1), hasLength(first));
    expect(engine.state.scores, [0, 0]);

    await tester.tapAt(p2);
    await tester.pump();
    expect(engine.state.hasTapped(Player.p2), isTrue);
    expect(engine.state.hasTapped(Player.p1), isTrue);
    expect(
      engine.state.phase,
      anyOf(DuelPhase.scored, DuelPhase.tie),
    );
    expect(_burstsOn(tester, Player.p2), isNotEmpty);
  });

  testWidgets('two fingers on one half count as one tap', (tester) async {
    _phone(tester);
    final services = await _services({
      PrefsKeys.language: 'en',
      PrefsKeys.onboardingDone: true,
    });
    final clock = FakeClock();
    final engine = DuelEngine(clock: clock, rng: SeededRng(1))..start();
    clock.set(engine.nextDeadline!);
    engine.tick();

    await tester.pumpWidget(
      ReactionDuelApp(
        services: services,
        home: DuelScreen(config: const MatchConfig(), engine: engine, driveTimers: false),
      ),
    );
    await tester.pump();

    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final a = Offset(size.width * 0.35, size.height * 0.75);
    final b = Offset(size.width * 0.65, size.height * 0.78);
    final first = await tester.startGesture(a);
    final second = await tester.startGesture(b);
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pump();

    expect(engine.state.phase, DuelPhase.foul);
    expect(engine.state.statsOf(Player.p1).fouls, 1);
    expect(_burstsOn(tester, Player.p1).where((b) => b.persist), hasLength(1));
  });
}

List<TapBurstSpec> _burstsOn(WidgetTester tester, Player player) {
  final pads = find.byType(HalfPad);
  final index = player == Player.p2 ? 0 : 1;
  final layer = tester.widget<TapBurstLayer>(
    find.descendant(of: pads.at(index), matching: find.byType(TapBurstLayer)),
  );
  return layer.bursts;
}
