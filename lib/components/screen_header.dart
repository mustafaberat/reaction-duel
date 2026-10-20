/// Back button + title row used by setup, settings and how-to screens.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import 'app_button.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.title,
    this.onBack,
    this.trailing,
    this.closeIcon = false,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool closeIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pageTight,
        AppDimens.gapS,
        AppDimens.pageTight,
        AppDimens.gapS,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
            tooltip: closeIcon ? l10n.howClose : l10n.back,
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: AppDimens.gapM),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
