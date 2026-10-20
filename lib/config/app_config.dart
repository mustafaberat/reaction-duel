/// Reaction Duel — game rules, timing and identity constants.
///
/// Pure Dart (no Flutter import) so the engine can read it. Visual tokens
/// live in `tokens.dart`; ad unit ids in `ad_config.dart`.
library;

abstract final class AppIdentity {
  static const String appName = 'Reaction Duel';
  static const String developer = 'ARU SOFT';
  static const String packageId = 'com.arusoft.reactionduel';
  static const String privacyUrl = 'https://arusoft.vercel.app/privacy';
}

abstract final class AppRoutes {
  static const String home = '/';
  static const String setup = '/setup';
  static const String duel = '/duel';
  static const String settings = '/settings';
  static const String howTo = '/how-to-play';
}

/// SharedPreferences keys (storage ids, not UI text).
abstract final class PrefsKeys {
  static const String language = 'language';
  static const String colorBlind = 'color_blind';
  static const String reduceMotion = 'reduce_motion';
  static const String onboardingDone = 'onboarding_done';
  static const String howToSeen = 'how_to_seen';

  static const String mode = 'match_mode';
  static const String target = 'match_target';
  static const String winScore = 'match_win_score';
  static const String wait = 'match_wait';
  static const String penalty = 'match_penalty';
  static const String guessGuard = 'match_guess_guard';
  static const String p1Name = 'match_p1_name';
  static const String p2Name = 'match_p2_name';
  static const String p1Color = 'match_p1_color';
  static const String p2Color = 'match_p2_color';

  static const String bestReactionMs = 'stats_best_ms';
  static const String totalMatches = 'stats_total_matches';
}

/// Round state machine timing (rfc §3). All values in milliseconds.
abstract final class GameTiming {
  /// Neutral lead-in at match start / after resume. Input locked.
  static const int cooldownMs = 1500;

  /// Round result stays on screen this long (input locked), then neutral.
  static const int resultHoldMs = 2200;
  static const int signalTimeoutMs = 3000;
  static const int guessThresholdMs = 80;

  /// Two valid taps closer than this are a tie (microseconds).
  static const int tieWindowUs = 1000;

  /// Two consecutive waiting delays must differ by at least this. Ranges
  /// under 2 s use the narrow gap: 0.6 s there leaves so few choices that
  /// the next delay becomes predictable (always near an edge).
  static const int minDelayGapMs = 600;
  static const int minDelayGapNarrowMs = 400;

  static const int waitShortMinMs = 1200;
  static const int waitShortMaxMs = 2500;
  static const int waitNormalMinMs = 2000;
  static const int waitNormalMaxMs = 3500;
  static const int waitLongMinMs = 3000;
  static const int waitLongMaxMs = 6000;

  static const int maxDecoys = 3;
  static const int decoyMinMs = 600;
  static const int decoyMaxMs = 1200;
  static const int decoyLeadMinMs = 700;
  static const int decoyLeadMaxMs = 1500;
  static const int postDecoyMinMs = 800;
  static const int postDecoyJitterMs = 900;
}

abstract final class GameRules {
  static const List<int> winScores = [1, 3, 5, 7, 10];
  static const int defaultWinScore = 3;
  static const int maxNameLength = 12;

  /// Decoys must be perceptually far from the target (OKLab ΔE).
  static const double decoyMinDistance = 0.15;
}

/// Signal palette as ARGB ints (rfc §4.2). Red is intentionally absent.
abstract final class PaletteArgb {
  static const int green = 0xFF2ECC71;
  static const int blue = 0xFF3B82F6;
  static const int yellow = 0xFFFACC15;
  static const int orange = 0xFFFB8C3C;
  static const int pink = 0xFFF472B6;
  static const int purple = 0xFF9F7AEA;

  // Color-blind safe set (deutan/protan), always paired with shapes.
  static const int cbBlue = 0xFF2F6BFF;
  static const int cbYellow = 0xFFFFD60A;
  static const int cbWhite = 0xFFF2F4F7;
  static const int cbOrange = 0xFFFF8A00;
  static const int cbSky = 0xFF5CC8FF;
}

/// Interstitial frequency (rfc §9).
abstract final class AdRules {
  static const int matchesBetweenInterstitials = 3;
  static const Duration minInterstitialGap = Duration(seconds: 90);
  static const Duration interstitialLoadWait = Duration(seconds: 1);
  static const Duration interstitialTimeout = Duration(seconds: 5);
}
