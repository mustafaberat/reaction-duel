/// Minimal segmented control with an optional second line per segment.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

class SegmentOption<T> {
  const SegmentOption(this.value, this.label, {this.caption});

  final T value;
  final String label;
  final String? caption;
}

class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasCaption = options.any((o) => o.caption != null);
    return Container(
      padding: const EdgeInsets.all(AppDimens.segmentInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.segmentRadius),
        border: Border.all(color: AppColors.stroke, width: AppDimens.hairline),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Semantics(
                selected: o.value == value,
                button: true,
                label: o.label,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(o.value),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    height: hasCaption
                        ? AppDimens.segmentHeight + AppDimens.gapL
                        : AppDimens.segmentHeight - AppDimens.segmentInset * 2,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.gapXs),
                    decoration: BoxDecoration(
                      color: o.value == value ? AppColors.surfaceHigh : AppColors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimens.segmentRadius - AppDimens.segmentInset,
                      ),
                      border: Border.all(
                        color: o.value == value ? AppColors.stroke : AppColors.transparent,
                        width: AppDimens.hairline,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          o.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleMedium!.copyWith(
                            fontSize: AppType.bodySmall,
                            color: o.value == value ? AppColors.text : AppColors.textMuted,
                          ),
                        ),
                        if (o.caption != null)
                          Text(
                            o.caption!,
                            maxLines: 1,
                            style: theme.bodySmall!.copyWith(
                              color: o.value == value ? AppColors.textMuted : AppColors.textFaint,
                              fontFeatures: AppFonts.tabular,
                            ),
                          ),
                      ],
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
