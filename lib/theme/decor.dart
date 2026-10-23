/// Dino Pals backgrounds and card motifs. Original vector decor only.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

enum DecorKind { home, screen, half, overlay, card }

class ThemedScaffold extends StatelessWidget {
  const ThemedScaffold({required this.body, this.decor = DecorKind.screen, super.key});

  final Widget body;
  final DecorKind decor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ThemeDecor(kind: decor),
          body,
        ],
      ),
    );
  }
}

class ThemeDecor extends StatelessWidget {
  const ThemeDecor({this.kind = DecorKind.screen, super.key});

  final DecorKind kind;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: DecorPainter(kind: kind),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class DecorPainter extends CustomPainter {
  DecorPainter({required this.kind});

  final DecorKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    if (kind == DecorKind.card) {
      _leafCorners(canvas, size);
      return;
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundTop, AppColors.background, AppColors.backgroundBottom],
        ).createShader(Offset.zero & size),
    );
    if (kind == DecorKind.half) {
      PaintKit.egg(canvas, Offset(size.width * 0.9, size.height * 0.18), 14, const Color(0xFFFFF4DC));
      PaintKit.dinoFoot(
        canvas,
        Offset(size.width * 0.12, size.height * 0.82),
        16,
        AppColors.stroke.withValues(alpha: 0.35),
      );
      return;
    }
    final home = kind == DecorKind.home;
    final groundY = home ? size.height * 0.86 : size.height * 0.94;
    final ground = Path()
      ..moveTo(0, groundY)
      ..quadraticBezierTo(size.width * 0.35, groundY - 10, size.width * 0.55, groundY + 6)
      ..quadraticBezierTo(size.width * 0.8, groundY + 14, size.width, groundY - 4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, PaintKit.fill(const Color(0xFF8BC94A)));
    canvas.drawPath(ground, PaintKit.stroke(AppColors.outline.withValues(alpha: 0.35), 2));
    if (home) {
      _sun(canvas, Offset(size.width * 0.9, size.height * 0.2), 22);
      _volcano(canvas, Offset(size.width * 0.9, size.height * 0.68), 62);
      _palm(canvas, Offset(size.width * 0.08, size.height * 0.7), 64);
      PaintKit.egg(canvas, Offset(size.width * 0.18, size.height * 0.95), 14, const Color(0xFFFFF4DC));
      PaintKit.dinoFoot(
        canvas,
        Offset(size.width * 0.78, size.height * 0.92),
        18,
        AppColors.stroke.withValues(alpha: 0.4),
      );
    }
  }

  void _leafCorners(Canvas canvas, Size size) {
    _leaf(canvas, Offset(16, 14), 10, math.pi / 3);
    _leaf(canvas, Offset(size.width - 16, 14), 10, math.pi * 0.7);
  }

  void _leaf(Canvas canvas, Offset c, double s, double rot) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final path = Path()
      ..moveTo(0, -s)
      ..quadraticBezierTo(s * 0.7, 0, 0, s)
      ..quadraticBezierTo(-s * 0.7, 0, 0, -s)
      ..close();
    PaintKit.blob(canvas, path, color: const Color(0xFF3D9E45), width: 1.4);
    canvas.drawLine(Offset(0, -s * 0.6), Offset(0, s * 0.6), PaintKit.stroke(AppColors.outline, 1));
    canvas.restore();
  }

  void _palm(Canvas canvas, Offset base, double h) {
    final trunk = Path()
      ..moveTo(base.dx - 4, base.dy)
      ..quadraticBezierTo(base.dx + 6, base.dy - h * 0.5, base.dx, base.dy - h);
    canvas.drawPath(trunk, PaintKit.stroke(const Color(0xFF8A5A2A), 6));
    for (var i = 0; i < 6; i++) {
      final a = -math.pi * 0.9 + i * math.pi * 0.28;
      final tip = Offset(base.dx + math.cos(a) * h * 0.55, base.dy - h + math.sin(a) * h * 0.28);
      final leaf = Path()
        ..moveTo(base.dx, base.dy - h)
        ..quadraticBezierTo((base.dx + tip.dx) / 2 + 8, (base.dy - h + tip.dy) / 2, tip.dx, tip.dy)
        ..quadraticBezierTo((base.dx + tip.dx) / 2 - 8, (base.dy - h + tip.dy) / 2, base.dx, base.dy - h);
      canvas.drawPath(leaf, PaintKit.fill(const Color(0xFF3D9E45)));
      canvas.drawPath(leaf, PaintKit.stroke(AppColors.outline, 1.2));
    }
  }

  void _volcano(Canvas canvas, Offset base, double h) {
    final body = Path()
      ..moveTo(base.dx - h * 0.55, base.dy)
      ..lineTo(base.dx - h * 0.16, base.dy - h)
      ..lineTo(base.dx + h * 0.16, base.dy - h)
      ..lineTo(base.dx + h * 0.55, base.dy)
      ..close();
    PaintKit.blob(canvas, body, color: const Color(0xFF8A5A3A), width: 2);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - h * 0.16, base.dy - h)
        ..lineTo(base.dx + h * 0.16, base.dy - h)
        ..lineTo(base.dx + h * 0.08, base.dy - h + 10)
        ..lineTo(base.dx - h * 0.08, base.dy - h + 10)
        ..close(),
      PaintKit.fill(const Color(0xFF3A2010)),
    );
    for (final (dx, dy, s) in [(0.0, -h - 10, 9.0), (-14.0, -h - 24, 7.0), (12.0, -h - 30, 8.0)]) {
      canvas.drawCircle(base + Offset(dx, dy), s, PaintKit.fill(const Color(0x88FFFFFF)));
      canvas.drawCircle(base + Offset(dx, dy), s, PaintKit.stroke(const Color(0x66FFFFFF), 1.2));
    }
  }

  void _sun(Canvas canvas, Offset c, double r) {
    PaintKit.rays(canvas, c, r * 1.7, count: 8, color: const Color(0x44FFE566));
    PaintKit.circle(canvas, c, r, color: const Color(0xFFFFE566), width: 2);
    PaintKit.highlight(canvas, c + Offset(-r * 0.28, -r * 0.28), r * 0.28, alpha: 0.45);
  }

  @override
  bool shouldRepaint(DecorPainter old) => old.kind != kind;
}

class ThemeCardChrome extends StatelessWidget {
  const ThemeCardChrome({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DecorPainter(kind: DecorKind.card),
      child: child,
    );
  }
}
