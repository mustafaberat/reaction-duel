/// Vector dinos ported 1:1 from the Taş Tabela mockup (`dinos.py` / SVGs).
///
/// viewBox `-6 0 212 178`, outline `#3A280C` width 4.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/duel_state.dart';

const Color _out = AppColors.outline;
const Color _cream = Color(0xFFFFF1C8);

/// Darker readable dino accent for UI chrome (names, dots) on cream.
Color dinoAccent(Player player) => AppColors.dinoInkOf(player.index);

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

class DinoPalette {
  const DinoPalette({
    required this.body,
    required this.dark,
    required this.belly,
  });

  final Color body;
  final Color dark;
  final Color belly;

  /// Green T-rex (player 1).
  static const DinoPalette trex = DinoPalette(
    body: Color(0xFF6CC04A),
    dark: Color(0xFF3E9A3A),
    belly: Color(0xFFDDF3B8),
  );

  /// Blue triceratops (player 2).
  static const DinoPalette tri = DinoPalette(
    body: Color(0xFF5AA8E8),
    dark: Color(0xFF2E74C0),
    belly: Color(0xFFD6EAFB),
  );

  static DinoPalette of(Player player) => player == Player.p1 ? trex : tri;
}

enum DinoKind { trex, tri }

/// Full mockup dino in viewBox space, contained in the parent (or [size] wide).
class DinoArt extends StatelessWidget {
  const DinoArt({
    required this.kind,
    this.flip = false,
    this.openMouth = false,
    this.mood,
    this.crowned = false,
    this.toward = 0,
    this.size,
    this.palette,
    super.key,
  });

  const DinoArt.trex({
    this.flip = false,
    this.openMouth = false,
    this.mood,
    this.crowned = false,
    this.toward = 0,
    this.size,
    this.palette = DinoPalette.trex,
    super.key,
  }) : kind = DinoKind.trex;

  const DinoArt.tri({
    this.flip = false,
    this.openMouth = false,
    this.mood,
    this.crowned = false,
    this.toward = 0,
    this.size,
    this.palette = DinoPalette.tri,
    super.key,
  }) : kind = DinoKind.tri;

  const DinoArt.forPlayer(
    Player player, {
    this.mood = CharacterMood.waiting,
    this.flip = false,
    this.crowned = false,
    this.toward = 0,
    this.size,
    this.openMouth = false,
    super.key,
  }) : kind = player == Player.p1 ? DinoKind.trex : DinoKind.tri,
       palette = null;

  final DinoKind kind;
  final bool flip;
  final bool openMouth;
  final CharacterMood? mood;
  final bool crowned;
  final double toward;
  final double? size;
  final DinoPalette? palette;

  static double heightFor(double width) =>
      width * DinoPainter.viewSize.height / DinoPainter.viewSize.width;

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      painter: DinoPainter(
        kind: kind,
        flip: flip,
        openMouth: openMouth,
        mood: mood,
        crowned: crowned,
        toward: toward,
        palette:
            palette ??
            DinoPalette.of(kind == DinoKind.trex ? Player.p1 : Player.p2),
      ),
      size: DinoPainter.viewSize,
    );
    Widget child = FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: DinoPainter.viewSize.width,
        height: DinoPainter.viewSize.height,
        child: paint,
      ),
    );
    final w = size;
    if (w != null) {
      child = SizedBox(width: w, height: heightFor(w), child: child);
    }
    return ExcludeSemantics(child: child);
  }
}

class DinoPainter extends CustomPainter {
  DinoPainter({
    required this.kind,
    this.flip = false,
    this.openMouth = false,
    this.mood,
    this.crowned = false,
    this.toward = 0,
    this.palette = DinoPalette.trex,
  });

  final DinoKind kind;
  final bool flip;
  final bool openMouth;
  final CharacterMood? mood;
  final bool crowned;
  final double toward;
  final DinoPalette palette;

  static const Size viewSize = Size(212, 178);
  static const Offset viewOrigin = Offset(-6, 0);

