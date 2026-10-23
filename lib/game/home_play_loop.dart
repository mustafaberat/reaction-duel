/// Home sketch of one round: wait, tap the paw, the faster time wins.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../theme/paint_kit.dart';

class HomePlayLoop extends StatefulWidget {
  const HomePlayLoop({
    required this.size,
    required this.waitLabel,
    required this.goLabel,
    required this.slowTime,
    required this.fastTime,
    this.reduceMotion = false,
    this.frozenProgress,
    super.key,
  });

  final double size;

  /// Same words the match shows on the wait / go cue.
  final String waitLabel;
  final String goLabel;
  final String slowTime;
  final String fastTime;
  final bool reduceMotion;

  /// Fixes the loop at this point (0–1) for captures.
  final double? frozenProgress;

  /// Frozen frame: both times are up and the faster bubble is gold.
  static const double stillFrame = 0.84;

  /// Demo times shown in the sketch (ms).
  static const int demoSlowMs = 361;
  static const int demoFastMs = 214;

  @override
  State<HomePlayLoop> createState() => _HomePlayLoopState();
}

class _HomePlayLoopState extends State<HomePlayLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(HomePlayLoop old) {
    super.didUpdateWidget(old);
    if (old.reduceMotion != widget.reduceMotion ||
        old.frozenProgress != widget.frozenProgress) {
      _sync();
    }
  }

  void _sync() {
    final frozen = widget.frozenProgress;
    if (frozen != null) {
      _loop.stop();
      _loop.value = frozen;
    } else if (widget.reduceMotion) {
      _loop.stop();
      _loop.value = HomePlayLoop.stillFrame;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _loop,
          builder: (context, _) => _Board(
            t: _loop.value,
            size: widget.size,
            waitLabel: widget.waitLabel,
            goLabel: widget.goLabel,
            slowTime: widget.slowTime,
            fastTime: widget.fastTime,
          ),
        ),
      ),
    );
  }
}

enum _Phase { wait, go, press, result }

enum _TailAim { toTopRight, toBottomLeft }

/// Shared layout so the painted print and the palm label stay lined up.
abstract final class _PadGeom {
  static double sizeOf(double s) => s * 0.56;

  static Offset center(double s, double nudge) =>
      Offset(s * 0.50, s * 0.50 + nudge);

  static Rect heel(double s, double nudge) {
    final p = sizeOf(s);
    return Rect.fromCenter(
      center: center(s, nudge) + Offset(0, p * 0.18),
      width: p * 0.56,
      height: p * 0.40,
    );
  }

  /// Heel, then left / mid / right toes. Local space around [c].
  static List<Rect> ovals(Offset c, double s) => [
    Rect.fromCenter(
      center: c + Offset(0, s * 0.18),
      width: s * 0.56,
      height: s * 0.44,
    ),
    Rect.fromCenter(
      center: c + Offset(-s * 0.24, -s * 0.12),
      width: s * 0.34,
      height: s * 0.38,
    ),
    Rect.fromCenter(
      center: c + Offset(0, -s * 0.22),
      width: s * 0.36,
      height: s * 0.42,
    ),
    Rect.fromCenter(
      center: c + Offset(s * 0.24, -s * 0.12),
      width: s * 0.34,
      height: s * 0.38,
    ),
  ];
}

class _Board extends StatelessWidget {
  const _Board({
    required this.t,
    required this.size,
    required this.waitLabel,
    required this.goLabel,
    required this.slowTime,
    required this.fastTime,
  });

  final double t;
  final double size;
  final String waitLabel;
  final String goLabel;
  final String slowTime;
  final String fastTime;

  static const double _goAt = 0.18;
  static const double _pressAt = 0.38;
  static const double _resultAt = 0.56;
  static const double _resetAt = 0.92;

