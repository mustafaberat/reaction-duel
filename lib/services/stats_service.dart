/// Device record + total matches (persisted) and the in-memory session series.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../engine/duel_state.dart';

class StatsService extends ChangeNotifier {
  StatsService(this._prefs)
    : _bestMs = _prefs.getInt(PrefsKeys.bestReactionMs),
      _totalMatches = _prefs.getInt(PrefsKeys.totalMatches) ?? 0 {
    firstSession = _totalMatches == 0;
  }

  final SharedPreferences _prefs;

  int? _bestMs;
  int _totalMatches;
  final List<int> _series = [0, 0];

  /// True if no match had been completed before this app launch.
  late final bool firstSession;

  int? get bestMs => _bestMs;
  int get totalMatches => _totalMatches;
  int seriesOf(Player p) => _series[p.index];

  /// Records a finished match. Returns true if a new device record was set.
  Future<bool> recordMatch(DuelState state) async {
    final winner = state.matchWinner;
    if (winner != null) _series[winner.index]++;
    _totalMatches++;
    var record = false;
    for (final p in Player.values) {
      final best = state.statsOf(p).bestMs;
      if (best != null && (_bestMs == null || best < _bestMs!)) {
        _bestMs = best;
        record = true;
      }
    }
    notifyListeners();
    await _prefs.setInt(PrefsKeys.totalMatches, _totalMatches);
    if (record) await _prefs.setInt(PrefsKeys.bestReactionMs, _bestMs!);
    return record;
  }

  /// Series resets when the players go back to Home (rfc §6).
  void resetSeries() {
    _series[0] = 0;
    _series[1] = 0;
  }
}
