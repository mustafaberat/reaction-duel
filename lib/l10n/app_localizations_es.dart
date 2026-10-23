// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Espera el color. Toca primero.';

  @override
  String homeRecord(int ms) {
    return 'Mejor $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Jugar';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get back => 'Atrás';

  @override
  String get setupTitle => 'Preparar partida';

  @override
  String get setupMode => 'Modo';

  @override
  String get modeClassic => 'Clásico';

  @override
  String get modeTarget => 'Color objetivo';

  @override
  String get modeClassicHint =>
      'Toca cuando el centro diga ¡YA! y se ponga verde.';

  @override
  String get modeTargetHint =>
      'Toca solo tu color, el de forma ●. Otros colores y formas son trampas.';

  @override
  String get setupTargetColor => 'Color objetivo';

  @override
  String get setupColorBlindNote => 'Paleta daltónica · formas on';

  @override
  String get setupWinScore => 'Puntos para ganar';

  @override
  String get setupWait => 'Tiempo de espera';

  @override
  String get waitShort => 'Corto';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Largo';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Penalización por tocar pronto';

  @override
  String get penaltyOpponent => 'Rival +1';

  @override
  String get penaltySelf => 'Tú −1';

  @override
  String get penaltyRound => 'Solo ronda';

  @override
  String get setupGuessGuard => 'Anti-adivinanza';

  @override
  String get setupGuessGuardHint =>
      'Toques bajo 80 ms cuentan como adivinanza.';

  @override
  String get setupPlayers => 'Jugadores';

  @override
  String get player1 => 'Jugador 1';

  @override
  String get player2 => 'Jugador 2';

  @override
  String get start => 'Empezar';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorWhite => 'Blanco';

  @override
  String get colorSky => 'Cielo';

  @override
  String get duelEarly => '¡MUY PRONTO!';

  @override
  String get duelGuess => '¡ADIVINÓ!';

  @override
  String get duelDecoy => '¡TRAMPA!';

  @override
  String get duelTie => 'Empate';

  @override
  String get duelTieSub => 'Repetir la ronda';

  @override
  String get duelNoContest => 'Nadie tocó';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Ronda perdida';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Objetivo';

  @override
  String get duelCoach => 'No toques en ESPERA · Toca en ¡YA!';

  @override
  String get duelWait => 'ESPERA';

  @override
  String get duelGo => '¡YA!';

  @override
  String get duelWinner => 'GANÓ';

  @override
  String get duelTooSlow => 'MUY LENTO';

  @override
  String get duelRivalFoul => 'El rival tocó pronto';

  @override
  String get duelGuessSub => 'Más rápido que 80 ms';

  @override
  String get duelPause => 'Pausa';

  @override
  String get pauseTitle => 'En pausa';

  @override
  String get pauseResume => 'Seguir';

  @override
  String get pauseRestart => 'Reiniciar';

  @override
  String get home => 'Inicio';

  @override
  String endWinner(String name) {
    return '$name gana';
  }

  @override
  String get endBest => 'Mejor';

  @override
  String get endAverage => 'Media';

  @override
  String get endFouls => 'Faltas';

  @override
  String get endSeries => 'Serie';

  @override
  String get endNewRecord => 'Nuevo récord';

  @override
  String get endRematch => 'Revancha';

  @override
  String get endChangeSettings => 'Ajustes';

  @override
  String get settingsGame => 'Juego';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del sistema';

  @override
  String get settingsColorBlind => 'Modo daltónico';

  @override
  String get settingsColorBlindHint =>
      'Paleta segura. El color objetivo siempre muestra formas.';

  @override
  String get settingsReduceMotion => 'Menos movimiento';

  @override
  String get settingsAccessibility => 'Accesibilidad';

  @override
  String get motionSystem => 'Sistema';

  @override
  String get motionOn => 'Sí';

  @override
  String get motionOff => 'No';

  @override
  String get settingsShowTips => 'Mostrar otra vez los consejos';

  @override
  String get settingsTipsReset => 'Los consejos saldrán en la próxima partida.';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get howStep1Title => 'Frente a frente';

  @override
  String get howStep1Body =>
      'Pon el teléfono en medio. Cada uno toca su mitad.';

  @override
  String get howStep2Title => 'Espera';

  @override
  String get howStep2Body => 'No toques mientras el centro dice ESPERA.';

  @override
  String get howStep3Title => '¡YA! es tocar';

  @override
  String get howStep3Body =>
      'Cuando salga ¡YA!, el primer toque gana el punto.';

  @override
  String get howStep4Title => 'No toques pronto';

  @override
  String get howStep4Body =>
      'Si tocas demasiado pronto, el punto es del rival.';

  @override
  String get howStep5Title => 'Colores trampa';

  @override
  String get howStep5Body =>
      'Toca solo tu color — la forma ●. Las otras formas son trampas.';

  @override
  String get howNext => 'Siguiente';

  @override
  String get howSkip => 'Saltar';

  @override
  String get howPlayNow => 'Jugar ya';

  @override
  String get howClose => 'Cerrar';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
