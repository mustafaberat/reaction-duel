/// Match rules chosen on the setup screen (rfc §5). Engine-only fields.
library;

import '../config/app_config.dart';
import 'signal_palette.dart';

enum DuelMode { classic, targetColor }

enum WaitPreset {
  short(GameTiming.waitShortMinMs, GameTiming.waitShortMaxMs, GameTiming.minDelayGapNarrowMs),
  normal(GameTiming.waitNormalMinMs, GameTiming.waitNormalMaxMs, GameTiming.minDelayGapNarrowMs),
  long(GameTiming.waitLongMinMs, GameTiming.waitLongMaxMs, GameTiming.minDelayGapMs);

  const WaitPreset(this.minMs, this.maxMs, this.minGapMs);

  final int minMs;
  final int maxMs;

  /// Consecutive delays differ by at least this.
  final int minGapMs;
}

enum FoulPenalty { opponentPlusOne, selfMinusOne, roundLossOnly }

class DuelSettings {
  const DuelSettings({
    this.mode = DuelMode.classic,
    this.target = SignalColor.green,
    this.winScore = GameRules.defaultWinScore,
    this.wait = WaitPreset.normal,
    this.penalty = FoulPenalty.opponentPlusOne,
    this.guessGuard = true,
    this.colorBlind = false,
  });

  final DuelMode mode;
  final SignalColor target;
  final int winScore;
  final WaitPreset wait;
  final FoulPenalty penalty;
  final bool guessGuard;
  final bool colorBlind;

  /// Color the orb turns to on the real signal.
  SignalColor get effectiveTarget => mode == DuelMode.classic
      ? SignalColor.green
      : SignalPalette.resolveTarget(target, colorBlind: colorBlind);

  bool get hasDecoys => mode == DuelMode.targetColor;

  DuelSettings copyWith({
    DuelMode? mode,
    SignalColor? target,
    int? winScore,
    WaitPreset? wait,
    FoulPenalty? penalty,
    bool? guessGuard,
    bool? colorBlind,
  }) {
    return DuelSettings(
      mode: mode ?? this.mode,
      target: target ?? this.target,
      winScore: winScore ?? this.winScore,
      wait: wait ?? this.wait,
      penalty: penalty ?? this.penalty,
      guessGuard: guessGuard ?? this.guessGuard,
      colorBlind: colorBlind ?? this.colorBlind,
    );
  }
}
