/// Original chibi dinosaurs for Dino Pals.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/duel_state.dart';
import 'paint_kit.dart';

CharacterMood moodFor(Player player, DuelState state) {
  final last = state.lastResult;
  switch (state.phase) {
    case DuelPhase.ready:
      return CharacterMood.ready;
    case DuelPhase.waiting:
    case DuelPhase.decoy:
    case DuelPhase.paused:
      return CharacterMood.waiting;
    case DuelPhase.signal:
      return CharacterMood.pouncing;
    case DuelPhase.scored:
    case DuelPhase.matchOver:
      if (last?.winner == player) return CharacterMood.happy;
      return CharacterMood.oops;
    case DuelPhase.foul:
      if (last?.foulBy == player) return CharacterMood.oops;
      if (last?.winner == player) return CharacterMood.happy;
      return CharacterMood.waiting;
    case DuelPhase.tie:
    case DuelPhase.noContest:
      return CharacterMood.surprised;
  }
}

class CharacterPainter extends CustomPainter {
  CharacterPainter({
    required this.player,
    required this.mood,
    this.flip = false,
    this.crowned = false,
    this.toward = 0,
  });

  final Player player;
  final CharacterMood mood;
  final bool flip;
  final bool crowned;
  final double toward;

  @override
  void paint(Canvas canvas, Size size) {
    if (flip) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final rect = Offset.zero & size;
    if (player == Player.p1) {
      _TrexPainter(mood: mood, toward: toward, crowned: crowned).paint(canvas, rect);
    } else {
      _TriceratopsPainter(mood: mood, toward: toward, crowned: crowned).paint(canvas, rect);
    }
    if (flip) canvas.restore();
  }

  @override
  bool shouldRepaint(CharacterPainter old) =>
      old.player != player ||
      old.mood != mood ||
      old.flip != flip ||
      old.crowned != crowned ||
      old.toward != toward;
}

class CharacterView extends StatelessWidget {
  const CharacterView({
    required this.player,
    required this.mood,
    required this.size,
    this.flip = false,
    this.crowned = false,
    this.toward = 0,
    super.key,
  });

  final Player player;
  final CharacterMood mood;
  final double size;
  final bool flip;
  final bool crowned;
  final double toward;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: CharacterPainter(
            player: player,
            mood: mood,
            flip: flip,
            crowned: crowned,
            toward: toward,
          ),
        ),
      ),
    );
  }
}

double _open(CharacterMood m) => switch (m) {
  CharacterMood.waiting => 0.7,
  CharacterMood.ready => 0.92,
  CharacterMood.pouncing => 1,
  CharacterMood.happy => 0.08,
  CharacterMood.oops => 1,
  CharacterMood.surprised => 1,
  CharacterMood.nextTime => 1,
};

Offset _look(CharacterMood m, double toward) {
  final x = toward.clamp(-1.0, 1.0);
  return switch (m) {
    CharacterMood.waiting => Offset(0.12 * (x == 0 ? 1 : x), 0.1),
    CharacterMood.ready => Offset(0.22 * x, 0),
    CharacterMood.pouncing => Offset(0.08 * x, -0.16),
    CharacterMood.happy => Offset.zero,
    CharacterMood.oops => Offset(0.06 * x, -0.04),
    CharacterMood.surprised => Offset.zero,
    CharacterMood.nextTime => Offset(0.1 * (x == 0 ? 1 : x), -0.08),
  };
}

double _tilt(CharacterMood m) => switch (m) {
  CharacterMood.oops => -0.12,
  CharacterMood.pouncing => 0.1,
  CharacterMood.happy => -0.05,
  CharacterMood.surprised => 0.06,
  CharacterMood.nextTime => -0.08,
  _ => 0,
};

double _hop(CharacterMood m) => switch (m) {
  CharacterMood.pouncing => -0.07,
  CharacterMood.happy => -0.04,
  CharacterMood.oops => 0.03,
  CharacterMood.nextTime => -0.02,
  _ => 0,
};

void _pose(Canvas canvas, Offset o, double s, CharacterMood mood, VoidCallback draw) {
  canvas.save();
  canvas.translate(o.dx, o.dy);
  canvas.rotate(_tilt(mood));
  canvas.translate(0, s * _hop(mood));
  canvas.translate(-o.dx, -o.dy);
  draw();
  canvas.restore();
}

void _happyEyes(Canvas canvas, Offset c, double r) {
  final p = PaintKit.stroke(AppColors.outline, r * 0.38);
  final path = Path()
    ..moveTo(c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy - r * 0.95, c.dx + r, c.dy);
  canvas.drawPath(path, p);
}

