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

  static const Color _homeSky = Color(0xFFA6E0F5);
  static const Color _homeMid = Color(0xFFE4F3EA);
  static const Color _homeSand = Color(0xFFFCEBB6);

  @override
  void paint(Canvas canvas, Size size) {
    if (kind == DecorKind.card) return;
    if (kind == DecorKind.home) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_homeSky, _homeMid, _homeSand],
            stops: [0.0, 0.34, 0.62],
          ).createShader(Offset.zero & size),
      );
      return;
    }
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
    final groundY = size.height * 0.94;
    const dip = 10.0;
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
        size.height * 0.97,
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
