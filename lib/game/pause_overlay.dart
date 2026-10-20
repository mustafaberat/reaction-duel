/// Pause sheet readable from both sides (top copy rotated 180°).
library;

import 'package:flutter/material.dart';

import '../components/app_button.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';

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
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(child: RotatedBox(quarterTurns: 2, child: _panel(context, padding.top))),
          const Divider(height: AppDimens.hairline, color: AppColors.hairline),
          Expanded(child: _panel(context, padding.bottom)),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context, double edgeInset) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.page,
        AppDimens.gapXl,
        AppDimens.page,
        AppDimens.gapXl + edgeInset,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.endPanelMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_outline_rounded,
                size: AppDimens.iconButton,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppDimens.gapM),
              Text(l10n.pauseTitle, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppDimens.gapXl),
              AppButton(
                label: l10n.pauseResume,
                icon: Icons.play_arrow_rounded,
                onPressed: onResume,
              ),
              const SizedBox(height: AppDimens.gapM),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.pauseRestart,
                      height: AppDimens.buttonHeightSmall + AppDimens.gapXs,
                      onPressed: onRestart,
                    ),
                  ),
                  const SizedBox(width: AppDimens.gapM),
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.home,
                      height: AppDimens.buttonHeightSmall + AppDimens.gapXs,
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
  }
}
