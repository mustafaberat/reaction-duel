/// Pause sheet readable from both sides (top copy rotated 180°).
library;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import '../theme/decor.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onHome,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return ColoredBox(
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
                  child: _panel(context, padding.top),
                ),
              ),
              Divider(height: AppDimens.hairline, color: AppColors.hairline),
              Expanded(child: _panel(context, padding.bottom)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context, double edgeInset) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = AppLayout.stackActions(constraints.maxWidth - AppDimens.page * 2);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.page,
            AppDimens.gapM,
            AppDimens.page,
            AppDimens.gapM + edgeInset,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.endPanelMaxWidth,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause_circle_outline_rounded,
                            size: AppDimens.iconButton,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: AppDimens.gapM),
                          Text(
                            l10n.pauseTitle,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppButton(
                    label: l10n.pauseResume,
                    icon: Icons.play_arrow_rounded,
                    onPressed: onResume,
                  ),
                  const SizedBox(height: AppDimens.gapS),
                  if (stacked)
                    Column(
                      children: [
                        AppButton.secondary(
                          label: l10n.pauseRestart,
                          icon: Icons.replay_rounded,
                          height: AppDimens.buttonHeightSmall,
                          onPressed: onRestart,
                        ),
                        const SizedBox(height: AppDimens.gapS),
                        AppButton.secondary(
                          label: l10n.home,
                          icon: Icons.home_outlined,
                          height: AppDimens.buttonHeightSmall,
                          onPressed: onHome,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: l10n.pauseRestart,
                            icon: Icons.replay_rounded,
                            height: AppDimens.buttonHeightSmall,
                            onPressed: onRestart,
                          ),
                        ),
                        const SizedBox(width: AppDimens.gapS),
                        Expanded(
                          child: AppButton.secondary(
                            label: l10n.home,
                            icon: Icons.home_outlined,
                            height: AppDimens.buttonHeightSmall,
                            onPressed: onHome,
                          ),
                        ),
                      ],
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