void _oMouth(Canvas canvas, Offset c, double w, double h) {
  canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h), PaintKit.fill(const Color(0xFF3A2018)));
}

void _moodBits(Canvas canvas, Offset head, double s, CharacterMood mood, {double sweatX = 0.28, double sweatY = -0.32}) {
  switch (mood) {
    case CharacterMood.oops:
      PaintKit.sweatDrop(canvas, head + Offset(s * sweatX, s * sweatY), s * 0.09);
      PaintKit.blush(canvas, head + Offset(-s * 0.22, s * 0.04), s * 0.06, alpha: 0.7);
      PaintKit.blush(canvas, head + Offset(s * 0.22, s * 0.04), s * 0.06, alpha: 0.7);
    case CharacterMood.nextTime:
      PaintKit.blush(canvas, head + Offset(-s * 0.2, s * 0.06), s * 0.07, alpha: 0.8);
      PaintKit.blush(canvas, head + Offset(s * 0.2, s * 0.06), s * 0.07, alpha: 0.8);
      PaintKit.sparkleStar(canvas, head + Offset(s * 0.36, -s * 0.22), s * 0.055, const Color(0xFFFFE566));
    case CharacterMood.happy:
      PaintKit.sparkleStar(canvas, head + Offset(-s * 0.4, -s * 0.28), s * 0.07, const Color(0xFFFFE566));
      PaintKit.sparkleStar(canvas, head + Offset(s * 0.42, -s * 0.16), s * 0.055, const Color(0xFFFFF6C8));
    case CharacterMood.pouncing:
      final p = PaintKit.stroke(AppColors.outline.withValues(alpha: 0.35), s * 0.03);
      for (final y in [-0.08, 0.04, 0.16]) {
        canvas.drawLine(head + Offset(-s * 0.5, s * y), head + Offset(-s * 0.34, s * y * 0.6), p);
      }
    case CharacterMood.surprised:
      PaintKit.sweatDrop(canvas, head + Offset(s * sweatX, s * sweatY), s * 0.08);
    case CharacterMood.waiting:
    case CharacterMood.ready:
      break;
  }
}

/// Big open cartoon eye so "next time" never reads as asleep or blank.
void _cheerEye(Canvas canvas, Offset c, double r, Offset look) {
  canvas.drawCircle(c, r, PaintKit.fill(const Color(0xFFFFFDF8)));
  canvas.drawCircle(c, r, PaintKit.stroke(AppColors.outline, r * 0.14));
  final p = c + look * r * 0.28;
  canvas.drawCircle(p, r * 0.4, PaintKit.fill(const Color(0xFF1A1210)));
  canvas.drawCircle(p + Offset(-r * 0.16, -r * 0.18), r * 0.18, PaintKit.fill(const Color(0xFFFFFFFF)));
  canvas.drawCircle(p + Offset(r * 0.16, r * 0.12), r * 0.08, PaintKit.fill(const Color(0x66FFFFFF)));
}

/// Cute "next time!" cue: cream bubble + thumbs-up, not a sad face.
void _nextTimeCue(Canvas canvas, Offset tip, double s) {
  final at = tip;
  final bubble = RRect.fromRectAndRadius(
    Rect.fromCenter(center: at, width: s * 0.5, height: s * 0.42),
    Radius.circular(s * 0.14),
  );
  canvas.drawRRect(bubble, PaintKit.fill(const Color(0xFFFFF8DC)));
  canvas.drawRRect(bubble, PaintKit.stroke(AppColors.outline, s * 0.04));
  final tail = Path()
    ..moveTo(at.dx - s * 0.04, at.dy + s * 0.18)
    ..lineTo(at.dx - s * 0.16, at.dy + s * 0.3)
    ..lineTo(at.dx + s * 0.08, at.dy + s * 0.18)
    ..close();
  canvas.drawPath(tail, PaintKit.fill(const Color(0xFFFFF8DC)));
  canvas.drawPath(tail, PaintKit.stroke(AppColors.outline, s * 0.04));
  PaintKit.thumbsUp(canvas, at + Offset(0, s * 0.01), s * 0.26);
}

class _TrexPainter {
  _TrexPainter({required this.mood, required this.toward, required this.crowned});

  final CharacterMood mood;
  final double toward;
  final bool crowned;

  void paint(Canvas canvas, Rect rect) {
    final s = rect.shortestSide;
    final o = rect.center;
    _pose(canvas, o, s, mood, () => _draw(canvas, o, s));
  }

