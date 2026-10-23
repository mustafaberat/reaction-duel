/// Animated tap feedback: dino stomps.
///
/// [progress] 0→1 drives scale / fade / particles so capture tools can freeze
/// a frame by passing a fixed value.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

class TapBurstSpec {
  const TapBurstSpec({
    required this.dx,
    required this.dy,
    required this.progress,
    this.winning = false,
  });

  /// Local alignment in the half, 0–1.
  final double dx;
  final double dy;
  final double progress;
  final bool winning;
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

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bursts) {
      final c = Offset(b.dx * size.width, b.dy * size.height);
      final t = b.progress.clamp(0.0, 1.0);
      _stomp(canvas, c, t, b.winning);
    }
  }

  void _stomp(Canvas canvas, Offset c, double t, bool winning) {
    final scale = _pop(t) * (winning ? 1.32 : 1);
    final opacity = ((winning ? 1 : 0.78) * (1 - Curves.easeIn.transform(t))).clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(scale);
    PaintKit.dinoFoot(canvas, Offset.zero, 64, const Color(0xFF5A3A18), opacity: opacity);
    for (var i = 0; i < 8; i++) {
      final a = math.pi * 0.12 + i * math.pi * 0.12;
      final d = 24 + t * 20;
      canvas.drawCircle(
        Offset(math.cos(a) * d * (i.isEven ? 1 : -1), 14 + math.sin(a) * 8),
        6 + t * 5,
        PaintKit.fill(const Color(0xFFC8A06A).withValues(alpha: opacity * 0.75)),
      );
    }
    canvas.restore();

    final bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 68 + (winning ? 10 : 0), height: 34),
      const Radius.circular(14),
    );
    canvas.save();
    canvas.translate(c.dx + 22, c.dy - 52 - t * 10);
    canvas.rotate(-0.18);
    canvas.drawRRect(bubble, PaintKit.fill(const Color(0xFFFFF8DC).withValues(alpha: opacity)));
    canvas.drawRRect(bubble, PaintKit.stroke(AppColors.outline.withValues(alpha: opacity), 3.2));
    final tail = Path()
      ..moveTo(-8, 14)
      ..lineTo(-2, 28)
      ..lineTo(10, 14)
      ..close();
    canvas.drawPath(tail, PaintKit.fill(const Color(0xFFFFF8DC).withValues(alpha: opacity)));
    canvas.drawPath(tail, PaintKit.stroke(AppColors.outline.withValues(alpha: opacity), 3.2));
    final tp = TextPainter(
      text: TextSpan(
        text: 'POW!',
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20 + (winning ? 6 : 0),
          fontWeight: FontWeight.w800,
          color: AppColors.outline.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  double _pop(double t) {
    if (t < 0.28) return Curves.easeOutBack.transform(t / 0.28) * 1.12;
    return 1.12 - (t - 0.28) * 0.2;
  }

  @override
  bool shouldRepaint(TapBurstPainter old) => old.bursts != bursts;
}
