/// Seedable randomness so rounds are reproducible in tests.
library;

import 'dart:math' as math;

abstract class Rng {
  /// Uniform in [0, 1).
  double nextDouble();

  /// Uniform in [0, max).
  int nextInt(int max);
}

class SeededRng implements Rng {
  /// Fixed seed: tests and screenshots only.
  SeededRng(this.seed) : _random = math.Random(seed);

  /// Fresh unpredictable seed per instance (the real app).
  factory SeededRng.entropy() => SeededRng(entropySeed());

  final int seed;
  final math.Random _random;

  /// JS bitwise shifts are 32-bit, so `1 << 32` is 0 on web and `nextInt`
  /// throws. Stay inside 31 bits.
  static const int _seedRange = 0x7fffffff;

  static int entropySeed() {
    try {
      return math.Random.secure().nextInt(_seedRange);
    } on UnsupportedError {
      return DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(_seedRange);
    }
  }

  @override
  double nextDouble() => _random.nextDouble();

  @override
  int nextInt(int max) => _random.nextInt(max);
}