  void _draw(Canvas canvas, Offset o, double s) {
    const green = Color(0xFF5BBF4A);
    const belly = Color(0xFFE8F6B0);
    final line = AppColors.outline;
    final w = s * 0.045;
    final cheer = mood == CharacterMood.nextTime;

    final tail = Path()
      ..moveTo(o.dx + s * 0.08, o.dy + s * 0.04)
      ..cubicTo(o.dx + s * 0.28, o.dy + s * 0.02, o.dx + s * 0.42, o.dy - s * 0.16, o.dx + s * 0.46, o.dy - s * 0.22)
      ..cubicTo(o.dx + s * 0.4, o.dy - s * 0.08, o.dx + s * 0.22, o.dy + s * 0.16, o.dx + s * 0.04, o.dy + s * 0.2)
      ..close();
    PaintKit.blob(canvas, tail, color: PaintKit.darken(green, 0.05), line: line, width: w);

    for (final x in [-0.06, 0.16]) {
      PaintKit.oval(
        canvas,
        Rect.fromCenter(center: o + Offset(s * x, s * 0.32), width: s * 0.18, height: s * 0.32),
        color: green,
        line: line,
        width: w * 0.9,
      );
      PaintKit.oval(
        canvas,
        Rect.fromCenter(center: o + Offset(s * x + s * 0.05, s * 0.46), width: s * 0.22, height: s * 0.1),
        color: PaintKit.darken(green, 0.1),
        line: line,
        width: w * 0.7,
      );
    }

    PaintKit.blob(
      canvas,
      PaintKit.unionAll([
        Path()..addOval(Rect.fromCenter(center: o + Offset(s * 0.04, s * 0.1), width: s * 0.46, height: s * 0.5)),
        Path()..addOval(Rect.fromCenter(center: o + Offset(-s * 0.08, -s * 0.22), width: s * 0.46, height: s * 0.38)),
        Path()..addOval(Rect.fromCenter(center: o + Offset(-s * 0.26, -s * 0.16), width: s * 0.34, height: s * 0.2)),
      ]),
      color: green,
      line: line,
      width: w,
    );
    canvas.drawOval(
      Rect.fromCenter(center: o + Offset(s * 0.02, s * 0.16), width: s * 0.26, height: s * 0.3),
      PaintKit.fill(belly),
    );

    if (cheer) {
      canvas.drawLine(
        o + Offset(-s * 0.08, -s * 0.02),
        o + Offset(-s * 0.2, -s * 0.18),
        PaintKit.stroke(line, s * 0.04),
      );
      PaintKit.circle(canvas, o + Offset(-s * 0.22, -s * 0.2), s * 0.04, color: green, line: line, width: w * 0.5);
      canvas.drawLine(
        o + Offset(-s * 0.08, s * 0.04),
        o + Offset(-s * 0.18, s * 0.1),
        PaintKit.stroke(line, s * 0.04),
      );
      PaintKit.circle(canvas, o + Offset(-s * 0.2, s * 0.11), s * 0.032, color: green, line: line, width: w * 0.5);
    } else {
      for (final y in [-0.02, 0.04]) {
        canvas.drawLine(o + Offset(-s * 0.08, s * y), o + Offset(-s * 0.2, s * (y + 0.06)), PaintKit.stroke(line, s * 0.04));
        PaintKit.circle(canvas, o + Offset(-s * 0.22, s * (y + 0.07)), s * 0.035, color: green, line: line, width: w * 0.5);
      }
    }

    for (final p in [const Offset(0.14, 0.0), const Offset(0.1, 0.18), const Offset(-0.02, 0.06)]) {
      canvas.drawOval(
        Rect.fromCenter(center: o + Offset(p.dx * s, p.dy * s), width: s * 0.1, height: s * 0.07),
        PaintKit.fill(const Color(0xFF3D9E45).withValues(alpha: 0.55)),
      );
    }

    final eye = o + Offset(-s * 0.1, -s * 0.26);
    if (mood == CharacterMood.happy) {
      _happyEyes(canvas, eye, s * 0.07);
    } else if (cheer) {
      _cheerEye(canvas, eye, s * 0.13, _look(mood, toward));
    } else {
      PaintKit.eye(canvas, eye, s * 0.08, open: _open(mood), look: _look(mood, toward));
    }
    canvas.drawCircle(o + Offset(-s * 0.36, -s * 0.16), s * 0.016, PaintKit.fill(line));
    switch (mood) {
      case CharacterMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.38, o.dy - s * 0.1)
            ..quadraticBezierTo(o.dx - s * 0.24, o.dy - s * 0.02, o.dx - s * 0.14, o.dy - s * 0.08),
          PaintKit.stroke(line, w * 0.8),
        );
      case CharacterMood.nextTime:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.38, o.dy - s * 0.1)
            ..quadraticBezierTo(o.dx - s * 0.24, o.dy, o.dx - s * 0.14, o.dy - s * 0.08),
          PaintKit.stroke(line, w),
        );
      case CharacterMood.oops:
        _oMouth(canvas, o + Offset(-s * 0.28, -s * 0.08), s * 0.13, s * 0.11);
        PaintKit.tongue(canvas, o + Offset(-s * 0.28, -s * 0.04), s * 0.05);
      case CharacterMood.surprised:
      case CharacterMood.pouncing:
        _oMouth(canvas, o + Offset(-s * 0.28, -s * 0.08), s * 0.12, s * 0.1);
      case CharacterMood.ready:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.38, o.dy - s * 0.08)
            ..quadraticBezierTo(o.dx - s * 0.26, o.dy - s * 0.03, o.dx - s * 0.16, o.dy - s * 0.08),
          PaintKit.stroke(line, w * 0.7),
        );
      case CharacterMood.waiting:
        canvas.drawLine(o + Offset(-s * 0.38, -s * 0.08), o + Offset(-s * 0.16, -s * 0.08), PaintKit.stroke(line, w * 0.7));
    }
    PaintKit.blush(
      canvas,
      o + Offset(-s * 0.04, -s * 0.12),
      cheer ? s * 0.055 : s * 0.04,
      alpha: mood == CharacterMood.oops || cheer ? 0.8 : 0.5,
    );
    PaintKit.highlight(canvas, o + Offset(-s * 0.16, -s * 0.34), s * 0.08, alpha: 0.35);
    _moodBits(canvas, o + Offset(-s * 0.08, -s * 0.22), s, mood, sweatX: 0.22, sweatY: -0.22);
    if (cheer) _nextTimeCue(canvas, o + Offset(s * 0.4, -s * 0.54), s * 0.88);
    if (crowned) PaintKit.crown(canvas, o + Offset(-s * 0.1, -s * 0.48), s * 0.2);
  }
}

