/// Presentational duel layout: two halves (top one rotated 180°) + orb.
///
/// Pure function of a [DuelState]; the live screen and the How to Play demo
/// both render through this widget.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/duel_settings.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/characters.dart';
import '../theme/orb_frame.dart';
import '../theme/tap_burst.dart';
import 'duel_labels.dart';
import 'half_pad.dart';
import 'signal_orb.dart';

typedef HalfTap = void Function(Player player, PointerDownEvent event);

class DuelBoard extends StatelessWidget {
  const DuelBoard({
    required this.state,
    required this.names,
    required this.hues,
    this.onTap,
    this.coach = false,
    this.reduceMotion = false,
    this.shakeTriggers = const [0, 0],
    this.highlight,
    this.labelOverride,
    this.safeTop = 0,
    this.safeBottom = 0,
    this.pauseButton,
    this.frozenBursts = const [],
    super.key,
  });

  final DuelState state;

  /// Indexed by [Player.index].
  final List<String> names;
  final List<PlayerHue> hues;
  final HalfTap? onTap;
  final bool coach;
  final bool reduceMotion;
  final List<int> shakeTriggers;

  /// Demo only: emphasize one half.
  final Player? highlight;

  /// Demo only: replaces the result in each half.
  final List<HalfResult?>? labelOverride;

  final double safeTop;
  final double safeBottom;
  final Widget? pauseButton;
  final List<(Player, TapBurstSpec)> frozenBursts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = state.settings;
    final signalFill = state.isSignal
        ? AppColors.signal(state.orbColor!)
        : null;
    final showTarget = settings.mode == DuelMode.targetColor;
    final target = settings.effectiveTarget;
    final showResult = switch (state.phase) {
      DuelPhase.scored ||
      DuelPhase.foul ||
      DuelPhase.tie ||
      DuelPhase.noContest ||
      DuelPhase.matchOver => true,
      _ => false,
    };
    final coachText = coach && !showResult ? l10n.duelCoach : null;

    Widget half(Player p) {
      final last = state.lastResult;
      final lastMs = _lastMs(p);
      return HalfPad(
        name: names[p.index],
        hue: hues[p.index],
        score: state.scoreOf(p),
        winScore: settings.winScore,
        lastMs: lastMs == null ? l10n.duelNoTime : l10n.duelMs(lastMs),
        signalFill: signalFill,
        result: labelOverride != null
            ? labelOverride![p.index]
            : (showResult && last != null ? _result(l10n, last, p) : null),
        target: showTarget ? AppColors.signal(target) : null,
        targetLabel: '${l10n.duelTarget} · ${target.label(l10n)}',
        coach: coachText,
        shakeTrigger: shakeTriggers[p.index],
        highlight: highlight == p,
        edgeInset: p == Player.p1 ? safeBottom : safeTop,
        leadingInset: p == Player.p1 && pauseButton != null
            ? AppDimens.pauseButton + AppDimens.gapM
            : 0,
        reduceMotion: reduceMotion,
        player: p,
        mood: moodFor(p, state),
        frozenBursts: [
          for (final b in frozenBursts)
            if (b.$1 == p) b.$2,
        ],
        onPointerDown: onTap == null ? null : (e) => onTap!(p, e),
      );
    }

