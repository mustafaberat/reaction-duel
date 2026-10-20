/// Persisted app preferences and last match setup (SharedPreferences).
library;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/duel_settings.dart';
import '../engine/signal_palette.dart';

enum ReduceMotionPref { system, on, off }

/// Setup screen values: engine rules + player names / hues.
class MatchConfig {
  const MatchConfig({
    this.rules = const DuelSettings(),
    this.p1Name = '',
    this.p2Name = '',
    this.p1Hue = PlayerHue.defaultP1,
    this.p2Hue = PlayerHue.defaultP2,
  });

  final DuelSettings rules;

  /// Empty = localized default ("Player 1").
  final String p1Name;
  final String p2Name;
  final PlayerHue p1Hue;
  final PlayerHue p2Hue;

  /// Hues after auto-switching away from the target color.
  (PlayerHue, PlayerHue) get resolvedHues => PlayerHue.resolve(p1Hue, p2Hue, rules.effectiveTarget);

  MatchConfig copyWith({
    DuelSettings? rules,
    String? p1Name,
    String? p2Name,
    PlayerHue? p1Hue,
    PlayerHue? p2Hue,
  }) {
    return MatchConfig(
      rules: rules ?? this.rules,
      p1Name: p1Name ?? this.p1Name,
      p2Name: p2Name ?? this.p2Name,
      p1Hue: p1Hue ?? this.p1Hue,
      p2Hue: p2Hue ?? this.p2Hue,
    );
  }
}

