/// AdMob wrapper (Click Battle pattern). Banner on Home only; interstitial
/// after match end → Home / Change settings, gated by [InterstitialPolicy].
///
/// Skipped on web and under `FLUTTER_TEST` (no platform channel).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../config/app_config.dart';
import '../engine/clock.dart';
import 'interstitial_policy.dart';
import 'platform_env.dart';

class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final Clock _clock = MonotonicClock();
  InterstitialPolicy _policy = InterstitialPolicy(firstSession: true);
  final ValueNotifier<BannerAd?> banner = ValueNotifier(null);
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  bool _initialized = false;

  bool get enabled => !kIsWeb && !isFlutterTest;

  void initialize({required bool firstSession}) {
    if (_initialized) return;
    _initialized = true;
    _policy = InterstitialPolicy(firstSession: firstSession);
    if (!enabled) return;
    try {
      MobileAds.instance.initialize();
      _loadBanner();
    } catch (_) {}
  }

  void _loadBanner() {
    banner.value?.dispose();
    banner.value = null;
    BannerAd(
      adUnitId: AdConfig.homeBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => banner.value = ad as BannerAd,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    ).load();
  }

  void onMatchFinished() {
    _policy.onMatchFinished();
    if (enabled && _policy.shouldShow(_clock.now())) _loadInterstitial();
  }

  void _loadInterstitial() {
    if (_loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.matchEndInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (_) => _loadingInterstitial = false,
      ),
    );
  }

  /// Shows an interstitial if the policy allows; never blocks longer than
  /// load wait + timeout. Rematch must not call this.
  Future<void> maybeShowMatchEndInterstitial() async {
    if (!enabled || !_policy.shouldShow(_clock.now())) return;
    if (_interstitial == null) {
      _loadInterstitial();
      await Future<void>.delayed(AdRules.interstitialLoadWait);
      if (_interstitial == null) return;
    }
    final ad = _interstitial!;
    _interstitial = null;
    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!done.isCompleted) done.complete();
      },
    );
    _policy.onShown(_clock.now());
    await ad.show();
    return done.future.timeout(AdRules.interstitialTimeout, onTimeout: () {});
  }
}
