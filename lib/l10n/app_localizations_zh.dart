// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => '等颜色变了再点。';

  @override
  String homeRecord(int ms) {
    return '最佳 $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 场',
    );
    return '$_temp0';
  }

  @override
  String get play => '开始';

  @override
  String get settings => '设置';

  @override
  String get howToPlay => '玩法';

  @override
  String get back => '返回';

  @override
  String get setupTitle => '对局设置';

  @override
  String get setupMode => '模式';

  @override
  String get modeClassic => '经典';

  @override
  String get modeTarget => '目标颜色';

  @override
  String get modeClassicHint => '中间出现点！并变绿时再点。';

  @override
  String get modeTargetHint => '只在自己的颜色、● 形状时点。其他颜色和形状是陷阱。';

  @override
  String get setupTargetColor => '目标颜色';

  @override
  String get setupColorBlindNote => '色盲配色 · 形状开';

  @override
  String get setupWinScore => '获胜分数';

  @override
  String get setupWait => '等待时间';

  @override
  String get waitShort => '短';

  @override
  String get waitNormal => '普通';

  @override
  String get waitLong => '长';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max 秒';
  }

  @override
  String get setupPenalty => '抢点惩罚';

  @override
  String get penaltyOpponent => '对手 +1';

  @override
  String get penaltySelf => '自己 −1';

  @override
  String get penaltyRound => '仅本轮';

  @override
  String get setupGuessGuard => '防猜';

  @override
  String get setupGuessGuardHint => '快于 80 ms 的点击算猜测。';

  @override
  String get setupPlayers => '玩家';

  @override
  String get player1 => '玩家 1';

  @override
  String get player2 => '玩家 2';

  @override
  String get start => '开始';

  @override
  String get colorGreen => '绿';

  @override
  String get colorBlue => '蓝';

  @override
  String get colorYellow => '黄';

  @override
  String get colorOrange => '橙';

  @override
  String get colorPink => '粉';

  @override
  String get colorPurple => '紫';

  @override
  String get colorWhite => '白';

  @override
  String get colorSky => '天蓝';

  @override
  String get duelEarly => '太早！';

  @override
  String get duelGuess => '猜的！';

  @override
  String get duelDecoy => '陷阱！';

  @override
  String get duelTie => '平局';

  @override
  String get duelTieSub => '重赛本轮';

  @override
  String get duelNoContest => '没人点';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => '本轮输了';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => '目标';

  @override
  String get duelCoach => '显示等时不要点 · 点！时再点';

  @override
  String get duelWait => '等';

  @override
  String get duelGo => '点！';

  @override
  String get duelWinner => '胜';

  @override
  String get duelTooSlow => '太慢';

  @override
  String get duelRivalFoul => '对手点太早';

  @override
  String get duelGuessSub => '快于 80 ms';

  @override
  String get duelPause => '暂停';

  @override
  String get pauseTitle => '已暂停';

  @override
  String get pauseResume => '继续';

  @override
  String get pauseRestart => '重开';

  @override
  String get home => '首页';

  @override
  String endWinner(String name) {
    return '$name 赢了';
  }

  @override
  String get endBest => '最佳';

  @override
  String get endAverage => '平均';

  @override
  String get endFouls => '犯规';

  @override
  String get endSeries => '累计';

  @override
  String get endNewRecord => '新纪录';

  @override
  String get endRematch => '再来一局';

  @override
  String get endChangeSettings => '设置';

  @override
  String get settingsGame => '游戏';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsColorBlind => '色盲模式';

  @override
  String get settingsColorBlindHint => '安全配色。目标颜色总会显示形状。';

  @override
  String get settingsReduceMotion => '减少动效';

  @override
  String get settingsAccessibility => '无障碍';

  @override
  String get motionSystem => '系统';

  @override
  String get motionOn => '开';

  @override
  String get motionOff => '关';

  @override
  String get settingsShowTips => '再次显示首次提示';

  @override
  String get settingsTipsReset => '提示会在下一场出现。';

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get settingsVersion => '版本';

  @override
  String get howStep1Title => '面对面坐下';

  @override
  String get howStep1Body => '把手机放中间。每人点自己的半边。';

  @override
  String get howStep2Title => '等待';

  @override
  String get howStep2Body => '中间显示等的时候不要点。';

  @override
  String get howStep3Title => '点！再点';

  @override
  String get howStep3Body => '出现点！时，先点的人得分。';

  @override
  String get howStep4Title => '不要抢点';

  @override
  String get howStep4Body => '点太早，分数给对手。';

  @override
  String get howStep5Title => '陷阱颜色';

  @override
  String get howStep5Body => '只在自己的颜色、● 形状时点。其他形状是陷阱。';

  @override
  String get howNext => '下一步';

  @override
  String get howSkip => '跳过';

  @override
  String get howPlayNow => '开始玩';

  @override
  String get howClose => '关闭';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
