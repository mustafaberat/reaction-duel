/// Home sketch of one round: both players tap, the faster time grows.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

class HomePlayLoop extends StatefulWidget {
  const HomePlayLoop({
    required this.size,
    required this.goLabel,
    this.reduceMotion = false,
    this.frozenProgress,
    super.key,
  });

  final double size;

  /// Same word the match shows when the signal turns the button color.
  final String goLabel;
  final bool reduceMotion;

  /// Fixes the loop at this point (0–1) for captures.
  final double? frozenProgress;

  /// Frozen frame: both times are up and the faster side has the trophy.
  static const double stillFrame = 0.84;

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
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _loop,
          builder: (context, _) => _Board(
            t: _loop.value,
            size: widget.size,
            goLabel: widget.goLabel,
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.t, required this.size, required this.goLabel});

  final double t;
  final double size;
  final String goLabel;

  /// Example round. The bottom tap is faster, so it wins.
  static const String _slow = '361 ms';
  static const String _fast = '214 ms';

  static const double _signalOn = 0.08;
  static const double _signalOff = 0.94;
  static const double _fastPress = 0.18;
  static const double _fastTime = 0.34;
  static const double _slowPress = 0.44;
  static const double _slowTime = 0.62;
  static const double _trophy = 0.76;

  @override
  Widget build(BuildContext context) {
    final signal = t >= _signalOn && t < _signalOff;
    final won = t >= _trophy && t < _signalOff;
    final orb = size * 0.36;
    final icon = size * 0.13;
    final timeSize = size * 0.075;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: ColoredBox(
        color: AppColors.surface,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _Half(
                    alignment: const Alignment(0, -0.62),
                    child: _SlowCue(
                      pressing: t >= _slowPress && t < _slowTime,
                      showing: t >= _slowTime && t < _signalOff,
                      shrunk: won,
                      icon: icon,
                      timeSize: timeSize,
                    ),
                  ),
                ),
                Expanded(
                  child: _Half(
                    alignment: const Alignment(0, 0.72),
                    child: _FastCue(
                      pressing: t >= _fastPress && t < _fastTime,
                      showing: t >= _fastTime && t < _signalOff,
                      trophy: won,
                      icon: icon,
                      timeSize: timeSize,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              top: size / 2 - 1,
              height: 2,
              child: ColoredBox(color: AppColors.textMuted),
            ),
            Center(
              child: Container(
                width: orb,
                height: orb,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: signal ? AppColors.accent : AppColors.orbCore,
                  border: Border.all(
                    color: AppColors.orbRing,
                    width: AppDimens.orbRingWidth,
                  ),
                ),
                child: signal
                    ? Text(
                        goLabel,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontFamilyFallback: AppFonts.fallback,
                          fontSize: orb * 0.28,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: AppColors.onAccent,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Align(alignment: alignment, child: child),
    );
  }
}

class _SlowCue extends StatelessWidget {
  const _SlowCue({
    required this.pressing,
    required this.showing,
    required this.shrunk,
    required this.icon,
    required this.timeSize,
  });

  final bool pressing;
  final bool showing;
  final bool shrunk;
  final double icon;
  final double timeSize;

  @override
  Widget build(BuildContext context) {
    if (pressing) {
      return Transform.rotate(
        angle: 3.1416,
        child: Transform.scale(
          scale: 0.88,
          child: Icon(
            Icons.touch_app_rounded,
            size: icon,
            color: AppColors.text,
          ),
        ),
      );
    }
    if (!showing) return SizedBox(width: icon, height: icon);
    return Transform.scale(
      scale: shrunk ? 0.72 : 1,
      child: Text(
        _Board._slow,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontFamilyFallback: AppFonts.fallback,
          fontSize: timeSize,
          fontWeight: FontWeight.w700,
          height: 1,
          color: shrunk ? AppColors.textMuted : AppColors.text,
          fontFeatures: AppFonts.tabular,
        ),
      ),
    );
  }
}

class _FastCue extends StatelessWidget {
  const _FastCue({
    required this.pressing,
    required this.showing,
    required this.trophy,
    required this.icon,
    required this.timeSize,
  });

  final bool pressing;
  final bool showing;
  final bool trophy;
  final double icon;
  final double timeSize;

  @override
  Widget build(BuildContext context) {
    if (pressing) {
      return Transform.scale(
        scale: 0.88,
        child: Icon(Icons.touch_app_rounded, size: icon, color: AppColors.text),
      );
    }
    if (!showing) return SizedBox(width: icon, height: icon);
    return Transform.scale(
      scale: trophy ? 1.28 : 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trophy) ...[
            Icon(
              Icons.emoji_events_rounded,
              size: icon * 0.9,
              color: AppColors.text,
            ),
            SizedBox(width: timeSize * 0.25),
          ],
          Text(
            _Board._fast,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontFamilyFallback: AppFonts.fallback,
              fontSize: timeSize,
              fontWeight: FontWeight.w700,
              height: 1,
              color: AppColors.text,
              fontFeatures: AppFonts.tabular,
            ),
          ),
        ],
      ),
    );
  }
}
