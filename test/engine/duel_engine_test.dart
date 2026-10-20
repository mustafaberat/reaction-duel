import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/engine/clock.dart';
import 'package:reaction_duel/engine/duel_engine.dart';
import 'package:reaction_duel/engine/duel_settings.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/engine/rng.dart';
import 'package:reaction_duel/engine/signal_palette.dart';

DuelEngine _engine(FakeClock clock, {DuelSettings settings = const DuelSettings(), int seed = 7}) {
  return DuelEngine(clock: clock, rng: SeededRng(seed), settings: settings)..start();
}

/// Jumps the clock to each deadline until [phase] is reached.
void _runTo(DuelEngine engine, FakeClock clock, DuelPhase phase) {
  for (var i = 0; i < 32 && engine.state.phase != phase; i++) {
    final deadline = engine.nextDeadline;
    if (deadline == null) break;
    clock.set(deadline);
    engine.tick();
  }
  expect(engine.state.phase, phase);
}

Duration _ms(int ms) => Duration(milliseconds: ms);

void main() {
  group('round flow', () {
    test('ready → waiting after cooldown, input locked during cooldown', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      expect(engine.state.phase, DuelPhase.ready);
      expect(engine.nextDeadline, _ms(GameTiming.cooldownMs));

      engine.tap(Player.p1);
      expect(engine.state.phase, DuelPhase.ready);
      expect(engine.state.scores, [0, 0]);

      clock.advanceMs(GameTiming.cooldownMs - 1);
      engine.tick();
      expect(engine.state.phase, DuelPhase.ready);
      clock.advanceMs(1);
      engine.tick();
      expect(engine.state.phase, DuelPhase.waiting);
    });

    test('first valid tap after signal scores with correct ms', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final signalAt = engine.state.signalAt!;
      expect(engine.state.orbColor, SignalColor.green);

      engine.tap(Player.p1, at: signalAt + _ms(243));
      clock.set(signalAt + _ms(244));
      engine.tick();

      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.scores, [1, 0]);
      expect(engine.state.lastResult!.winner, Player.p1);
      expect(engine.state.lastResult!.winnerMs, 243);
      expect(engine.state.lastResult!.loserMs, isNull);
    });

    test('second tap ≥1ms later resolves immediately and records loser ms', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p2, at: s + _ms(250));
      engine.tap(Player.p1, at: s + _ms(290));
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.lastResult!.winner, Player.p2);
      expect(engine.state.lastResult!.msFor(Player.p2), 250);
      expect(engine.state.lastResult!.msFor(Player.p1), 290);
    });

    test('loser tapping during cooldown is recorded but does not score', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p1, at: s + _ms(200));
      clock.set(s + _ms(210));
      engine.tick();
      engine.tap(Player.p2, at: s + _ms(330));
      expect(engine.state.scores, [1, 0]);
      expect(engine.state.lastResult!.loserMs, 330);
    });

    test('signal timeout → no contest, nobody scores', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      clock.set(s + _ms(GameTiming.signalTimeoutMs - 1));
      engine.tick();
      expect(engine.state.phase, DuelPhase.signal);
      clock.set(s + _ms(GameTiming.signalTimeoutMs));
      engine.tick();
      expect(engine.state.phase, DuelPhase.noContest);
      expect(engine.state.scores, [0, 0]);
    });

    test('after a round the next signal is at least result hold + min delay away', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      for (var round = 0; round < 20; round++) {
        _runTo(engine, clock, DuelPhase.signal);
        final s = engine.state.signalAt!;
        engine.tap(Player.p1, at: s + _ms(200));
        clock.set(s + _ms(200));
        engine.tick();
        final resolvedAt = clock.now();
        engine.updateSettings(engine.state.settings.copyWith(winScore: 99));
        _runTo(engine, clock, DuelPhase.waiting);
        final next = engine.plannedSignalAt!;
        expect(
          next - resolvedAt,
          greaterThanOrEqualTo(_ms(GameTiming.resultHoldMs + GameTiming.waitNormalMinMs)),
        );
      }
    });

    test('consecutive delays differ by the preset gap and stay in range', () {
      for (final preset in WaitPreset.values) {
        final clock = FakeClock();
        final engine = _engine(
          clock,
          settings: DuelSettings(wait: preset, winScore: 999),
          seed: preset.index + 11,
        );
        Duration? lastDelay;
        for (var round = 0; round < 60; round++) {
          _runTo(engine, clock, DuelPhase.waiting);
          final waitStart = clock.now();
          final delay = engine.plannedSignalAt! - waitStart;
          expect(delay, greaterThanOrEqualTo(_ms(preset.minMs)));
          expect(delay, lessThanOrEqualTo(_ms(preset.maxMs)));
          if (lastDelay != null) {
            expect(
              (delay - lastDelay).abs(),
              greaterThanOrEqualTo(_ms(preset.minGapMs) - const Duration(microseconds: 1)),
            );
          }
          lastDelay = delay;
          _runTo(engine, clock, DuelPhase.noContest);
        }
      }
    });
  });

  group('timing retune', () {
    test('wait presets: Short 1.2–2.5 s, Normal 2.0–3.5 s, Long 3.0–6.0 s', () {
      expect((WaitPreset.short.minMs, WaitPreset.short.maxMs), (1200, 2500));
      expect((WaitPreset.normal.minMs, WaitPreset.normal.maxMs), (2000, 3500));
      expect((WaitPreset.long.minMs, WaitPreset.long.maxMs), (3000, 6000));
      expect(WaitPreset.short.minGapMs, 400);
      expect(WaitPreset.normal.minGapMs, 400);
      expect(WaitPreset.long.minGapMs, 600);
    });

    test('delays spread over the whole range (not clustered)', () {
      for (final preset in WaitPreset.values) {
        final clock = FakeClock();
        final engine = _engine(
          clock,
          settings: DuelSettings(wait: preset, winScore: 999),
          seed: preset.index + 40,
        );
        final delays = <int>[];
        for (var round = 0; round < 200; round++) {
          _runTo(engine, clock, DuelPhase.waiting);
          delays.add((engine.plannedSignalAt! - clock.now()).inMilliseconds);
          _runTo(engine, clock, DuelPhase.noContest);
        }
        final span = preset.maxMs - preset.minMs;
        final lowQuarter = delays.where((d) => d < preset.minMs + span / 4).length;
        final highQuarter = delays.where((d) => d > preset.maxMs - span / 4).length;
        expect(lowQuarter, greaterThan(20), reason: '$preset');
        expect(highQuarter, greaterThan(20), reason: '$preset');
      }
    });

    test('result is held for resultHoldMs with input locked, then neutral waiting', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: const DuelSettings(winScore: 99));
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p1, at: s + _ms(240));
      clock.set(s + _ms(241));
      engine.tick();
      expect(engine.state.phase, DuelPhase.scored);
      final resolvedAt = clock.now();
      expect(engine.nextDeadline, resolvedAt + _ms(GameTiming.resultHoldMs));
      expect(engine.state.inputLocked, isTrue);

      clock.set(resolvedAt + _ms(GameTiming.resultHoldMs - 1));
      engine.tick();
      engine.tap(Player.p1);
      engine.tap(Player.p2);
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.scores, [1, 0]);
      expect(engine.state.lastResult!.winner, Player.p1);

      clock.set(resolvedAt + _ms(GameTiming.resultHoldMs));
      engine.tick();
      expect(engine.state.phase, DuelPhase.waiting);
      expect(engine.state.lastResult, isNull);
      expect(engine.state.orbColor, isNull);
    });

    test('foul result is held too, and taps during the hold are ignored', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: const DuelSettings(winScore: 99));
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p2);
      expect(engine.state.phase, DuelPhase.foul);
      final at = clock.now();
      expect(engine.nextDeadline, at + _ms(GameTiming.resultHoldMs));
      engine.tap(Player.p2);
      engine.tap(Player.p1);
      expect(engine.state.scores, [1, 0]);
      expect(engine.state.stats[Player.p2.index].fouls, 1);
    });

    test('a pending valid tap notifies listeners so the host reschedules', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      expect(engine.nextDeadline, s + _ms(GameTiming.signalTimeoutMs));
      var calls = 0;
      engine.addListener(() => calls++);
      engine.tap(Player.p1, at: s + _ms(250));
      expect(calls, 1);
      expect(
        engine.nextDeadline,
        s + _ms(250) + const Duration(microseconds: GameTiming.tieWindowUs),
      );
    });
  });

  group('rng seeding', () {
    test('default engine seeds from entropy: engines get different sequences', () {
      List<Duration> delays(DuelEngine engine, FakeClock clock) {
        final out = <Duration>[];
        for (var i = 0; i < 6; i++) {
          _runTo(engine, clock, DuelPhase.waiting);
          out.add(engine.plannedSignalAt! - clock.now());
          _runTo(engine, clock, DuelPhase.noContest);
        }
        return out;
      }

      final seeds = <int?>{};
      final sequences = <String>{};
      for (var i = 0; i < 5; i++) {
        final clock = FakeClock();
        final engine = DuelEngine(
          clock: clock,
          settings: const DuelSettings(winScore: 99),
        )..start();
        seeds.add(engine.seed);
        sequences.add(delays(engine, clock).join(','));
      }
      expect(seeds.contains(null), isFalse);
      expect(seeds.length, 5);
      expect(sequences.length, 5);
    });

    test('a fixed seed reproduces the same delays (tests / screenshots)', () {
      String run() {
        final clock = FakeClock();
        final engine = _engine(clock, settings: const DuelSettings(winScore: 99), seed: 21);
        final out = <Duration>[];
        for (var i = 0; i < 6; i++) {
          _runTo(engine, clock, DuelPhase.waiting);
          out.add(engine.plannedSignalAt! - clock.now());
          _runTo(engine, clock, DuelPhase.noContest);
        }
        return out.join(',');
      }

      expect(run(), run());
    });

    test('SeededRng.entropy yields distinct seeds', () {
      final seeds = {for (var i = 0; i < 20; i++) SeededRng.entropy().seed};
      expect(seeds.length, greaterThan(18));
    });
  });

  group('fouls and penalties', () {
    test('early tap: opponent +1 (default)', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p1);
      expect(engine.state.phase, DuelPhase.foul);
      expect(engine.state.scores, [0, 1]);
      expect(engine.state.lastResult!.foulBy, Player.p1);
      expect(engine.state.lastResult!.reason, FoulReason.early);
      expect(engine.state.statsOf(Player.p1).fouls, 1);
    });

    test('both early: only the first is a foul, second is ignored', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p2);
      engine.tap(Player.p1);
      expect(engine.state.scores, [1, 0]);
      expect(engine.state.statsOf(Player.p1).fouls, 0);
    });

    test('self −1 never goes below zero', () {
      final clock = FakeClock();
      final engine = _engine(
        clock,
        settings: const DuelSettings(penalty: FoulPenalty.selfMinusOne),
      );
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p1);
      expect(engine.state.scores, [0, 0]);

      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p1, at: s + _ms(300));
      engine.tap(Player.p2, at: s + _ms(400));
      expect(engine.state.scores, [1, 0]);

      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p1);
      expect(engine.state.scores, [0, 0]);
    });

    test('round loss only: no score change', () {
      final clock = FakeClock();
      final engine = _engine(
        clock,
        settings: const DuelSettings(penalty: FoulPenalty.roundLossOnly),
      );
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p2);
      expect(engine.state.phase, DuelPhase.foul);
      expect(engine.state.scores, [0, 0]);
      expect(engine.state.lastResult!.winner, isNull);
    });

    test('tap before the signal frame (negative reaction) is early', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      engine.tap(Player.p1, at: engine.state.signalAt! - _ms(5));
      expect(engine.state.phase, DuelPhase.foul);
      expect(engine.state.lastResult!.reason, FoulReason.early);
    });
  });

  group('guess guard', () {
    test('< 80 ms after signal is a guess foul when enabled', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      engine.tap(Player.p2, at: engine.state.signalAt! + _ms(GameTiming.guessThresholdMs - 1));
      expect(engine.state.phase, DuelPhase.foul);
      expect(engine.state.lastResult!.reason, FoulReason.guess);
      expect(engine.state.scores, [1, 0]);
    });

    test('exactly 80 ms is valid', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p2, at: s + _ms(GameTiming.guessThresholdMs));
      clock.set(s + _ms(200));
      engine.tick();
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.scores, [0, 1]);
    });

    test('disabled guard accepts fast taps', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: const DuelSettings(guessGuard: false));
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p1, at: s + _ms(40));
      clock.set(s + _ms(50));
      engine.tick();
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.lastResult!.winnerMs, 40);
    });
  });

  group('tie', () {
    test('two taps < 1 ms apart → tie, no points, round repeats', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      final roundBefore = engine.state.round;
      engine.tap(Player.p1, at: s + _ms(220));
      engine.tap(Player.p2, at: s + _ms(220) + const Duration(microseconds: 600));
      expect(engine.state.phase, DuelPhase.tie);
      expect(engine.state.scores, [0, 0]);
      _runTo(engine, clock, DuelPhase.waiting);
      expect(engine.state.round, roundBefore + 1);
    });

    test('exactly 1 ms apart is not a tie', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      final s = engine.state.signalAt!;
      engine.tap(Player.p1, at: s + _ms(220));
      engine.tap(Player.p2, at: s + _ms(221));
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.lastResult!.winner, Player.p1);
    });
  });

  group('target color mode', () {
    DuelSettings target({bool cb = false}) => DuelSettings(
      mode: DuelMode.targetColor,
      target: SignalColor.blue,
      colorBlind: cb,
      winScore: 999,
    );

    test('decoys are far from target, short, and signal ≥ 0.8 s after last', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: target(), seed: 3);
      var sawDecoy = false;
      for (var round = 0; round < 40; round++) {
        _runTo(engine, clock, DuelPhase.waiting);
        final decoys = engine.plannedDecoys;
        expect(decoys.length, lessThanOrEqualTo(GameTiming.maxDecoys));
        for (final d in decoys) {
          sawDecoy = true;
          expect(d.color, isNot(SignalColor.blue));
          expect(
            SignalPalette.distance(d.color, SignalColor.blue, colorBlind: false),
            greaterThanOrEqualTo(GameRules.decoyMinDistance),
          );
          final len = d.end - d.start;
          expect(len, greaterThanOrEqualTo(_ms(GameTiming.decoyMinMs)));
          expect(len, lessThanOrEqualTo(_ms(GameTiming.decoyMaxMs)));
        }
        if (decoys.isNotEmpty) {
          expect(
            engine.plannedSignalAt! - decoys.last.end,
            greaterThanOrEqualTo(_ms(GameTiming.postDecoyMinMs)),
          );
        }
        _runTo(engine, clock, DuelPhase.noContest);
      }
      expect(sawDecoy, isTrue);
    });

    test('tapping on a decoy is a foul; tapping on target scores', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: target(), seed: 3);
      var checkedDecoy = false;
      for (var round = 0; round < 20 && !checkedDecoy; round++) {
        _runTo(engine, clock, DuelPhase.waiting);
        if (engine.plannedDecoys.isEmpty) {
          _runTo(engine, clock, DuelPhase.noContest);
          continue;
        }
        _runTo(engine, clock, DuelPhase.decoy);
        expect(engine.state.orbColor, isNot(SignalColor.blue));
        engine.tap(Player.p1);
        expect(engine.state.phase, DuelPhase.foul);
        expect(engine.state.lastResult!.reason, FoulReason.decoy);
        expect(engine.state.scoreOf(Player.p2), 1);
        checkedDecoy = true;
      }
      expect(checkedDecoy, isTrue);

      _runTo(engine, clock, DuelPhase.signal);
      expect(engine.state.orbColor, SignalColor.blue);
      engine.tap(Player.p1, at: engine.state.signalAt! + _ms(300));
      engine.tap(Player.p2, at: engine.state.signalAt! + _ms(320));
      expect(engine.state.phase, DuelPhase.scored);
      expect(engine.state.lastResult!.winner, Player.p1);
    });

    test('color-blind mode uses CB palette with shapes', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: target(cb: true), seed: 5);
      expect(engine.state.settings.effectiveTarget, SignalColor.cbBlue);
      for (var round = 0; round < 20; round++) {
        _runTo(engine, clock, DuelPhase.waiting);
        for (final d in engine.plannedDecoys) {
          expect(SignalPalette.colorBlind, contains(d.color));
          expect(d.shape, isNot(SignalShape.circle));
          expect(
            SignalPalette.distance(d.color, SignalColor.cbBlue, colorBlind: true),
            greaterThanOrEqualTo(GameRules.decoyMinDistance),
          );
        }
        _runTo(engine, clock, DuelPhase.signal);
        expect(engine.state.orbShape, SignalShape.circle);
        _runTo(engine, clock, DuelPhase.noContest);
      }
    });

    test('every standard target has at least one valid decoy', () {
      for (final cb in [false, true]) {
        for (final t in SignalPalette.forMode(colorBlind: cb)) {
          expect(SignalPalette.decoysFor(t, colorBlind: cb), isNotEmpty);
        }
      }
    });
  });

  group('match', () {
    test('reaching win score ends the match; rematch resets', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: const DuelSettings(winScore: 3));
      for (var i = 0; i < 3; i++) {
        _runTo(engine, clock, DuelPhase.signal);
        final s = engine.state.signalAt!;
        engine.tap(Player.p2, at: s + _ms(200 + i * 10));
        engine.tap(Player.p1, at: s + _ms(300));
      }
      expect(engine.state.phase, DuelPhase.matchOver);
      expect(engine.state.matchWinner, Player.p2);
      expect(engine.state.scores, [0, 3]);
      expect(engine.state.statsOf(Player.p2).bestMs, 200);
      expect(engine.state.statsOf(Player.p2).averageMs, 210);
      expect(engine.nextDeadline, isNull);

      engine.tap(Player.p1);
      expect(engine.state.scores, [0, 3]);

      engine.rematch();
      expect(engine.state.phase, DuelPhase.ready);
      expect(engine.state.scores, [0, 0]);
      expect(engine.state.matchWinner, isNull);
    });

    test('foul can win the match for the opponent', () {
      final clock = FakeClock();
      final engine = _engine(clock, settings: const DuelSettings(winScore: 1));
      _runTo(engine, clock, DuelPhase.waiting);
      engine.tap(Player.p1);
      expect(engine.state.phase, DuelPhase.matchOver);
      expect(engine.state.matchWinner, Player.p2);
    });

    test('win score 1/3/5/7/10 all work', () {
      for (final target in GameRules.winScores) {
        final clock = FakeClock();
        final engine = _engine(clock, settings: DuelSettings(winScore: target));
        for (var i = 0; i < target; i++) {
          expect(engine.state.phase, isNot(DuelPhase.matchOver));
          _runTo(engine, clock, DuelPhase.waiting);
          engine.tap(Player.p2);
        }
        expect(engine.state.phase, DuelPhase.matchOver);
        expect(engine.state.scores, [target, 0]);
      }
    });

    test('pause cancels the round; resume starts a fresh cooldown', () {
      final clock = FakeClock();
      final engine = _engine(clock);
      _runTo(engine, clock, DuelPhase.signal);
      engine.pause();
      expect(engine.state.phase, DuelPhase.paused);
      expect(engine.nextDeadline, isNull);
      engine.tap(Player.p1);
      expect(engine.state.scores, [0, 0]);

      clock.advanceMs(10000);
      engine.resume();
      expect(engine.state.phase, DuelPhase.ready);
      expect(engine.nextDeadline, clock.now() + _ms(GameTiming.cooldownMs));
    });
  });
}
