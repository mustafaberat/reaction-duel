/// Home: title, breathing orb (same component as the duel), Play, Settings, ?.
/// The only screen with a banner (rfc §9).
library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../game/signal_orb.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.autoOpenHowTo = true, super.key});

  /// First launch opens How to Play once (skippable).
  final bool autoOpenHowTo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.autoOpenHowTo) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = AppScope.read(context).settings;
      if (settings.howToSeen) return;
      settings.setHowToSeen();
      Navigator.of(context).pushNamed(AppRoutes.howTo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final reduceMotion = services.settings.reduceMotionFor(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.page,
                AppDimens.gapS,
                AppDimens.pageTight,
                0,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  AppIconButton(
                    icon: Icons.question_mark_rounded,
                    tooltip: l10n.howToPlay,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.howTo),
                  ),
                  const SizedBox(width: AppDimens.gapS),
                  AppIconButton(
                    icon: Icons.settings_outlined,
                    tooltip: l10n.settings,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.page),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        Text(l10n.appTitle, textAlign: TextAlign.center, style: theme.displayLarge),
                        const SizedBox(height: AppDimens.gapM),
                        Text(
                          l10n.homeTagline,
                          textAlign: TextAlign.center,
                          style: theme.bodyLarge!.copyWith(color: AppColors.textMuted),
                        ),
                        const Spacer(flex: 3),
                        SignalOrb(
                          size: AppDimens.orbHome,
                          reduceMotion: reduceMotion,
                        ),
                        const Spacer(flex: 3),
                        _StatsLine(),
                        const SizedBox(height: AppDimens.gapL),
                        AppButton(
                          label: l10n.play,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.setup),
                        ),
                        const SizedBox(height: AppDimens.gapXl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const _HomeBanner(),
          ],
        ),
      ),
    );
  }
}

class _StatsLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = AppScope.of(context).stats;
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: stats,
      builder: (context, _) {
        final best = stats.bestMs;
        if (best == null && stats.totalMatches == 0) {
          return const SizedBox(height: AppDimens.gapL);
        }
        final parts = [
          if (best != null) l10n.homeRecord(best),
          if (stats.totalMatches > 0) l10n.homeMatches(stats.totalMatches),
        ];
        return Text(
          parts.join(AppGlyphs.separator),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFeatures: AppFonts.tabular),
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
