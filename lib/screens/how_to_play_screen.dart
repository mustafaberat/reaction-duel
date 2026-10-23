/// How to Play (rfc §7): a live mini demo rendered with the real [DuelBoard],
/// one sentence per step, Next / Skip, ending in Play now / Close.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/duel_settings.dart';
import '../engine/duel_state.dart';
import '../engine/signal_palette.dart';
import '../game/duel_board.dart';
import '../game/half_pad.dart';
import '../l10n/app_localizations.dart';
import '../theme/decor.dart';
import '../theme/tap_burst.dart';

enum HowStep { sit, wait, tap, early, decoy }

/// Logical size the demo board is laid out at before being scaled down.
const Size _demoBoardSize = Size(393, 852);

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({
    this.initialStep = 0,
    this.includeDecoyStep,
    this.frozenProgress,
    super.key,
  });

  final int initialStep;

  /// Null = only when Target Color is the selected mode.
  final bool? includeDecoyStep;

  /// Fixes the demo loop at this point (0–1) for deterministic captures.
  final double? frozenProgress;

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  late int _step = widget.initialStep;
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: AppMotion.demoLoop,
    value: widget.frozenProgress ?? 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.frozenProgress == null) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  void _go(int step) {
    setState(() => _step = step);
    if (widget.frozenProgress == null) {
      _loop.forward(from: 0).then((_) => _loop.repeat());
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final match = services.settings.match;
    final includeDecoy =
        widget.includeDecoyStep ?? match.rules.mode == DuelMode.targetColor;
    final steps = [
      HowStep.sit,
      HowStep.wait,
      HowStep.tap,
      HowStep.early,
      if (includeDecoy) HowStep.decoy,
    ];
    final index = _step.clamp(0, steps.length - 1);
    final step = steps[index];
    final last = index == steps.length - 1;
    final (title, body) = switch (step) {
      HowStep.sit => (l10n.howStep1Title, l10n.howStep1Body),
      HowStep.wait => (l10n.howStep2Title, l10n.howStep2Body),
      HowStep.tap => (l10n.howStep3Title, l10n.howStep3Body),
      HowStep.early => (l10n.howStep4Title, l10n.howStep4Body),
      HowStep.decoy => (l10n.howStep5Title, l10n.howStep5Body),
    };
    final (h1, h2) = match.resolvedHues;

    return ThemedScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pageTight,
                AppDimens.gapS,
                AppDimens.pageTight,
                0,
              ),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.howClose,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.howToPlay,
                      textAlign: TextAlign.center,
                      style: theme.titleMedium,
                    ),
                  ),
                  SizedBox(
                    width: AppDimens.iconButton,
                    child: Text(
                      l10n.howStepOf(index + 1, steps.length),
                      textAlign: TextAlign.center,
                      style: theme.bodySmall!.copyWith(
                        fontFeatures: AppFonts.tabular,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.gapS),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _demoBoardSize.width / _demoBoardSize.height,
                    child: _DemoFrame(
                      child: AnimatedBuilder(
                        animation: _loop,
                        builder: (context, _) => _Demo(
                          step: step,
                          t: _loop.value,
                          hues: [h1, h2],
                          target: match.rules.mode == DuelMode.targetColor
                              ? match.rules.effectiveTarget
                              : SignalPalette.resolveTarget(
                                  SignalColor.green,
                                  colorBlind: match.rules.colorBlind,
                                ),
                          colorBlind: match.rules.colorBlind,
                          reduceMotion: services.settings.reduceMotionFor(
                            context,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final tight = c.maxWidth < 400;
                  final pad = tight ? AppDimens.pageTight : AppDimens.page;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      pad,
                      0,
                      pad,
                      AppDimens.gapM,
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.displayMedium,
                          ),
                        ),
                        const SizedBox(height: AppDimens.gapS),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          maxLines: tight ? 4 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyLarge!.copyWith(
                            color: AppColors.textMuted,
                            fontSize: tight ? 14 : 16,
                          ),
                        ),
                        const SizedBox(height: AppDimens.gapS),
                        _StepDots(count: steps.length, index: index),
                        const SizedBox(height: AppDimens.gapM),
                        if (!last)
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.secondary(
                                  label: l10n.howSkip,
                                  compact: tight,
                                  height: tight
                                      ? AppDimens.buttonHeightSmall
                                      : AppDimens.buttonHeight,
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                              ),
                              const SizedBox(width: AppDimens.gapS),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  label: l10n.howNext,
                                  icon: Icons.arrow_forward_rounded,
                                  compact: tight,
                                  height: tight
                                      ? AppDimens.buttonHeightSmall
                                      : AppDimens.buttonHeight,
                                  onPressed: () => _go(index + 1),
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.secondary(
                                  label: l10n.howClose,
                                  compact: tight,
                                  height: tight
                                      ? AppDimens.buttonHeightSmall
                                      : AppDimens.buttonHeight,
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                              ),
                              const SizedBox(width: AppDimens.gapS),
                              Expanded(
                                flex: 2,
                                child: AppButton(
                                  label: l10n.howPlayNow,
                                  icon: Icons.play_arrow_rounded,
                                  compact: tight,
                                  height: tight
                                      ? AppDimens.buttonHeightSmall
                                      : AppDimens.buttonHeight,
                                  onPressed: () => Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.setup),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoFrame extends StatelessWidget {
  const _DemoFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.demoFrameRadius),
        border: Border.all(
          color: AppColors.stroke,
          width: AppDimens.demoFrameBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.demoFrameRadius - AppDimens.demoFrameBorder,
        ),
        child: FittedBox(
          child: SizedBox.fromSize(size: _demoBoardSize, child: child),
        ),
      ),
    );
  }
}

