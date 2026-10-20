import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/engine/clock.dart';
import 'package:reaction_duel/engine/duel_engine.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/engine/rng.dart';
import 'package:reaction_duel/game/duel_screen.dart';
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
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
    final services = await _services({PrefsKeys.language: 'tr', PrefsKeys.howToSeen: true});
    await tester.pumpWidget(
      ReactionDuelApp(services: services, home: const HomeScreen(autoOpenHowTo: false)),
    );
    await tester.pump();
    expect(find.text('Refleks Düellosu'), findsOneWidget);
    await tester.tap(find.text('Oyna'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Maç ayarları'), findsOneWidget);
  });

  testWidgets('live language switch updates the UI', (tester) async {
    _phone(tester);
    final services = await _services({PrefsKeys.language: 'tr', PrefsKeys.howToSeen: true});
    await tester.pumpWidget(
      ReactionDuelApp(services: services, home: const HomeScreen(autoOpenHowTo: false)),
    );
    await tester.pump();
    await services.settings.setLanguage('en');
    await tester.pump();
    expect(find.text('Reaction Duel'), findsOneWidget);
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
}
