/// Center signal orb (rfc §2.1).
///
/// The breath runs on its own fixed-period controller and never reacts to
/// the round schedule, so motion can't leak the signal. In the duel the body
/// stays still ([calm]) and only the ring fades in and out, so it reads as
/// a status light rather than a button. The fill switches instantly.
/// Shapes: ● = tap, ▲ ■ ✕ = decoys.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/signal_palette.dart';

class SignalOrb extends StatefulWidget {
  const SignalOrb({
    this.size = AppDimens.orbDuel,
    this.fill,
    this.shape,
    this.calm = false,
    this.reduceMotion = false,
    this.pulseTrigger = 0,
    this.pulseUp = false,
    this.pulseColor = AppColors.text,
    super.key,
  });

  final double size;

  /// Null = neutral ring.
  final Color? fill;
  final SignalShape? shape;

  /// Static body, breathing ring only (duel waiting state).
  final bool calm;
  final bool reduceMotion;

  /// Changing this runs a 250 ms pulse toward the winner's half.
  final int pulseTrigger;
  final bool pulseUp;
  final Color pulseColor;

  @override
  State<SignalOrb> createState() => _SignalOrbState();
}

class _SignalOrbState extends State<SignalOrb> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AppMotion.breath ~/ 2,
  )..repeat(reverse: true);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
    value: 1,
  );

  @override
  void didUpdateWidget(SignalOrb old) {
    super.didUpdateWidget(old);
    if (widget.pulseTrigger != old.pulseTrigger &&
        widget.pulseTrigger != 0 &&
        !widget.reduceMotion) {
      _pulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_breath, _pulse]),
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_breath.value);
            final still = widget.reduceMotion || widget.calm;
            final scale = still
                ? 1.0
                : AppMotion.breathMin + (AppMotion.breathMax - AppMotion.breathMin) * t;
            final opacity = widget.reduceMotion && !widget.calm
                ? AppMotion.reducedOpacityMin + (1 - AppMotion.reducedOpacityMin) * t
                : 1.0;
            final ringAlpha = !widget.calm
                ? 1.0
                : widget.reduceMotion
                ? AppMotion.ringBreathMax
                : AppMotion.ringBreathMin + (AppMotion.ringBreathMax - AppMotion.ringBreathMin) * t;
            return CustomPaint(
              painter: _PulsePainter(
                progress: _pulse.value,
                up: widget.pulseUp,
                color: widget.pulseColor,
              ),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: widget.fill == null ? opacity : 1,
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _OrbPainter(
                      fill: widget.fill,
                      shape: widget.shape,
                      ringAlpha: ringAlpha,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({this.fill, this.shape, this.ringAlpha = 1});

  final Color? fill;
  final SignalShape? shape;
  final double ringAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final fillColor = fill;

    if (fillColor == null) {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.orbCore);
      canvas.drawCircle(
        center,
        radius - AppDimens.orbRingWidth / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppDimens.orbRingWidth
          ..color = AppColors.orbRing.withValues(alpha: ringAlpha),
      );
      return;
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = fillColor.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, AppDimens.orbGlowBlur / 2),
    );
    canvas.drawCircle(center, radius, Paint()..color = fillColor);

    final s = shape;
    if (s != null) _paintShape(canvas, center, radius * 2 * AppDimens.orbShapeFactor, s);
  }

  void _paintShape(Canvas canvas, Offset c, double extent, SignalShape shape) {
    final paint = Paint()..color = AppColors.onSignal;
    final h = extent / 2;
    switch (shape) {
      case SignalShape.circle:
        canvas.drawCircle(c, h, paint);
      case SignalShape.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: extent, height: extent),
            Radius.circular(extent * 0.12),
          ),
          paint,
        );
      case SignalShape.triangle:
        final path = Path()
          ..moveTo(c.dx, c.dy - h * 1.1)
          ..lineTo(c.dx + h * 1.1, c.dy + h * 0.8)
          ..lineTo(c.dx - h * 1.1, c.dy + h * 0.8)
          ..close();
        canvas.drawPath(path, paint);
      case SignalShape.cross:
        final bar = extent * 0.26;
        final arm = extent * 1.15;
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 4);
        for (final (w, h) in [(arm, bar), (bar, arm)]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: w, height: h),
              Radius.circular(bar * 0.3),
            ),
            paint,
          );
        }
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.fill != fill || old.shape != shape || old.ringAlpha != ringAlpha;
}

/// Thin ring that expands and drifts toward the winning half.
class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.up, required this.color});

  final double progress;
  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final t = Curves.easeOut.transform(progress);
    final radius = size.shortestSide / 2 * (1 + (AppDimens.orbPulseGrow - 1) * t);
    final dy = AppDimens.orbPulseTravel * t * (up ? -1 : 1);
    canvas.drawCircle(
      size.center(Offset(0, dy)),
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimens.orbRingWidth
        ..color = color.withValues(alpha: (1 - t) * 0.7),
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.progress != progress;
}