  @override
  void paint(Canvas canvas, Size size) {
    final face = _Face.of(mood, openMouth: openMouth, toward: toward);
    canvas.save();
    canvas.scale(size.width / viewSize.width, size.height / viewSize.height);
    canvas.translate(-viewOrigin.dx, -viewOrigin.dy);
    if (flip) {
      canvas.translate(200, 0);
      canvas.scale(-1, 1);
    }
    if (face.hop != 0 || face.tilt != 0) {
      canvas.translate(100, 100);
      canvas.rotate(face.tilt);
      canvas.translate(0, face.hop);
      canvas.translate(-100, -100);
    }
    if (kind == DinoKind.trex) {
      _paintTrex(canvas, palette, face);
    } else {
      _paintTri(canvas, palette, face);
    }
    if (crowned) _paintCrown(canvas, kind);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DinoPainter old) =>
      old.kind != kind ||
      old.flip != flip ||
      old.openMouth != openMouth ||
      old.mood != mood ||
      old.crowned != crowned ||
      old.toward != toward ||
      old.palette != palette;
}

void _paintTrex(Canvas canvas, DinoPalette c, _Face face) {
  final s = _stroke(4);
  _fillStroke(
    canvas,
    _svg('M62,118 C40,122 16,114 4,90 C24,102 44,104 66,100 Z'),
    c.body,
    s,
  );
  _poly(
    canvas,
    const [Offset(40, 104), Offset(30, 90), Offset(50, 94)],
    c.dark,
    s,
  );
  _poly(
    canvas,
    const [Offset(50, 92), Offset(44, 74), Offset(62, 82)],
    c.dark,
    s,
  );
  _poly(
    canvas,
    const [Offset(64, 82), Offset(64, 64), Offset(78, 76)],
    c.dark,
    s,
  );
  _poly(
    canvas,
    const [Offset(100, 36), Offset(100, 16), Offset(116, 28)],
    c.dark,
    s,
  );
  _poly(
    canvas,
    const [Offset(116, 26), Offset(122, 8), Offset(132, 24)],
    c.dark,
    s,
  );
  _rrect(canvas, const Rect.fromLTWH(54, 134, 24, 32), 10, c.body, s);
  _rrect(canvas, const Rect.fromLTWH(90, 136, 24, 30), 10, c.body, s);
  _ellipse(canvas, const Offset(66, 167), 17, 7, c.dark, s);
  _ellipse(canvas, const Offset(104, 167), 17, 7, c.dark, s);
  _ellipse(canvas, const Offset(84, 114), 40, 36, c.body, s);
  _ellipse(canvas, const Offset(99, 122), 21, 23, c.belly, _stroke(3));
  canvas.drawCircle(
    const Offset(64, 104),
    5,
    _fill(c.dark.withValues(alpha: 0.55)),
  );
  canvas.drawCircle(
    const Offset(72, 124),
    3.5,
    _fill(c.dark.withValues(alpha: 0.55)),
  );
  canvas.drawCircle(
    const Offset(58, 120),
    3,
    _fill(c.dark.withValues(alpha: 0.55)),
  );
  _fillStroke(
    canvas,
    _svg(
      'M96,62 C92,34 110,20 136,20 C164,20 184,32 186,54 C188,74 172,86 150,86 L118,88 C104,88 98,76 96,62 Z',
    ),
    c.body,
    s,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(146, 62), width: 14, height: 8),
    _fill(const Color(0xFFFF9F8A).withValues(alpha: 0.7)),
  );
  _dinoEye(canvas, const Offset(130, 45), 12, face);
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(176, 42), width: 5.2, height: 4),
    _fill(_out),
  );
  _dinoMouth(canvas, 150, 68, 164, 78, 180, 62, face);
  if (face.sadBrows) _sadBrow(canvas, const Offset(130, 45), 12);
  if (face.sweat) _sweat(canvas, const Offset(108, 26));
  if (face.armsUp) {
    _arm(canvas, 'M112,104 q4,-20 16,-28', c.body);
    _arm(canvas, 'M108,116 q8,-18 20,-22', c.body);
  } else {
    _arm(canvas, 'M112,104 q14,-4 20,6', c.body);
    _arm(canvas, 'M108,116 q14,-2 18,8', c.body);
  }
}

