/// Match setup (rfc §5). Defaults let players hit Start immediately; every
/// change is persisted.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../components/form_rows.dart';
import '../components/screen_header.dart';
import '../components/segmented_choice.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/duel_settings.dart';
import '../engine/signal_palette.dart';
import '../game/duel_labels.dart';
import '../game/duel_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  late final TextEditingController _p1;
  late final TextEditingController _p2;

  @override
  void initState() {
    super.initState();
    final match = AppScope.read(context).settings.match;
    _p1 = TextEditingController(text: match.p1Name);
    _p2 = TextEditingController(text: match.p2Name);
  }

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  SettingsService get _settings => AppScope.read(context).settings;

  void _update(MatchConfig Function(MatchConfig) change) {
    _settings.setMatch(change(_settings.match));
  }

  void _rules(DuelSettings Function(DuelSettings) change) {
    _update((m) => m.copyWith(rules: change(m.rules)));
  }

  void _start() {
    FocusScope.of(context).unfocus();
    final config = _settings.match.copyWith(p1Name: _p1.text.trim(), p2Name: _p2.text.trim());
    _settings.setMatch(config);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.duel),
        builder: (_) => DuelScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final match = services.settings.match;
    final rules = match.rules;
    final cb = rules.colorBlind;
    final (h1, h2) = match.resolvedHues;
    final seconds = NumberFormat('0.0', Localizations.localeOf(context).toString());
    String range(WaitPreset w) =>
        l10n.secondsRange(seconds.format(w.minMs / 1000), seconds.format(w.maxMs / 1000));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l10n.setupTitle),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.page,
                      0,
                      AppDimens.page,
                      AppDimens.gapXl,
                    ),
                    children: [
                      SectionLabel(l10n.setupMode),
                      SegmentedChoice<DuelMode>(
                        value: rules.mode,
                        onChanged: (v) => _rules((r) => r.copyWith(mode: v)),
                        options: [
                          SegmentOption(DuelMode.classic, l10n.modeClassic),
                          SegmentOption(DuelMode.targetColor, l10n.modeTarget),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimens.gapS, left: AppDimens.gapXs),
                        child: Text(
                          rules.mode == DuelMode.classic
                              ? l10n.modeClassicHint
                              : l10n.modeTargetHint,
                          style: theme.bodyMedium,
                        ),
                      ),
                      if (rules.mode == DuelMode.targetColor) ...[
                        SectionLabel(
                          l10n.setupTargetColor,
                          trailing: Text(
                            rules.effectiveTarget.label(l10n),
                            style: theme.bodySmall!.copyWith(color: AppColors.text),
                          ),
                        ),
                        _ColorChips(
                          palette: SignalPalette.forMode(colorBlind: cb),
                          selected: rules.effectiveTarget,
                          showShape: cb,
                          labelOf: (c) => c.label(l10n),
                          onSelected: (c) => _rules((r) => r.copyWith(target: c)),
                        ),
                        if (cb)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppDimens.gapS,
                              left: AppDimens.gapXs,
                            ),
                            child: Text(l10n.setupColorBlindNote, style: theme.bodySmall),
                          ),
                      ],
                      SectionLabel(l10n.setupWinScore),
                      SegmentedChoice<int>(
                        value: rules.winScore,
                        onChanged: (v) => _rules((r) => r.copyWith(winScore: v)),
                        options: [for (final s in GameRules.winScores) SegmentOption(s, '$s')],
                      ),
                      SectionLabel(l10n.setupWait),
                      SegmentedChoice<WaitPreset>(
                        value: rules.wait,
                        onChanged: (v) => _rules((r) => r.copyWith(wait: v)),
                        options: [
                          for (final w in WaitPreset.values)
                            SegmentOption(w, w.label(l10n), caption: range(w)),
                        ],
                      ),
                      SectionLabel(l10n.setupPenalty),
                      SegmentedChoice<FoulPenalty>(
                        value: rules.penalty,
                        onChanged: (v) => _rules((r) => r.copyWith(penalty: v)),
                        options: [
                          for (final p in FoulPenalty.values) SegmentOption(p, p.label(l10n)),
                        ],
                      ),
                      const SizedBox(height: AppDimens.gapL),
                      GroupCard(
                        children: [
                          ToggleRow(
                            title: l10n.setupGuessGuard,
                            subtitle: l10n.setupGuessGuardHint,
                            value: rules.guessGuard,
                            onChanged: (v) => _rules((r) => r.copyWith(guessGuard: v)),
                          ),
                        ],
                      ),
                      SectionLabel(l10n.setupPlayers),
                      GroupCard(
                        children: [
                          _PlayerRow(
                            controller: _p1,
                            hint: l10n.player1,
                            hue: h1,
                            onHue: (h) => _update((m) => m.copyWith(p1Hue: h)),
                            onName: (v) => _update((m) => m.copyWith(p1Name: v.trim())),
                          ),
                          _PlayerRow(
                            controller: _p2,
                            hint: l10n.player2,
                            hue: h2,
                            onHue: (h) => _update((m) => m.copyWith(p2Hue: h)),
                            onName: (v) => _update((m) => m.copyWith(p2Name: v.trim())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.page,
                AppDimens.gapS,
                AppDimens.page,
                AppDimens.gapL,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
                child: AppButton(
                  label: l10n.start,
                  icon: Icons.play_arrow_rounded,
                  onPressed: _start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChips extends StatelessWidget {
  const _ColorChips({
    required this.palette,
    required this.selected,
    required this.showShape,
    required this.labelOf,
    required this.onSelected,
  });

  final List<SignalColor> palette;
  final SignalColor selected;
  final bool showShape;
  final String Function(SignalColor) labelOf;
  final ValueChanged<SignalColor> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.gapM, horizontal: AppDimens.gapM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.hairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final c in palette)
            Semantics(
              button: true,
              selected: c == selected,
              label: labelOf(c),
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onSelected(c),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  width: AppDimens.colorChip,
                  height: AppDimens.colorChip,
                  padding: const EdgeInsets.all(AppDimens.colorChipRing + 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c == selected ? AppColors.text : AppColors.transparent,
                      width: AppDimens.colorChipRing,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.signal(c), shape: BoxShape.circle),
                    child: c == selected
                        ? Icon(
                            showShape ? Icons.circle : Icons.check_rounded,
                            size: showShape ? AppDimens.iconSmall - 4 : AppDimens.iconSmall,
                            color: AppColors.onSignal,
                          )
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.controller,
    required this.hint,
    required this.hue,
    required this.onHue,
    required this.onName,
  });

  final TextEditingController controller;
  final String hint;
  final PlayerHue hue;
  final ValueChanged<PlayerHue> onHue;
  final ValueChanged<String> onName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapL, vertical: AppDimens.gapS),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: GameRules.maxNameLength,
              onChanged: onName,
              textCapitalization: TextCapitalization.words,
              style: theme.titleMedium,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.titleMedium!.copyWith(color: AppColors.textMuted),
                counterText: '',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          for (final h in PlayerHue.values)
            Semantics(
              button: true,
              selected: h == hue,
              label: h.name,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onHue(h),
                child: Container(
                  width: AppDimens.iconButton - AppDimens.gapM,
                  height: AppDimens.iconButton,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    width: h == hue ? AppDimens.colorChip / 2 : AppDimens.dot + AppDimens.gapXs,
                    height: h == hue ? AppDimens.colorChip / 2 : AppDimens.dot + AppDimens.gapXs,
                    decoration: BoxDecoration(
                      color: h.ink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: h == hue ? AppColors.text : AppColors.transparent,
                        width: AppDimens.dotStroke,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
