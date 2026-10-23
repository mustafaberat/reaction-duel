/// Pure Dart round state machine (rfc §3). No Flutter import.
///
/// Time only moves through [Clock]. The host calls [tick] at or after
/// [nextDeadline] and forwards pointer-downs to [tap] with a timestamp in the
/// engine clock's time base.
library;

import '../config/app_config.dart';
import 'clock.dart';
import 'duel_settings.dart';
import 'duel_state.dart';
import 'rng.dart';
import 'signal_palette.dart';

class DecoyWindow {
  const DecoyWindow({
    required this.start,
    required this.end,
    required this.color,
    required this.shape,
  });

  final Duration start;
  final Duration end;
  final SignalColor color;
  final SignalShape shape;
}

class _PendingTap {
  const _PendingTap(this.player, this.at);

  final Player player;
  final Duration at;
}

class DuelEngine {
  DuelEngine({required this.clock, Rng? rng, DuelSettings settings = const DuelSettings()})
    : _rng = rng ?? SeededRng.entropy(),
      _state = DuelState(phase: DuelPhase.ready, settings: settings);

  final Clock clock;
  final Rng _rng;

  DuelState _state;
  Duration _phaseStart = Duration.zero;
  Duration? _signalAt;
  List<DecoyWindow> _decoys = const [];
  int _nextDecoy = 0;
  _PendingTap? _pending;
  double? _lastDelayMs;
  final List<void Function()> _listeners = [];

  static const Duration _cooldown = Duration(milliseconds: GameTiming.cooldownMs);
  static const Duration _resultHold = Duration(milliseconds: GameTiming.resultHoldMs);
  static const Duration _timeout = Duration(milliseconds: GameTiming.signalTimeoutMs);
  static const Duration _tieWindow = Duration(microseconds: GameTiming.tieWindowUs);
  static const Duration _guess = Duration(milliseconds: GameTiming.guessThresholdMs);

  DuelState get state => _state;

  /// Seed of the round RNG when it is a [SeededRng] (diagnostics / tests).
  int? get seed => switch (_rng) {
    SeededRng(:final seed) => seed,
    _ => null,
  };

  /// Decoys planned for the current round (tests / debugging).
  List<DecoyWindow> get plannedDecoys => List.unmodifiable(_decoys);

  /// Scheduled signal time for the current round, once waiting has begun.
  Duration? get plannedSignalAt => _signalAt;

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _emit(DuelState next) {
    _state = next;
    _notify();
  }

  /// Also fired when only [nextDeadline] moved (a pending tap), so the host
  /// reschedules its timer instead of waiting for the old deadline.
  void _notify() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  /// Starts (or restarts) the match with a cooldown.
  void start() {
    _resetRound();
    _phaseStart = clock.now();
    _emit(DuelState(phase: DuelPhase.ready, settings: _state.settings));
  }

  /// Same settings, scores reset, straight into cooldown (rfc §6).
  void rematch() => start();

  void updateSettings(DuelSettings settings) {
    _emit(_state.copyWith(settings: settings));
  }

  /// Cancels the current round. Scores are kept.
  void pause() {
    if (_state.phase == DuelPhase.paused || _state.phase == DuelPhase.matchOver) {
      return;
    }
    _resetRound();
    _emit(
      _state.copyWith(
        phase: DuelPhase.paused,
        clearOrb: true,
        clearSignal: true,
        clearResult: true,
        clearTapped: true,
      ),
    );
  }

  /// New waiting period after a fresh cooldown.
  void resume() {
    if (_state.phase != DuelPhase.paused) return;
    _phaseStart = clock.now();
    _emit(_state.copyWith(phase: DuelPhase.ready));
  }

  /// When the host should call [tick] next; null = nothing scheduled.
  Duration? get nextDeadline {
    switch (_state.phase) {
      case DuelPhase.ready:
        return _phaseStart + _cooldown;
      case DuelPhase.scored:
      case DuelPhase.foul:
      case DuelPhase.noContest:
      case DuelPhase.tie:
        return _phaseStart + _resultHold;
      case DuelPhase.waiting:
        if (_nextDecoy < _decoys.length) return _decoys[_nextDecoy].start;
        return _signalAt;
      case DuelPhase.decoy:
        return _decoys[_nextDecoy].end;
      case DuelPhase.signal:
        final pending = _pending;
        if (pending != null) return pending.at + _tieWindow;
        return _signalAt! + _timeout;
      case DuelPhase.paused:
      case DuelPhase.matchOver:
        return null;
    }
  }

  /// Applies every transition that is due at the current clock time.
  void tick() {
    final now = clock.now();
    for (var guard = 0; guard < 16; guard++) {
      final deadline = nextDeadline;
      if (deadline == null || now < deadline) return;
      _advance(deadline);
    }
  }

