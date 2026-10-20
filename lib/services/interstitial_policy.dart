/// Pure interstitial frequency rule (rfc §9), testable without ads.
///
/// At most one interstitial per [matchesBetween] finished matches, at least
/// [minGap] apart, and never after the very first match of the first session.
library;

import '../config/app_config.dart';

class InterstitialPolicy {
  InterstitialPolicy({
    required this.firstSession,
    this.matchesBetween = AdRules.matchesBetweenInterstitials,
    this.minGap = AdRules.minInterstitialGap,
  });

  final bool firstSession;
  final int matchesBetween;
  final Duration minGap;

  int _sessionMatches = 0;
  int _matchesSinceAd = 0;
  Duration? _lastShownAt;

  void onMatchFinished() {
    _sessionMatches++;
    _matchesSinceAd++;
  }

  bool shouldShow(Duration now) {
    if (firstSession && _sessionMatches <= 1) return false;
    if (_matchesSinceAd < matchesBetween) return false;
    final last = _lastShownAt;
    if (last != null && now - last < minGap) return false;
    return true;
  }

  void onShown(Duration now) {
    _lastShownAt = now;
    _matchesSinceAd = 0;
  }
}
