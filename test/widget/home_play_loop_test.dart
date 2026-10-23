import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/game/home_play_loop.dart';
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _size(WidgetTester tester, Size logical) {
  const dpr = 2.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = Size(logical.width * dpr, logical.height * dpr);
  tester.view.padding = FakeViewPadding(top: 20 * dpr);
  tester.view.viewPadding = tester.view.padding;
  addTearDown(tester.view.reset);
}

Future<void> _pumpLoop(
  WidgetTester tester, {
  required double progress,
  double size = 160,
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: HomePlayLoop(
            size: size,
            waitLabel: 'WAIT',
            goLabel: 'GO!',
            slowTime: '361 ms',
            fastTime: '214 ms',
            reduceMotion: reduceMotion,
            frozenProgress: progress,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<AppServices> _services({String language = 'tr'}) async {
  SharedPreferences.setMockInitialValues({
    PrefsKeys.language: language,
    PrefsKeys.onboardingDone: true,
    PrefsKeys.bestReactionMs: 187,
    PrefsKeys.totalMatches: 12,
  });
  PackageInfo.setMockInitialValues(
    appName: AppIdentity.appName,
    packageName: AppIdentity.packageId,
    version: '0.1.0',
    buildNumber: '1',
    buildSignature: '',
  );
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsService(prefs);
  await settings.setLanguage(language);
  return AppServices(settings: settings, stats: StatsService(prefs));
}

void main() {
  testWidgets('wait frame shows wait label only', (tester) async {
    await _pumpLoop(tester, progress: 0.08);
    expect(find.text('WAIT'), findsOneWidget);
    expect(find.text('GO!'), findsNothing);
    expect(find.text('361 ms'), findsNothing);
    expect(find.text('214 ms'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('go frame turns the pad live', (tester) async {
    await _pumpLoop(tester, progress: 0.28);
    expect(find.text('GO!'), findsOneWidget);
    expect(find.text('WAIT'), findsNothing);
    expect(find.text('361 ms'), findsNothing);
    expect(find.text('214 ms'), findsNothing);
  });

  testWidgets('press frame shows the faster time', (tester) async {
    await _pumpLoop(tester, progress: 0.46);
    expect(find.text('GO!'), findsOneWidget);
    expect(find.text('214 ms'), findsOneWidget);
    expect(find.text('361 ms'), findsNothing);
  });

  testWidgets('result frame shows both times', (tester) async {
    await _pumpLoop(tester, progress: HomePlayLoop.stillFrame);
    expect(find.text('GO!'), findsOneWidget);
    expect(find.text('361 ms'), findsOneWidget);
    expect(find.text('214 ms'), findsOneWidget);
  });

  testWidgets('reduce motion freezes on the result frame', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: HomePlayLoop(
              size: 160,
              waitLabel: 'WAIT',
              goLabel: 'GO!',
              slowTime: '361 ms',
              fastTime: '214 ms',
              reduceMotion: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('361 ms'), findsOneWidget);
    expect(find.text('214 ms'), findsOneWidget);
  });

  testWidgets('card stays inside its square on a tiny phone', (tester) async {
    _size(tester, const Size(320, 568));
    await _pumpLoop(tester, progress: HomePlayLoop.stillFrame, size: 80);
    final box = tester.getSize(find.byType(HomePlayLoop));
    expect(box, const Size(80, 80));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home still frame uses localized wait/go/times', (tester) async {
    _size(tester, const Size(375, 667));
    await tester.pumpWidget(
      ReactionDuelApp(
        services: await _services(),
        home: const HomeScreen(playLoopProgress: HomePlayLoop.stillFrame),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('BAS!'), findsOneWidget);
    expect(find.text('361 ms'), findsOneWidget);
    expect(find.text('214 ms'), findsOneWidget);
    expect(find.text('BEKLE'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home wait frame uses localized wait label', (tester) async {
    _size(tester, const Size(375, 667));
    await tester.pumpWidget(
      ReactionDuelApp(
        services: await _services(),
        home: const HomeScreen(playLoopProgress: 0.08),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('BEKLE'), findsOneWidget);
    expect(find.text('BAS!'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