  _Phase get _phase {
    if (t >= _resetAt) return _Phase.wait;
    if (t >= _resultAt) return _Phase.result;
    if (t >= _pressAt) return _Phase.press;
    if (t >= _goAt) return _Phase.go;
    return _Phase.wait;
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase;
    final live = phase != _Phase.wait;
    final pressed = phase == _Phase.press;
    final showFast = phase == _Phase.press || phase == _Phase.result;
    final showSlow = phase == _Phase.result;
    final won = phase == _Phase.result;
    final stamp = phase == _Phase.press || phase == _Phase.result;
    final pressNudge = pressed ? size * 0.022 : 0.0;
    final heel = _PadGeom.heel(size, pressNudge);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: CustomPaint(painter: _MeadowFill())),
          Positioned.fill(
            child: CustomPaint(
              painter: _GrassPadPainter(
                live: live,
                pressed: pressed,
                stamp: stamp,
                won: won,
              ),
            ),
          ),
          Positioned.fromRect(
            rect: heel,
            child: _PadLabel(
              text: live ? goLabel : waitLabel,
              live: live,
              size: heel.width,
            ),
          ),
          if (showSlow)
            Positioned(
              left: size * 0.04,
              top: size * 0.012,
              child: _SpeechBubble(
                text: slowTime,
                size: size,
                winner: false,
                aim: _TailAim.toTopRight,
              ),
            ),
          if (showFast)
            Positioned(
              right: size * 0.04,
              bottom: size * 0.012,
              child: _SpeechBubble(
                text: fastTime,
                size: size,
                winner: won,
                aim: _TailAim.toBottomLeft,
              ),
            ),
        ],
      ),
    );
  }
}

class _PadLabel extends StatelessWidget {
  const _PadLabel({required this.text, required this.live, required this.size});

  final String text;
  final bool live;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.08),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.fallback,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0.2,
              color: live ? AppColors.onAccent : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.size,
    required this.winner,
    required this.aim,
  });

  final String text;
  final double size;
  final bool winner;
  final _TailAim aim;

  @override
  Widget build(BuildContext context) {
    final fill = winner ? const Color(0xFFFFD24A) : AppColors.surface;
    final font = (size * 0.068).clamp(8.0, 13.0);
    final tail = (size * 0.07).clamp(7.0, 13.0);
    final padH = size * 0.032;
    final padV = size * 0.015;
    final towardBlue = aim == _TailAim.toTopRight;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: size * 0.48),
      child: CustomPaint(
        painter: _BubblePainter(
          fill: fill,
          aim: aim,
          tail: tail,
          strokeW: (size * 0.016).clamp(1.4, 2.2),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            padH + (towardBlue ? 0 : tail * 0.85),
            padV,
            padH + (towardBlue ? tail * 0.85 : 0),
            padV,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontFamilyFallback: AppFonts.fallback,
                fontSize: font,
                fontWeight: FontWeight.w800,
                height: 1,
                color: AppColors.text,
                fontFeatures: AppFonts.tabular,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.fill,
    required this.aim,
    required this.tail,
    required this.strokeW,
  });

  final Color fill;
  final _TailAim aim;
  final double tail;
  final double strokeW;

  @override
  void paint(Canvas canvas, Size size) {
    final towardBlue = aim == _TailAim.toTopRight;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        towardBlue ? 0 : tail * 0.7,
        0,
        size.width - tail * 0.7,
        size.height,
      ),
      Radius.circular(size.height * 0.46),
    );
    final tip = towardBlue
        ? Offset(size.width, size.height * 0.28)
        : Offset(0, size.height * 0.72);
    final baseA = towardBlue
        ? Offset(size.width - tail * 0.85, size.height * 0.12)
        : Offset(tail * 0.85, size.height * 0.88);
    final baseB = towardBlue
        ? Offset(size.width - tail * 0.85, size.height * 0.78)
        : Offset(tail * 0.85, size.height * 0.22);
    final spike = Path()
      ..moveTo(baseA.dx, baseA.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(baseB.dx, baseB.dy)
      ..close();
    final shape = Path.combine(
      PathOperation.union,
      Path()..addRRect(body),
      spike,
    );
    canvas.drawPath(
      shape.shift(Offset(0, strokeW * 0.9)),
      PaintKit.fill(AppColors.outline.withValues(alpha: 0.28)),
    );
    canvas.drawPath(shape, PaintKit.fill(fill));
    canvas.drawPath(shape, PaintKit.stroke(AppColors.outline, strokeW));
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.fill != fill || old.aim != aim || old.tail != tail;
}

