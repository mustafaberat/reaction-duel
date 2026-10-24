/// Section label, grouped card, toggle row and navigation row.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../theme/decor.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.gapXs,
        top: AppDimens.gapXl,
        bottom: AppDimens.gapS,
      ),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall)),
          ?trailing,
        ],
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(
          Divider(
            height: AppDimens.hairline,
            thickness: AppDimens.hairline,
            color: AppColors.hairline,
            indent: AppDimens.gapL,
          ),
        );
      }
      items.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.cardOutline),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: ThemeCardChrome(child: Column(mainAxisSize: MainAxisSize.min, children: items)),
    );
  }
}

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: _RowShell(
          icon: icon,
          title: title,
          subtitle: subtitle,
          trailing: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}

class NavRow extends StatelessWidget {
  const NavRow({
    required this.title,
    required this.onTap,
    this.value,
    this.icon,
    this.trailingIcon = Icons.chevron_right_rounded,
    super.key,
  });

  final String title;
  final String? value;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: _RowShell(
        icon: icon,
        title: title,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(value!, style: theme.bodyMedium!.copyWith(fontFeatures: AppFonts.tabular)),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppDimens.gapXs),
              Icon(trailingIcon, size: AppDimens.icon, color: AppColors.textFaint),
            ],
          ],
        ),
      ),
    );
  }
}

class _RowShell extends StatelessWidget {
  const _RowShell({required this.title, required this.trailing, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimens.tileMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapL, vertical: AppDimens.gapS),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimens.icon, color: AppColors.textMuted),
              const SizedBox(width: AppDimens.gapM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: theme.titleMedium),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimens.gapXs / 2),
                      child: Text(subtitle!, style: theme.bodySmall),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.gapM),
            trailing,
          ],
        ),
      ),
    );
  }
}
