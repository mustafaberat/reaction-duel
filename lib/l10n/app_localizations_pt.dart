// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Espere a cor. Toque primeiro.';

  @override
  String homeRecord(int ms) {
    return 'Melhor $ms ms';
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
  String get play => 'Jogar';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get back => 'Voltar';

  @override
  String get setupTitle => 'Preparar partida';

  @override
  String get setupMode => 'Modo';

  @override
  String get modeClassic => 'Clássico';

  @override
  String get modeTarget => 'Cor alvo';

  @override
  String get modeClassicHint =>
      'Toque quando o centro disser JÁ! e ficar verde.';

  @override
  String get modeTargetHint =>
      'Toque só na sua cor, a forma ●. Outras cores e formas são armadilhas.';

  @override
  String get setupTargetColor => 'Cor alvo';

  @override
  String get setupColorBlindNote => 'Paleta daltônica · formas on';

  @override
  String get setupWinScore => 'Pontos para vencer';

  @override
  String get setupWait => 'Tempo de espera';

  @override
  String get waitShort => 'Curto';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Longo';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max s';
  }

  @override
  String get setupPenalty => 'Pena por toque cedo';

  @override
  String get penaltyOpponent => 'Rival +1';

  @override
  String get penaltySelf => 'Você −1';

  @override
  String get penaltyRound => 'Só a rodada';

  @override
  String get setupGuessGuard => 'Anti-chute';

  @override
  String get setupGuessGuardHint => 'Toques abaixo de 80 ms contam como chute.';

  @override
  String get setupPlayers => 'Jogadores';

  @override
  String get player1 => 'Jogador 1';

  @override
  String get player2 => 'Jogador 2';

  @override
  String get start => 'Começar';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorWhite => 'Branco';

  @override
  String get colorSky => 'Céu';

  @override
  String get duelEarly => 'CEDO DEMAIS!';

  @override
  String get duelGuess => 'CHUTE!';

  @override
  String get duelDecoy => 'ARMADILHA!';

  @override
  String get duelTie => 'Empate';

  @override
  String get duelTieSub => 'Repetir a rodada';

  @override
  String get duelNoContest => 'Ninguém tocou';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Rodada perdida';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Alvo';

  @override
  String get duelCoach => 'Não toque em ESPERE · Toque em JÁ!';

  @override
  String get duelWait => 'ESPERE';

  @override
  String get duelGo => 'JÁ!';

  @override
  String get duelWinner => 'VENCEU';

  @override
  String get duelTooSlow => 'DEVAGAR';

  @override
  String get duelRivalFoul => 'O rival tocou cedo';

  @override
  String get duelGuessSub => 'Mais rápido que 80 ms';

  @override
  String get duelPause => 'Pausa';

  @override
  String get pauseTitle => 'Pausado';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Recomeçar';

  @override
  String get home => 'Início';

  @override
  String endWinner(String name) {
    return '$name vence';
  }

  @override
  String get endBest => 'Melhor';

  @override
  String get endAverage => 'Média';

  @override
  String get endFouls => 'Faltas';

  @override
  String get endSeries => 'Série';

  @override
  String get endNewRecord => 'Novo recorde';

  @override
  String get endRematch => 'Revanche';

  @override
  String get endChangeSettings => 'Ajustes';

  @override
  String get settingsGame => 'Jogo';

  @override
  String get settingsGeneral => 'Geral';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma do sistema';

  @override
  String get settingsColorBlind => 'Modo daltônico';

  @override
  String get settingsColorBlindHint =>
      'Paleta segura. A cor alvo sempre mostra formas.';

  @override
  String get settingsReduceMotion => 'Menos movimento';

  @override
  String get settingsAccessibility => 'Acessibilidade';

  @override
  String get motionSystem => 'Sistema';

  @override
  String get motionOn => 'Sim';

  @override
  String get motionOff => 'Não';

  @override
  String get settingsShowTips => 'Mostrar de novo as dicas';

  @override
  String get settingsTipsReset => 'As dicas aparecem na próxima partida.';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get howStep1Title => 'Frente a frente';

  @override
  String get howStep1Body =>
      'Coloque o celular no meio. Cada um toca o próprio lado.';

  @override
  String get howStep2Title => 'Espere';

  @override
  String get howStep2Body => 'Não toque enquanto o centro diz ESPERE.';

  @override
  String get howStep3Title => 'JÁ! é tocar';

  @override
  String get howStep3Body => 'Quando sair JÁ!, o primeiro toque ganha o ponto.';

  @override
  String get howStep4Title => 'Não toque cedo';

  @override
  String get howStep4Body => 'Tocar cedo demais entrega o ponto ao rival.';

  @override
  String get howStep5Title => 'Cores armadilha';

  @override
  String get howStep5Body =>
      'Toque só na sua cor — a forma ●. As outras formas são armadilhas.';

  @override
  String get howNext => 'Próximo';

  @override
  String get howSkip => 'Pular';

  @override
  String get howPlayNow => 'Jogar agora';

  @override
  String get howClose => 'Fechar';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
