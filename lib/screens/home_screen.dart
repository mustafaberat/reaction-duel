/// Home: stone title sign, a looping two-player sketch, Play, Settings, ?.
/// The only screen with a banner (rfc §9).
library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../game/home_play_loop.dart';
import '../l10n/app_localizations.dart';
import '../theme/decor.dart';
import '../theme/dino_art.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.playLoopProgress, this.bannerOverride, super.key});

  /// Fixes the home sketch at this point (0–1) for captures.
  final double? playLoopProgress;

  /// Replaces the live AdMob banner (tests / design shots).
  final Widget? bannerOverride;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  );

  @override
  void initState() {
    super.initState();
    final frozen = widget.playLoopProgress;
    if (frozen != null) _loop.value = frozen;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLoop();
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    if (old.playLoopProgress != widget.playLoopProgress) {
      _syncLoop();
    }
  }

  void _syncLoop() {
    final frozen = widget.playLoopProgress;
    final reduce = AppScope.of(context).settings.reduceMotionFor(context);
    if (frozen != null) {
      _loop.stop();
      _loop.value = frozen;
    } else if (reduce) {
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
    final services = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final reduceMotion = services.settings.reduceMotionFor(context);

    return ThemedScaffold(
      decor: DecorKind.home,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final small = h < 600;
            final signH = small ? 104.0 : 124.0;
            final cardH = small ? 88.0 : 118.0;
            final playH = small ? 54.0 : 62.0;
            final sideH = small ? 44.0 : 50.0;
            final playFont = small ? 24.0 : 26.0;
            final sideFont = small ? 15.0 : 17.0;

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: box.maxWidth,
                            child: AnimatedBuilder(
                              animation: _loop,
                              builder: (context, _) {
                                final t = _loop.value;
                                final go = t >= 0.18 && t < 0.56;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: small ? 8 : 22),
                                    _StoneSign(
                                      height: signH,
                                      title: l10n.appTitle,
                                      openMouth: go,
                                      compact: small,
                                    ),
                                    SizedBox(height: small ? 8 : 12),
                                    Text(
                                      l10n.homeTagline,
                                      textAlign: TextAlign.center,
                                      style: theme.bodyLarge!.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: small ? 15 : 17,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: small ? 8 : 16),
                                    Semantics(
                                      label: l10n.homeTagline,
                                      image: true,
                                      excludeSemantics: true,
                                      child: HomePlayLoop(
                                        size: cardH,
                                        waitLabel: l10n.duelWait,
                                        goLabel: l10n.duelGo,
                                        slowTime: l10n.duelMs(
                                          HomePlayLoop.demoSlowMs,
                                        ),
                                        fastTime: l10n.duelMs(
                                          HomePlayLoop.demoFastMs,
                                        ),
                                        reduceMotion: reduceMotion,
                                        frozenProgress: t,
                                      ),
                                    ),
                                    SizedBox(height: small ? 8 : 12),
                                    const _StatsLine(),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        AppButton(
                          label: l10n.play,
                          icon: Icons.play_arrow_rounded,
                          height: playH,
                          fontSize: playFont,
                          iconSize: small ? 26 : 28,
                          foreground: Colors.white,
                          borderColor: AppColors.outline,
                          radius: 22,
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.setup),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.settings,
                                icon: Icons.settings_rounded,
                                height: sideH,
                                fontSize: sideFont,
                                compact: true,
                                iconSize: 21,
                                radius: 18,
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pushNamed(AppRoutes.settings),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton.secondary(
                                label: l10n.howToPlay,
                                icon: Icons.question_mark_rounded,
                                height: sideH,
                                fontSize: sideFont,
                                compact: true,
                                iconSize: 20,
                                radius: 18,
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pushNamed(AppRoutes.howTo),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.gapM),
                FittedBox(
                  key: const ValueKey<String>('home-banner'),
                  fit: BoxFit.scaleDown,
                  child: widget.bannerOverride ?? const _HomeBanner(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StoneSign extends StatelessWidget {
  const _StoneSign({
    required this.height,
    required this.title,
    required this.openMouth,
    required this.compact,
  });

  final double height;
  final String title;
  final bool openMouth;
  final bool compact;

  static const Color _carved = Color(0xFF4A3C28);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth.clamp(0.0, AppDimens.maxContentWidth);
        final ds = sw * 0.47;
        final peek = ds * 0.52;
        final total = height + peek;
        final handW = 22.0;
        final handH = 16.0;

        return SizedBox(
          width: sw,
          height: total,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: sw * 0.03,
                top: 0,
                width: ds,
                height:
                    ds *
                    DinoPainter.viewSize.height /
                    DinoPainter.viewSize.width,
                child: DinoArt.trex(openMouth: openMouth),
              ),
              Positioned(
                right: sw * 0.03,
                top: 0,
                width: ds,
                height:
                    ds *
                    DinoPainter.viewSize.height /
                    DinoPainter.viewSize.width,
                child: const DinoArt.tri(flip: true),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -_StoneSlabPainter.shadowH,
                height: height + _StoneSlabPainter.shadowH,
                child: CustomPaint(painter: const _StoneSlabPainter()),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: sw * 0.72),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontFamilyFallback: const [
                              AppFonts.body,
                              AppFonts.ja,
                              AppFonts.ko,
                              AppFonts.zh,
                            ],
                            fontWeight: FontWeight.w800,
                            fontSize: compact ? 36 : 44,
                            height: 0.95,
                            color: _carved,
                            shadows: const [
                              Shadow(
                                color: Color(0xFFE8E1D2),
                                offset: Offset(0, 2),
                              ),
                              Shadow(
                                color: Color(0xFF8C826E),
                                offset: Offset(0, -1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _Hand(
                left: sw * 0.03 + ds * 0.48,
                bottom: height - 11,
                width: handW,
                height: handH,
                color: DinoPalette.trex.body,
              ),
              _Hand(
                left: sw * 0.03 + ds * 0.62,
                bottom: height - 11,
                width: handW,
                height: handH,
                color: DinoPalette.trex.body,
              ),
              _Hand(
                right: sw * 0.03 + ds * 0.50,
                bottom: height - 11,
                width: handW,
                height: handH,
                color: DinoPalette.tri.body,
              ),
              _Hand(
                right: sw * 0.03 + ds * 0.30,
                bottom: height - 11,
                width: handW,
                height: handH,
                color: DinoPalette.tri.body,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stone plaque: inset #ADA390 band clipped to the inner rounded rect, then a
/// solid (0, 5) drop shadow. Flutter's 0-blur BoxShadow leaves a gap/line.
class _StoneSlabPainter extends CustomPainter {
  const _StoneSlabPainter();

  static const double shadowH = 5;
  static const double shadeH = 8;
  static const double borderW = 4;
  static const Color _slab = Color(0xFFC9C0AE);
  static const Color _shade = Color(0xFFADA390);
  static const Color _shadow = Color(0x593A280C);

  static const BorderRadius _radius = BorderRadius.only(
    topLeft: Radius.circular(26),
    topRight: Radius.circular(30),
    bottomRight: Radius.circular(24),
    bottomLeft: Radius.circular(32),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final slab = Rect.fromLTWH(0, 0, size.width, size.height - shadowH);
    final outer = _radius.toRRect(slab);
    canvas.drawRRect(
      outer.shift(const Offset(0, shadowH)),
      Paint()..color = _shadow,
    );
    canvas.drawRRect(outer, Paint()..color = _slab);
    final inner = outer.deflate(borderW);
    canvas.save();
    canvas.clipRRect(inner);
    canvas.drawRect(
      Rect.fromLTWH(inner.left, inner.bottom - shadeH, inner.width, shadeH),
      Paint()..color = _shade,
    );
    canvas.restore();
    canvas.drawRRect(
      outer.deflate(borderW / 2),
      Paint()
        ..color = AppColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderW,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Hand extends StatelessWidget {
  const _Hand({
    required this.bottom,
    required this.width,
    required this.height,
    required this.color,
    this.left,
    this.right,
  });

  final double? left;
  final double? right;
  final double bottom;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline, width: 3.5),
        ),
      ),
    );
  }
}

class _StatsLine extends StatelessWidget {
  const _StatsLine();

  @override
  Widget build(BuildContext context) {
    final stats = AppScope.of(context).stats;
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: stats,
      builder: (context, _) {
        final best = stats.bestMs;
        if (best == null && stats.totalMatches == 0) {
          return const SizedBox.shrink();
        }
        final parts = [
          if (best != null) l10n.homeRecord(best),
          if (stats.totalMatches > 0) l10n.homeMatches(stats.totalMatches),
        ];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(painter: TrophyPainter()),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                parts.join(AppGlyphs.separator),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppFonts.tabular,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner();

  @override
  Widget build(BuildContext context) {
    final ads = AppScope.of(context).ads;
    return ValueListenableBuilder<BannerAd?>(
      valueListenable: ads.banner,
      builder: (context, ad, _) {
        if (ad == null) return const SizedBox.shrink();
        return SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        );
      },
    );
  }
}
