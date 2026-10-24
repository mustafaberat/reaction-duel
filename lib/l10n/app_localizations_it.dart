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
  String get homeTagline => 'Aspetta il colore. Tocca per primo.';

  @override
  String homeRecord(int ms) {
    return 'Migliore $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '1 partita',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Gioca';

  @override
  String get settings => 'Impostazioni';

  @override
  String get howToPlay => 'Come si gioca';

  @override
  String get back => 'Indietro';

  @override
  String get setupTitle => 'Prepara la partita';

  @override
  String get setupMode => 'Modalità';

  @override
  String get modeClassic => 'Classica';

  @override
  String get modeTarget => 'Colore obiettivo';

  @override
  String get modeClassicHint =>
      'Tocca quando il centro dice VIA! e diventa verde.';

  @override
  String get modeTargetHint =>
      'Tocca solo il tuo colore, la forma ●. Altri colori e forme sono trappole.';

  @override
  String get setupTargetColor => 'Colore obiettivo';

  @override
  String get setupColorBlindNote => 'Tavolozza daltonici · forme on';

  @override
  String get setupWinScore => 'Punti per vincere';

  @override
  String get setupWait => 'Tempo di attesa';

  @override
  String get waitShort => 'Breve';

  @override
  String get waitNormal => 'Normale';

  @override
  String get waitLong => 'Lungo';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Penalità per tocco presto';

  @override
  String get penaltyOpponent => 'Rivale +1';

  @override
  String get penaltySelf => 'Tu −1';

  @override
  String get penaltyRound => 'Solo round';

  @override
  String get setupGuessGuard => 'Anti-indovinare';

  @override
  String get setupGuessGuardHint =>
      'Tocchi sotto 80 ms contano come indovinare.';

  @override
  String get setupPlayers => 'Giocatori';

  @override
  String get player1 => 'Giocatore 1';

  @override
  String get player2 => 'Giocatore 2';

  @override
  String get start => 'Inizia';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Blu';

  @override
  String get colorYellow => 'Giallo';

  @override
  String get colorOrange => 'Arancio';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Viola';

  @override
  String get colorWhite => 'Bianco';

  @override
  String get colorSky => 'Cielo';

  @override
  String get duelEarly => 'TROPPO PRESTO!';

  @override
  String get duelGuess => 'INDOVINATO!';

  @override
  String get duelDecoy => 'TRAPPOLA!';

  @override
  String get duelTie => 'Pareggio';

  @override
  String get duelTieSub => 'Rigioca il round';

  @override
  String get duelNoContest => 'Nessuno ha toccato';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Round perso';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Obiettivo';

  @override
  String get duelCoach => 'Non toccare su ASPETTA · Tocca su VIA!';

  @override
  String get duelWait => 'ASPETTA';

  @override
  String get duelGo => 'VIA!';

  @override
  String get duelWinner => 'VINTO';

  @override
  String get duelTooSlow => 'TROPPO LENTO';

  @override
  String get duelRivalFoul => 'Il rivale ha toccato presto';

  @override
  String get duelGuessSub => 'Più veloce di 80 ms';

  @override
  String get duelPause => 'Pausa';

  @override
  String get pauseTitle => 'In pausa';

  @override
  String get pauseResume => 'Riprendi';

  @override
  String get pauseRestart => 'Ricomincia';

  @override
  String get home => 'Home';

  @override
  String endWinner(String name) {
    return '$name vince';
  }

  @override
  String get endBest => 'Migliore';

  @override
  String get endAverage => 'Media';

  @override
  String get endFouls => 'Falli';

  @override
  String get endSeries => 'Serie';

  @override
  String get endNewRecord => 'Nuovo record';

  @override
  String get endRematch => 'Rivincita';

  @override
  String get endChangeSettings => 'Impostazioni';

  @override
  String get settingsGame => 'Gioco';

  @override
  String get settingsGeneral => 'Generale';

  @override
  String get settingsAbout => 'Info';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Lingua di sistema';

  @override
  String get settingsColorBlind => 'Modalità daltonici';

  @override
  String get settingsColorBlindHint =>
      'Tavolozza sicura. Il colore obiettivo mostra sempre le forme.';

  @override
  String get settingsReduceMotion => 'Meno movimento';

  @override
  String get settingsAccessibility => 'Accessibilità';

  @override
  String get motionSystem => 'Sistema';

  @override
  String get motionOn => 'Sì';

  @override
  String get motionOff => 'No';

  @override
  String get settingsShowTips => 'Mostra di nuovo i consigli';

  @override
  String get settingsTipsReset =>
      'I consigli appariranno nella prossima partita.';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get howStep1Title => 'Uno di fronte all\'altro';

  @override
  String get howStep1Body =>
      'Metti il telefono in mezzo. Ognuno tocca la sua metà.';

  @override
  String get howStep2Title => 'Aspetta';

  @override
  String get howStep2Body => 'Non toccare mentre il centro dice ASPETTA.';

  @override
  String get howStep3Title => 'VIA! = tocca';

  @override
  String get howStep3Body =>
      'Quando compare VIA!, il primo tap vince il punto.';

  @override
  String get howStep4Title => 'Non troppo presto';

  @override
  String get howStep4Body => 'Toccare troppo presto dà il punto al rivale.';

  @override
  String get howStep5Title => 'Colori trappola';

  @override
  String get howStep5Body =>
      'Tocca solo il tuo colore — la forma ●. Le altre forme sono trappole.';

  @override
  String get howNext => 'Avanti';

  @override
  String get howSkip => 'Salta';

  @override
  String get howPlayNow => 'Gioca ora';

  @override
  String get howClose => 'Chiudi';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
