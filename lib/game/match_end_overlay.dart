/// Match end: winner, score, per-player stats, session series, Rematch.
/// Mirrored for both players (top copy rotated 180°).
library;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/celebration.dart';
import '../theme/characters.dart';
import '../theme/decor.dart';

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
        color: AppColors.scrim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ThemeDecor(kind: DecorKind.overlay),
            Column(
              children: [
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: _EndPanel(overlay: this, edgeInset: padding.top),
                  ),
                ),
                Divider(height: AppDimens.hairline, color: AppColors.hairline),
                Expanded(
                  child: _EndPanel(overlay: this, edgeInset: padding.bottom),
                ),
              ],
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 400 || constraints.maxHeight < 340;
        final padH = tight ? AppDimens.pageTight : AppDimens.page;
        final rematchH = tight
            ? AppDimens.buttonHeightSmall
            : AppDimens.buttonHeight;
        final winSize = AppLayout.endWinSize(constraints.maxHeight);
        final loseSize = AppLayout.endLoseSize(winSize);
        final nameSize = tight ? 18.0 : AppType.endName;
        final scoreSize = tight ? 28.0 : AppType.endScore;
        final bodySize = tight ? 12.0 : AppType.bodySmall;
        final topPad = winSize * 0.18;
        final dinoGap = tight ? AppDimens.gapL : AppDimens.gapXl;

        Widget dinoSlot({required Widget child, double endPad = 0}) {
          return Padding(
            padding: EdgeInsets.only(top: topPad, right: endPad),
            child: child,
          );
        }

        Widget dinos() => Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Positioned.fill(child: ConfettiBurst()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                dinoSlot(
                  child: CharacterView(
                    player: winner,
                    mood: CharacterMood.happy,
                    size: winSize,
                    crowned: true,
                  ),
                ),
                SizedBox(width: dinoGap),
                dinoSlot(
                  endPad: loseSize * 0.22,
                  child: CharacterView(
                    player: loser,
                    mood: CharacterMood.nextTime,
                    size: loseSize,
                  ),
                ),
              ],
            ),
          ],
        );

        Widget winnerLine() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimens.dot,
              height: AppDimens.dot,
              decoration: BoxDecoration(
                color: winnerHue.ink,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimens.gapS),
            Flexible(
              child: Text(
                l10n.endWinner(overlay.names[winner.index]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.displayMedium!.copyWith(fontSize: nameSize),
              ),
            ),
          ],
        );

        Widget score() => Text(
          '${s.scoreOf(winner)}${AppGlyphs.scoreDash}${s.scoreOf(loser)}',
          style: theme.displayLarge!.copyWith(
            fontSize: scoreSize,
            fontFeatures: AppFonts.tabular,
          ),
        );

        Widget stats() => _StatsTable(overlay: overlay, bodySize: bodySize);

        final headline = tight
            ? Row(
                children: [
                  Expanded(child: winnerLine()),
                  const SizedBox(width: AppDimens.gapS),
                  score(),
                ],
              )
            : Column(
                children: [
                  winnerLine(),
                  const SizedBox(height: AppDimens.gapXs),
                  score(),
                ],
              );

        final body = <Widget>[
          dinos(),
          SizedBox(height: tight ? AppDimens.gapXs : AppDimens.gapS),
          headline,
          if (overlay.newRecord) ...[
            const SizedBox(height: AppDimens.gapXs),
            _Badge(text: l10n.endNewRecord),
          ],
          SizedBox(height: tight ? AppDimens.gapXs : AppDimens.gapS),
          stats(),
        ];

        return Padding(
          padding: EdgeInsets.fromLTRB(
            padH,
            tight ? AppDimens.gapXs : AppDimens.gapM,
            padH,
            AppDimens.gapXs + edgeInset,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.endPanelMaxWidth,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: body,
                      ),
                    ),
                  ),
                  SizedBox(height: tight ? AppDimens.gapXs : AppDimens.gapS),
                  AppButton(
                    label: l10n.endRematch,
                    icon: Icons.replay_rounded,
                    height: rematchH,
                    onPressed: overlay.onRematch,
                  ),
                  SizedBox(height: tight ? AppDimens.gapXs : AppDimens.gapS),
                  _EndSecondaryActions(
                    changeLabel: l10n.endChangeSettings,
                    homeLabel: l10n.home,
                    onChangeSettings: overlay.onChangeSettings,
                    onHome: overlay.onHome,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EndSecondaryActions extends StatelessWidget {
  const _EndSecondaryActions({
    required this.changeLabel,
    required this.homeLabel,
    required this.onChangeSettings,
    required this.onHome,
  });

  final String changeLabel;
  final String homeLabel;
  final VoidCallback onChangeSettings;
  final VoidCallback onHome;

  bool _wordTooWide(BuildContext context, String label, double textWidth) {
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: AppType.caption,
      fontWeight: FontWeight.w600,
    );
    for (final word in label.split(RegExp(r'\s+'))) {
      final painter = TextPainter(
        text: TextSpan(text: word, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
      )..layout();
      if (painter.width > textWidth * 1.2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    AppButton compact(String label, IconData icon, VoidCallback onPressed) {
      return AppButton.secondary(
        label: label,
        icon: icon,
        expand: true,
        compact: true,
        height: AppDimens.buttonHeightSmall,
        onPressed: onPressed,
      );
    }

    final change = compact(
      changeLabel,
      Icons.tune_rounded,
      onChangeSettings,
    );
    final home = compact(homeLabel, Icons.home_outlined, onHome);

    return LayoutBuilder(
      builder: (context, c) {
        final chrome =
            AppDimens.gapM * 2 + AppDimens.iconSmall + AppDimens.gapXs;
        final textWidth = (c.maxWidth - AppDimens.gapS) / 2 - chrome;
        final stack =
            AppLayout.stackEndActions(c.maxWidth) ||
            textWidth < 48 ||
            _wordTooWide(context, changeLabel, textWidth) ||
            _wordTooWide(context, homeLabel, textWidth);
        if (stack) {
          return Column(
            children: [
              change,
              const SizedBox(height: AppDimens.gapS),
              home,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: change),
            const SizedBox(width: AppDimens.gapS),
            Expanded(child: home),
          ],
        );
      },
    );
  }
}

class _StatsTable extends StatelessWidget {
  const _StatsTable({required this.overlay, required this.bodySize});

  final MatchEndOverlay overlay;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final s = overlay.state;
    final compact = bodySize <= 13;
    String ms(int? v) => v == null ? l10n.duelNoTime : l10n.duelMs(v);

    TableRow row(String label, String a, String b, {bool header = false}) {
      final style = (header ? theme.bodySmall! : theme.titleMedium!).copyWith(
        fontSize: bodySize,
        height: 1.1,
        fontFeatures: header ? null : AppFonts.tabular,
      );
      Widget cell(
        String text, {
        TextAlign align = TextAlign.right,
        Color? color,
      }) => Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 1 : 3),
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
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimens.gapS : AppDimens.gapL,
        vertical: compact ? 2 : AppDimens.gapS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.hairline),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.gapM,
        vertical: AppDimens.gapXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            size: AppDimens.iconSmall,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppDimens.gapXs),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