void _paintTri(Canvas canvas, DinoPalette c, _Face face) {
  final s = _stroke(4);
  _fillStroke(
    canvas,
    _svg('M36,112 C18,116 4,106 0,90 C14,102 28,104 42,100 Z'),
    c.body,
    s,
  );
  _rrect(canvas, const Rect.fromLTWH(38, 126, 24, 40), 10, c.dark, s);
  _rrect(canvas, const Rect.fromLTWH(104, 126, 24, 40), 10, c.dark, s);
  _rrect(canvas, const Rect.fromLTWH(60, 128, 24, 38), 10, c.body, s);
  _rrect(canvas, const Rect.fromLTWH(124, 128, 24, 38), 10, c.body, s);
  _ellipse(canvas, const Offset(84, 106), 58, 36, c.body, s);
  _fillStroke(canvas, _svg('M44,124 Q84,146 128,122'), c.belly, _stroke(3));
  canvas.drawCircle(
    const Offset(60, 92),
    6,
    _fill(c.dark.withValues(alpha: 0.5)),
  );
  canvas.drawCircle(
    const Offset(82, 84),
    4.5,
    _fill(c.dark.withValues(alpha: 0.5)),
  );
  canvas.drawCircle(
    const Offset(76, 104),
    3.5,
    _fill(c.dark.withValues(alpha: 0.5)),
  );
  for (final a in [120, 148, 176, 204, 232, 260, 288, 316, 344]) {
    final rad = a * math.pi / 180;
    canvas.drawCircle(
      Offset(138 + 38 * math.cos(rad), 80 + 38 * math.sin(rad)),
      8,
      _fill(c.dark),
    );
    canvas.drawCircle(
      Offset(138 + 38 * math.cos(rad), 80 + 38 * math.sin(rad)),
      8,
      s,
    );
  }
  canvas.drawCircle(const Offset(138, 80), 38, _fill(c.dark));
  canvas.drawCircle(const Offset(138, 80), 38, s);
  canvas.drawCircle(
    const Offset(126, 64),
    6,
    _fill(c.belly.withValues(alpha: 0.8)),
  );
  canvas.drawCircle(
    const Offset(116, 82),
    5,
    _fill(c.belly.withValues(alpha: 0.8)),
  );
  canvas.drawCircle(
    const Offset(130, 48),
    4,
    _fill(c.belly.withValues(alpha: 0.8)),
  );
  _fillStroke(
    canvas,
    _svg('M146,74 C146,58 150,44 156,32 C160,46 162,60 162,72 Z'),
    _cream,
    s,
  );
  _fillStroke(
    canvas,
    _svg('M166,72 C170,58 176,46 186,38 C186,52 182,64 178,76 Z'),
    _cream,
    s,
  );
  _fillStroke(
    canvas,
    _svg(
      'M128,94 C126,72 146,64 166,68 C184,72 194,86 194,98 C194,112 180,122 160,120 C142,118 130,110 128,94 Z',
    ),
    c.body,
    s,
  );
  _fillStroke(canvas, _svg('M180,84 L188,70 L192,88 Z'), _cream, s);
  _fillStroke(
    canvas,
    _svg('M186,92 C200,94 202,108 190,114 L182,104 Z'),
    const Color(0xFFFFD27A),
    s,
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(152, 104), width: 13, height: 8),
    _fill(const Color(0xFFFF9F8A).withValues(alpha: 0.7)),
  );
  _dinoEye(canvas, const Offset(160, 88), 10, face);
  _dinoMouth(canvas, 164, 106, 174, 112, 184, 104, face);
  if (face.sadBrows) _sadBrow(canvas, const Offset(160, 88), 10);
  if (face.sweat) _sweat(canvas, const Offset(122, 52));
}

enum _MouthKind { smile, open, o, sad, grin }

