import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/engine/duel_settings.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

DuelState _finished(int p1Ms, int p2Ms) => DuelState(
  phase: DuelPhase.matchOver,
  settings: const DuelSettings(),
  stats: [
    PlayerStats(reactions: [p1Ms]),
    PlayerStats(reactions: [p2Ms]),
  ],
  matchWinner: Player.p1,
);

void main() {
  test('best reaction is stored locally and survives a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final stats = StatsService(prefs);
    expect(stats.bestMs, isNull);

    expect(await stats.recordMatch(_finished(250, 310)), isTrue);
    expect(await stats.recordMatch(_finished(280, 300)), isFalse);
    expect(stats.bestMs, 250);
    expect(prefs.getInt(PrefsKeys.bestReactionMs), 250);

    final reloaded = StatsService(prefs);
    expect(reloaded.bestMs, 250);
    expect(reloaded.totalMatches, 2);
  });
}
