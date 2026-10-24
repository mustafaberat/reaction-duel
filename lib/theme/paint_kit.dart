/// Shared drawing helpers for decor, bursts, marks and celebration.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

abstract final class PaintKit {
  static Paint fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static Paint stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  static Path unionAll(List<Path> paths) {
    if (paths.isEmpty) return Path();
    var acc = paths.first;
    for (var i = 1; i < paths.length; i++) {
      acc = Path.combine(PathOperation.union, acc, paths[i]);
    }
    return acc;
  }

  static void oval(
    Canvas canvas,
    Rect rect, {
    required Color color,
    Color? line,
    double width = 2.2,
  }) {
    canvas.drawOval(rect, fill(color));
    canvas.drawOval(rect, stroke(line ?? AppColors.outline, width));
  }

  static void highlight(Canvas canvas, Offset c, double r, {double alpha = 0.55}) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.6, height: r),
      fill(const Color(0xFFFFFFFF).withValues(alpha: alpha)),
    );
  }

  /// 4-point sparkle (no hearts).
  static Path sparkle(Offset c, double r) => star(c, r, points: 4, inner: 0.28);

  static void sparkleStar(Canvas canvas, Offset c, double r, Color color, {double opacity = 1}) {
    final p = sparkle(c, r);
    canvas.drawPath(p, fill(color.withValues(alpha: opacity)));
    canvas.drawPath(p, stroke(AppColors.outline.withValues(alpha: opacity * 0.7), r * 0.12));
  }

  static void rays(
    Canvas canvas,
    Offset c,
    double r, {
    int count = 10,
    Color color = const Color(0x33FFFFFF),
  }) {
    final paint = fill(color);
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / count;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.08) * r, c.dy + math.sin(a - 0.08) * r)
        ..lineTo(c.dx + math.cos(a + 0.08) * r, c.dy + math.sin(a + 0.08) * r)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  static Path star(Offset c, double r, {int points = 5, double inner = 0.42}) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final ang = -math.pi / 2 + i * math.pi / points;
      final rad = i.isEven ? r : r * inner;
      final p = Offset(c.dx + math.cos(ang) * rad, c.dy + math.sin(ang) * rad);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static void egg(Canvas canvas, Offset c, double s, Color color, {bool cracked = false}) {
    final rect = Rect.fromCenter(center: c, width: s * 0.72, height: s);
    oval(canvas, rect, color: color, width: s * 0.07);
    highlight(canvas, c + Offset(-s * 0.12, -s * 0.22), s * 0.12, alpha: 0.7);
    if (cracked) {
      final zig = Path()
        ..moveTo(c.dx - s * 0.08, c.dy - s * 0.1)
        ..lineTo(c.dx, c.dy)
        ..lineTo(c.dx + s * 0.1, c.dy + s * 0.08);
      canvas.drawPath(zig, stroke(AppColors.outline, s * 0.05));
    }
  }

}
