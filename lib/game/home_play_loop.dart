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
    final pad = size * 0.44;
    final pressNudge = pressed ? size * 0.03 : 0.0;

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
              ),
            ),
          ),
          Positioned(
            left: (size - pad) / 2,
            top: (size - pad) / 2 + pressNudge,
            width: pad,
            height: pad,
            child: _PadLabel(
              text: live ? goLabel : waitLabel,
              live: live,
              size: pad,
            ),
          ),
          if (showSlow)
            Positioned(
              right: size * 0.04,
              top: size * 0.03,
              child: _SpeechBubble(text: slowTime, size: size, winner: false),
            ),
          if (showFast)
            Positioned(
              right: size * 0.04,
              bottom: size * 0.03,
              child: _SpeechBubble(text: fastTime, size: size, winner: won),
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
    return Align(
      alignment: const Alignment(0, 0.38),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.fallback,
              fontSize: size * 0.18,
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
  });

  final String text;
  final double size;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    final fill = winner ? const Color(0xFFFFD24A) : AppColors.surface;
    final font = (size * 0.07).clamp(8.0, 14.0);
    final crown = font * 1.15;

    return Container(
      constraints: BoxConstraints(maxWidth: size * 0.48),
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.035,
        vertical: size * 0.016,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(size * 0.05),
        border: Border.all(
          color: AppColors.outline,
          width: (size * 0.018).clamp(1.5, 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.22),
            offset: Offset(0, size * 0.012),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (winner) ...[
            CustomPaint(
              size: Size(crown * 1.35, crown),
              painter: const _CrownPainter(),
            ),
            SizedBox(width: size * 0.02),
          ],
          Flexible(
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
        ],
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    PaintKit.crown(
      canvas,
      Offset(size.width / 2, size.height * 0.62),
      size.shortestSide * 0.46,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MeadowFill extends CustomPainter {
  const _MeadowFill();

  static const _meadow = Color(0xFFF6E8A0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, PaintKit.fill(_meadow));
    final paint = PaintKit.fill(const Color(0x338BC94A));
    const dots = [
      Offset(0.16, 0.36),
      Offset(0.84, 0.32),
      Offset(0.14, 0.68),
      Offset(0.86, 0.64),
      Offset(0.24, 0.5),
      Offset(0.76, 0.48),
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
  });

  final bool live;
  final bool pressed;
  final bool stamp;

  static const _grass = Color(0xFF8BC94A);
  static const _grassDeep = Color(0xFF5FA636);
  static const _stone = Color(0xFFEDE3C4);
  static const _stonePrint = Color(0xFFB8A478);
  static const _green = Color(0xFF4CAF50);
  static const _greenPrint = Color(0xFFE8F6B0);
  static const _dirt = Color(0xFF8B5A2B);
  static const _blue = Color(0xFF5AA4E0);
  static const _greenDino = Color(0xFF5BBF4A);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final grassH = s * 0.15;
    final head = s * 0.14;
    _dinoHead(
      canvas,
      Offset(s * 0.3, grassH + head * 0.35),
      head,
      _blue,
      frill: true,
    );
    _dinoHead(
      canvas,
      Offset(s * 0.3, s - grassH - head * 0.35),
      head,
      _greenDino,
    );
    _grassStrip(canvas, size, top: true, h: grassH);
    _grassStrip(canvas, size, top: false, h: grassH);

    final pad = s * 0.44;
    final center = Offset(s / 2, s / 2 + (pressed ? s * 0.03 : 0));
    _pad(canvas, center, pad);

    if (stamp) {
      _dirtBurst(canvas, Offset(s * 0.84, s * 0.56), s);
      _miniPrint(canvas, Offset(s * 0.86, s * 0.66), s * 0.13);
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
    final samples = 10;
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

  void _dinoHead(
    Canvas canvas,
    Offset c,
    double r,
    Color fill, {
    bool frill = false,
  }) {
    if (frill) {
      for (final a in [-0.95, -0.35, 0.35, 0.95]) {
        final p = c + Offset(math.sin(a) * r * 0.92, -math.cos(a) * r * 0.62);
        PaintKit.circle(
          canvas,
          p,
          r * 0.3,
          color: const Color(0xFF3D7EC8),
          width: r * 0.1,
        );
      }
    }
    PaintKit.circle(canvas, c, r, color: fill, width: r * 0.12);
    PaintKit.highlight(
      canvas,
      c + Offset(-r * 0.28, -r * 0.3),
      r * 0.3,
      alpha: 0.4,
    );
    _happyEye(canvas, c + Offset(-r * 0.34, -r * 0.1), r * 0.22);
    _happyEye(canvas, c + Offset(r * 0.34, -r * 0.1), r * 0.22);
    final smile = Path()
      ..moveTo(c.dx - r * 0.36, c.dy + r * 0.26)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.52,
        c.dx + r * 0.36,
        c.dy + r * 0.26,
      );
    canvas.drawPath(smile, PaintKit.stroke(AppColors.outline, r * 0.11));
    PaintKit.blush(
      canvas,
      c + Offset(-r * 0.46, r * 0.16),
      r * 0.14,
      alpha: 0.5,
    );
    PaintKit.blush(
      canvas,
      c + Offset(r * 0.46, r * 0.16),
      r * 0.14,
      alpha: 0.5,
    );
  }

  void _happyEye(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - r * 1.05, c.dx + r, c.dy);
    canvas.drawPath(path, PaintKit.stroke(AppColors.outline, r * 0.4));
  }

  void _pad(Canvas canvas, Offset c, double s) {
    final r = s / 2;
    final depth = pressed ? r * 0.1 : r * 0.28;
    canvas.drawCircle(
      c + Offset(0, depth),
      r,
      PaintKit.fill(AppColors.outline.withValues(alpha: 0.42)),
    );
    canvas.drawCircle(c, r, PaintKit.fill(live ? _green : _stone));
    canvas.drawCircle(c, r, PaintKit.stroke(AppColors.outline, r * 0.14));
    canvas.drawArc(
      Rect.fromCircle(
        center: c + Offset(-r * 0.08, -r * 0.1),
        radius: r * 0.72,
      ),
      math.pi * 1.05,
      math.pi * 0.7,
      false,
      PaintKit.stroke(
        Colors.white.withValues(alpha: live ? 0.28 : 0.4),
        r * 0.07,
      ),
    );
    _carvedPrint(
      canvas,
      c + Offset(0, -r * 0.16),
      r * 1.15,
      live ? _greenPrint : _stonePrint,
    );
  }

  void _carvedPrint(Canvas canvas, Offset c, double s, Color color) {
    final line = AppColors.outline.withValues(alpha: 0.55);
    final w = s * 0.035;
    void pad(Offset o, double ww, double hh) {
      final rect = Rect.fromCenter(center: c + o, width: ww, height: hh);
      canvas.drawOval(rect, PaintKit.fill(color));
      canvas.drawOval(rect, PaintKit.stroke(line, w));
    }

    pad(Offset(0, s * 0.2), s * 0.28, s * 0.18);
    pad(Offset(-s * 0.2, -s * 0.02), s * 0.16, s * 0.22);
    pad(Offset(0, -s * 0.12), s * 0.17, s * 0.28);
    pad(Offset(s * 0.2, -s * 0.02), s * 0.16, s * 0.22);
  }

  void _dirtBurst(Canvas canvas, Offset c, double s) {
    const clods = [
      (Offset(-0.55, -0.85), 0.034),
      (Offset(0.05, -1.1), 0.028),
      (Offset(0.7, -0.55), 0.032),
      (Offset(0.85, 0.2), 0.024),
      (Offset(0.25, 0.7), 0.03),
      (Offset(-0.45, 0.5), 0.022),
      (Offset(-0.1, -0.15), 0.02),
    ];
    for (var i = 0; i < clods.length; i++) {
      final (o, r) = clods[i];
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(o.dx * s * 0.11, o.dy * s * 0.09),
          width: s * r * 2.2,
          height: s * r * 1.45,
        ),
        PaintKit.fill(_dirt.withValues(alpha: 0.88 - i * 0.05)),
      );
    }
  }

  void _miniPrint(Canvas canvas, Offset c, double s) {
    final fill = const Color(0xFF5A3A1E);
    void oval(Offset o, double w, double h) {
      canvas.drawOval(
        Rect.fromCenter(center: c + o, width: w, height: h),
        PaintKit.fill(fill),
      );
    }

    oval(Offset(0, s * 0.28), s * 0.55, s * 0.4);
    oval(Offset(-s * 0.22, -s * 0.08), s * 0.28, s * 0.4);
    oval(Offset(0, -s * 0.22), s * 0.3, s * 0.48);
    oval(Offset(s * 0.22, -s * 0.08), s * 0.28, s * 0.4);
  }

  @override
  bool shouldRepaint(_GrassPadPainter old) =>
      old.live != live || old.pressed != pressed || old.stamp != stamp;
}