/// Timeline of one demo loop. [t] is 0–1.
class _Demo extends StatelessWidget {
  const _Demo({
    required this.step,
    required this.t,
    required this.hues,
    required this.target,
    required this.colorBlind,
    required this.reduceMotion,
  });

  final HowStep step;
  final double t;
  final List<PlayerHue> hues;
  final SignalColor target;
  final bool colorBlind;
  final bool reduceMotion;

  static const int _demoP1Ms = 243;
  static const int _demoP2Ms = 312;
  static const double _signalAt = 0.4;
  static const double _pressAt = 0.5;
  static const double _scoredAt = 0.58;
  static const double _pressHold = 0.06;
  static const double _sitHalf = 0.5;
  static const double _sitPressFrom = 0.2;
  static const double _sitPressTo = 0.32;
  static const double _earlyAt = 0.35;
  static const double _decoyFrom = 0.18;
  static const double _decoyTo = 0.42;
  static const double _targetAt = 0.6;
  static const double _targetPressAt = 0.68;
  static const double _targetScoredAt = 0.76;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = [l10n.player1, l10n.player2];
    final classic = DuelSettings(colorBlind: colorBlind);
    final targetRules = DuelSettings(
      mode: DuelMode.targetColor,
      target: target,
      colorBlind: colorBlind,
    );

    DuelState waiting(DuelSettings s) =>
        DuelState(phase: DuelPhase.waiting, settings: s, round: 1);
    DuelState signal(DuelSettings s) => DuelState(
      phase: DuelPhase.signal,
      settings: s,
      round: 1,
      orbColor: s.effectiveTarget,
      orbShape: SignalShape.circle,
    );
    DuelState scored(DuelSettings s) => DuelState(
      phase: DuelPhase.scored,
      settings: s,
      round: 1,
      scores: const [1, 0],
      lastResult: const RoundResult(
        outcome: RoundOutcome.scored,
        winner: Player.p1,
        winnerMs: _demoP1Ms,
        loserMs: _demoP2Ms,
      ),
    );

    DuelState state;
    Player? highlight;
    var hand = Player.p1;
    var pressed = false;
    List<HalfResult?>? labels;
    var shake = 0;
    var coach = false;

