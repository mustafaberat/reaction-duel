// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => '색을 기다리세요. 먼저 탭하세요.';

  @override
  String homeRecord(int ms) {
    return '최고 $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count경기',
    );
    return '$_temp0';
  }

  @override
  String get play => '플레이';

  @override
  String get settings => '설정';

  @override
  String get howToPlay => '플레이 방법';

  @override
  String get back => '뒤로';

  @override
  String get setupTitle => '경기 설정';

  @override
  String get setupMode => '모드';

  @override
  String get modeClassic => '클래식';

  @override
  String get modeTarget => '목표 색';

  @override
  String get modeClassicHint => '중앙에 탭!이 나오고 초록이 되면 탭하세요.';

  @override
  String get modeTargetHint => '자기 색, ● 모양일 때만 탭. 다른 색과 모양은 함정.';

  @override
  String get setupTargetColor => '목표 색';

  @override
  String get setupColorBlindNote => '색각 팔레트 · 모양 켜짐';

  @override
  String get setupWinScore => '승리 점수';

  @override
  String get setupWait => '대기 시간';

  @override
  String get waitShort => '짧게';

  @override
  String get waitNormal => '보통';

  @override
  String get waitLong => '길게';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max초';
  }

  @override
  String get setupPenalty => '빨리 누른 벌';

  @override
  String get penaltyOpponent => '상대 +1';

  @override
  String get penaltySelf => '나 −1';

  @override
  String get penaltyRound => '라운드만';

  @override
  String get setupGuessGuard => '찍기 방지';

  @override
  String get setupGuessGuardHint => '80 ms 미만 탭은 찍기로 봅니다.';

  @override
  String get setupPlayers => '플레이어';

  @override
  String get player1 => '플레이어 1';

  @override
  String get player2 => '플레이어 2';

  @override
  String get start => '시작';

  @override
  String get colorGreen => '초록';

  @override
  String get colorBlue => '파랑';

  @override
  String get colorYellow => '노랑';

  @override
  String get colorOrange => '주황';

  @override
  String get colorPink => '분홍';

  @override
  String get colorPurple => '보라';

  @override
  String get colorWhite => '흰색';

  @override
  String get colorSky => '하늘';

  @override
  String get duelEarly => '너무 빨라!';

  @override
  String get duelGuess => '찍기!';

  @override
  String get duelDecoy => '함정!';

  @override
  String get duelTie => '무승부';

  @override
  String get duelTieSub => '라운드 다시';

  @override
  String get duelNoContest => '아무도 안 눌렀어요';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => '라운드 패';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => '목표';

  @override
  String get duelCoach => '대기 중엔 누르지 마세요 · 탭!에서 탭';

  @override
  String get duelWait => '대기';

  @override
  String get duelGo => '탭!';

  @override
  String get duelWinner => '승리';

  @override
  String get duelTooSlow => '너무 느림';

  @override
  String get duelRivalFoul => '상대가 빨리 누름';

  @override
  String get duelGuessSub => '80 ms보다 빠름';

  @override
  String get duelPause => '일시정지';

  @override
  String get pauseTitle => '일시정지';

  @override
  String get pauseResume => '계속';

  @override
  String get pauseRestart => '다시 시작';

  @override
  String get home => '홈';

  @override
  String endWinner(String name) {
    return '$name 승';
  }

  @override
  String get endBest => '최고';

  @override
  String get endAverage => '평균';

  @override
  String get endFouls => '파울';

  @override
  String get endSeries => '통산';

  @override
  String get endNewRecord => '신기록';

  @override
  String get endRematch => '재대결';

  @override
  String get endChangeSettings => '설정';

  @override
  String get settingsGame => '게임';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSystem => '기기 언어';

  @override
  String get settingsColorBlind => '색각 모드';

  @override
  String get settingsColorBlindHint => '안전한 팔레트. 목표 색은 항상 모양을 보여 줍니다.';

  @override
  String get settingsReduceMotion => '움직임 줄이기';

  @override
  String get settingsAccessibility => '접근성';

  @override
  String get motionSystem => '시스템';

  @override
  String get motionOn => '켜짐';

  @override
  String get motionOff => '꺼짐';

  @override
  String get settingsShowTips => '첫 게임 팁 다시 보기';

  @override
  String get settingsTipsReset => '팁은 다음 경기에 나옵니다.';

  @override
  String get settingsPrivacy => '개인정보';

  @override
  String get settingsVersion => '버전';

  @override
  String get howStep1Title => '마주 앉기';

  @override
  String get howStep1Body => '폰을 가운데 두세요. 각자 자기 쪽을 탭합니다.';

  @override
  String get howStep2Title => '기다리기';

  @override
  String get howStep2Body => '중앙에 대기가 보일 때는 누르지 마세요.';

  @override
  String get howStep3Title => '탭!이면 탭';

  @override
  String get howStep3Body => '탭!이 나오면 먼저 탭한 쪽이 득점합니다.';

  @override
  String get howStep4Title => '너무 일찍 누르지 않기';

  @override
  String get howStep4Body => '너무 일찍 누르면 점수는 상대에게 갑니다.';

  @override
  String get howStep5Title => '함정 색';

  @override
  String get howStep5Body => '자기 색, ● 모양일 때만 탭. 다른 모양은 함정.';

  @override
  String get howNext => '다음';

  @override
  String get howSkip => '건너뛰기';

  @override
  String get howPlayNow => '지금 플레이';

  @override
  String get howClose => '닫기';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
