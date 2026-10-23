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

  test('match-end dinos shrink on short halves', () {
    expect(AppLayout.endWinSize(280), 80);
    expect(AppLayout.endLoseSize(80), lessThan(80));
    expect(AppLayout.endWinSize(333), 80);
    expect(AppLayout.endWinSize(420), 120);
  });
}
