/// Home sketch of one round: wait, tap the print, the faster time wins.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../theme/dino_art.dart';

class HomePlayLoop extends StatefulWidget {
  const HomePlayLoop({
    required this.waitLabel,
    required this.goLabel,
    required this.slowTime,
    required this.fastTime,
    this.size = 118,
    this.reduceMotion = false,
    this.frozenProgress,
    super.key,
  });

  /// Height of the cream strip. Width expands to the parent.
  final double size;

  /// Same words the match shows on the wait / go cue.
  final String waitLabel;
  final String goLabel;
  final String slowTime;
  final String fastTime;
  final bool reduceMotion;

  /// Fixes the loop at this point (0–1) for captures.
  final double? frozenProgress;

  /// Frozen frame: both times are up and the faster chip is gold.
  static const double stillFrame = 0.84;

  /// Demo times shown in the sketch (ms).
  static const int demoSlowMs = 361;
  static const int demoFastMs = 214;

  /// Placeholder chips before the result frame.
  static const String pendingTime = '… ms';

  @override
  State<HomePlayLoop> createState() => _HomePlayLoopState();
}

class _HomePlayLoopState extends State<HomePlayLoop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(HomePlayLoop old) {
    super.didUpdateWidget(old);
    if (old.reduceMotion != widget.reduceMotion ||
        old.frozenProgress != widget.frozenProgress) {
      _sync();
    }
  }

  void _sync() {
    final frozen = widget.frozenProgress;
    if (frozen != null) {
      _loop.stop();
      _loop.value = frozen;
    } else if (widget.reduceMotion) {
      _loop.stop();
      _loop.value = HomePlayLoop.stillFrame;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, _) => _Board(
          t: _loop.value,
          height: widget.size,
          waitLabel: widget.waitLabel,
          goLabel: widget.goLabel,
          slowTime: widget.slowTime,
          fastTime: widget.fastTime,
        ),
      ),
    );
  }
}

enum _Phase { wait, go, press, result }

class _Board extends StatelessWidget {
  const _Board({
    required this.t,
    required this.height,
    required this.waitLabel,
    required this.goLabel,
    required this.slowTime,
    required this.fastTime,
  });

  final double t;
  final double height;
  final String waitLabel;
  final String goLabel;
  final String slowTime;
  final String fastTime;

  static const double _goAt = 0.18;
  static const double _pressAt = 0.38;
  static const double _resultAt = 0.56;
  static const double _resetAt = 0.92;

  static const Color _cream = Color(0xFFFFF8E2);

  _Phase get _phase {
    if (t >= _resetAt) return _Phase.wait;
    if (t >= _resultAt) return _Phase.result;
    if (t >= _pressAt) return _Phase.press;
    if (t >= _goAt) return _Phase.go;
    return _Phase.wait;
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase;
    final live = phase != _Phase.wait;
    final pressed = phase == _Phase.press;
    final won = phase == _Phase.result;
    final stamp = phase == _Phase.press || phase == _Phase.result;
    final orb = (height - 14).clamp(56.0, 132.0);

    return SizedBox(
      height: height + 5,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outline, width: 3.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D3A280C),
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _Side(
                            color: DinoPalette.trex.body,
                            child: _TimeChip(
                              text: won ? fastTime : HomePlayLoop.pendingTime,
                              gold: won,
                              faded: !won,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _Side(
                            color: DinoPalette.tri.body,
                            child: _TimeChip(
                              text: won ? slowTime : HomePlayLoop.pendingTime,
                              faded: !won,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Orb(
                    size: orb,
                    live: live,
                    pressed: pressed,
                    label: live ? goLabel : waitLabel,
                  ),
                ],
              ),
            ),
          ),
          if (stamp)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: height,
              child: IgnorePointer(
                child: CustomPaint(painter: _DirtStampPainter(orb: orb)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DirtStampPainter extends CustomPainter {
  const _DirtStampPainter({required this.orb});

  final double orb;

  @override
  void paint(Canvas canvas, Size size) {
    final splash = orb * 0.48;
    final c = Offset(size.width / 2 + orb * 0.38, size.height / 2 + orb * 0.28);
    canvas.save();
    canvas.translate(c.dx - splash / 2, c.dy - splash / 2);
    paintDirt(canvas, Size.square(splash));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DirtStampPainter old) => old.orb != orb;
}

class _Side extends StatelessWidget {
  const _Side({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline, width: 2.5),
          ),
        ),
        const SizedBox(height: 3),
        child,
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.text, this.gold = false, this.faded = false});

  final String text;
  final bool gold;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gold ? const Color(0xFFFFC93C) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D3A280C),
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 1, 9, 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (gold) ...[
                const SizedBox(
                  width: 16,
                  height: 14,
                  child: CustomPaint(painter: ChipCrownPainter()),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontFamilyFallback: AppFonts.fallback,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.15,
                  color: AppColors.text,
                  fontFeatures: AppFonts.tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.live,
    required this.pressed,
    required this.label,
  });

  final double size;
  final bool live;
  final bool pressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fill = live ? const Color(0xFF3D9E45) : const Color(0xFFE9A93A);
    final printColor = live ? const Color(0xE6FFFFFF) : const Color(0x733A280C);
    final labelColor = live ? Colors.white : AppColors.outline;
    final printSize = size * 0.42;

    return Transform.scale(
      scale: pressed ? 0.94 : 1,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline, width: 4),
          boxShadow: [
            const BoxShadow(
              color: AppColors.outline,
              offset: Offset(0, 5),
              blurRadius: 0,
            ),
            if (live && !pressed)
              BoxShadow(
                color: const Color(0xFF3D9E45).withValues(alpha: 0.25),
                spreadRadius: 8,
                blurRadius: 0,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: printSize,
              height: printSize,
              child: CustomPaint(painter: FootprintPainter(printColor)),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.08),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.fallback,
                    fontWeight: FontWeight.w800,
                    fontSize: (size * 0.17).clamp(13.0, 22.0),
                    height: 1,
                    color: labelColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