class _Face {
  const _Face({
    required this.mouth,
    this.happyEyes = false,
    this.wideEyes = false,
    this.sadBrows = false,
    this.sweat = false,
    this.look,
    this.armsUp = false,
    this.hop = 0,
    this.tilt = 0,
  });

  final _MouthKind mouth;
  final bool happyEyes;
  final bool wideEyes;
  final bool sadBrows;
  final bool sweat;
  final Offset? look;
  final bool armsUp;
  final double hop;
  final double tilt;

  static _Face of(
    CharacterMood? mood, {
    required bool openMouth,
    required double toward,
  }) {
    if (mood == null) {
      return _Face(mouth: openMouth ? _MouthKind.open : _MouthKind.smile);
    }
    final x = toward.clamp(-1.0, 1.0);
    final dir = x == 0 ? 1.0 : x;
    return switch (mood) {
      CharacterMood.waiting => _Face(
        mouth: _MouthKind.smile,
        look: Offset(3 + 2 * dir, 1.5),
      ),
      CharacterMood.ready => _Face(
        mouth: _MouthKind.smile,
        look: Offset(5 + 3 * dir, 0),
      ),
      CharacterMood.pouncing => _Face(
        mouth: _MouthKind.open,
        look: Offset(2 + 2 * dir, -3),
        armsUp: true,
        hop: -10,
        tilt: 0.05,
      ),
      CharacterMood.happy => const _Face(
        mouth: _MouthKind.grin,
        happyEyes: true,
        armsUp: true,
        hop: -7,
        tilt: -0.04,
      ),
      CharacterMood.oops => _Face(
        mouth: _MouthKind.o,
        sadBrows: true,
        sweat: true,
        look: Offset(2 + 2 * dir, -1),
        hop: 2,
        tilt: -0.04,
      ),
      CharacterMood.surprised => const _Face(
        mouth: _MouthKind.o,
        wideEyes: true,
        look: Offset.zero,
        hop: -3,
        tilt: 0.04,
      ),
      CharacterMood.nextTime => _Face(
        mouth: _MouthKind.sad,
        sadBrows: true,
        sweat: true,
        look: Offset(2 + 2 * dir, -1.5),
        hop: -2,
        tilt: -0.03,
      ),
    };
  }
}

void _dinoEye(Canvas canvas, Offset c, double r, _Face face) {
  if (face.happyEyes) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r, c.dy + r * 0.1)
        ..quadraticBezierTo(c.dx, c.dy - r * 0.95, c.dx + r, c.dy + r * 0.1),
      _stroke(3.6)..strokeCap = StrokeCap.round,
    );
    return;
  }
  final rr = face.wideEyes ? r * 1.12 : r;
  canvas.drawCircle(c, rr, _fill(const Color(0xFFFFFFFF)));
  canvas.drawCircle(c, rr, _stroke(3.5));
  final pupil = face.look ?? const Offset(3, 1);
  final pr = face.wideEyes ? rr * 0.42 : rr * 0.55;
  canvas.drawCircle(c + pupil, pr, _fill(_out));
  canvas.drawCircle(
    c + pupil + const Offset(2, -3),
    rr * 0.2,
    _fill(const Color(0xFFFFFFFF)),
  );
}

void _dinoMouth(
  Canvas canvas,
  double x1,
  double y1,
  double cx,
  double cy,
  double x2,
  double y2,
  _Face face,
) {
  switch (face.mouth) {
    case _MouthKind.smile:
      _mouth(canvas, x1, y1, cx, cy, x2, y2, false);
    case _MouthKind.open:
      _mouth(canvas, x1, y1, cx, cy, x2, y2, true);
    case _MouthKind.grin:
      _mouth(canvas, x1, y1, cx, cy + 6, x2, y2, false);
    case _MouthKind.sad:
      canvas.drawPath(
        _svg('M$x1,$y1 Q$cx,${cy - 8} $x2,$y2'),
        _stroke(3.8)..strokeCap = StrokeCap.round,
      );
    case _MouthKind.o:
      final o = Offset((x1 + x2) / 2, (y1 + y2) / 2 + 3);
      _ellipse(canvas, o, 8, 7, const Color(0xFF8A2E1E), _stroke(3.2));
  }
}

