/// Match end: one upright card over the whole board.
///
/// Winner + loser dinos, title, stats, Rematch, then Change settings / Home.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/celebration.dart';
import '../theme/dino_art.dart';
import '../theme/decor.dart';

class MatchEndOverlay extends StatelessWidget {
  const MatchEndOverlay({
    required this.state,
    required this.names,
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
            LayoutBuilder(
              builder: (context, constraints) {
                return _EndCard(
                  overlay: this,
                  constraints: constraints,
                  padding: padding,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EndCard extends StatelessWidget {
  const _EndCard({
    required this.overlay,
    required this.constraints,
    required this.padding,
  });

  final MatchEndOverlay overlay;
  final BoxConstraints constraints;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final s = overlay.state;
    final winner = s.matchWinner ?? Player.p1;
    final loser = winner.other;
    final winnerInk = dinoAccent(winner);

    final short = AppLayout.short(constraints.maxHeight);
    final tiny = AppLayout.tiny(constraints.maxHeight);
    final padH = tiny ? AppDimens.pageTight : AppDimens.page;
    final cardPad = tiny ? AppDimens.gapM : AppDimens.gapL;
    final rematchH = tiny
        ? AppDimens.buttonHeightSmall
        : AppDimens.buttonHeight;

    final innerW = math.min(
      constraints.maxWidth - padH * 2,
      AppDimens.endCardMaxWidth,
    );
    final heightSize = AppLayout.endWinSize(constraints.maxHeight);
    final widthSize = ((innerW - cardPad * 2 - AppDimens.gapL) / 2.2).clamp(
      72.0,
      120.0,
    );
    final winSize = math.min(heightSize, widthSize);
    final loseSize = AppLayout.endLoseSize(winSize);
    final nameSize = tiny ? 20.0 : AppType.endName;
    final scoreSize = tiny ? 30.0 : AppType.endScore;
    final bodySize = tiny ? 14.0 : AppType.bodySmall;
    final dinoGap = tiny ? AppDimens.gapM : AppDimens.gapL;

    Widget dino(
      Player player, {
      required CharacterMood mood,
      required double size,
      required bool flip,
      bool crowned = false,
    }) {
      return DinoArt.forPlayer(
        player,
        mood: mood,
        size: size,
        flip: flip,
        crowned: crowned,
      );
    }

    Widget dinos() => SizedBox(
      height: DinoArt.heightFor(winSize) + winSize * 0.18,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Positioned.fill(child: ConfettiBurst()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: winSize * 0.1),
                child: dino(
                  winner,
                  mood: CharacterMood.happy,
                  size: winSize,
                  flip: false,
                  crowned: true,
                ),
              ),
              SizedBox(width: dinoGap),
              Padding(
                padding: EdgeInsets.only(top: winSize * 0.16),
                child: dino(
                  loser,
                  mood: CharacterMood.nextTime,
                  size: loseSize,
                  flip: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget title() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          key: const ValueKey('match-end-winner-dot'),
          width: AppDimens.dot,
          height: AppDimens.dot,
          decoration: BoxDecoration(color: winnerInk, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimens.gapS),
        Flexible(
          child: Text(
            l10n.endWinner(overlay.names[winner.index]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.displayMedium!.copyWith(
              fontSize: nameSize,
              color: winnerInk,
            ),
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
                    dinos(),
                    SizedBox(height: tiny ? AppDimens.gapS : AppDimens.gapM),
                    title(),
                    const SizedBox(height: AppDimens.gapXs),
                    score(),
                    if (overlay.newRecord) ...[
                      const SizedBox(height: AppDimens.gapS),
                      _Badge(text: l10n.endNewRecord),
                    ],
                    SizedBox(height: tiny ? AppDimens.gapS : AppDimens.gapM),
                    _StatsTable(overlay: overlay, bodySize: bodySize),
                    SizedBox(height: tiny ? AppDimens.gapM : AppDimens.gapL),
                    AppButton(
                      label: l10n.endRematch,
                      icon: Icons.replay_rounded,
                      height: rematchH,
                      onPressed: overlay.onRematch,
                    ),
                    const SizedBox(height: AppDimens.gapS),
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
          ),
        ),
      ),
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
          child: outlined(
            changeLabel,
            Icons.tune_rounded,
            onChangeSettings,
          ),
        ),
        const SizedBox(width: AppDimens.gapS),
        Expanded(child: outlined(homeLabel, Icons.home_outlined, onHome)),
      ],
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
    String ms(int? v) => v == null ? l10n.duelNoTime : l10n.duelMs(v);

    TableRow row(String label, String a, String b, {bool header = false}) {
      final style = (header ? theme.bodySmall! : theme.titleMedium!).copyWith(
        fontSize: bodySize,
        height: 1.25,
        fontFeatures: header ? null : AppFonts.tabular,
      );
      Widget cell(
        String text, {
        TextAlign align = TextAlign.right,
        Color? color,
      }) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
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
          cell(a, color: header ? dinoAccent(Player.p1) : null),
          cell(b, color: header ? dinoAccent(Player.p2) : null),
        ],
      );
    }

    final p1 = s.statsOf(Player.p1);
    final p2 = s.statsOf(Player.p2);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.gapM,
          vertical: AppDimens.gapS,
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
