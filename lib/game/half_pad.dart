/// One player's half: full-bleed touch area + score bar + round result.
///
/// Uses [Listener.onPointerDown] (no gesture arena, no tap slop) so every new
/// pointer counts immediately; each half is independent for multi-touch.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../theme/celebration.dart';
import '../theme/characters.dart';
import '../theme/decor.dart';
import '../theme/tap_burst.dart';
import 'score_dots.dart';

enum ResultTone { win, lose, foul, neutral }

/// What the half shows in its center after a round. Every outcome carries
/// text (and fouls an ✕ icon), never color alone.
class HalfResult {
  const HalfResult({
    this.badge,
    this.label,
    this.big,
    this.sub,
    this.icon,
    this.tone = ResultTone.neutral,
  });

  /// Small pill above the label ("WINNER" / "TOO SLOW").
  final String? badge;
  final String? label;
  final String? big;
  final String? sub;
  final IconData? icon;
  final ResultTone tone;
}

class HalfPad extends StatefulWidget {
  const HalfPad({
    required this.name,
    required this.hue,
    required this.score,
    required this.winScore,
    required this.lastMs,
    this.signalFill,
    this.result,
    this.target,
    this.targetLabel,
    this.coach,
    this.shakeTrigger = 0,
    this.highlight = false,
    this.edgeInset = 0,
    this.leadingInset = 0,
    this.reduceMotion = false,
    this.player = Player.p1,
    this.mood = CharacterMood.waiting,
    this.frozenBursts = const [],
    this.onPointerDown,
    super.key,
  });

  final String name;
  final PlayerHue hue;
  final int score;
  final int winScore;

  /// Already formatted ("287 ms" / "—").
  final String lastMs;

  /// Non-null while the real signal is on: the whole half takes this color.
  final Color? signalFill;
  final HalfResult? result;

  /// Target Color mode: small "Target · Blue ●" reminder.
  final Color? target;
  final String? targetLabel;

  final String? coach;
  final int shakeTrigger;
  final bool highlight;

  /// Safe-area inset on this player's screen edge.
  final double edgeInset;

  /// Space reserved at the bar's start (e.g. for the pause button).
  final double leadingInset;
  final bool reduceMotion;
  final Player player;
  final CharacterMood mood;
  final List<TapBurstSpec> frozenBursts;
  final PointerDownEventListener? onPointerDown;

  @override
  State<HalfPad> createState() => _HalfPadState();
}

class _LiveTap {
  _LiveTap(this.dx, this.dy, this.controller);

  final double dx;
  final double dy;
  final AnimationController controller;
}

