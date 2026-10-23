// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => '色を待って、先にタップ。';

  @override
  String homeRecord(int ms) {
    return 'ベスト $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 試合',
    );
    return '$_temp0';
  }

  @override
  String get play => 'プレイ';

  @override
  String get settings => '設定';

  @override
  String get howToPlay => '遊び方';

  @override
  String get back => '戻る';

  @override
  String get setupTitle => '試合設定';

  @override
  String get setupMode => 'モード';

  @override
  String get modeClassic => 'クラシック';

  @override
  String get modeTarget => 'ターゲット色';

  @override
  String get modeClassicHint => '中央がタップ！と出て緑になった瞬間にタップ。';

  @override
  String get modeTargetHint => '自分の色、●の形のときだけタップ。他の色と形はトラップ。';

  @override
  String get setupTargetColor => 'ターゲット色';

  @override
  String get setupColorBlindNote => '色覚サポート · 形オン';

  @override
  String get setupWinScore => '勝利点数';

  @override
  String get setupWait => '待ち時間';

  @override
  String get waitShort => '短い';

  @override
  String get waitNormal => 'ふつう';

  @override
  String get waitLong => '長い';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max 秒';
  }

  @override
  String get setupPenalty => '早押しの罰';

  @override
  String get penaltyOpponent => '相手 +1';

  @override
  String get penaltySelf => '自分 −1';

  @override
  String get penaltyRound => 'ラウンドのみ';

  @override
  String get setupGuessGuard => '予想ガード';

  @override
  String get setupGuessGuardHint => '80 ms未満のタップは予想とみなす。';

  @override
  String get setupPlayers => 'プレイヤー';

  @override
  String get player1 => 'プレイヤー 1';

  @override
  String get player2 => 'プレイヤー 2';

  @override
  String get start => 'スタート';

  @override
  String get colorGreen => '緑';

  @override
  String get colorBlue => '青';

  @override
  String get colorYellow => '黄';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorPurple => '紫';

  @override
  String get colorWhite => '白';

  @override
  String get colorSky => '空';

  @override
  String get duelEarly => '早すぎ！';

  @override
  String get duelGuess => '予想！';

  @override
  String get duelDecoy => 'トラップ！';

  @override
  String get duelTie => '引き分け';

  @override
  String get duelTieSub => 'ラウンド再試合';

  @override
  String get duelNoContest => 'だれもタップしなかった';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'ラウンド負け';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'ターゲット';

  @override
  String get duelCoach => '待て中はタップしない · タップ！でタップ';

  @override
  String get duelWait => '待て';

  @override
  String get duelGo => 'タップ！';

  @override
  String get duelWinner => '勝ち';

  @override
  String get duelTooSlow => '遅い';

  @override
  String get duelRivalFoul => '相手が早押し';

  @override
  String get duelGuessSub => '80 msより速い';

  @override
  String get duelPause => '一時停止';

  @override
  String get pauseTitle => '一時停止';

  @override
  String get pauseResume => '再開';

  @override
  String get pauseRestart => 'やり直す';

  @override
  String get home => 'ホーム';

  @override
  String endWinner(String name) {
    return '$nameの勝ち';
  }

  @override
  String get endBest => 'ベスト';

  @override
  String get endAverage => '平均';

  @override
  String get endFouls => 'ファウル';

  @override
  String get endSeries => '通算';

  @override
  String get endNewRecord => '新記録';

  @override
  String get endRematch => '再戦';

  @override
  String get endChangeSettings => '設定';

  @override
  String get settingsGame => 'ゲーム';

  @override
  String get settingsGeneral => '一般';

  @override
  String get settingsAbout => '情報';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => '端末の言語';

  @override
  String get settingsColorBlind => '色覚サポート';

  @override
  String get settingsColorBlindHint => '色だけに頼らない。ターゲット色はいつも形を出す。';

  @override
  String get settingsReduceMotion => '動きを減らす';

  @override
  String get settingsAccessibility => 'アクセシビリティ';

  @override
  String get motionSystem => 'システム';

  @override
  String get motionOn => 'オン';

  @override
  String get motionOff => 'オフ';

  @override
  String get settingsShowTips => '最初のヒントを再表示';

  @override
  String get settingsTipsReset => 'ヒントは次の試合で出ます。';

  @override
  String get settingsPrivacy => 'プライバシー';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get howStep1Title => '向かい合って座る';

  @override
  String get howStep1Body => 'スマホを間に置く。各自が自分の半分をタップ。';

  @override
  String get howStep2Title => '待つ';

  @override
  String get howStep2Body => '中央が待てと出ている間は触らない。';

  @override
  String get howStep3Title => 'タップ！でタップ';

  @override
  String get howStep3Body => 'タップ！が出たら、先にタップした方が得点。';

  @override
  String get howStep4Title => '早押ししない';

  @override
  String get howStep4Body => '早すぎると点数は相手へ。';

  @override
  String get howStep5Title => 'トラップ色';

  @override
  String get howStep5Body => '自分の色、●の形のときだけタップ。他の形はトラップ。';

  @override
  String get howNext => '次へ';

  @override
  String get howSkip => 'スキップ';

  @override
  String get howPlayNow => '今すぐ遊ぶ';

  @override
  String get howClose => '閉じる';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
