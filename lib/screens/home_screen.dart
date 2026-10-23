/// Home: title, a looping two-player sketch, Play, Settings, ?.
/// The only screen with a banner (rfc §9).
library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../game/home_play_loop.dart';
import '../l10n/app_localizations.dart';
import '../theme/characters.dart';
import '../theme/decor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.playLoopProgress, super.key});

  /// Fixes the home sketch at this point (0–1) for captures.
  final double? playLoopProgress;

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
            final hero = AppLayout.mascot(h, AppDimens.characterHome);
            final preview = AppLayout.mascot(h, AppDimens.orbHome);
            final compact = AppLayout.short(h);

            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.page,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: inner.maxHeight,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppDimens.maxContentWidth,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: compact
                                        ? AppDimens.gapS
                                        : AppDimens.gapM,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _OutlinedTitle(l10n.appTitle),
                                  ),
                                  const SizedBox(height: AppDimens.gapS),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.gapXl,
                                    ),
                                    child: Text(
                                      l10n.homeTagline,
                                      textAlign: TextAlign.center,
                                      style: theme.bodyLarge!.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: compact
                                        ? AppDimens.gapM
                                        : AppDimens.gapL,
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _HeroRow(size: hero),
                                  ),
                                  SizedBox(
                                    height: compact
                                        ? AppDimens.gapM
                                        : AppDimens.gapL,
                                  ),
                                  Semantics(
                                    label: l10n.homeTagline,
                                    image: true,
                                    excludeSemantics: true,
                                    child: HomePlayLoop(
                                      size: preview,
                                      goLabel: l10n.duelGo,
                                      reduceMotion: reduceMotion,
                                      frozenProgress: playLoopProgress,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimens.gapM),
                                  const _StatsLine(),
                                  SizedBox(
                                    height: compact
                                        ? AppDimens.gapS
                                        : AppDimens.gapM,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.page,
                      0,
                      AppDimens.page,
                      AppDimens.gapM,
                    ),
                    child: Column(
                      children: [
                        AppButton(
                          label: l10n.play,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.setup),
                        ),
                        const SizedBox(height: AppDimens.gapS),
                        AppButton.secondary(
                          label: l10n.settings,
                          icon: Icons.settings_outlined,
                          onPressed: () =>
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.settings),
                        ),
                        const SizedBox(height: AppDimens.gapS),
                        AppButton.secondary(
                          label: l10n.howToPlay,
                          icon: Icons.question_mark_rounded,
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.howTo),
                        ),
                      ],
                    ),
                  ),
                ),
                const _HomeBanner(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OutlinedTitle extends StatelessWidget {
  const _OutlinedTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
        fontSize: AppType.hero,
        height: AppType.heroHeight,
        color: AppColors.displaySkyFill,
        letterSpacing: AppType.displayTracking,
        shadows: AppType.displaySkyHalo,
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CharacterView(
          player: Player.p1,
          mood: CharacterMood.ready,
          size: size,
          flip: true,
        ),
        const SizedBox(width: AppDimens.gapS),
        const _VsBadge(),
        const SizedBox(width: AppDimens.gapS),
        CharacterView(player: Player.p2, mood: CharacterMood.ready, size: size),
      ],
    );
  }
}

class _VsBadge extends StatelessWidget {
  const _VsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.28),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        'VS',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.onAccent,
          height: 1,
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
        return Text(
          parts.join(AppGlyphs.separator),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(fontFeatures: AppFonts.tabular),
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
