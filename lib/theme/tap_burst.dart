/// Animated tap feedback: dirt burst + a stamped dinosaur footprint.
///
/// [progress] 0→1 drives scale / fade / particles so capture tools can freeze
/// a frame by passing a fixed value. One [CustomPainter] per layer.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/duel_state.dart';
import 'paint_kit.dart';

class TapBurstSpec {
  const TapBurstSpec({
    required this.dx,
    required this.dy,
    required this.progress,
    this.winning = false,
    this.player = Player.p1,
    this.reduceMotion = false,
    this.persist = false,
  });

  /// Frame where dirt is airborne and the print is fully stamped.
  static const double holdProgress = 0.28;

  /// Local alignment in the half, 0–1.
  final double dx;
  final double dy;
  final double progress;
  final bool winning;
  final Player player;
  final bool reduceMotion;

  /// Too-early stamp: stay fully visible (no fade) until the next round.
  final bool persist;
}

class TapBurstLayer extends StatelessWidget {
  const TapBurstLayer({required this.bursts, super.key});

  final List<TapBurstSpec> bursts;

  @override
  Widget build(BuildContext context) {
    if (bursts.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: TapBurstPainter(bursts: bursts),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class TapBurstPainter extends CustomPainter {
  TapBurstPainter({required this.bursts});

  final List<TapBurstSpec> bursts;

  static const _earth = [
    Color(0xFF8B4518),
    Color(0xFFC46A24),
    Color(0xFF6B2E0C),
    Color(0xFFD08A30),
  ];
  static const _dust = Color(0xFFF3D9A4);
  static const _printFill = Color(0xFF5A3A1E);
  static const _printLine = Color(0xFF3A2410);
  static const _printHi = Color(0xFF8B5E34);
  static const int _clods = 14;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bursts) {
      final c = Offset(b.dx * size.width, b.dy * size.height);
      final t = b.persist ? TapBurstSpec.holdProgress : b.progress.clamp(0.0, 1.0);
      _burst(canvas, c, t, b);
    }
  }

  void _burst(Canvas canvas, Offset c, double t, TapBurstSpec b) {
    final win = b.winning ? 1.32 : 1.0;
    final still = b.reduceMotion;
    final footOpacity = _footFade(t, still) * (b.winning ? 1 : 0.92);
    final footScale = _footPop(t, still) * win;
    const footSize = 64.0;

    if (!still) {
      _dirt(canvas, c, t, win);
    } else {
      _dirtStill(canvas, c, t, win);
    }

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(footScale);
    canvas.rotate(_stampYaw(b.player));
    _theropodPrint(canvas, Offset.zero, footSize, footOpacity);
    canvas.restore();
  }

  /// Toes of [_theropodPrint] point toward local -Y (top of this half).
  /// Each HalfPad is already in owner-local space (P2 is RotatedBox 180°),
  /// so extra yaw would aim the track at its owner instead of forward.
  double _stampYaw(Player player) => switch (player) {
    Player.p1 => 0,
    Player.p2 => 0,
  };

  /// 0.6 → 1.0 with a soft overshoot in the first ~200 ms of a 900 ms burst.
  double _footPop(double t, bool still) {
    if (still) return 1;
    const popEnd = 0.22;
    if (t >= popEnd) return 1;
    return 0.6 + 0.4 * Curves.easeOutBack.transform(t / popEnd);
  }

  double _footFade(double t, bool still) {
    if (still) return (1 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);
    final fadeT = ((t - 0.22) / 0.78).clamp(0.0, 1.0);
    return (1 - Curves.easeIn.transform(fadeT)).clamp(0.0, 1.0);
  }

  void _dirt(Canvas canvas, Offset c, double t, double win) {
    // Particles settle by ~700 ms of the 900 ms controller.
    final life = (t / 0.78).clamp(0.0, 1.0);
    final fade = (1 - Curves.easeIn.transform(life)).clamp(0.0, 1.0);
    for (var i = 0; i < _clods; i++) {
      final ang =
          -math.pi / 2 + (i - (_clods - 1) / 2) * 0.38 + (i * 0.19 % 0.28);
      final speed = (88 + (i % 5) * 22.0) * win;
      final g = 240.0 + (i % 3) * 28;
      final x = math.cos(ang) * speed * life;
      final y = math.sin(ang) * speed * life + 0.5 * g * life * life;
      final r = (5.4 + (i % 4) * 2.1) * (1.08 - life * 0.2) * win;
      _clod(
        canvas,
        c + Offset(x, y),
        r,
        _earth[i % _earth.length].withValues(
          alpha: fade * (i.isEven ? 0.96 : 0.78),
        ),
        rot: i * 0.7 + life * 1.8,
        dust: i % 3 == 2,
      );
    }
    for (var i = 0; i < 10; i++) {
      final ang = -math.pi / 2 + (i - 4.5) * 0.36 + 0.08;
      final d = (28 + (i % 4) * 13.0) * win * life;
      canvas.drawCircle(
        c + Offset(
          math.cos(ang) * d,
          math.sin(ang) * d + 0.32 * 160 * life * life,
        ),
        (0.7 + (i % 3) * 0.35) * win,
        PaintKit.fill(_dust.withValues(alpha: fade * (i.isEven ? 0.8 : 0.55))),
      );
    }
  }

  void _dirtStill(Canvas canvas, Offset c, double t, double win) {
    final fade = (1 - t).clamp(0.0, 1.0);
    for (var i = 0; i < 8; i++) {
      final ang = -math.pi / 2 + i * math.pi / 4;
      final d = 22.0 * win;
      canvas.drawCircle(
        c + Offset(math.cos(ang) * d, math.sin(ang) * d * 0.55),
        4.5 * win,
        PaintKit.fill(_earth[i % _earth.length].withValues(alpha: fade * 0.6)),
      );
    }
    for (var i = 0; i < 7; i++) {
      final ang = -math.pi / 2 + i * math.pi / 3.5 + 0.28;
      canvas.drawCircle(
        c + Offset(math.cos(ang) * 15 * win, math.sin(ang) * 9 * win),
        (0.7 + (i % 2) * 0.35) * win,
        PaintKit.fill(_dust.withValues(alpha: fade * 0.62)),
      );
    }
  }

  void _clod(
    Canvas canvas,
    Offset c,
    double r,
    Color color, {
    required double rot,
    required bool dust,
  }) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    if (dust) {
      canvas.drawCircle(Offset.zero, r * 0.7, PaintKit.fill(color));
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 2.1, height: r * 1.35),
        PaintKit.fill(color),
      );
    }
    canvas.restore();
  }

  /// Classic theropod track: three separated clawed toes + a small heel.
  /// Shared by both players so the stamp stays readable at phone size.
  void _theropodPrint(Canvas canvas, Offset c, double s, double opacity) {
    final fill = _printFill.withValues(alpha: opacity);
    final line = _printLine.withValues(alpha: opacity);
    final hi = _printHi.withValues(alpha: opacity * 0.55);
    final w = s * 0.036;

    _printPad(
      canvas,
      c + Offset(0, s * 0.38),
      s * 0.24,
      s * 0.16,
      fill,
      line,
      hi,
      w,
    );

    const spread = 34 * math.pi / 180;
    _theropodToe(
      canvas,
      c + Offset(-s * 0.3, s * 0.16),
      s,
      -spread,
      longToe: false,
      fill: fill,
      line: line,
      hi: hi,
      strokeW: w,
    );
    _theropodToe(
      canvas,
      c + Offset(0, s * 0.08),
      s,
      0,
      longToe: true,
      fill: fill,
      line: line,
      hi: hi,
      strokeW: w,
    );
    _theropodToe(
      canvas,
      c + Offset(s * 0.3, s * 0.16),
      s,
      spread,
      longToe: false,
      fill: fill,
      line: line,
      hi: hi,
      strokeW: w,
    );
  }

  void _theropodToe(
    Canvas canvas,
    Offset start,
    double s,
    double angle, {
    required bool longToe,
    required Color fill,
    required Color line,
    required Color hi,
    required double strokeW,
  }) {
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);

    final paths = <Path>[
      Path()..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: s * (longToe ? 0.17 : 0.155),
          height: s * 0.24,
        ),
      ),
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(0, s * (longToe ? -0.2 : -0.18)),
          width: s * (longToe ? 0.14 : 0.125),
          height: s * 0.22,
        ),
      ),
    ];
    if (longToe) {
      paths.add(
        Path()..addOval(
          Rect.fromCenter(
            center: Offset(0, s * -0.38),
            width: s * 0.11,
            height: s * 0.16,
          ),
        ),
      );
    }
    final body = PaintKit.unionAll(paths);
    canvas.drawPath(body, PaintKit.fill(fill));
    canvas.drawPath(body, PaintKit.stroke(line, strokeW));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-s * 0.03, -s * 0.04),
        width: s * 0.07,
        height: s * 0.05,
      ),
      PaintKit.fill(hi),
    );

    _printClaw(
      canvas,
      Offset(0, s * (longToe ? -0.47 : -0.29)),
      s * 0.07,
      fill,
      line,
      strokeW,
    );
    canvas.restore();
  }

  void _printPad(
    Canvas canvas,
    Offset c,
    double w,
    double h,
    Color fill,
    Color line,
    Color hi,
    double strokeW,
  ) {
    final oval = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawOval(oval, PaintKit.fill(fill));
    canvas.drawOval(oval, PaintKit.stroke(line, strokeW));
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-w * 0.14, -h * 0.16),
        width: w * 0.4,
        height: h * 0.3,
      ),
      PaintKit.fill(hi),
    );
  }

  void _printClaw(
    Canvas canvas,
    Offset base,
    double len,
    Color fill,
    Color line,
    double strokeW,
  ) {
    final half = len * 0.3;
    final path = Path()
      ..moveTo(base.dx - half, base.dy + len * 0.1)
      ..quadraticBezierTo(
        base.dx,
        base.dy + len * 0.16,
        base.dx + half,
        base.dy + len * 0.1,
      )
      ..lineTo(base.dx, base.dy - len)
      ..close();
    canvas.drawPath(path, PaintKit.fill(fill));
    canvas.drawPath(path, PaintKit.stroke(line, strokeW * 0.85));
  }

  @override
  bool shouldRepaint(TapBurstPainter old) => old.bursts != bursts;
}
