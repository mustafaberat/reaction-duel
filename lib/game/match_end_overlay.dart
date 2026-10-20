/// Match end: winner, score, per-player stats, session series, Rematch.
/// Mirrored for both players (top copy rotated 180°).
library;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';

class MatchEndOverlay extends StatelessWidget {
  const MatchEndOverlay({
    required this.state,
    required this.names,
    required this.hues,
    required this.series,
    required this.onRematch,
    required this.onChangeSettings,
    required this.onHome,
    this.newRecord = false,
    this.reduceMotion = false,
    super.key,
  });

  final DuelState state;
  final List<String> names;
  final List<PlayerHue> hues;
  final List<int> series;
  final bool newRecord;
  final bool reduceMotion;
  final VoidCallback onRematch;
  final VoidCallback onChangeSettings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
      duration: AppMotion.medium,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: ColoredBox(
        color: AppColors.background,
        child: Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: _EndPanel(overlay: this, edgeInset: padding.top),
              ),
            ),
            const Divider(height: AppDimens.hairline, color: AppColors.hairline),
            Expanded(
              child: _EndPanel(overlay: this, edgeInset: padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndPanel extends StatelessWidget {
  const _EndPanel({required this.overlay, required this.edgeInset});

  final MatchEndOverlay overlay;
  final double edgeInset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final s = overlay.state;
    final winner = s.matchWinner ?? Player.p1;
    final loser = winner.other;
    final winnerHue = overlay.hues[winner.index];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.page,
        AppDimens.gapL,
        AppDimens.page,
        AppDimens.gapL + edgeInset,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: AppDimens.endPanelMaxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: AppDimens.dot,
                      height: AppDimens.dot,
                      decoration: BoxDecoration(color: winnerHue.ink, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppDimens.gapS),
                    Flexible(
                      child: Text(
                        l10n.endWinner(overlay.names[winner.index]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.displayMedium!.copyWith(fontSize: AppType.endName),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.gapXs),
                Text(
                  '${s.scoreOf(winner)}${AppGlyphs.scoreDash}${s.scoreOf(loser)}',
                  style: theme.displayLarge!.copyWith(
                    fontSize: AppType.endScore,
                    color: winnerHue.ink,
                    fontFeatures: AppFonts.tabular,
                  ),
                ),
                if (overlay.newRecord) ...[
                  const SizedBox(height: AppDimens.gapS),
                  _Badge(text: l10n.endNewRecord),
                ],
                const SizedBox(height: AppDimens.gapL),
                _StatsTable(overlay: overlay),
                const SizedBox(height: AppDimens.gapL),
                AppButton(
                  label: l10n.endRematch,
                  icon: Icons.replay_rounded,
                  onPressed: overlay.onRematch,
                ),
                const SizedBox(height: AppDimens.gapS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AppButton.ghost(
                        label: l10n.endChangeSettings,
                        expand: true,
                        onPressed: overlay.onChangeSettings,
                      ),
                    ),
                    Expanded(
                      child: AppButton.ghost(
                        label: l10n.home,
                        expand: true,
                        onPressed: overlay.onHome,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsTable extends StatelessWidget {
  const _StatsTable({required this.overlay});

  final MatchEndOverlay overlay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final s = overlay.state;
    String ms(int? v) => v == null ? l10n.duelNoTime : l10n.duelMs(v);

    TableRow row(String label, String a, String b, {bool header = false}) {
      final style = header
          ? theme.bodySmall!
          : theme.titleMedium!.copyWith(
              fontSize: AppType.bodySmall,
              fontFeatures: AppFonts.tabular,
            );
      Widget cell(String text, {TextAlign align = TextAlign.right, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.gapXs + 1),
        child: Text(
          text,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: color),
        ),
      );
      return TableRow(
        children: [
          cell(label, align: TextAlign.left, color: AppColors.textMuted),
          cell(a, color: header ? overlay.hues[0].ink : null),
          cell(b, color: header ? overlay.hues[1].ink : null),
        ],
      );
    }

    final p1 = s.statsOf(Player.p1);
    final p2 = s.statsOf(Player.p2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapL, vertical: AppDimens.gapS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.hairline),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(),
          1: FixedColumnWidth(AppDimens.statsColumn),
          2: FixedColumnWidth(AppDimens.statsColumn),
        },
        children: [
          row('', overlay.names[0], overlay.names[1], header: true),
          row(l10n.endBest, ms(p1.bestMs), ms(p2.bestMs)),
          row(l10n.endAverage, ms(p1.averageMs), ms(p2.averageMs)),
          row(l10n.endFouls, '${p1.fouls}', '${p2.fouls}'),
          row(l10n.endSeries, '${overlay.series[0]}', '${overlay.series[1]}'),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapM, vertical: AppDimens.gapXs),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: AppDimens.iconSmall, color: AppColors.accent),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
