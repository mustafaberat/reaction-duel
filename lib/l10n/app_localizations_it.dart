// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Wait for the color. Tap first.';

  @override
  String homeRecord(int ms) {
    return 'Best $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Play';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to play';

  @override
  String get back => 'Back';

  @override
  String get setupTitle => 'Match setup';

  @override
  String get setupMode => 'Mode';

  @override
  String get modeClassic => 'Classic';

  @override
  String get modeTarget => 'Target Color';

  @override
  String get modeClassicHint =>
      'Tap the moment the center says GO! and turns green.';

  @override
  String get modeTargetHint =>
      'Tap only on your color, shown with the ● shape. Other colors and shapes are traps.';

  @override
  String get setupTargetColor => 'Target color';

  @override
  String get setupColorBlindNote => 'Color-blind palette · shapes on';

  @override
  String get setupWinScore => 'Points to win';

  @override
  String get setupWait => 'Wait time';

  @override
  String get waitShort => 'Short';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Long';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Early tap penalty';

  @override
  String get penaltyOpponent => 'Rival +1';

  @override
  String get penaltySelf => 'Self −1';

  @override
  String get penaltyRound => 'Round only';

  @override
  String get setupGuessGuard => 'Guess guard';

  @override
  String get setupGuessGuardHint => 'Taps under 80 ms count as a guess.';

  @override
  String get setupPlayers => 'Players';

  @override
  String get player1 => 'Player 1';

  @override
  String get player2 => 'Player 2';

  @override
  String get start => 'Start';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorWhite => 'White';

  @override
  String get colorSky => 'Sky';

  @override
  String get duelEarly => 'TOO EARLY!';

  @override
  String get duelGuess => 'GUESS!';

  @override
  String get duelDecoy => 'TRAP!';

  @override
  String get duelTie => 'Tie';

  @override
  String get duelTieSub => 'Replay the round';

  @override
  String get duelNoContest => 'No one tapped';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Round lost';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Target';

  @override
  String get duelCoach => 'Don\'t tap on WAIT · Tap on GO!';

  @override
  String get duelWait => 'WAIT';

  @override
  String get duelGo => 'GO!';

  @override
  String get duelWinner => 'WINNER';

  @override
  String get duelTooSlow => 'TOO SLOW';

  @override
  String get duelRivalFoul => 'Rival tapped early';

  @override
  String get duelGuessSub => 'Faster than 80 ms';

  @override
  String get duelPause => 'Pause';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get home => 'Home';

  @override
  String endWinner(String name) {
    return '$name wins';
  }

  @override
  String get endBest => 'Best';

  @override
  String get endAverage => 'Average';

  @override
  String get endFouls => 'Fouls';

  @override
  String get endSeries => 'Series';

  @override
  String get endNewRecord => 'New record';

  @override
  String get endRematch => 'Rematch';

  @override
  String get endChangeSettings => 'Change settings';

  @override
  String get settingsGame => 'Game';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsColorBlind => 'Color-blind mode';

  @override
  String get settingsColorBlindHint =>
      'Color-blind safe palette. Target Color always shows shapes.';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get motionSystem => 'System';

  @override
  String get motionOn => 'On';

  @override
  String get motionOff => 'Off';

  @override
  String get settingsShowTips => 'Show first-game tips again';

  @override
  String get settingsTipsReset => 'Tips will show in your next match.';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get howStep1Title => 'Sit face to face';

  @override
  String get howStep1Body =>
      'Put the phone between you. Each player taps their own half.';

  @override
  String get howStep2Title => 'Wait';

  @override
  String get howStep2Body => 'Don\'t touch while the center says WAIT.';

  @override
  String get howStep3Title => 'GO! means tap';

  @override
  String get howStep3Body => 'When GO! appears, the first tap wins the point.';

  @override
  String get howStep4Title => 'Don\'t tap early';

  @override
  String get howStep4Body => 'Tap too early and the point goes to your rival.';

  @override
  String get howStep5Title => 'Trap colors';

  @override
  String get howStep5Body =>
      'Only tap on your color — the ● shape. Other shapes are traps.';

  @override
  String get howNext => 'Next';

  @override
  String get howSkip => 'Skip';

  @override
  String get howPlayNow => 'Play now';

  @override
  String get howClose => 'Close';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