  void _advance(Duration at) {
    switch (_state.phase) {
      case DuelPhase.ready:
      case DuelPhase.scored:
      case DuelPhase.foul:
      case DuelPhase.noContest:
      case DuelPhase.tie:
        _beginWaiting(at);
      case DuelPhase.waiting:
        if (_nextDecoy < _decoys.length) {
          final decoy = _decoys[_nextDecoy];
          _phaseStart = at;
          _emit(
            _state.copyWith(phase: DuelPhase.decoy, orbColor: decoy.color, orbShape: decoy.shape),
          );
        } else {
          _phaseStart = at;
          _emit(
            _state.copyWith(
              phase: DuelPhase.signal,
              orbColor: _state.settings.effectiveTarget,
              orbShape: SignalShape.circle,
              signalAt: _signalAt,
            ),
          );
        }
      case DuelPhase.decoy:
        _nextDecoy++;
        _phaseStart = at;
        _emit(_state.copyWith(phase: DuelPhase.waiting, clearOrb: true));
      case DuelPhase.signal:
        final pending = _pending;
        if (pending != null) {
          _resolveWin(pending.player, pending.at, null);
        } else {
          _finishRound(DuelPhase.noContest, const RoundResult(outcome: RoundOutcome.noContest));
        }
      case DuelPhase.paused:
      case DuelPhase.matchOver:
        break;
    }
  }

  /// A new pointer went down on [player]'s half at engine time [at].
  ///
  /// Returns `true` when this is the player's first tap of the round and it
  /// was consumed. A locked player gets no splash, no score change, and no
  /// extra foul.
  bool tap(Player player, {Duration? at}) {
    if (_state.hasTapped(player)) return false;
    final time = at ?? clock.now();
    switch (_state.phase) {
      case DuelPhase.waiting:
        _lock(player);
        _foul(player, FoulReason.early);
        return true;
      case DuelPhase.decoy:
        _lock(player);
        _foul(player, FoulReason.decoy);
        return true;
      case DuelPhase.signal:
        return _tapDuringSignal(player, time);
      case DuelPhase.scored:
      case DuelPhase.matchOver:
        return _maybeRecordLoser(player, time);
      case DuelPhase.ready:
      case DuelPhase.foul:
      case DuelPhase.noContest:
      case DuelPhase.tie:
      case DuelPhase.paused:
        return false;
    }
  }

  bool _tapDuringSignal(Player player, Duration at) {
    final signalAt = _signalAt!;
    final pending = _pending;
    if (pending != null) {
      if (pending.player == player) return false;
      _lock(player);
      final delta = at - pending.at;
      if (delta.abs() < _tieWindow) {
        _resolveTie(pending, _PendingTap(player, at));
      } else if (delta.isNegative) {
        _resolveWin(player, at, pending.at);
      } else {
        _resolveWin(pending.player, pending.at, at);
      }
      return true;
    }
    final reaction = at - signalAt;
    if (reaction.isNegative) {
      _lock(player);
      _foul(player, FoulReason.early);
      return true;
    }
    if (_state.settings.guessGuard && reaction < _guess) {
      _lock(player);
      _foul(player, FoulReason.guess);
      return true;
    }
    _lock(player);
    _pending = _PendingTap(player, at);
    _notify();
    return true;
  }

  bool _maybeRecordLoser(Player player, Duration at) {
    final result = _state.lastResult;
    final signalAt = _state.signalAt;
    if (result == null ||
        signalAt == null ||
        result.outcome != RoundOutcome.scored ||
        result.winner == player ||
        result.loserMs != null) {
      return false;
    }
    final ms = _ms(at - signalAt);
    if (ms > GameTiming.signalTimeoutMs) return false;
    _lock(player);
    final stats = [..._state.stats];
    stats[player.index] = stats[player.index].addReaction(ms);
    _emit(_state.copyWith(lastResult: result.withLoserMs(ms), stats: stats));
    return true;
  }

  void _lock(Player player) {
    if (_state.hasTapped(player)) return;
    final tapped = [..._state.tappedThisRound];
    tapped[player.index] = true;
    _state = _state.copyWith(tappedThisRound: tapped);
  }

  void _foul(Player player, FoulReason reason) {
    final scores = [..._state.scores];
    final opponent = player.other;
    switch (_state.settings.penalty) {
      case FoulPenalty.opponentPlusOne:
        scores[opponent.index]++;
      case FoulPenalty.selfMinusOne:
        if (scores[player.index] > 0) scores[player.index]--;
      case FoulPenalty.roundLossOnly:
        break;
    }
    final stats = [..._state.stats];
    stats[player.index] = stats[player.index].addFoul();
    final result = RoundResult(
      outcome: RoundOutcome.foul,
      winner: _state.settings.penalty == FoulPenalty.opponentPlusOne ? opponent : null,
      foulBy: player,
      reason: reason,
    );
    _finishRound(DuelPhase.foul, result, scores: scores, stats: stats);
  }

