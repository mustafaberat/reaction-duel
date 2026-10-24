import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/config/app_theme.dart';
import 'package:reaction_duel/config/tokens.dart';

void main() {
  test('Dino Pals is the only theme', () {
    expect(AppIdentity.themeName, 'Dino Pals');
    expect(AppFonts.display, 'Baloo2');
    expect(AppFonts.body, 'Nunito');
    expect(AppFonts.ja, 'ZenMaruGothic');
    expect(AppFonts.ko, 'Jua');
    expect(AppFonts.zh, 'ZCOOLKuaiLe');
    expect(AppColors.background, const Color(0xFFFFF4C0));
    expect(AppColors.backgroundTop, const Color(0xFF87D6F0));
    expect(AppDimens.buttonDepth, 6);
  });

  test('display type is dark-brown on light, yellow on sky', () {
    expect(AppTheme.current.textTheme.displayMedium!.color, AppColors.text);
    expect(
      AppTheme.current.textTheme.displayLarge!.shadows,
      AppType.displayHalo,
    );
    expect(AppColors.displaySkyFill, const Color(0xFFFFE566));
    expect(AppType.displaySkyHalo, isNotEmpty);
    expect(AppColors.text, isNot(AppColors.displaySkyFill));
  });

  test('dino inks are readable on cream and match each dino', () {
    expect(AppColors.trexInk, isNot(AppColors.triInk));
    expect(AppColors.dinoInkOf(0), AppColors.trexInk);
    expect(AppColors.dinoInkOf(1), AppColors.triInk);
    expect(_contrast(AppColors.trexInk, AppColors.surface), greaterThan(4.5));
    expect(_contrast(AppColors.triInk, AppColors.surface), greaterThan(4.5));
    expect(_contrast(AppColors.trexInk, AppColors.highlight), greaterThan(4.5));
    expect(_contrast(AppColors.triInk, AppColors.highlight), greaterThan(4.5));
  });

  test('player hues stay distinct and resolve a clash', () {
    expect(PlayerHue.blue.ink, isNot(PlayerHue.yellow.ink));
    expect(PlayerHue.green.tint, isNot(PlayerHue.cream.tint));
    final clash = PlayerHue.resolve(PlayerHue.blue, PlayerHue.blue);
    expect(clash.$1, PlayerHue.blue);
    expect(clash.$2, isNot(PlayerHue.blue));
  });

  test('match-end loser mood is encouraging, not sad', () {
    expect(CharacterMood.values, contains(CharacterMood.nextTime));
    expect(CharacterMood.values, contains(CharacterMood.oops));
    expect(CharacterMood.values.map((m) => m.name), isNot(contains('sad')));
  });

  test('old blob CharacterView is gone', () {
    const banned = [
      'CharacterView',
      'CharacterPainter',
      '_TrexPainter',
      '_TriceratopsPainter',
    ];
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      for (final token in banned) {
        if (text.contains(token)) hits.add('${file.path}: $token');
      }
    }
    expect(hits, isEmpty);
  });

  test('match-end dinos shrink on short halves', () {
    expect(AppLayout.endWinSize(280), 80);
    expect(AppLayout.endLoseSize(80), lessThan(80));
    expect(AppLayout.endWinSize(333), 80);
    expect(AppLayout.endWinSize(420), 120);
    expect(AppDimens.endCardMaxWidth, 480);
  });
}

double _contrast(Color a, Color b) {
  double lin(double s) =>
      s <= 0.04045 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  double lum(Color c) =>
      0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  final l1 = lum(a);
  final l2 = lum(b);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}
