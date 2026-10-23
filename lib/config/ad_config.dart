/// AdMob ids (rfc §9). Debug/profile → Google test ids; release → real ids.
///
/// Phase 1 ships with TEST ids in both modes until the AdMob app is created
/// under publisher pub-1508520223269936 (add it to `lib/admob/account.json`).
library;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdConfig {
  // Google sample ids — https://developers.google.com/admob/android/test-ads
  static const String testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  // TODO(phase2): real ids, e.g. 'ca-app-pub-1508520223269936/<TBD>'.
  // Until then release also uses the test ids.
  static const String releaseAppId = testAppIdAndroid; // ca-app-pub-1508520223269936~<TBD>
  static const String releaseHomeBanner = testBanner; // home_banner → <TBD>
  static const String releaseMatchEndInterstitial =
      testInterstitial; // match_end_interstitial → <TBD>

  static String get homeBanner => kReleaseMode ? releaseHomeBanner : testBanner;

  static String get matchEndInterstitial =>
      kReleaseMode ? releaseMatchEndInterstitial : testInterstitial;

  /// Play Families (all ages, including under 5). Apply before and after
  /// [MobileAds.initialize]. TFCD / TFUA stay set: `google_mobile_ads` 9.x
  /// also wants [AgeRestrictedTreatment.child].
  static RequestConfiguration get familiesRequestConfiguration {
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      // ignore: deprecated_member_use
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      // ignore: deprecated_member_use
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      ageRestrictedTreatment: AgeRestrictedTreatment.child,
    );
  }

  static const AdRequest request = AdRequest(nonPersonalizedAds: true);
}
