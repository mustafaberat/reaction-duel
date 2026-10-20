/// Click sound + haptics on points and fouls. Sound never on the signal
/// (rfc §8); the optional signal buzz is an accessibility aid (rfc §8.1).
library;

import 'package:flutter/services.dart';

import '../config/tokens.dart';
import 'settings_service.dart';

class FeedbackService {
  FeedbackService(this._settings);

  final SettingsService _settings;

  void point() {
    if (_settings.sound) SystemSound.play(SystemSoundType.click);
    if (_settings.haptics) HapticFeedback.lightImpact();
  }

  /// Heavy double buzz.
  Future<void> foul() async {
    if (_settings.sound) SystemSound.play(SystemSoundType.click);
    if (!_settings.haptics) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(AppMotion.hapticGap);
    await HapticFeedback.heavyImpact();
  }

  /// Independent of [SettingsService.haptics]: it carries game information.
  void signal() {
    if (_settings.signalVibration) HapticFeedback.heavyImpact();
  }
}
