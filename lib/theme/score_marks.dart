/// Themed score marks: dinosaur eggs.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

class ScoreMark extends StatelessWidget {
  const ScoreMark({required this.filled, required this.color, required this.emptyColor, super.key});

  final bool filled;
  final Color color;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppDimens.dot,
      child: CustomPaint(
        painter: _ScoreMarkPainter(
          filled: filled,
          color: color,
          emptyColor: emptyColor,
        ),
      ),
    );
  }
}

class _ScoreMarkPainter extends CustomPainter {
  _ScoreMarkPainter({
    required this.filled,
    required this.color,
    required this.emptyColor,
  });

  final bool filled;
  final Color color;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide;
    PaintKit.egg(canvas, c, s * 0.95, filled ? color : AppColors.transparent);
    if (!filled) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: s * 0.68, height: s * 0.95),
        PaintKit.stroke(emptyColor, 1.4),
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreMarkPainter old) =>
      old.filled != filled || old.color != color || old.emptyColor != emptyColor;
}
