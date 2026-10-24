/// Tone-on-tone GO celebration and match-end confetti. Original vectors only.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'paint_kit.dart';

class SignalCelebrate extends StatelessWidget {
  const SignalCelebrate({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _SignalCelebratePainter(), child: SizedBox.expand()),
    );
  }
}

class _SignalCelebratePainter extends CustomPainter {
  const _SignalCelebratePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.72;
    PaintKit.rays(canvas, c, r, count: 12, color: const Color(0x22FFFFFF));
    final rnd = math.Random(56);
    for (var i = 0; i < 14; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      final s = 3.5 + rnd.nextDouble() * 5;
      if (i.isEven) {
        PaintKit.sparkleStar(canvas, p, s, const Color(0xFFFFF4C0), opacity: 0.5);
      } else {
        canvas.drawCircle(p, s * 0.45, PaintKit.fill(const Color(0x55FFFFFF)));
      }
    }
  }

  @override
  bool shouldRepaint(_SignalCelebratePainter old) => false;
}

class ConfettiBurst extends StatelessWidget {
  const ConfettiBurst({this.seed = 1, super.key});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(seed: seed),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.seed});

  final int seed;

  static const _palette = [
    Color(0xFF3D9E45),
    Color(0xFFFFE566),
    Color(0xFF5AA4E0),
    Color(0xFFFF9A4A),
    Color(0xFFFFF4C0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed + 93);
    for (var i = 0; i < 40; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
      final color = _palette[i % _palette.length];
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(rnd.nextDouble() * math.pi);
      if (i % 4 == 0) {
        canvas.drawPath(PaintKit.star(Offset.zero, 6 + rnd.nextDouble() * 5), PaintKit.fill(color));
      } else if (i % 4 == 1) {
        canvas.drawCircle(Offset.zero, 2.2 + rnd.nextDouble() * 2, PaintKit.fill(color));
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 8, height: 3.8),
            const Radius.circular(1.2),
          ),
          PaintKit.fill(color),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.seed != seed;
}