class _MeadowFill extends CustomPainter {
  const _MeadowFill();

  static const _meadow = Color(0xFFF6E8A0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, PaintKit.fill(_meadow));
    final paint = PaintKit.fill(const Color(0x338BC94A));
    const dots = [
      Offset(0.12, 0.38),
      Offset(0.88, 0.34),
      Offset(0.10, 0.66),
      Offset(0.90, 0.62),
      Offset(0.18, 0.52),
      Offset(0.82, 0.48),
    ];
    for (final d in dots) {
      canvas.drawCircle(
        Offset(d.dx * size.width, d.dy * size.height),
        size.shortestSide * 0.012,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GrassPadPainter extends CustomPainter {
  const _GrassPadPainter({
    required this.live,
    required this.pressed,
    required this.stamp,
    required this.won,
  });

  final bool live;
  final bool pressed;
  final bool stamp;
  final bool won;

  static const _grass = Color(0xFF8BC94A);
  static const _grassDeep = Color(0xFF5FA636);
  static const _stone = Color(0xFFF4EBD0);
  static const _green = Color(0xFF4CAF50);
  static const _dirt = Color(0xFF8B5A2B);
  static const _blue = Color(0xFF5AA4E0);
  static const _frill = Color(0xFF3D7EC8);
  static const _greenDino = Color(0xFF5BBF4A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final grassH = s * 0.145;
    final head = s * 0.145;

    _grassStrip(canvas, size, top: true, h: grassH);
    _grassStrip(canvas, size, top: false, h: grassH);

    // Faces sit on the grass line so eyes and smiles stay visible.
    _triHead(canvas, Offset(s * 0.82, grassH + head * 0.18), head);
    _trexHead(canvas, Offset(s * 0.18, s - grassH - head * 0.16), head);
    if (won) {
      PaintKit.crown(canvas, Offset(s * 0.34, s - grassH - head * 0.42), s * 0.07);
    }

    final pad = _PadGeom.sizeOf(s);
    final center = _PadGeom.center(s, pressed ? s * 0.022 : 0);
    _pad(canvas, center, pad);

    if (stamp) {
      _dirtBurst(canvas, Offset(s * 0.84, s * 0.54), s);
      _miniPrint(canvas, Offset(s * 0.86, s * 0.64), s * 0.15);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(AppDimens.cardRadius),
      ),
      PaintKit.stroke(AppColors.outline, (s * 0.02).clamp(1.8, 2.8)),
    );
  }

  void _grassStrip(
    Canvas canvas,
    Size size, {
    required bool top,
    required double h,
  }) {
    final w = size.width;
    final edge = Path();
    const samples = 10;
    if (top) {
      edge.moveTo(0, 0);
      edge.lineTo(w, 0);
      for (var i = samples; i >= 0; i--) {
        final x = w * i / samples;
        edge.lineTo(x, h + math.sin(i * 1.05) * h * 0.18);
      }
      edge.close();
    } else {
      final topY = size.height - h;
      edge.moveTo(0, size.height);
      edge.lineTo(w, size.height);
      for (var i = samples; i >= 0; i--) {
        final x = w * i / samples;
        edge.lineTo(x, topY + math.sin(i * 1.05 + 0.7) * h * 0.18);
      }
      edge.close();
    }
    canvas.drawPath(edge, PaintKit.fill(_grass));
    canvas.drawPath(
      edge,
      PaintKit.stroke(AppColors.outline.withValues(alpha: 0.28), 1.4),
    );

    final blade = PaintKit.fill(_grassDeep);
    final origin = top ? h * 0.72 : size.height - h * 0.12;
    for (var i = 0; i < 9; i++) {
      final x = w * (0.06 + i * 0.11);
      final tall = h * (0.38 + (i % 3) * 0.1);
      final lean = (i.isEven ? -1 : 1) * h * 0.1;
      final dir = top ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(x - h * 0.07, origin)
        ..quadraticBezierTo(
          x + lean * 0.25,
          origin + dir * tall * 0.55,
          x + lean,
          origin + dir * tall,
        )
        ..quadraticBezierTo(
          x + h * 0.02,
          origin + dir * tall * 0.4,
          x + h * 0.06,
          origin,
        )
        ..close();
      canvas.drawPath(path, blade);
    }
  }

  /// Blue triceratops head peeking from the top grass (home dino, head only).
  void _triHead(Canvas canvas, Offset c, double r) {
    final line = AppColors.outline;
    final w = r * 0.12;

    final frill = Path()
      ..addOval(
        Rect.fromCenter(
          center: c + Offset(0, -r * 0.22),
          width: r * 1.85,
          height: r * 1.15,
        ),
      );
    PaintKit.blob(canvas, frill, color: _frill, width: w);
    for (final a in [-0.8, -0.4, 0.0, 0.4, 0.8]) {
      final p = c +
          Offset(math.sin(a) * r * 0.78, -r * 0.22 - math.cos(a) * r * 0.42);
      PaintKit.circle(
        canvas,
        p,
        r * 0.14,
        color: PaintKit.lighten(_frill, 0.08),
        width: w * 0.55,
      );
    }

    _horn(canvas, c + Offset(-r * 0.2, -r * 0.58), r * 0.42, true);
    _horn(canvas, c + Offset(r * 0.16, -r * 0.52), r * 0.36, true);
    _horn(canvas, c + Offset(-r * 0.58, -r * 0.02), r * 0.32, false);

    PaintKit.blob(
      canvas,
      Path()..addOval(
        Rect.fromCenter(center: c, width: r * 1.4, height: r * 1.15),
      ),
      color: _blue,
      width: w,
    );

    final beak = Path()
      ..moveTo(c.dx - r * 0.42, c.dy + r * 0.08)
      ..quadraticBezierTo(
        c.dx - r * 0.78,
        c.dy + r * 0.16,
        c.dx - r * 0.44,
        c.dy + r * 0.34,
      )
      ..quadraticBezierTo(
        c.dx - r * 0.22,
        c.dy + r * 0.22,
        c.dx - r * 0.16,
        c.dy + r * 0.1,
      )
      ..close();
    PaintKit.blob(canvas, beak, color: const Color(0xFFFFE08A), width: w * 0.7);

    PaintKit.eye(
      canvas,
      c + Offset(-r * 0.1, -r * 0.04),
      r * 0.22,
      look: const Offset(-0.12, 0.18),
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.32, c.dy + r * 0.22)
        ..quadraticBezierTo(
          c.dx - r * 0.1,
          c.dy + r * 0.36,
          c.dx + r * 0.12,
          c.dy + r * 0.22,
        ),
      PaintKit.stroke(line, w * 0.7),
    );
    PaintKit.blush(canvas, c + Offset(r * 0.22, r * 0.16), r * 0.13, alpha: 0.5);
    PaintKit.highlight(
      canvas,
      c + Offset(-r * 0.18, -r * 0.16),
      r * 0.16,
      alpha: 0.35,
    );
  }

  void _horn(Canvas canvas, Offset tip, double len, bool up) {
    final base = tip +
        Offset(up ? len * 0.08 : len * 0.42, up ? len * 0.72 : len * 0.18);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx - len * 0.16, base.dy)
      ..lineTo(base.dx + len * 0.16, base.dy)
      ..close();
    PaintKit.blob(
      canvas,
      path,
      color: const Color(0xFFFFF4DC),
      width: len * 0.1,
    );
  }

