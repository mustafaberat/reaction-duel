/// Pill buttons: primary (accent), secondary (surface), ghost (text only).
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

enum AppButtonKind { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.expand = true,
    this.height = AppDimens.buttonHeight,
    super.key,
  });

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.height = AppDimens.buttonHeight,
    super.key,
  }) : kind = AppButtonKind.secondary;

  const AppButton.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.height = AppDimens.buttonHeightSmall,
    super.key,
  }) : kind = AppButtonKind.ghost;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      AppButtonKind.primary => (AppColors.accent, AppColors.onAccent, AppColors.transparent),
      AppButtonKind.secondary => (AppColors.surfaceHigh, AppColors.text, AppColors.stroke),
      AppButtonKind.ghost => (AppColors.transparent, AppColors.textMuted, AppColors.transparent),
    };
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(
      color: fg,
      fontWeight: kind == AppButtonKind.primary ? FontWeight.w700 : FontWeight.w600,
      letterSpacing: AppType.buttonTracking,
    );

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppDimens.icon, color: fg),
          const SizedBox(width: AppDimens.gapS),
        ],
        Flexible(
          child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: expand ? double.infinity : null,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            side: BorderSide(color: border, width: AppDimens.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kind == AppButtonKind.ghost ? AppDimens.gapS : AppDimens.gapXl,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = AppDimens.iconButton,
    this.filled = true,
    this.color = AppColors.text,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: size,
          child: Material(
            color: filled ? AppColors.surfaceHigh : AppColors.transparent,
            shape: CircleBorder(
              side: BorderSide(
                color: filled ? AppColors.stroke : AppColors.transparent,
                width: AppDimens.hairline,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Icon(icon, size: size * 0.48, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
