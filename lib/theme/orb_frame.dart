/// Decorative leaf ring around the signal orb. Fill/shape stay the signal.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

class OrbFrame extends StatelessWidget {
  const OrbFrame({required this.size, required this.child, super.key});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: const _OrbFramePainter()),
          child,
        ],
      ),
    );
  }
}

class _OrbFramePainter extends CustomPainter {
  const _OrbFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r + 5, PaintKit.stroke(const Color(0xFF3D9E45), 5));
    canvas.drawCircle(c, r + 5, PaintKit.stroke(AppColors.outline, 2));
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final p = Offset(c.dx + math.cos(a) * (r + 5), c.dy + math.sin(a) * (r + 5));
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(a);
      final leaf = Path()
        ..moveTo(0, -6)
        ..quadraticBezierTo(5, 0, 0, 6)
        ..quadraticBezierTo(-5, 0, 0, -6);
      canvas.drawPath(leaf, PaintKit.fill(const Color(0xFF3D9E45)));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbFramePainter old) => false;
}