  void _resolveWin(Player winner, Duration winnerAt, Duration? loserAt) {
    final signalAt = _signalAt!;
    final winnerMs = _ms(winnerAt - signalAt);
    final loserMs = loserAt == null ? null : _ms(loserAt - signalAt);
    final scores = [..._state.scores];
    scores[winner.index]++;
    final stats = [..._state.stats];
    stats[winner.index] = stats[winner.index].addReaction(winnerMs);
    if (loserMs != null) {
      stats[winner.other.index] = stats[winner.other.index].addReaction(loserMs);
    }
    _finishRound(
      DuelPhase.scored,
      RoundResult(
        outcome: RoundOutcome.scored,
        winner: winner,
        winnerMs: winnerMs,
        loserMs: loserMs,
      ),
      scores: scores,
      stats: stats,
    );
  }

  void _resolveTie(_PendingTap a, _PendingTap b) {
    final signalAt = _signalAt!;
    final p1 = a.player == Player.p1 ? a : b;
    final p2 = a.player == Player.p1 ? b : a;
    _finishRound(
      DuelPhase.tie,
      RoundResult(
        outcome: RoundOutcome.tie,
        winnerMs: _ms(p1.at - signalAt),
        loserMs: _ms(p2.at - signalAt),
      ),
    );
  }

  void _finishRound(
    DuelPhase phase,
    RoundResult result, {
    List<int>? scores,
    List<PlayerStats>? stats,
  }) {
    _pending = null;
    _decoys = const [];
    _nextDecoy = 0;
    _phaseStart = clock.now();
    final nextScores = scores ?? _state.scores;
    Player? winner;
    for (final p in Player.values) {
      if (nextScores[p.index] >= _state.settings.winScore) winner = p;
    }
    _emit(
      _state.copyWith(
        phase: winner != null ? DuelPhase.matchOver : phase,
        scores: nextScores,
        stats: stats,
        lastResult: result,
        matchWinner: winner,
        clearOrb: true,
      ),
    );
  }

  void _beginWaiting(Duration t0) {
    final settings = _state.settings;
    final wait = settings.wait;
    final delayMs = _sampleDelay(
      wait.minMs.toDouble(),
      wait.maxMs.toDouble(),
      wait.minGapMs.toDouble(),
    );
    _lastDelayMs = delayMs;
    var signalAt = t0 + _durationMs(delayMs);

    final decoys = <DecoyWindow>[];
    if (settings.hasDecoys) {
      final target = settings.effectiveTarget;
      final candidates = SignalPalette.decoysFor(target, colorBlind: settings.colorBlind);
      final count = _rng.nextInt(GameTiming.maxDecoys + 1);
      var cursor = t0;
      SignalColor? previous;
      for (var i = 0; i < count; i++) {
        cursor += _durationMs(
          _uniform(GameTiming.decoyLeadMinMs.toDouble(), GameTiming.decoyLeadMaxMs.toDouble()),
        );
        final length = _durationMs(
          _uniform(GameTiming.decoyMinMs.toDouble(), GameTiming.decoyMaxMs.toDouble()),
        );
        final pool = candidates.length > 1
            ? candidates.where((c) => c != previous).toList()
            : candidates;
        final color = pool[_rng.nextInt(pool.length)];
        final shape = SignalPalette.decoyShapes[_rng.nextInt(SignalPalette.decoyShapes.length)];
        decoys.add(DecoyWindow(start: cursor, end: cursor + length, color: color, shape: shape));
        previous = color;
        cursor += length;
      }
      if (decoys.isNotEmpty) {
        final earliest =
            cursor +
            _durationMs(
              GameTiming.postDecoyMinMs + _rng.nextDouble() * GameTiming.postDecoyJitterMs,
            );
        if (earliest > signalAt) signalAt = earliest;
      }
    }

    _decoys = decoys;
    _nextDecoy = 0;
    _signalAt = signalAt;
    _pending = null;
    _phaseStart = t0;
    _emit(
      _state.copyWith(
        phase: DuelPhase.waiting,
        round: _state.round + 1,
        clearOrb: true,
        clearSignal: true,
        clearResult: true,
        clearTapped: true,
      ),
    );
  }

  /// Uniform in [min, max] while keeping ≥ [gap] from the last delay.
  double _sampleDelay(double min, double max, double gap) {
    final last = _lastDelayMs;
    if (last == null) return _uniform(min, max);
    final lowLen = ((last - gap) - min).clamp(0.0, double.infinity);
    final highLen = (max - (last + gap)).clamp(0.0, double.infinity);
    final total = lowLen + highLen;
    if (total <= 0) return _uniform(min, max);
    final x = _rng.nextDouble() * total;
    return x < lowLen ? min + x : last + gap + (x - lowLen);
  }

  double _uniform(double min, double max) => min + _rng.nextDouble() * (max - min);

  void _resetRound() {
    _pending = null;
    _decoys = const [];
    _nextDecoy = 0;
    _signalAt = null;
  }

  static Duration _durationMs(double ms) => Duration(microseconds: (ms * 1000).round());

  static int _ms(Duration d) => (d.inMicroseconds / 1000).round();
}
