import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/theme/tap_burst.dart';

void main() {
  testWidgets('tap burst paints without emoji or POW text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: TapBurstLayer(
              bursts: [
                TapBurstSpec(
                  dx: 0.35,
                  dy: 0.6,
                  progress: 0.28,
                  winning: true,
                  player: Player.p1,
                ),
                TapBurstSpec(
                  dx: 0.65,
                  dy: 0.4,
                  progress: 0.28,
                  player: Player.p2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TapBurstLayer), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('POW!'), findsNothing);
    expect(find.textContaining('POW'), findsNothing);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('tap burst respects reduced motion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.expand(
          child: TapBurstLayer(
            bursts: [
              TapBurstSpec(
                dx: 0.5,
                dy: 0.5,
                progress: 0.4,
                player: Player.p1,
                reduceMotion: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(TapBurstLayer), findsOneWidget);
    expect(find.text('POW!'), findsNothing);
  });

  testWidgets('persist stamp stays visible at progress 1', (tester) async {
    Future<List<int>> bytes({required bool persist, required double progress}) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: RepaintBoundary(
                  key: key,
                  child: TapBurstLayer(
                    bursts: [
                      TapBurstSpec(
                        dx: 0.5,
                        dy: 0.5,
                        progress: progress,
                        persist: persist,
                        player: Player.p1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      return png!;
    }

    final faded = await bytes(persist: false, progress: 1);
    final held = await bytes(persist: true, progress: 1);
    final peak = await bytes(persist: false, progress: TapBurstSpec.holdProgress);
    expect(held, isNot(faded));
    expect(held, peak);
  });

  testWidgets('p1 and p2 stamp the same 3-toed track', (tester) async {
    Future<List<int>> bytesFor(Player player) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: RepaintBoundary(
                  key: key,
                  child: TapBurstLayer(
                    bursts: [
                      TapBurstSpec(
                        dx: 0.5,
                        dy: 0.5,
                        progress: 0.28,
                        winning: true,
                        player: player,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final png = await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      return png!;
    }

    final p1 = await bytesFor(Player.p1);
    final p2 = await bytesFor(Player.p2);
    expect(p1, p2);
  });
}
