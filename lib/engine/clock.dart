/// Monotonic time source for the engine. Tests and screenshots use [FakeClock].
library;

abstract class Clock {
  Duration now();
}

class MonotonicClock implements Clock {
  MonotonicClock() : _watch = Stopwatch()..start();

  final Stopwatch _watch;

  @override
  Duration now() => _watch.elapsed;
}

class FakeClock implements Clock {
  FakeClock([this._now = Duration.zero]);

  Duration _now;

  @override
  Duration now() => _now;

  void advance(Duration delta) => _now += delta;

  void advanceMs(int ms) => advance(Duration(milliseconds: ms));

  void set(Duration value) => _now = value;
}
