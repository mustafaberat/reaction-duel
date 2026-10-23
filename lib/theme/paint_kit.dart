/// Shared drawing helpers for original character / decor painters.
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

  static void blob(Canvas canvas, Path path, {required Color color, Color? line, double width = 2.2}) {
    canvas.drawPath(path, fill(color));
    canvas.drawPath(path, stroke(line ?? AppColors.outline, width));
  }

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

  static void circle(
    Canvas canvas,
    Offset c,
    double r, {
    required Color color,
    Color? line,
    double width = 2.2,
  }) {
    canvas.drawCircle(c, r, fill(color));
    canvas.drawCircle(c, r, stroke(line ?? AppColors.outline, width));
  }

  static Color lighten(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static void highlight(Canvas canvas, Offset c, double r, {double alpha = 0.55}) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.6, height: r),
      fill(const Color(0xFFFFFFFF).withValues(alpha: alpha)),
    );
  }

  /// Big cartoon eye. [look] is pupil offset in eye-radii. [open] 0=closed, 1=full.
  static void eye(
    Canvas canvas,
    Offset c,
    double r, {
    double open = 1,
    Offset look = Offset.zero,
    Color white = const Color(0xFFFFFDF8),
    Color pupil = const Color(0xFF1A1210),
    bool sparkle = true,
    bool angry = false,
  }) {
    final h = r * (0.18 + 1.64 * open.clamp(0.0, 1.0));
    final lid = Rect.fromCenter(center: c, width: r * 2, height: h);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(lid, Radius.circular(r)));
    canvas.drawOval(Rect.fromCircle(center: c, radius: r), fill(white));
    canvas.drawOval(Rect.fromCircle(center: c, radius: r), stroke(AppColors.outline, r * 0.12));
    final p = c + look * r;
    canvas.drawCircle(p, r * 0.42, fill(pupil));
    if (sparkle && open > 0.35) {
      canvas.drawCircle(p + Offset(-r * 0.16, -r * 0.18), r * 0.16, fill(const Color(0xFFFFFFFF)));
      canvas.drawCircle(p + Offset(r * 0.18, r * 0.12), r * 0.07, fill(const Color(0x66FFFFFF)));
    }
    canvas.restore();
    if (angry) {
      final brow = Path()
        ..moveTo(c.dx - r * 1.05, c.dy - r * 0.95)
        ..quadraticBezierTo(c.dx, c.dy - r * 0.45, c.dx + r * 1.05, c.dy - r * 1.05);
      canvas.drawPath(brow, stroke(AppColors.outline, r * 0.22));
    }
  }

  static void blush(Canvas canvas, Offset c, double r, {double alpha = 0.5}) {
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2.4, height: r * 1.1),
      fill(const Color(0xFFFF9A6A).withValues(alpha: alpha)),
    );
  }

  /// 4-point sparkle (no hearts).
  static Path sparkle(Offset c, double r) => star(c, r, points: 4, inner: 0.28);

  static void sparkleStar(Canvas canvas, Offset c, double r, Color color, {double opacity = 1}) {
    final p = sparkle(c, r);
    canvas.drawPath(p, fill(color.withValues(alpha: opacity)));
    canvas.drawPath(p, stroke(AppColors.outline.withValues(alpha: opacity * 0.7), r * 0.12));
  }

  static void sweatDrop(Canvas canvas, Offset tip, double s) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(tip.dx + s * 0.55, tip.dy + s * 0.55, tip.dx, tip.dy + s)
      ..quadraticBezierTo(tip.dx - s * 0.55, tip.dy + s * 0.55, tip.dx, tip.dy)
      ..close();
    blob(canvas, path, color: const Color(0xFFB8E8FF), width: s * 0.12);
    highlight(canvas, tip + Offset(-s * 0.08, s * 0.35), s * 0.16, alpha: 0.7);
  }

  static void tongue(Canvas canvas, Offset c, double s) {
    oval(
      canvas,
      Rect.fromCenter(center: c, width: s * 0.7, height: s),
      color: const Color(0xFFFF8A7A),
      line: AppColors.outline,
      width: s * 0.12,
    );
  }

  static void thumbsUp(Canvas canvas, Offset c, double s) {
    const skin = Color(0xFFFFE08A);
    final fist = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + Offset(s * 0.08, s * 0.16), width: s * 0.78, height: s * 0.62),
      Radius.circular(s * 0.22),
    );
    canvas.drawRRect(fist, fill(skin));
    canvas.drawRRect(fist, stroke(AppColors.outline, s * 0.11));
    oval(
      canvas,
      Rect.fromCenter(center: c + Offset(-s * 0.22, -s * 0.18), width: s * 0.38, height: s * 0.7),
      color: skin,
      width: s * 0.11,
    );
    highlight(canvas, c + Offset(-s * 0.28, -s * 0.32), s * 0.1, alpha: 0.55);
  }

  static void crown(Canvas canvas, Offset c, double s) {
    final gold = const Color(0xFFFFD24A);
    final goldLight = const Color(0xFFFFF0A0);
    final band = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 1.7, height: s * 0.32),
          Radius.circular(s * 0.1),
        ),
      );
    blob(canvas, band, color: gold, width: s * 0.08);
    for (final x in [-0.58, 0.0, 0.58]) {
      final peak = x == 0.0 ? 0.55 : 0.32;
      final tip = Path()
        ..moveTo(c.dx + s * (x - 0.2), c.dy + s * 0.14)
        ..lineTo(c.dx + s * x, c.dy - s * peak)
        ..lineTo(c.dx + s * (x + 0.2), c.dy + s * 0.14)
        ..close();
      blob(canvas, tip, color: x == 0.0 ? goldLight : gold, width: s * 0.07);
    }
    circle(canvas, c + Offset(0, -s * 0.52), s * 0.13, color: const Color(0xFF5EC8FF), width: s * 0.08);
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

  static void dinoFoot(Canvas canvas, Offset c, double s, Color color, {double opacity = 1}) {
    final fillC = color.withValues(alpha: opacity);
    final line = AppColors.outline.withValues(alpha: opacity);
    for (final x in [-0.34, 0.0, 0.34]) {
      final toe = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c + Offset(x * s, -s * 0.22), width: s * 0.22, height: s * 0.55),
            Radius.circular(s * 0.11),
          ),
        );
      blob(canvas, toe, color: fillC, line: line, width: s * 0.05);
    }
    final pad = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * 0.18), width: s * 0.78, height: s * 0.42),
          Radius.circular(s * 0.2),
        ),
      );
    blob(canvas, pad, color: fillC, line: line, width: s * 0.06);
  }
}
