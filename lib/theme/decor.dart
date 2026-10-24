/// Dino Pals backgrounds. Original vector decor only.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

enum DecorKind { home, screen, half, overlay, card }

class ThemedScaffold extends StatelessWidget {
  const ThemedScaffold({
    required this.body,
    this.decor = DecorKind.screen,
    super.key,
  });

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
    if (kind == DecorKind.card) return;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.background,
            AppColors.backgroundBottom,
          ],
        ).createShader(Offset.zero & size),
    );
    if (kind == DecorKind.half) return;
    final home = kind == DecorKind.home;
    final groundY = home ? size.height * 0.97 : size.height * 0.94;
    final dip = home ? 8.0 : 10.0;
    final ground = Path()
      ..moveTo(0, groundY)
      ..quadraticBezierTo(
        size.width * 0.35,
        groundY - dip,
        size.width * 0.55,
        groundY + dip * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * (home ? 0.92 : 0.97),
        size.width,
        groundY - 4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, PaintKit.fill(const Color(0xFF8BC94A)));
    canvas.drawPath(
      ground,
      PaintKit.stroke(AppColors.outline.withValues(alpha: 0.28), 2),
    );
    if (home) {
      _sun(canvas, Offset(size.width - 22, 30), 12);
    }
  }

  void _sun(Canvas canvas, Offset c, double r) {
    PaintKit.rays(
      canvas,
      c,
      r * 1.55,
      count: 8,
      color: const Color(0x33FFE566),
    );
    PaintKit.circle(canvas, c, r, color: const Color(0xFFFFE566), width: 1.8);
    PaintKit.highlight(
      canvas,
      c + Offset(-r * 0.28, -r * 0.28),
      r * 0.28,
      alpha: 0.4,
    );
  }

  @override
  bool shouldRepaint(DecorPainter old) => old.kind != kind;
}

class ThemeCardChrome extends StatelessWidget {
  const ThemeCardChrome({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