class _TriceratopsPainter {
  _TriceratopsPainter({required this.mood, required this.toward, required this.crowned});

  final CharacterMood mood;
  final double toward;
  final bool crowned;

  void paint(Canvas canvas, Rect rect) {
    final s = rect.shortestSide;
    final o = rect.center;
    _pose(canvas, o, s, mood, () => _draw(canvas, o, s));
  }

  void _draw(Canvas canvas, Offset o, double s) {
    const blue = Color(0xFF5AA4E0);
    const frillC = Color(0xFF3D7EC8);
    const belly = Color(0xFFD8F0FF);
    final line = AppColors.outline;
    final w = s * 0.045;
    final cheer = mood == CharacterMood.nextTime;

    final tail = Path()
      ..moveTo(o.dx + s * 0.18, o.dy + s * 0.08)
      ..cubicTo(o.dx + s * 0.4, o.dy + s * 0.12, o.dx + s * 0.46, o.dy - s * 0.02, o.dx + s * 0.4, o.dy)
      ..cubicTo(o.dx + s * 0.3, o.dy + s * 0.14, o.dx + s * 0.14, o.dy + s * 0.2, o.dx + s * 0.04, o.dy + s * 0.16)
      ..close();
    PaintKit.blob(canvas, tail, color: PaintKit.darken(blue, 0.06), line: line, width: w);

    for (final x in [-0.18, -0.02, 0.14, 0.28]) {
      final lift = cheer && x == -0.18 ? -0.14 : 0.0;
      PaintKit.oval(
        canvas,
        Rect.fromCenter(center: o + Offset(s * x, s * (0.38 + lift)), width: s * 0.15, height: s * 0.2),
        color: blue,
        line: line,
        width: w * 0.8,
      );
    }

    final frill = Path()
      ..addOval(Rect.fromCenter(center: o + Offset(-s * 0.02, -s * 0.16), width: s * 0.5, height: s * 0.4));
    PaintKit.blob(canvas, frill, color: frillC, line: line, width: w);
    for (final a in [-0.9, -0.45, 0.0, 0.45, 0.9]) {
      final p = o + Offset(-s * 0.02 + math.sin(a) * s * 0.22, -s * 0.16 - math.cos(a) * s * 0.16);
      PaintKit.circle(canvas, p, s * 0.045, color: PaintKit.lighten(frillC, 0.08), line: line, width: w * 0.5);
    }

    PaintKit.blob(
      canvas,
      PaintKit.unionAll([
        Path()..addOval(Rect.fromCenter(center: o + Offset(s * 0.06, s * 0.12), width: s * 0.64, height: s * 0.42)),
        Path()..addOval(Rect.fromCenter(center: o + Offset(-s * 0.16, -s * 0.06), width: s * 0.38, height: s * 0.28)),
      ]),
      color: blue,
      line: line,
      width: w,
    );
    canvas.drawOval(
      Rect.fromCenter(center: o + Offset(s * 0.04, s * 0.16), width: s * 0.34, height: s * 0.22),
      PaintKit.fill(belly),
    );

    _horn(canvas, o + Offset(-s * 0.14, -s * 0.32), s * 0.18, true);
    _horn(canvas, o + Offset(s * 0.0, -s * 0.3), s * 0.16, true);
    _horn(canvas, o + Offset(-s * 0.34, -s * 0.12), s * 0.14, false);

    final beak = Path()
      ..moveTo(o.dx - s * 0.3, o.dy - s * 0.04)
      ..quadraticBezierTo(o.dx - s * 0.44, o.dy, o.dx - s * 0.32, o.dy + s * 0.08)
      ..quadraticBezierTo(o.dx - s * 0.24, o.dy + s * 0.04, o.dx - s * 0.22, o.dy - s * 0.02)
      ..close();
    PaintKit.blob(canvas, beak, color: const Color(0xFFFFE08A), line: line, width: w * 0.7);

    final eye = o + Offset(-s * 0.16, -s * 0.1);
    if (mood == CharacterMood.happy) {
      _happyEyes(canvas, eye, s * 0.06);
    } else if (cheer) {
      _cheerEye(canvas, o + Offset(-s * 0.14, -s * 0.12), s * 0.12, _look(mood, toward));
    } else {
      PaintKit.eye(canvas, eye, s * 0.07, open: _open(mood), look: _look(mood, toward));
    }

    switch (mood) {
      case CharacterMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.36, o.dy + s * 0.02)
            ..quadraticBezierTo(o.dx - s * 0.28, o.dy + s * 0.08, o.dx - s * 0.22, o.dy + s * 0.02),
          PaintKit.stroke(line, w * 0.7),
        );
      case CharacterMood.nextTime:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.4, o.dy + s * 0.01)
            ..quadraticBezierTo(o.dx - s * 0.3, o.dy + s * 0.12, o.dx - s * 0.18, o.dy + s * 0.01),
          PaintKit.stroke(line, w * 1.15),
        );
      case CharacterMood.oops:
        _oMouth(canvas, o + Offset(-s * 0.32, s * 0.04), s * 0.1, s * 0.08);
        PaintKit.tongue(canvas, o + Offset(-s * 0.32, s * 0.07), s * 0.04);
      case CharacterMood.surprised:
      case CharacterMood.pouncing:
        _oMouth(canvas, o + Offset(-s * 0.32, s * 0.04), s * 0.09, s * 0.07);
      case CharacterMood.ready:
        canvas.drawPath(
          Path()
            ..moveTo(o.dx - s * 0.38, o.dy + s * 0.03)
            ..quadraticBezierTo(o.dx - s * 0.3, o.dy + s * 0.07, o.dx - s * 0.24, o.dy + s * 0.03),
          PaintKit.stroke(line, w * 0.7),
        );
      case CharacterMood.waiting:
        canvas.drawLine(
          o + Offset(-s * 0.38, s * 0.04),
          o + Offset(-s * 0.24, s * 0.04),
          PaintKit.stroke(line, w * 0.7),
        );
    }

    PaintKit.blush(
      canvas,
      o + Offset(-s * 0.04, s * 0.0),
      cheer ? s * 0.055 : s * 0.04,
      alpha: mood == CharacterMood.oops || cheer ? 0.8 : 0.5,
    );
    PaintKit.highlight(canvas, o + Offset(-s * 0.2, -s * 0.16), s * 0.06, alpha: 0.35);
    _moodBits(canvas, o + Offset(-s * 0.16, -s * 0.06), s, mood, sweatX: 0.2, sweatY: -0.28);
    if (cheer) _nextTimeCue(canvas, o + Offset(s * 0.46, -s * 0.52), s * 0.88);
    if (crowned) PaintKit.crown(canvas, o + Offset(-s * 0.08, -s * 0.48), s * 0.18);
  }

  void _horn(Canvas canvas, Offset tip, double len, bool up) {
    final base = tip + Offset(up ? len * 0.08 : len * 0.4, up ? len * 0.7 : len * 0.2);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx - len * 0.16, base.dy)
      ..lineTo(base.dx + len * 0.16, base.dy)
      ..close();
    PaintKit.blob(canvas, path, color: const Color(0xFFFFF4DC), line: AppColors.outline, width: len * 0.1);
  }
}
