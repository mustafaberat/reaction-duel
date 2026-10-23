// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Warte auf die Farbe. Tippe zuerst.';

  @override
  String homeRecord(int ms) {
    return 'Beste $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spiele',
      one: '1 Spiel',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Spielen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get howToPlay => 'So spielt man';

  @override
  String get back => 'Zurück';

  @override
  String get setupTitle => 'Spielstart';

  @override
  String get setupMode => 'Modus';

  @override
  String get modeClassic => 'Klassisch';

  @override
  String get modeTarget => 'Zielfarbe';

  @override
  String get modeClassicHint =>
      'Tippe, sobald die Mitte LOS! sagt und grün wird.';

  @override
  String get modeTargetHint =>
      'Tippe nur bei deiner Farbe, dem ●. Andere Farben und Formen sind Fallen.';

  @override
  String get setupTargetColor => 'Zielfarbe';

  @override
  String get setupColorBlindNote => 'Farbenblind-Palette · Formen an';

  @override
  String get setupWinScore => 'Punkte zum Sieg';

  @override
  String get setupWait => 'Wartezeit';

  @override
  String get waitShort => 'Kurz';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Lang';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Strafe bei Frühstart';

  @override
  String get penaltyOpponent => 'Rivale +1';

  @override
  String get penaltySelf => 'Selbst −1';

  @override
  String get penaltyRound => 'Nur Runde';

  @override
  String get setupGuessGuard => 'Rateschutz';

  @override
  String get setupGuessGuardHint => 'Tipps unter 80 ms gelten als Rateversuch.';

  @override
  String get setupPlayers => 'Spieler';

  @override
  String get player1 => 'Spieler 1';

  @override
  String get player2 => 'Spieler 2';

  @override
  String get start => 'Start';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorYellow => 'Gelb';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorWhite => 'Weiß';

  @override
  String get colorSky => 'Himmel';

  @override
  String get duelEarly => 'ZU FRÜH!';

  @override
  String get duelGuess => 'GERATEN!';

  @override
  String get duelDecoy => 'FALLE!';

  @override
  String get duelTie => 'Unentschieden';

  @override
  String get duelTieSub => 'Runde nochmal';

  @override
  String get duelNoContest => 'Niemand hat getippt';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Runde verloren';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Ziel';

  @override
  String get duelCoach => 'Bei WARTE nicht tippen · Bei LOS! tippen';

  @override
  String get duelWait => 'WARTE';

  @override
  String get duelGo => 'LOS!';

  @override
  String get duelWinner => 'SIEG';

  @override
  String get duelTooSlow => 'ZU LANGSAM';

  @override
  String get duelRivalFoul => 'Rivale zu früh';

  @override
  String get duelGuessSub => 'Schneller als 80 ms';

  @override
  String get duelPause => 'Pause';

  @override
  String get pauseTitle => 'Pause';

  @override
  String get pauseResume => 'Weiter';

  @override
  String get pauseRestart => 'Neu starten';

  @override
  String get home => 'Start';

  @override
  String endWinner(String name) {
    return '$name gewinnt';
  }

  @override
  String get endBest => 'Beste';

  @override
  String get endAverage => 'Schnitt';

  @override
  String get endFouls => 'Fehler';

  @override
  String get endSeries => 'Serie';

  @override
  String get endNewRecord => 'Neuer Rekord';

  @override
  String get endRematch => 'Revanche';

  @override
  String get endChangeSettings => 'Einstellungen';

  @override
  String get settingsGame => 'Spiel';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsAbout => 'Info';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemsprache';

  @override
  String get settingsColorBlind => 'Farbenblind-Modus';

  @override
  String get settingsColorBlindHint =>
      'Sichere Palette. Zielfarbe zeigt immer Formen.';

  @override
  String get settingsReduceMotion => 'Weniger Bewegung';

  @override
  String get settingsAccessibility => 'Barrierefreiheit';

  @override
  String get motionSystem => 'System';

  @override
  String get motionOn => 'An';

  @override
  String get motionOff => 'Aus';

  @override
  String get settingsShowTips => 'Erste-Spiel-Tipps wieder zeigen';

  @override
  String get settingsTipsReset => 'Tipps erscheinen im nächsten Spiel.';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsVersion => 'Version';

  @override
  String get howStep1Title => 'Gegenüber setzen';

  @override
  String get howStep1Body => 'Handy in die Mitte. Jeder tippt seine Hälfte.';

  @override
  String get howStep2Title => 'Warten';

  @override
  String get howStep2Body => 'Nicht tippen, solange die Mitte WARTE zeigt.';

  @override
  String get howStep3Title => 'LOS! heißt tippen';

  @override
  String get howStep3Body => 'Bei LOS! gewinnt der erste Tipp den Punkt.';

  @override
  String get howStep4Title => 'Nicht zu früh';

  @override
  String get howStep4Body => 'Zu früh tippen gibt den Punkt dem Rivalen.';

  @override
  String get howStep5Title => 'Fallenfarben';

  @override
  String get howStep5Body =>
      'Nur bei deiner Farbe tippen — dem ●. Andere Formen sind Fallen.';

  @override
  String get howNext => 'Weiter';

  @override
  String get howSkip => 'Überspringen';

  @override
  String get howPlayNow => 'Jetzt spielen';

  @override
  String get howClose => 'Schließen';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
