// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Attends la couleur. Tape en premier.';

  @override
  String homeRecord(int ms) {
    return 'Meilleur $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matchs',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Jouer';

  @override
  String get settings => 'Réglages';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get back => 'Retour';

  @override
  String get setupTitle => 'Préparer le match';

  @override
  String get setupMode => 'Mode';

  @override
  String get modeClassic => 'Classique';

  @override
  String get modeTarget => 'Couleur cible';

  @override
  String get modeClassicHint =>
      'Tape dès que le centre dit GO ! et devient vert.';

  @override
  String get modeTargetHint =>
      'Tape seulement ta couleur, la forme ●. Les autres couleurs et formes sont des pièges.';

  @override
  String get setupTargetColor => 'Couleur cible';

  @override
  String get setupColorBlindNote => 'Palette daltonien · formes on';

  @override
  String get setupWinScore => 'Points pour gagner';

  @override
  String get setupWait => 'Temps d\'attente';

  @override
  String get waitShort => 'Court';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Long';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Pénalité trop tôt';

  @override
  String get penaltyOpponent => 'Rival +1';

  @override
  String get penaltySelf => 'Toi −1';

  @override
  String get penaltyRound => 'Manche seule';

  @override
  String get setupGuessGuard => 'Anti-devinette';

  @override
  String get setupGuessGuardHint =>
      'Un tap sous 80 ms compte comme une devinette.';

  @override
  String get setupPlayers => 'Joueurs';

  @override
  String get player1 => 'Joueur 1';

  @override
  String get player2 => 'Joueur 2';

  @override
  String get start => 'Commencer';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorSky => 'Ciel';

  @override
  String get duelEarly => 'TROP TÔT !';

  @override
  String get duelGuess => 'DEVINETTE !';

  @override
  String get duelDecoy => 'PIÈGE !';

  @override
  String get duelTie => 'Égalité';

  @override
  String get duelTieSub => 'Rejouer la manche';

  @override
  String get duelNoContest => 'Personne n\'a tapé';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Manche perdue';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Cible';

  @override
  String get duelCoach => 'Ne tape pas sur ATTENDS · Tape sur GO !';

  @override
  String get duelWait => 'ATTENDS';

  @override
  String get duelGo => 'GO !';

  @override
  String get duelWinner => 'GAGNÉ';

  @override
  String get duelTooSlow => 'TROP LENT';

  @override
  String get duelRivalFoul => 'Le rival a tapé trop tôt';

  @override
  String get duelGuessSub => 'Plus vite que 80 ms';

  @override
  String get duelPause => 'Pause';

  @override
  String get pauseTitle => 'En pause';

  @override
  String get pauseResume => 'Reprendre';

  @override
  String get pauseRestart => 'Recommencer';

  @override
  String get home => 'Accueil';

  @override
  String endWinner(String name) {
    return '$name gagne';
  }

  @override
  String get endBest => 'Meilleur';

  @override
  String get endAverage => 'Moyenne';

  @override
  String get endFouls => 'Fautes';

  @override
  String get endSeries => 'Série';

  @override
  String get endNewRecord => 'Nouveau record';

  @override
  String get endRematch => 'Revanche';

  @override
  String get endChangeSettings => 'Réglages';

  @override
  String get settingsGame => 'Jeu';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

  @override
  String get settingsColorBlind => 'Mode daltonien';

  @override
  String get settingsColorBlindHint =>
      'Palette sûre. La couleur cible montre toujours des formes.';

  @override
  String get settingsReduceMotion => 'Moins de mouvement';

  @override
  String get settingsAccessibility => 'Accessibilité';

  @override
  String get motionSystem => 'Système';

  @override
  String get motionOn => 'Oui';

  @override
  String get motionOff => 'Non';

  @override
  String get settingsShowTips => 'Revoir les conseils du premier match';

  @override
  String get settingsTipsReset =>
      'Les conseils s\'affichent au prochain match.';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsVersion => 'Version';

  @override
  String get howStep1Title => 'Face à face';

  @override
  String get howStep1Body =>
      'Mets le téléphone au milieu. Chacun tape sa moitié.';

  @override
  String get howStep2Title => 'Attends';

  @override
  String get howStep2Body => 'Ne touche pas tant que le centre dit ATTENDS.';

  @override
  String get howStep3Title => 'GO ! = taper';

  @override
  String get howStep3Body =>
      'Quand GO ! apparaît, le premier tap gagne le point.';

  @override
  String get howStep4Title => 'Pas trop tôt';

  @override
  String get howStep4Body => 'Taper trop tôt donne le point au rival.';

  @override
  String get howStep5Title => 'Couleurs piège';

  @override
  String get howStep5Body =>
      'Tape seulement ta couleur — la forme ●. Les autres formes sont des pièges.';

  @override
  String get howNext => 'Suivant';

  @override
  String get howSkip => 'Passer';

  @override
  String get howPlayNow => 'Jouer';

  @override
  String get howClose => 'Fermer';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
