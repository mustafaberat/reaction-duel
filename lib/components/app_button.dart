/// Pill buttons: primary (accent), secondary (surface), ghost (text only).
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../theme/button_chrome.dart';

enum AppButtonKind { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.expand = true,
    this.height = AppDimens.buttonHeight,
    this.maxLines = 1,
    this.compact = false,
    super.key,
  });

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.height = AppDimens.buttonHeight,
    this.maxLines = 1,
    this.compact = false,
    super.key,
  }) : kind = AppButtonKind.secondary;

  const AppButton.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.height = AppDimens.buttonHeightSmall,
    this.maxLines = 1,
    this.compact = false,
    super.key,
  }) : kind = AppButtonKind.ghost;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;
  final double height;
  final int maxLines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final outline = kind == AppButtonKind.ghost
        ? AppColors.transparent
        : (kind == AppButtonKind.primary
              ? AppColors.onAccent.withValues(alpha: 0.2)
              : AppColors.outline);
    final (bg, fg, border) = switch (kind) {
      AppButtonKind.primary => (AppColors.accent, AppColors.onAccent, outline),
      AppButtonKind.secondary => (AppColors.surface, AppColors.text, outline),
      AppButtonKind.ghost => (
        AppColors.transparent,
        AppColors.textMuted,
        AppColors.transparent,
      ),
    };
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(
      color: fg,
      fontSize: compact ? AppType.caption : AppType.button,
      height: compact ? 1.15 : null,
      fontWeight: kind == AppButtonKind.primary
          ? FontWeight.w700
          : FontWeight.w600,
      letterSpacing: AppType.buttonTracking,
    );
    final lines = compact ? 2 : maxLines;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: compact ? AppDimens.iconSmall : AppDimens.icon,
            color: fg,
          ),
          SizedBox(width: compact ? AppDimens.gapXs : AppDimens.gapS),
        ],
        Flexible(
          child: compact
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: style,
                    maxLines: lines,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                )
              : Text(
                  label,
                  style: style,
                  maxLines: lines,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );

    final radius = BorderRadius.circular(AppDimens.buttonRadius);
    final button = Material(
      color: bg,
      elevation: 0,
      shadowColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: border,
          width: kind == AppButtonKind.ghost ? 0 : AppDimens.buttonOutline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kind == AppButtonKind.ghost
                  ? AppDimens.gapS
                  : compact
                  ? AppDimens.gapM
                  : AppDimens.gapXl,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );

    final framed = kind == AppButtonKind.ghost
        ? SizedBox(
            height: height,
            width: expand ? double.infinity : null,
            child: button,
          )
        : ThemedButtonFrame(height: height, expand: expand, child: button);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: framed,
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
    this.color,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.text;
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
              child: Icon(icon, size: size * 0.48, color: ink),
            ),
          ),
        ),
      ),
    );
  }
}