class _HalfPadState extends State<HalfPad> with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: AppMotion.shake,
    value: 1,
  );
  final List<_LiveTap> _taps = [];

  @override
  void didUpdateWidget(HalfPad old) {
    super.didUpdateWidget(old);
    if (widget.shakeTrigger > old.shakeTrigger) _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    for (final t in _taps) {
      t.controller.dispose();
    }
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    widget.onPointerDown?.call(event);
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    final size = box.size;
    if (size.width <= 0 || size.height <= 0) return;
    final controller = AnimationController(vsync: this, duration: AppMotion.tapBurst);
    final tap = _LiveTap(
      (local.dx / size.width).clamp(0.08, 0.92),
      (local.dy / size.height).clamp(0.12, 0.82),
      controller,
    );
    _taps.add(tap);
    controller
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..forward().whenComplete(() {
        controller.dispose();
        _taps.remove(tap);
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final onSignal = widget.signalFill != null;
    final ink = onSignal ? AppColors.onSignal : widget.hue.ink;
    final textColor = onSignal ? AppColors.onSignal : AppColors.text;
    final muted = onSignal ? AppColors.onSignalMuted : AppColors.textMuted;
    final bg = widget.signalFill ?? widget.hue.tint;
    final theme = Theme.of(context).textTheme;
    final fouled = widget.result?.tone == ResultTone.foul;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final t = _shake.value;
          final active = t < 1;
          final decay = (1 - t) * (1 - t);
          final dx = active && !widget.reduceMotion
              ? math.sin(t * math.pi * 2 * AppMotion.shakeOscillations) *
                    AppDimens.shakeAmplitude *
                    decay
              : 0.0;
          final flash = active ? AppColors.foulFlashAlpha * (1 - t) : 0.0;
          final hold = fouled ? AppColors.foulHoldAlpha : 0.0;
          final tint = math.max(flash, hold);
          return ColoredBox(
            color: bg,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.highlight) ColoredBox(color: AppColors.hairline),
                if (tint > 0) ColoredBox(color: AppColors.danger.withValues(alpha: tint)),
                Transform.translate(offset: Offset(dx, 0), child: child),
              ],
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!onSignal) const ThemeDecor(kind: DecorKind.half),
            if (onSignal) const SignalCelebrate(),
            if (widget.result == null)
              Positioned(
                right: 4,
                bottom: AppDimens.halfBarHeight + AppDimens.halfPadding + widget.edgeInset,
                child: CharacterView(
                  player: widget.player,
                  mood: widget.mood,
                  size: AppDimens.characterHalf,
                ),
              ),
            Align(
              alignment: widget.result == null ? const Alignment(0, -0.15) : const Alignment(0, 0.12),
              child: _center(theme, textColor, muted),
            ),
            Positioned(
              left: AppDimens.halfPadding + widget.leadingInset,
              right: AppDimens.halfPadding,
              bottom: AppDimens.halfPadding + widget.edgeInset,
              child: _bar(theme, ink, textColor, muted),
            ),
            if (widget.target != null)
              Positioned(
                left: AppDimens.halfPadding,
                top: AppDimens.halfPadding,
                child: _TargetChip(
                  label: widget.targetLabel ?? '',
                  color: widget.target!,
                  textColor: muted,
                ),
              ),
            TapBurstLayer(
              bursts: [
                ...widget.frozenBursts,
                for (final t in _taps) TapBurstSpec(dx: t.dx, dy: t.dy, progress: t.controller.value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _center(TextTheme theme, Color textColor, Color muted) {
    final r = widget.result;
    if (r == null) {
      final coach = widget.coach;
      if (coach == null) {
        if (widget.signalFill != null) return const SizedBox.shrink();
        return ExcludeSemantics(
          child: Text(
            '${widget.score}',
            style: theme.displayLarge!.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: AppType.idleScore,
              color: textColor.withValues(alpha: AppType.idleScoreAlpha),
              fontFeatures: AppFonts.tabular,
              shadows: const [],
              letterSpacing: AppType.tightTracking,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapXxl),
        child: Text(
          coach,
          textAlign: TextAlign.center,
          style: theme.bodyLarge!.copyWith(color: muted),
        ),
      );
    }
    final labelColor = switch (r.tone) {
      ResultTone.foul => widget.signalFill != null ? AppColors.onSignal : AppColors.danger,
      ResultTone.win => widget.signalFill != null ? AppColors.onSignal : widget.hue.ink,
      _ => muted,
    };
    final bigColor = r.tone == ResultTone.lose ? muted : textColor;
    final forceTint = r.tone == ResultTone.foul || widget.signalFill != null;
    // No entry animation: the result is fully visible on its first frame.
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.page,
        0,
        AppDimens.page,
        AppDimens.halfBarHeight + widget.edgeInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (r.icon != null) ...[
            Container(
              width: AppDimens.foulIcon,
              height: AppDimens.foulIcon,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: labelColor, width: AppDimens.foulIconStroke),
              ),
              child: Icon(r.icon, color: labelColor, size: AppDimens.foulIcon * 0.62),
            ),
            const SizedBox(height: AppDimens.gapS),
          ],
          if (r.badge != null) ...[
            _Badge(
              text: r.badge!,
              filled: r.tone == ResultTone.win,
              color: r.tone == ResultTone.win ? widget.hue.ink : muted,
            ),
            const SizedBox(height: AppDimens.gapS),
          ],
          if (r.label != null)
            Text(
              r.label!,
              textAlign: TextAlign.center,
              style: theme.displayMedium!.copyWith(
                fontSize: AppType.resultLabel,
                color: forceTint ? labelColor : null,
              ),
            ),
          if (r.big != null) ...[
            if (r.label != null) const SizedBox(height: AppDimens.gapXs),
            Text(
              r.big!,
              textAlign: TextAlign.center,
              style: theme.displayLarge!.copyWith(
                fontSize: r.tone == ResultTone.lose ? AppType.resultLabel : AppType.resultMs,
                color: forceTint ? bigColor : null,
                fontFeatures: AppFonts.tabular,
              ),
            ),
          ],
          if (r.sub != null) ...[
            const SizedBox(height: AppDimens.gapS),
            Text(
              r.sub!,
              textAlign: TextAlign.center,
              style: theme.bodyLarge!.copyWith(color: muted, fontSize: AppType.resultSub),
            ),
          ],
          const SizedBox(height: AppDimens.gapM),
          CharacterView(
            player: widget.player,
            mood: widget.mood,
            size: AppDimens.characterResult,
          ),
        ],
      ),
    );
  }

  Widget _bar(TextTheme theme, Color ink, Color textColor, Color muted) {
    return SizedBox(
      height: AppDimens.halfBarHeight,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: AppDimens.dot,
                  height: AppDimens.dot,
                  decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppDimens.gapS),
                Flexible(
                  child: Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleMedium!.copyWith(
                      fontSize: AppType.halfName,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.gapM),
                ScoreDots(
                  score: widget.score,
                  total: widget.winScore,
                  color: ink,
                  emptyColor: onSignalAware(muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.gapM),
          Text(
            widget.lastMs,
            style: theme.titleMedium!.copyWith(
              fontSize: AppType.halfMs,
              color: muted,
              fontFeatures: AppFonts.tabular,
            ),
          ),
        ],
      ),
    );
  }

  Color onSignalAware(Color muted) => widget.signalFill != null ? muted : AppColors.textFaint;
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.label, required this.color, required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: textColor)),
        const SizedBox(width: AppDimens.gapS),
        Container(
          width: AppDimens.targetDot,
          height: AppDimens.targetDot,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline, width: AppDimens.hairline),
          ),
          child: Container(
            width: AppDimens.targetDot * AppDimens.orbShapeFactor * 1.4,
            height: AppDimens.targetDot * AppDimens.orbShapeFactor * 1.4,
            decoration: const BoxDecoration(color: AppColors.onSignal, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.filled, required this.color});

  final String text;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.badgePadH,
        vertical: AppDimens.badgePadV,
      ),
      decoration: BoxDecoration(
        color: filled ? color : AppColors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        border: Border.all(color: color, width: AppDimens.dotStroke),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: AppType.resultBadge,
          fontWeight: FontWeight.w700,
          letterSpacing: AppType.overlineTracking,
          color: filled ? AppColors.onSignal : color,
        ),
      ),
    );
  }
}