    final last = state.lastResult;
    final pulseUp = last?.winner == Player.p2;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: signalFill ?? AppColors.background,
          child: Column(
            children: [
              Expanded(
                child: RotatedBox(quarterTurns: 2, child: half(Player.p2)),
              ),
              Expanded(child: half(Player.p1)),
            ],
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Row(
              children: [
                Expanded(child: _Hairline(visible: signalFill == null)),
                const SizedBox(
                  width: AppDimens.orbDuel + AppDimens.centerGap * 2,
                ),
                Expanded(child: _Hairline(visible: signalFill == null)),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: _CenterCue(
              cue: switch (state.phase) {
                DuelPhase.ready || DuelPhase.waiting => _Cue.wait,
                DuelPhase.signal => _Cue.go,
                _ => null,
              },
              waitText: l10n.duelWait,
              goText: l10n.duelGo,
              orb: OrbFrame(
                size: AppDimens.orbDuel,
                child: SignalOrb(
                  fill: state.orbColor == null
                      ? null
                      : AppColors.signal(state.orbColor!),
                  shape: state.orbShape,
                  calm: true,
                  reduceMotion: reduceMotion,
                  pulseTrigger:
                      state.phase == DuelPhase.scored ||
                          state.phase == DuelPhase.matchOver
                      ? state.round
                      : 0,
                  pulseUp: pulseUp,
                  pulseColor: last?.winner == null
                      ? AppColors.text
                      : hues[last!.winner!.index].ink,
                ),
              ),
            ),
          ),
        ),
        if (pauseButton != null)
          Positioned(
            left: AppDimens.halfPadding - AppDimens.gapXs,
            bottom:
                AppDimens.halfPadding +
                safeBottom +
                (AppDimens.halfBarHeight - AppDimens.pauseButton) / 2,
            child: pauseButton!,
          ),
      ],
    );
  }

  int? _lastMs(Player p) {
    final last = state.lastResult;
    if (last != null) {
      final ms = last.msFor(p);
      if (ms != null) return ms;
    }
    final reactions = state.statsOf(p).reactions;
    return reactions.isEmpty ? null : reactions.last;
  }

  HalfResult? _result(AppLocalizations l10n, RoundResult r, Player p) {
    switch (r.outcome) {
      case RoundOutcome.scored:
        final ms = r.msFor(p);
        if (r.winner == p) {
          return HalfResult(
            badge: l10n.duelWinner,
            label: l10n.duelPlusOne,
            big: l10n.duelMs(ms!),
            tone: ResultTone.win,
          );
        }
        return HalfResult(
          badge: l10n.duelTooSlow,
          big: ms == null ? l10n.duelNoTime : l10n.duelMs(ms),
          tone: ResultTone.lose,
        );
      case RoundOutcome.foul:
        if (r.foulBy == p) {
          final label = switch (r.reason!) {
            FoulReason.early => l10n.duelEarly,
            FoulReason.guess => l10n.duelGuess,
            FoulReason.decoy => l10n.duelDecoy,
          };
          final penalty = switch (state.settings.penalty) {
            FoulPenalty.opponentPlusOne => null,
            FoulPenalty.selfMinusOne => l10n.duelMinusOne,
            FoulPenalty.roundLossOnly => l10n.duelRoundLost,
          };
          final sub = [
            if (r.reason == FoulReason.guess) l10n.duelGuessSub,
            ?penalty,
          ].join(AppGlyphs.separator);
          return HalfResult(
            icon: Icons.close_rounded,
            label: label,
            sub: sub.isEmpty ? null : sub,
            tone: ResultTone.foul,
          );
        }
        if (r.winner == p) {
          return HalfResult(
            label: l10n.duelPlusOne,
            sub: l10n.duelRivalFoul,
            tone: ResultTone.win,
          );
        }
        return HalfResult(sub: l10n.duelRivalFoul);
      case RoundOutcome.tie:
        final ms = r.msFor(p);
        return HalfResult(
          label: l10n.duelTie,
          big: ms == null ? null : l10n.duelMs(ms),
          sub: l10n.duelTieSub,
        );
      case RoundOutcome.noContest:
        return HalfResult(label: l10n.duelNoContest);
    }
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.hairline,
      color: visible ? AppColors.hairline : AppColors.transparent,
    );
  }
}

enum _Cue { wait, go }

/// Orb with a text cue on both sides: the top copy is rotated for P2, so the
/// state reads from either seat. WAIT is calm and muted; GO! is big.
/// Decoys get no text — only their shape tells them apart from ●.
class _CenterCue extends StatelessWidget {
  const _CenterCue({
    required this.cue,
    required this.waitText,
    required this.goText,
    required this.orb,
  });

  final _Cue? cue;
  final String waitText;
  final String goText;
  final Widget orb;

  @override
  Widget build(BuildContext context) {
    final label = _label(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _slot(
          RotatedBox(quarterTurns: 2, child: ExcludeSemantics(child: label)),
        ),
        const SizedBox(height: AppDimens.cueGap),
        orb,
        const SizedBox(height: AppDimens.cueGap),
        _slot(label),
      ],
    );
  }

  /// Fixed height keeps the orb centered whatever the cue.
  Widget _slot(Widget child) => SizedBox(
    height: AppType.cueGo * AppType.heroHeight + AppDimens.gapL,
    child: Center(child: child),
  );

  Widget _label(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    switch (cue) {
      case null:
        return const SizedBox.shrink();
      case _Cue.wait:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.do_not_touch_outlined,
              size: AppDimens.cueIcon,
              color: AppColors.waitCue,
            ),
            const SizedBox(width: AppDimens.gapS),
            Text(
              waitText,
              style: theme.titleMedium!.copyWith(
                fontFamily: AppFonts.displayFor(
                  Localizations.localeOf(context),
                ),
                fontFamilyFallback: AppFonts.fallback,
                fontWeight: FontWeight.w700,
                fontSize: AppType.cueWait,
                letterSpacing: AppType.cueTracking,
                color: AppColors.waitCue,
              ),
            ),
          ],
        );
      case _Cue.go:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.highlight.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            goText,
            style: theme.displayLarge!.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: AppType.cueGo,
              height: AppType.heroHeight,
              letterSpacing: AppType.tightTracking,
              color: AppColors.outline,
              shadows: const [],
            ),
          ),
        );
    }
  }
}