/// Raised inner brow — sad/encouraging, never angry (no inward-down).
void _sadBrow(Canvas canvas, Offset eye, double r) {
  canvas.drawPath(
    Path()
      ..moveTo(eye.dx - r * 1.15, eye.dy - r * 0.75)
      ..quadraticBezierTo(
        eye.dx + r * 0.15,
        eye.dy - r * 1.25,
        eye.dx + r * 1.35,
        eye.dy - r * 1.55,
      ),
    _stroke(4)..strokeCap = StrokeCap.round,
  );
}

void _sweat(Canvas canvas, Offset tip) {
  const s = 16.0;
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..quadraticBezierTo(tip.dx + s * 0.55, tip.dy + s * 0.55, tip.dx, tip.dy + s)
    ..quadraticBezierTo(tip.dx - s * 0.55, tip.dy + s * 0.55, tip.dx, tip.dy)
    ..close();
  _fillStroke(canvas, path, const Color(0xFFB8E8FF), _stroke(2.6));
  canvas.drawOval(
    Rect.fromCenter(
      center: tip + const Offset(-1.6, 5.5),
      width: 4.4,
      height: 3,
    ),
    _fill(const Color(0x88FFFFFF)),
  );
}

void _paintCrown(Canvas canvas, DinoKind kind) {
  final at = kind == DinoKind.trex
      ? const Offset(140, 14)
      : const Offset(138, 36);
  const w = 48.0;
  const h = 24.0;
  canvas.save();
  canvas.translate(at.dx, at.dy);
  final path = Path()
    ..moveTo(-w / 2, h * 0.62)
    ..lineTo(-w / 2 - 2, h * 0.08)
    ..lineTo(-w * 0.2, h * 0.38)
    ..lineTo(0, -h * 0.42)
    ..lineTo(w * 0.2, h * 0.38)
    ..lineTo(w / 2 + 2, h * 0.08)
    ..lineTo(w / 2, h * 0.62)
    ..close();
  _fillStroke(canvas, path, const Color(0xFFFFD24A), _stroke(2.8));
  canvas.drawCircle(Offset(0, -h * 0.18), 3.2, _fill(const Color(0xFFFFF3B0)));
  canvas.drawCircle(Offset(0, -h * 0.18), 3.2, _stroke(2));
  canvas.restore();
}

void _mouth(
  Canvas canvas,
  double x1,
  double y1,
  double cx,
  double cy,
  double x2,
  double y2,
  bool open,
) {
  if (open) {
    _fillStroke(
      canvas,
      _svg('M$x1,$y1 Q$cx,${cy + 14} $x2,$y2 Z'),
      const Color(0xFF8A2E1E),
      _stroke(3.5),
    );
    final mx = (x1 + x2) / 2 - 6;
    final my = (y1 + y2) / 2 + 7;
    canvas.drawPath(
      _svg('M$mx,$my q6,-5 12,0 q-6,5 -12,0z'),
      _fill(const Color(0xFFF0786A)),
    );
  } else {
    canvas.drawPath(
      _svg('M$x1,$y1 Q$cx,$cy $x2,$y2'),
      _stroke(3.8)..strokeCap = StrokeCap.round,
    );
  }
}