    switch (step) {
      case HowStep.sit:
        state = DuelState(phase: DuelPhase.ready, settings: classic);
        highlight = t < _sitHalf ? Player.p1 : Player.p2;
        hand = highlight;
        pressed =
            (t % _sitHalf) > _sitPressFrom && (t % _sitHalf) < _sitPressTo;
        labels = [
          HalfResult(
            label: names[0],
            tone: highlight == Player.p1 ? ResultTone.win : ResultTone.neutral,
          ),
          HalfResult(
            label: names[1],
            tone: highlight == Player.p2 ? ResultTone.win : ResultTone.neutral,
          ),
        ];
      case HowStep.wait:
        state = waiting(classic);
        hand = Player.p1;
        coach = true;
      case HowStep.tap:
        state = t < _signalAt
            ? waiting(classic)
            : (t < _scoredAt ? signal(classic) : scored(classic));
        hand = Player.p1;
        pressed = t >= _pressAt && t < _scoredAt;
      case HowStep.early:
        if (t < _earlyAt) {
          state = waiting(classic);
        } else {
          state = DuelState(
            phase: DuelPhase.foul,
            settings: classic,
            round: 1,
            scores: const [0, 1],
            stats: const [PlayerStats(fouls: 1), PlayerStats()],
            lastResult: const RoundResult(
              outcome: RoundOutcome.foul,
              foulBy: Player.p1,
              winner: Player.p2,
              reason: FoulReason.early,
            ),
          );
          shake = 1;
        }
        hand = Player.p1;
        pressed = t >= _earlyAt && t < _earlyAt + _pressHold;
      case HowStep.decoy:
        final decoy = SignalPalette.decoysFor(
          targetRules.effectiveTarget,
          colorBlind: colorBlind,
        ).first;
        if (t >= _decoyFrom && t < _decoyTo) {
          state = waiting(targetRules).copyWith(
            phase: DuelPhase.decoy,
            orbColor: decoy,
            orbShape: SignalShape.triangle,
          );
        } else if (t < _targetAt) {
          state = waiting(targetRules);
        } else if (t < _targetScoredAt) {
          state = signal(targetRules);
        } else {
          state = scored(targetRules);
        }
        hand = Player.p1;
        pressed = t >= _targetPressAt && t < _targetScoredAt;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DuelBoard(
          state: state,
          names: names,
          hues: hues,
          coach: coach,
          reduceMotion: reduceMotion,
          shakeTriggers: [shake, 0],
          highlight: highlight,
          labelOverride: labels,
          frozenBursts: pressed
              ? [
                  (
                    hand,
                    TapBurstSpec(
                      dx: 0.72,
                      dy: 0.62,
                      progress: 0.4,
                      winning: step == HowStep.tap,
                      player: hand,
                    ),
                  ),
                ]
              : const [],
        ),
        _Hand(player: hand, pressed: pressed, t: t, reduceMotion: reduceMotion),
      ],
    );
  }
}

class _Hand extends StatelessWidget {
  const _Hand({
    required this.player,
    required this.pressed,
    required this.t,
    required this.reduceMotion,
  });

  final Player player;
  final bool pressed;
  final double t;
  final bool reduceMotion;

  static const double _p1Y = 0.84;
  static const double _p2Y = 0.16;
  static const double _x = 0.76;
  static const double _bob = 6;

  @override
  Widget build(BuildContext context) {
    final y = player == Player.p1 ? _p1Y : _p2Y;
    final bob = reduceMotion || pressed
        ? 0.0
        : math.sin(t * math.pi * 4) * _bob;
    final size = AppDimens.demoHand * 2;
    return Positioned(
      left:
          _demoBoardSize.width * (player == Player.p1 ? _x : 1 - _x) - size / 2,
      top: _demoBoardSize.height * y - size / 2 + bob,
      width: size,
      height: size,
      child: Transform.rotate(
        angle: player == Player.p2 ? math.pi : 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (pressed)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.text.withValues(alpha: 0.18),
                ),
              ),
            AnimatedScale(
              scale: pressed ? 0.86 : 1,
              duration: AppMotion.demoPress,
              child: Icon(
                Icons.touch_app_rounded,
                size: size * 0.7,
                color: AppColors.text,
                shadows: [Shadow(color: AppColors.background, blurRadius: 16)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.fast,
            margin: const EdgeInsets.symmetric(horizontal: AppDimens.gapXs / 2),
            width: i == index ? AppDimens.gapXl : AppDimens.gapS - 2,
            height: AppDimens.gapS - 2,
            decoration: BoxDecoration(
              color: i == index ? AppColors.accent : AppColors.stroke,
              borderRadius: BorderRadius.circular(AppDimens.gapS),
            ),
          ),
      ],
    );
  }
}
