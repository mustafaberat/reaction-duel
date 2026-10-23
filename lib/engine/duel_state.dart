/// Immutable snapshots of a duel, consumed by the UI and tests.
library;

import 'duel_settings.dart';
import 'signal_palette.dart';

enum Player {
  p1,
  p2;

  Player get other => this == Player.p1 ? Player.p2 : Player.p1;
}

enum DuelPhase {
  /// Cooldown at match start / after resume. Input locked.
  ready,

  /// Neutral orb, random delay running. Tap = foul.
  waiting,

  /// Target Color mode: orb shows a wrong color. Tap = foul.
  decoy,

  /// Orb shows the target color. First valid tap scores.
  signal,

  // Result phases hold the result on screen for resultHoldMs (input locked),
  // then go straight to a fresh neutral waiting period.
  scored,
  foul,
  noContest,
  tie,

  paused,
  matchOver,
}

enum FoulReason { early, decoy, guess }

enum RoundOutcome { scored, foul, noContest, tie }

class RoundResult {
  const RoundResult({
    required this.outcome,
    this.winner,
    this.foulBy,
    this.reason,
    this.winnerMs,
    this.loserMs,
  });

  final RoundOutcome outcome;
  final Player? winner;
  final Player? foulBy;
  final FoulReason? reason;

  /// For ties both players' times are in [winnerMs] (p1) / [loserMs] (p2).
  final int? winnerMs;
  final int? loserMs;

  int? msFor(Player p) {
    if (outcome == RoundOutcome.tie) {
      return p == Player.p1 ? winnerMs : loserMs;
    }
    if (winner == null) return null;
    return p == winner ? winnerMs : loserMs;
  }

  RoundResult withLoserMs(int ms) => RoundResult(
    outcome: outcome,
    winner: winner,
    foulBy: foulBy,
    reason: reason,
    winnerMs: winnerMs,
    loserMs: ms,
  );
}

class PlayerStats {
  const PlayerStats({this.reactions = const [], this.fouls = 0});

  final List<int> reactions;
  final int fouls;

  int? get bestMs => reactions.isEmpty ? null : reactions.reduce((a, b) => a < b ? a : b);

  int? get averageMs =>
      reactions.isEmpty ? null : (reactions.reduce((a, b) => a + b) / reactions.length).round();

  PlayerStats addReaction(int ms) => PlayerStats(reactions: [...reactions, ms], fouls: fouls);

  PlayerStats addFoul() => PlayerStats(reactions: reactions, fouls: fouls + 1);
}

class DuelState {
  const DuelState({
    required this.phase,
    required this.settings,
    this.scores = const [0, 0],
    this.stats = const [PlayerStats(), PlayerStats()],
    this.round = 0,
    this.orbColor,
    this.orbShape,
    this.signalAt,
    this.lastResult,
    this.matchWinner,
    this.tappedThisRound = const [false, false],
  });

  final DuelPhase phase;
  final DuelSettings settings;
  final List<int> scores;
  final List<PlayerStats> stats;

  /// Number of rounds started (ties and no-contests included).
  final int round;

  /// Color currently filling the orb; null = neutral ring.
  final SignalColor? orbColor;
  final SignalShape? orbShape;

  /// Engine clock time the signal was scheduled (signal phase onwards).
  final Duration? signalAt;
  final RoundResult? lastResult;
  final Player? matchWinner;

  /// Per-player lock for the current round. First pointer-down counts;
  /// later taps on that half are ignored until the next waiting period.
  final List<bool> tappedThisRound;

  int scoreOf(Player p) => scores[p.index];
  PlayerStats statsOf(Player p) => stats[p.index];
  bool hasTapped(Player p) => tappedThisRound[p.index];

  bool get isSignal => phase == DuelPhase.signal;
  bool get inputLocked => switch (phase) {
    DuelPhase.waiting || DuelPhase.decoy || DuelPhase.signal => false,
    _ => true,
  };

  DuelState copyWith({
    DuelPhase? phase,
    DuelSettings? settings,
    List<int>? scores,
    List<PlayerStats>? stats,
    int? round,
    SignalColor? orbColor,
    SignalShape? orbShape,
    bool clearOrb = false,
    Duration? signalAt,
    bool clearSignal = false,
    RoundResult? lastResult,
    bool clearResult = false,
    Player? matchWinner,
    bool clearWinner = false,
    List<bool>? tappedThisRound,
    bool clearTapped = false,
  }) {
    return DuelState(
      phase: phase ?? this.phase,
      settings: settings ?? this.settings,
      scores: scores ?? this.scores,
      stats: stats ?? this.stats,
      round: round ?? this.round,
      orbColor: clearOrb ? null : (orbColor ?? this.orbColor),
      orbShape: clearOrb ? null : (orbShape ?? this.orbShape),
      signalAt: clearSignal ? null : (signalAt ?? this.signalAt),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      matchWinner: clearWinner ? null : (matchWinner ?? this.matchWinner),
      tappedThisRound: clearTapped
          ? const [false, false]
          : (tappedThisRound ?? this.tappedThisRound),
    );
  }
}