void _arm(Canvas canvas, String d, Color body) {
  canvas.drawPath(
    _svg(d),
    _stroke(10)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawPath(_svg(d), _stroke(4.5, body)..strokeCap = StrokeCap.round);
}

/// Three-toed print in local space (heel at (0, 9)).
void _footOvals(Canvas canvas, Color color, {Color? stroke}) {
  final fill = _fill(color);
  void oval(Offset c, double w, double h) {
    final rect = Rect.fromCenter(center: c, width: w, height: h);
    canvas.drawOval(rect, fill);
    if (stroke != null) {
      canvas.drawOval(rect, _stroke(2.5, stroke));
    }
  }

  void toe(double deg) {
    canvas.save();
    if (deg != 0) {
      canvas.translate(0, 6);
      canvas.rotate(deg * math.pi / 180);
      canvas.translate(0, -6);
    }
    oval(const Offset(0, -12), 10, 22);
    canvas.restore();
  }

  oval(const Offset(0, 9), 22, 20);
  toe(0);
  toe(-34);
  toe(34);
}

/// Three-toed print. [viewBox] `-24 -28 48 52`.
void paintFootprint(Canvas canvas, Size size, Color color, {Color? stroke}) {
  canvas.save();
  canvas.scale(size.width / 48, size.height / 52);
  canvas.translate(24, 28);
  _footOvals(canvas, color, stroke: stroke);
  canvas.restore();
}

/// Dirt clods + a dark print. [viewBox] `-50 -50 100 100`.
void paintDirt(Canvas canvas, Size size) {
  canvas.save();
  canvas.scale(size.width / 100, size.height / 100);
  canvas.translate(50, 50);
  const clods = <(double, double, double, Color)>[
    (0, 0, 34, Color(0xFFA8743E)),
    (-30, -14, 10, Color(0xFF8B5A2B)),
    (32, -18, 8, Color(0xFF8B5A2B)),
    (-36, 16, 7, Color(0xFFA8743E)),
    (38, 14, 9, Color(0xFFA8743E)),
    (-10, -34, 6, Color(0xFF8B5A2B)),
    (14, 32, 7, Color(0xFF8B5A2B)),
    (26, -34, 4, Color(0xFFA8743E)),
    (-26, 32, 4, Color(0xFF8B5A2B)),
  ];
  for (final (x, y, rx, col) in clods) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: rx * 1.4),
      _fill(col),
    );
  }
  canvas.translate(0, 2);
  canvas.scale(0.9);
  _footOvals(canvas, const Color(0xFF5A3614));
  canvas.restore();
}

/// Simple gold crown for the winner chip (`gen.py` CROWN).
void paintChipCrown(Canvas canvas, Size size) {
  canvas.save();
  canvas.scale(size.width / 20, size.height / 16);
  _fillStroke(
    canvas,
    _svg('M2,14 h16 l1,-10 l-5,4 l-4,-6 l-4,6 l-5,-4 z'),
    const Color(0xFFFFF3B0),
    _stroke(2),
  );
  canvas.restore();
}

/// Gold trophy for the home stats line (`gen.py` TROPHY).
void paintTrophy(Canvas canvas, Size size) {
  canvas.save();
  canvas.scale(size.width / 24, size.height / 24);
  final cup = Path()
    ..moveTo(7, 4)
    ..lineTo(17, 4)
    ..lineTo(17, 8)
    ..cubicTo(17, 10.76, 14.76, 13, 12, 13)
    ..cubicTo(9.24, 13, 7, 10.76, 7, 8)
    ..close();
  final handles = Path()
    ..moveTo(5, 5)
    ..lineTo(3, 5)
    ..lineTo(3, 7)
    ..cubicTo(3, 8.66, 4.34, 10, 6, 10)
    ..moveTo(19, 5)
    ..lineTo(21, 5)
    ..lineTo(21, 7)
    ..cubicTo(21, 8.66, 19.66, 10, 18, 10);
  final stem = Path()
    ..addRect(const Rect.fromLTWH(10, 14, 4, 3))
    ..moveTo(8, 20)
    ..lineTo(16, 20);
  final gold = const Color(0xFFFFC93C);
  final line = _stroke(2, const Color(0xFF7A5C28));
  canvas.drawPath(cup, _fill(gold));
  canvas.drawPath(cup, line);
  canvas.drawPath(handles, line);
  canvas.drawPath(stem, line);
  canvas.restore();
}

class FootprintPainter extends CustomPainter {
  const FootprintPainter(this.color, {this.stroke});

  final Color color;
  final Color? stroke;