  /// Green T-rex head peeking from the bottom grass (home dino, head only).
  void _trexHead(Canvas canvas, Offset c, double r) {
    final line = AppColors.outline;
    final w = r * 0.12;

    PaintKit.blob(
      canvas,
      PaintKit.unionAll([
        Path()..addOval(
          Rect.fromCenter(center: c, width: r * 1.35, height: r * 1.25),
        ),
        Path()..addOval(
          Rect.fromCenter(
            center: c + Offset(r * 0.48, r * 0.08),
            width: r * 1.0,
            height: r * 0.7,
          ),
        ),
      ]),
      color: _greenDino,
      width: w,
    );
    PaintKit.eye(
      canvas,
      c + Offset(-r * 0.06, -r * 0.1),
      r * 0.22,
      look: const Offset(0.28, -0.08),
    );
    canvas.drawCircle(
      c + Offset(r * 0.74, r * 0.02),
      r * 0.05,
      PaintKit.fill(line),
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + r * 0.18, c.dy + r * 0.22)
        ..quadraticBezierTo(
          c.dx + r * 0.42,
          c.dy + r * 0.34,
          c.dx + r * 0.64,
          c.dy + r * 0.16,
        ),
      PaintKit.stroke(line, w * 0.7),
    );
    PaintKit.blush(canvas, c + Offset(r * 0.1, r * 0.16), r * 0.13, alpha: 0.5);
    PaintKit.highlight(
      canvas,
      c + Offset(-r * 0.2, -r * 0.28),
      r * 0.16,
      alpha: 0.35,
    );
  }

  void _pad(Canvas canvas, Offset c, double s) {
    final depth = pressed ? s * 0.045 : s * 0.11;
    final fill = live ? _green : _stone;
    final ovals = _PadGeom.ovals(c, s);
    final strokeW = s * 0.048;

    for (final oval in ovals) {
      canvas.drawOval(
        oval.shift(Offset(0, depth)),
        PaintKit.fill(AppColors.outline.withValues(alpha: 0.42)),
      );
    }
    for (final oval in ovals) {
      canvas.drawOval(oval, PaintKit.fill(fill));
    }
    for (final oval in ovals) {
      canvas.drawOval(oval, PaintKit.stroke(AppColors.outline, strokeW));
    }

    final heel = ovals.first;
    canvas.drawOval(
      Rect.fromCenter(
        center: heel.center + Offset(-heel.width * 0.12, -heel.height * 0.16),
        width: heel.width * 0.42,
        height: heel.height * 0.28,
      ),
      PaintKit.fill(Colors.white.withValues(alpha: live ? 0.22 : 0.38)),
    );
    for (final oval in ovals.skip(1)) {
      canvas.drawOval(
        Rect.fromCenter(
          center: oval.center + Offset(-oval.width * 0.12, -oval.height * 0.16),
          width: oval.width * 0.38,
          height: oval.height * 0.26,
        ),
        PaintKit.fill(Colors.white.withValues(alpha: live ? 0.18 : 0.32)),
      );
    }
  }

  void _dirtBurst(Canvas canvas, Offset c, double s) {
    const clods = [
      (Offset(-0.55, -0.85), 0.038),
      (Offset(0.08, -1.15), 0.03),
      (Offset(0.72, -0.5), 0.034),
      (Offset(0.88, 0.22), 0.026),
      (Offset(0.28, 0.72), 0.032),
      (Offset(-0.48, 0.52), 0.024),
      (Offset(-0.08, -0.12), 0.022),
      (Offset(0.42, -0.08), 0.018),
    ];
    for (var i = 0; i < clods.length; i++) {
      final (o, r) = clods[i];
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(o.dx * s * 0.11, o.dy * s * 0.09),
          width: s * r * 2.2,
          height: s * r * 1.45,
        ),
        PaintKit.fill(_dirt.withValues(alpha: 0.9 - i * 0.04)),
      );
    }
  }

  void _miniPrint(Canvas canvas, Offset c, double s) {
    const fill = Color(0xFF5A3A1E);
    for (final oval in _PadGeom.ovals(c, s)) {
      canvas.drawOval(oval, PaintKit.fill(fill));
    }
  }

  @override
  bool shouldRepaint(_GrassPadPainter old) =>
      old.live != live ||
      old.pressed != pressed ||
      old.stamp != stamp ||
      old.won != won;
}
