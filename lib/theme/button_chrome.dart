/// Chunky stone button frame with leaf corners.
///
/// Chrome (leaves, depth) is extra decoration around a full-height body.
/// The label body always gets [height] (typically 56dp); decorations sit
/// outside or on top and must not shrink or clip the label.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import 'paint_kit.dart';

class ThemedButtonFrame extends StatelessWidget {
  const ThemedButtonFrame({
    required this.height,
    required this.expand,
    required this.kindPrimary,
    required this.child,
    super.key,
  });

  final double height;
  final bool expand;
  final bool kindPrimary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget body = child;
    if (AppShadows.button.isNotEmpty) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          boxShadow: AppShadows.button,
        ),
        child: child,
      );
    }

    return SizedBox(
      height: height + AppDimens.buttonDepth,
      width: expand ? double.infinity : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            child: body,
          ),
          Positioned(
            left: 10,
            right: 10,
            top: 2,
            height: 18,
            child: IgnorePointer(child: CustomPaint(painter: _LeafPairPainter(primary: kindPrimary))),
          ),
        ],
      ),
    );
  }
}

class _LeafPairPainter extends CustomPainter {
  _LeafPairPainter({required this.primary});

  final bool primary;

  @override
  void paint(Canvas canvas, Size size) {
    _leaf(canvas, Offset(size.width * 0.1, size.height * 0.55), 10, -0.6);
    _leaf(canvas, Offset(size.width * 0.9, size.height * 0.55), 10, 0.6);
  }

  void _leaf(Canvas canvas, Offset c, double s, double rot) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final path = Path()
      ..moveTo(0, -s)
      ..quadraticBezierTo(s * 0.75, 0, 0, s)
      ..quadraticBezierTo(-s * 0.75, 0, 0, -s)
      ..close();
    PaintKit.blob(canvas, path, color: primary ? const Color(0xFF3D9E45) : const Color(0xFF7BC45A), width: 2.2);
    canvas.drawLine(Offset(0, -s * 0.55), Offset(0, s * 0.55), PaintKit.stroke(AppColors.outline, 1.2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LeafPairPainter old) => old.primary != primary;
}