  @override
  void paint(Canvas canvas, Size size) =>
      paintFootprint(canvas, size, color, stroke: stroke);

  @override
  bool shouldRepaint(FootprintPainter old) =>
      old.color != color || old.stroke != stroke;
}

class DirtPainter extends CustomPainter {
  const DirtPainter();

  @override
  void paint(Canvas canvas, Size size) => paintDirt(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipCrownPainter extends CustomPainter {
  const ChipCrownPainter();

  @override
  void paint(Canvas canvas, Size size) => paintChipCrown(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrophyPainter extends CustomPainter {
  const TrophyPainter();

  @override
  void paint(Canvas canvas, Size size) => paintTrophy(canvas, size);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Paint _fill(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

Paint _stroke(double w, [Color color = _out]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..isAntiAlias = true;

void _fillStroke(Canvas canvas, Path path, Color fill, Paint stroke) {
  canvas.drawPath(path, _fill(fill));
  canvas.drawPath(path, stroke);
}

void _poly(Canvas canvas, List<Offset> pts, Color fill, Paint stroke) {
  final path = Path()..addPolygon(pts, true);
  _fillStroke(canvas, path, fill, stroke);
}

void _ellipse(
  Canvas canvas,
  Offset c,
  double rx,
  double ry,
  Color fill,
  Paint stroke,
) {
  final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
  canvas.drawOval(rect, _fill(fill));
  canvas.drawOval(rect, stroke);
}

void _rrect(Canvas canvas, Rect rect, double r, Color fill, Paint stroke) {
  final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));
  canvas.drawRRect(rr, _fill(fill));
  canvas.drawRRect(rr, stroke);
}

Path _svg(String d) {
  final path = Path();
  final t = _svgTokens(d);
  var i = 0;
  var cmd = '';
  var x = 0.0;
  var y = 0.0;
  var sx = 0.0;
  var sy = 0.0;

  double n() => double.parse(t[i++]);

  bool hasNum() => i < t.length && double.tryParse(t[i]) != null;

  while (i < t.length) {
    if (double.tryParse(t[i]) == null) {
      cmd = t[i++];
    }
    switch (cmd) {
      case 'M':
        x = n();
        y = n();
        path.moveTo(x, y);
        sx = x;
        sy = y;
        cmd = 'L';
      case 'L':
        x = n();
        y = n();
        path.lineTo(x, y);
      case 'H':
        x = n();
        path.lineTo(x, y);
      case 'V':
        y = n();
        path.lineTo(x, y);
      case 'h':
        x += n();
        path.lineTo(x, y);
      case 'l':
        x += n();
        y += n();
        path.lineTo(x, y);
      case 'C':
        final x1 = n();
        final y1 = n();
        final x2 = n();
        final y2 = n();
        x = n();
        y = n();
        path.cubicTo(x1, y1, x2, y2, x, y);
      case 'Q':
        final x1 = n();
        final y1 = n();
        x = n();
        y = n();
        path.quadraticBezierTo(x1, y1, x, y);
      case 'q':
        final x1 = x + n();
        final y1 = y + n();
        x += n();
        y += n();
        path.quadraticBezierTo(x1, y1, x, y);
      case 'Z':
      case 'z':
        path.close();
        x = sx;
        y = sy;
      default:
        if (hasNum()) {
          i++;
        } else {
          i++;
        }
    }
  }
  return path;
}

List<String> _svgTokens(String d) {
  final out = <String>[];
  final buf = StringBuffer();
  void flush() {
    if (buf.isNotEmpty) {
      out.add(buf.toString());
      buf.clear();
    }
  }

  for (var i = 0; i < d.length; i++) {
    final ch = d[i];
    if ('MmLlHhVvCcQqZz'.contains(ch)) {
      flush();
      out.add(ch);
    } else if (ch == ',' || ch == ' ' || ch == '\n' || ch == '\t') {
      flush();
    } else if (ch == '-' && buf.isNotEmpty) {
      flush();
      buf.write(ch);
    } else {
      buf.write(ch);
    }
  }
  flush();
  return out;
}
