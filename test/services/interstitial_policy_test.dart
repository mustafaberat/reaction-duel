import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/services/interstitial_policy.dart';

void main() {
  const gap = Duration(seconds: 90);

  test('never after the first match of the first session', () {
    final p = InterstitialPolicy(firstSession: true, matchesBetween: 1);
    p.onMatchFinished();
    expect(p.shouldShow(const Duration(minutes: 10)), isFalse);
    p.onMatchFinished();
    expect(p.shouldShow(const Duration(minutes: 10)), isTrue);
  });

  test('at most one per 3 matches and at least 90 s apart', () {
    final p = InterstitialPolicy(firstSession: false);
    p.onMatchFinished();
    p.onMatchFinished();
    expect(p.shouldShow(const Duration(minutes: 5)), isFalse);
    p.onMatchFinished();
    expect(p.shouldShow(const Duration(minutes: 5)), isTrue);
    p.onShown(const Duration(minutes: 5));

    for (var i = 0; i < 3; i++) {
      p.onMatchFinished();
    }
    expect(p.shouldShow(const Duration(minutes: 5) + gap - const Duration(seconds: 1)), isFalse);
    expect(p.shouldShow(const Duration(minutes: 5) + gap), isTrue);
  });
}
