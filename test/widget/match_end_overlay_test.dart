import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/config/tokens.dart';
import 'package:reaction_duel/engine/duel_settings.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/game/match_end_overlay.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:reaction_duel/theme/dino_art.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppServices> _services() async {
  SharedPreferences.setMockInitialValues({PrefsKeys.language: 'tr'});
  final prefs = await SharedPreferences.getInstance();
  return AppServices(settings: SettingsService(prefs), stats: StatsService(prefs));
}

DuelState _endState({Player winner = Player.p1}) {
  final p1Wins = winner == Player.p1;
  return DuelState(
    phase: DuelPhase.matchOver,
    settings: const DuelSettings(),
    scores: p1Wins ? const [3, 1] : const [1, 3],
    stats: const [
      PlayerStats(reactions: [219, 204]),
      PlayerStats(reactions: [251], fouls: 1),
    ],
    matchWinner: winner,
  );
}

void main() {
  testWidgets('rematch, change settings and home exist once and fire', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    var rematch = 0;
    var settings = 0;
    var home = 0;
    await tester.pumpWidget(
      ReactionDuelApp(
        services: await _services(),
        home: MatchEndOverlay(
          state: _endState(),
          names: const ['Deniz', 'Mert'],
          series: const [2, 1],
          onRematch: () => rematch++,
          onChangeSettings: () => settings++,
          onHome: () => home++,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Rövanş'), findsOneWidget);
    expect(find.text('Ayarları değiştir'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsOneWidget);
    expect(find.text('Deniz kazandı'), findsOneWidget);

    await tester.tap(find.text('Rövanş'));
    await tester.pump();
    expect(rematch, 1);
    expect(settings, 0);
    expect(home, 0);

    await tester.tap(find.text('Ayarları değiştir'));
    await tester.pump();
    expect(settings, 1);

    await tester.tap(find.text('Ana sayfa'));
    await tester.pump();
    expect(home, 1);
  });

  testWidgets('winner dot uses that player\'s dino accent', (tester) async {
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    Future<void> pumpWinner(Player winner) async {
      await tester.pumpWidget(
        ReactionDuelApp(
          services: await _services(),
          home: MatchEndOverlay(
            state: _endState(winner: winner),
            names: const ['Deniz', 'Mert'],
            series: const [2, 1],
            onRematch: () {},
            onChangeSettings: () {},
            onHome: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    Color dotColor() {
      final box = tester.widget<Container>(
        find.byKey(const ValueKey('match-end-winner-dot')),
      );
      return (box.decoration! as BoxDecoration).color!;
    }

    await pumpWinner(Player.p1);
    expect(dotColor(), AppColors.trexInk);
    expect(dotColor(), isNot(PlayerHue.blue.ink));

    await pumpWinner(Player.p2);
    expect(dotColor(), AppColors.triInk);
    expect(dotColor(), isNot(PlayerHue.yellow.ink));
  });

  testWidgets('match end shows new dino painters with crown on winner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    Future<void> pumpWinner(Player winner) async {
      await tester.pumpWidget(
        ReactionDuelApp(
          services: await _services(),
          home: MatchEndOverlay(
            state: _endState(winner: winner),
            names: const ['Deniz', 'Mert'],
            series: const [2, 1],
            onRematch: () {},
            onChangeSettings: () {},
            onHome: () {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    Future<void> expectArt(Player winner) async {
      await pumpWinner(winner);
      expect(find.byType(DinoArt), findsNWidgets(2));
      final paints = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((w) => w.painter)
          .whereType<DinoPainter>()
          .toList();
      expect(paints, hasLength(2));
      final crown = paints.singleWhere((p) => p.crowned);
      expect(crown.mood, CharacterMood.happy);
      expect(
        crown.kind,
        winner == Player.p1 ? DinoKind.trex : DinoKind.tri,
      );
      final loser = paints.singleWhere((p) => !p.crowned);
      expect(loser.mood, CharacterMood.nextTime);
      expect(
        loser.kind,
        winner == Player.p1 ? DinoKind.tri : DinoKind.trex,
      );
    }

    await expectArt(Player.p1);
    await expectArt(Player.p2);
  });
}
