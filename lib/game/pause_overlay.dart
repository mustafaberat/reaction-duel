/// One upright pause card over the whole board — dozing dinos + actions.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/dino_art.dart';
import '../theme/decor.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    this.reduceMotion = false,
    this.frozenProgress,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final bool reduceMotion;

  /// Fixes the doze loop at this point (0–1) for captures.
  final double? frozenProgress;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: AppColors.scrim,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ThemeDecor(kind: DecorKind.overlay),
          LayoutBuilder(
            builder: (context, constraints) {
              return _PauseCard(
                overlay: this,
                constraints: constraints,
                padding: padding,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({
    required this.overlay,
    required this.constraints,
    required this.padding,
  });

  final PauseOverlay overlay;
  final BoxConstraints constraints;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final short = AppLayout.short(constraints.maxHeight);
    final tiny = AppLayout.tiny(constraints.maxHeight);
    final padH = tiny ? AppDimens.pageTight : AppDimens.page;
    final cardPad = tiny ? AppDimens.gapM : AppDimens.gapL;
    final resumeH = tiny ? AppDimens.buttonHeightSmall : AppDimens.buttonHeight;

    final innerW = math.min(
      constraints.maxWidth - padH * 2,
      AppDimens.endCardMaxWidth,
    );
    final heightSize = AppLayout.endWinSize(constraints.maxHeight);
    final widthSize = ((innerW - cardPad * 2 - AppDimens.gapL) / 2.2).clamp(
      64.0,
      110.0,
    );
    final dinoSize = math.min(heightSize, widthSize);
    final titleSize = tiny ? 22.0 : AppType.display;
    final dinoGap = tiny ? AppDimens.gapM : AppDimens.gapL;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padH,
        math.max(padding.top, AppDimens.gapS) + AppDimens.gapS,
        padH,
        math.max(padding.bottom, AppDimens.gapS) + AppDimens.gapS,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppDimens.endCardMaxWidth,
            maxHeight: constraints.maxHeight,
          ),
          child: SingleChildScrollView(
            child: DecoratedBox(
              key: const ValueKey('pause-card'),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                border: Border.all(
                  color: AppColors.outline,
                  width: AppDimens.cardOutline,
                ),
                boxShadow: AppShadows.card,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  cardPad,
                  short ? AppDimens.gapM : AppDimens.gapL,
                  cardPad,
                  cardPad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DozingDinos(
                      size: dinoSize,
                      gap: dinoGap,
                      reduceMotion: overlay.reduceMotion,
                      frozenProgress: overlay.frozenProgress,
                    ),
                    SizedBox(height: tiny ? AppDimens.gapS : AppDimens.gapM),
                    Text(
                      l10n.pauseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.displayMedium!.copyWith(fontSize: titleSize),
                    ),
                    SizedBox(height: tiny ? AppDimens.gapM : AppDimens.gapL),
                    AppButton(
                      label: l10n.pauseResume,
                      icon: Icons.play_arrow_rounded,
                      height: resumeH,
                      onPressed: overlay.onResume,
                    ),
                    const SizedBox(height: AppDimens.gapS),
                    _PauseSecondaryActions(
                      restartLabel: l10n.pauseRestart,
                      homeLabel: l10n.home,
                      onRestart: overlay.onRestart,
                      onHome: overlay.onHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseSecondaryActions extends StatelessWidget {
  const _PauseSecondaryActions({
    required this.restartLabel,
    required this.homeLabel,
    required this.onRestart,
    required this.onHome,
  });

  final String restartLabel;
  final String homeLabel;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    AppButton outlined(String label, IconData icon, VoidCallback onPressed) {
      return AppButton.secondary(
        label: label,
        icon: icon,
        expand: true,
        compact: true,
        height: AppDimens.buttonHeightSmall,
        onPressed: onPressed,
      );
    }

    return Row(
      children: [
        Expanded(
          child: outlined(restartLabel, Icons.replay_rounded, onRestart),
        ),
        const SizedBox(width: AppDimens.gapS),
        Expanded(child: outlined(homeLabel, Icons.home_outlined, onHome)),
      ],
    );
  }
}

class _DozingDinos extends StatefulWidget {
  const _DozingDinos({
    required this.size,
    required this.gap,
    required this.reduceMotion,
    this.frozenProgress,
  });

  final double size;
  final double gap;
  final bool reduceMotion;
  final double? frozenProgress;

  @override
  State<_DozingDinos> createState() => _DozingDinosState();
}

class _DozingDinosState extends State<_DozingDinos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: AppMotion.breath,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_DozingDinos old) {
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
      _loop.value = frozen.clamp(0.0, 1.0);
    } else if (widget.reduceMotion) {
      _loop.stop();
      _loop.value = 0.35;
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
    final zzzHead = widget.size * 0.42;
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        return SizedBox(
          height: DinoArt.heightFor(widget.size) + zzzHead,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _DozingBuddy(
                player: Player.p1,
                size: widget.size,
                t: _loop.value,
                reduceMotion: widget.reduceMotion,
                flip: false,
              ),
              SizedBox(width: widget.gap),
              _DozingBuddy(
                player: Player.p2,
                size: widget.size,
                t: (_loop.value + 0.38) % 1.0,
                reduceMotion: widget.reduceMotion,
                flip: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DozingBuddy extends StatelessWidget {
  const _DozingBuddy({
    required this.player,
    required this.size,
    required this.t,
    required this.reduceMotion,
    required this.flip,
  });

  final Player player;
  final double size;
  final double t;
  final bool reduceMotion;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(t * math.pi * 2);
    final scale = reduceMotion
        ? 1.0
        : AppMotion.breathMin +
              (AppMotion.breathMax - AppMotion.breathMin) * (0.5 + 0.5 * wave);
    final bob = reduceMotion ? 0.0 : wave * -4;

    return SizedBox(
      width: size,
      height: DinoArt.heightFor(size) + size * 0.42,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: flip
                ? const Alignment(-0.42, -1)
                : const Alignment(0.42, -1),
            child: _SleepZzz(
              t: t,
              reduceMotion: reduceMotion,
              color: dinoAccent(player),
            ),
          ),
          Transform.translate(
            offset: Offset(0, bob),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: DinoArt.forPlayer(
                player,
                mood: CharacterMood.sleepy,
                size: size,
                flip: flip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepZzz extends StatelessWidget {
  const _SleepZzz({
    required this.t,
    required this.reduceMotion,
    required this.color,
  });

  final double t;
  final bool reduceMotion;
  final Color color;

  static const _letters = ['Z', 'z', 'z'];

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium!
        .copyWith(color: color, fontWeight: FontWeight.w800, height: 1);
    return SizedBox(
      width: 40,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < _letters.length; i++)
            _letter(i, _letters[i], style),
        ],
      ),
    );
  }

  Widget _letter(int i, String glyph, TextStyle style) {
    final phase = reduceMotion ? 0.28 + i * 0.22 : (t + i * 0.28) % 1.0;
    final rise = 6.0 + phase * 28;
    final drift = (i - 1) * 9.0 + phase * 6;
    final fade = reduceMotion ? 0.78 - i * 0.12 : (1 - phase) * 0.88;
    final size = 15.0 - i * 2.4;
    return Positioned(
      left: 12 + drift,
      bottom: rise,
      child: Opacity(
        opacity: fade.clamp(0.0, 1.0),
        child: Text(glyph, style: style.copyWith(fontSize: size)),
      ),
    );
  }
}
