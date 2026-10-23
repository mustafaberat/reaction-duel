/// Themed score row: filled = points, hollow = remaining to win.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../theme/score_marks.dart';

class ScoreDots extends StatelessWidget {
  const ScoreDots({
    required this.score,
    required this.total,
    required this.color,
    required this.emptyColor,
    super.key,
  });

  final int score;
  final int total;
  final Color color;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$score / $total',
      excludeSemantics: true,
      child: Wrap(
        spacing: AppDimens.dotGap,
        runSpacing: AppDimens.dotGap,
        children: [
          for (var i = 0; i < total; i++)
            ScoreMark(filled: i < score, color: color, emptyColor: emptyColor),
        ],
      ),
    );
  }
}