class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs) {
    _load();
  }

  static Future<SettingsService> create() async =>
      SettingsService(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static const List<String> supportedLanguages = [
    'en', 'es', 'pt', 'zh', 'ja', 'de', 'fr', 'ko', 'it', 'tr', //
  ];

  /// Native names, shown untranslated in the language picker.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '简体中文',
    'ja': '日本語',
    'de': 'Deutsch',
    'fr': 'Français',
    'ko': '한국어',
    'it': 'Italiano',
    'tr': 'Türkçe',
  };

  String? _language;
  bool _sound = true;
  bool _haptics = true;
  bool _colorBlind = false;
  bool _signalVibration = false;
  ReduceMotionPref _reduceMotion = ReduceMotionPref.system;
  bool _onboardingDone = false;
  bool _howToSeen = false;
  MatchConfig _match = const MatchConfig();

  /// Null = follow the device language.
  String? get language => _language;
  Locale? get locale => _language == null ? null : Locale(_language!);
  bool get sound => _sound;
  bool get haptics => _haptics;
  bool get colorBlind => _colorBlind;

  /// Accessibility aid: buzz on the real signal (rfc §8.1). Default off.
  bool get signalVibration => _signalVibration;
  ReduceMotionPref get reduceMotion => _reduceMotion;
  bool get onboardingDone => _onboardingDone;
  bool get howToSeen => _howToSeen;

  /// Match setup with the global color-blind flag applied.
  MatchConfig get match => _match.copyWith(rules: _match.rules.copyWith(colorBlind: _colorBlind));

  bool reduceMotionFor(BuildContext context) => switch (_reduceMotion) {
    ReduceMotionPref.on => true,
    ReduceMotionPref.off => false,
    ReduceMotionPref.system => MediaQuery.maybeDisableAnimationsOf(context) ?? false,
  };

  void _load() {
    final lang = _prefs.getString(PrefsKeys.language);
    _language = supportedLanguages.contains(lang) ? lang : null;
    _sound = _prefs.getBool(PrefsKeys.sound) ?? true;
    _haptics = _prefs.getBool(PrefsKeys.haptics) ?? true;
    _colorBlind = _prefs.getBool(PrefsKeys.colorBlind) ?? false;
    _signalVibration = _prefs.getBool(PrefsKeys.signalVibration) ?? false;
    _reduceMotion =
        _byName(ReduceMotionPref.values, _prefs.getString(PrefsKeys.reduceMotion)) ??
        ReduceMotionPref.system;
    _onboardingDone = _prefs.getBool(PrefsKeys.onboardingDone) ?? false;
    _howToSeen = _prefs.getBool(PrefsKeys.howToSeen) ?? false;

    final winScore = _prefs.getInt(PrefsKeys.winScore);
    _match = MatchConfig(
      rules: DuelSettings(
        mode: _byName(DuelMode.values, _prefs.getString(PrefsKeys.mode)) ?? DuelMode.classic,
        target:
            _byName(SignalColor.values, _prefs.getString(PrefsKeys.target)) ?? SignalColor.green,
        winScore: GameRules.winScores.contains(winScore) ? winScore! : GameRules.defaultWinScore,
        wait: _byName(WaitPreset.values, _prefs.getString(PrefsKeys.wait)) ?? WaitPreset.normal,
        penalty:
            _byName(FoulPenalty.values, _prefs.getString(PrefsKeys.penalty)) ??
            FoulPenalty.opponentPlusOne,
        guessGuard: _prefs.getBool(PrefsKeys.guessGuard) ?? true,
      ),
      p1Name: _prefs.getString(PrefsKeys.p1Name) ?? '',
      p2Name: _prefs.getString(PrefsKeys.p2Name) ?? '',
      p1Hue: _byName(PlayerHue.values, _prefs.getString(PrefsKeys.p1Color)) ?? PlayerHue.defaultP1,
      p2Hue: _byName(PlayerHue.values, _prefs.getString(PrefsKeys.p2Color)) ?? PlayerHue.defaultP2,
    );
  }

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  Future<void> setLanguage(String? code) async {
    _language = code;
    notifyListeners();
    if (code == null) {
      await _prefs.remove(PrefsKeys.language);
    } else {
      await _prefs.setString(PrefsKeys.language, code);
    }
  }

  Future<void> setSound(bool value) async {
    _sound = value;
    notifyListeners();
    await _prefs.setBool(PrefsKeys.sound, value);
  }

  Future<void> setHaptics(bool value) async {
    _haptics = value;
    notifyListeners();
    await _prefs.setBool(PrefsKeys.haptics, value);
  }

  Future<void> setColorBlind(bool value) async {
    _colorBlind = value;
    notifyListeners();
    await _prefs.setBool(PrefsKeys.colorBlind, value);
  }

  Future<void> setSignalVibration(bool value) async {
    _signalVibration = value;
    notifyListeners();
    await _prefs.setBool(PrefsKeys.signalVibration, value);
  }

  Future<void> setReduceMotion(ReduceMotionPref value) async {
    _reduceMotion = value;
    notifyListeners();
    await _prefs.setString(PrefsKeys.reduceMotion, value.name);
  }

  Future<void> setOnboardingDone(bool value) async {
    if (_onboardingDone == value) return;
    _onboardingDone = value;
    notifyListeners();
    await _prefs.setBool(PrefsKeys.onboardingDone, value);
  }

  Future<void> setHowToSeen() async {
    if (_howToSeen) return;
    _howToSeen = true;
    await _prefs.setBool(PrefsKeys.howToSeen, true);
  }

  Future<void> setMatch(MatchConfig config) async {
    _match = config;
    notifyListeners();
    final r = config.rules;
    await Future.wait([
      _prefs.setString(PrefsKeys.mode, r.mode.name),
      _prefs.setString(PrefsKeys.target, r.target.name),
      _prefs.setInt(PrefsKeys.winScore, r.winScore),
      _prefs.setString(PrefsKeys.wait, r.wait.name),
      _prefs.setString(PrefsKeys.penalty, r.penalty.name),
      _prefs.setBool(PrefsKeys.guessGuard, r.guessGuard),
      _prefs.setString(PrefsKeys.p1Name, config.p1Name),
      _prefs.setString(PrefsKeys.p2Name, config.p2Name),
      _prefs.setString(PrefsKeys.p1Color, config.p1Hue.name),
      _prefs.setString(PrefsKeys.p2Color, config.p2Hue.name),
    ]);
  }

  SharedPreferences get prefs => _prefs;
}
