import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reaction_duel/config/ad_config.dart';

void main() {
  test('Families request tags child-directed G-rated non-personalized ads', () {
    final config = AdConfig.familiesRequestConfiguration;
    expect(config.maxAdContentRating, MaxAdContentRating.g);
    // ignore: deprecated_member_use
    expect(config.tagForChildDirectedTreatment, TagForChildDirectedTreatment.yes);
    // ignore: deprecated_member_use
    expect(config.tagForUnderAgeOfConsent, TagForUnderAgeOfConsent.yes);
    expect(config.ageRestrictedTreatment, AgeRestrictedTreatment.child);
    expect(AdConfig.request.nonPersonalizedAds, isTrue);
  });
}
