/// Chunky stone button frame: body plus a drop-shadow depth strip.
///
/// Chrome (depth) is extra decoration around a full-height body.
/// The label body always gets [height] (typically 56dp); the shadow sits
/// below and must not shrink or clip the label.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

class ThemedButtonFrame extends StatelessWidget {
  const ThemedButtonFrame({
    required this.height,
    required this.expand,
    required this.child,
    super.key,
  });

  final double height;
  final bool expand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget body = child;
    if (AppShadows.button.isNotEmpty) {
      body = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          boxShadow: AppShadows.button,
        ),
        child: child,
      );
    }

    return SizedBox(
      height: height + AppDimens.buttonDepth,
      width: expand ? double.infinity : null,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: height,
          width: expand ? double.infinity : null,
          child: body,
        ),
      ),
    );
  }
}
