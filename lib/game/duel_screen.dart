/// Live duel: drives [DuelEngine] with timers, maps pointer timestamps onto
/// the signal frame, pauses on background, shows pause / match-end overlays.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app_scope.dart';
import '../components/app_button.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/clock.dart';
import '../engine/duel_engine.dart';
import '../engine/duel_state.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../theme/tap_burst.dart';
import 'duel_board.dart';
import 'match_end_overlay.dart';
import 'pause_overlay.dart';

class DuelScreen extends StatefulWidget {
  const DuelScreen({
    required this.config,
    this.engine,
    this.driveTimers = true,
    this.showCoach,
    this.frozenBursts = const [],
    super.key,
  });

  final MatchConfig config;

  /// Injected for tests / screenshots (with a [FakeClock]).
  final DuelEngine? engine;

  /// False = the host advances the engine itself (deterministic captures).
  final bool driveTimers;

  /// Null = from `onboarding_done`.
  final bool? showCoach;

  /// Capture-tool freeze of tap feedback (player + local 0–1 + progress).
  final List<(Player, TapBurstSpec)> frozenBursts;

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> with WidgetsBindingObserver {
  late final DuelEngine _engine;
  late final Clock _clock;
  Timer? _tick;
  Timer? _endTimer;
  DuelPhase? _lastPhase;
  int _lastRound = -1;
  Duration? _signalFrameTs;
  final List<int> _shakes = [0, 0];
  bool _showEnd = false;
  bool _newRecord = false;

  static const Duration _sanity = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final injected = widget.engine;
    if (injected != null) {
      _engine = injected;
      _clock = injected.clock;
    } else {
      _clock = MonotonicClock();
      _engine = DuelEngine(clock: _clock, settings: widget.config.rules)..start();
    }
    _lastPhase = _engine.state.phase;
    _lastRound = _engine.state.round;
    _engine.addListener(_onEngine);
    if (_engine.state.phase == DuelPhase.matchOver) _showEnd = true;
    _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _engine.removeListener(_onEngine);
    _tick?.cancel();
    _endTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _engine.pause();
  }

  void _onEngine() {
    final s = _engine.state;
    final services = AppScope.read(context);
    final phaseChanged = s.phase != _lastPhase || s.round != _lastRound;
    if (phaseChanged) {
      if (s.phase == DuelPhase.signal) {
        _signalFrameTs = null;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _signalFrameTs = SchedulerBinding.instance.currentSystemFrameTimeStamp;
        });
      }
      final result = s.lastResult;
      if (s.phase == DuelPhase.scored ||
          (s.phase == DuelPhase.matchOver && result?.outcome == RoundOutcome.scored)) {
        services.settings.setOnboardingDone(true);
      }
      if (result?.outcome == RoundOutcome.foul &&
          (s.phase == DuelPhase.foul || s.phase == DuelPhase.matchOver)) {
        _shakes[result!.foulBy!.index]++;
      }
      if (s.phase == DuelPhase.matchOver) _onMatchOver(s);
      if (s.phase == DuelPhase.ready) {
        _endTimer?.cancel();
        _showEnd = false;
      }
    }
    _lastPhase = s.phase;
    _lastRound = s.round;
    if (mounted) setState(() {});
    _schedule();
  }

  Future<void> _onMatchOver(DuelState s) async {
    final services = AppScope.read(context);
    services.ads.onMatchFinished();
    _endTimer?.cancel();
    _endTimer = Timer(AppMotion.matchEndDelay, () {
      if (mounted) setState(() => _showEnd = true);
    });
    final record = await services.stats.recordMatch(s);
    if (mounted) setState(() => _newRecord = record);
  }

  void _schedule() {
    _tick?.cancel();
    if (!widget.driveTimers) return;
    final deadline = _engine.nextDeadline;
    if (deadline == null) return;
    final wait = deadline - _clock.now();
    _tick = Timer(wait.isNegative ? Duration.zero : wait, () {
      _engine.tick();
      _schedule();
    });
  }

  void _onTap(Player player, PointerDownEvent event) {
    final s = _engine.state;
    final signalAt = s.signalAt;
    Duration? at;
    if (signalAt != null &&
        (s.phase == DuelPhase.signal ||
            s.phase == DuelPhase.scored ||
            s.phase == DuelPhase.matchOver)) {
      final frame = _signalFrameTs;
      if (frame == null) {
        // Signal not on screen yet: the tap can't be a reaction to it.
        if (s.phase == DuelPhase.signal) at = signalAt - const Duration(microseconds: 1);
      } else {
        final delta = event.timeStamp - frame;
        final limit = const Duration(milliseconds: GameTiming.signalTimeoutMs) + _sanity;
        if (delta > -_sanity && delta < limit) at = signalAt + delta;
      }
    }
    _engine.tap(player, at: at);
  }

  void _pause() => _engine.pause();

  void _goHome() async {
    final services = AppScope.read(context);
    final navigator = Navigator.of(context);
    services.stats.resetSeries();
    if (_engine.state.phase == DuelPhase.matchOver) {
      await services.ads.maybeShowMatchEndInterstitial();
    }
    navigator.popUntil((r) => r.isFirst);
  }

  void _changeSettings() async {
    final services = AppScope.read(context);
    final navigator = Navigator.of(context);
    await services.ads.maybeShowMatchEndInterstitial();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final config = widget.config;
    final (h1, h2) = config.resolvedHues;
    final names = [
      config.p1Name.isEmpty ? l10n.player1 : config.p1Name,
      config.p2Name.isEmpty ? l10n.player2 : config.p2Name,
    ];
    final reduceMotion = services.settings.reduceMotionFor(context);
    final padding = MediaQuery.paddingOf(context);
    final s = _engine.state;
    final coach = widget.showCoach ?? !services.settings.onboardingDone;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _pause();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DuelBoard(
              state: s,
              names: names,
              hues: [h1, h2],
              onTap: _onTap,
              coach: coach,
              reduceMotion: reduceMotion,
              shakeTriggers: _shakes,
              frozenBursts: widget.frozenBursts,
              safeTop: padding.top,
              safeBottom: padding.bottom,
              pauseButton: s.phase == DuelPhase.paused || _showEnd
                  ? null
                  : AppIconButton(
                      icon: Icons.pause_rounded,
                      tooltip: l10n.duelPause,
                      size: AppDimens.pauseButton,
                      onPressed: _pause,
                    ),
            ),
            if (s.phase == DuelPhase.paused)
              PauseOverlay(onResume: _engine.resume, onRestart: _engine.start, onHome: _goHome),
            if (_showEnd && s.phase == DuelPhase.matchOver)
              MatchEndOverlay(
                state: s,
                names: names,
                hues: [h1, h2],
                series: [services.stats.seriesOf(Player.p1), services.stats.seriesOf(Player.p2)],
                newRecord: _newRecord,
                reduceMotion: reduceMotion,
                onRematch: _engine.rematch,
                onChangeSettings: _changeSettings,
                onHome: _goHome,
              ),
          ],
        ),
      ),
    );
  }
}
