/// Play Store visuals: real Reaction Rivals UI in IPTV-style frames.
///
/// Run: `APP_ROOT=. ../lib/scripts/generate_game_images.sh`
/// Out:
///   play/gorseller/{lang}/01-*.png          phone 1080×1920
///   play/gorseller/{lang}/tablet/01-*.png   tablet 1440×2560
///   play/gorseller/{lang}/feature.png       1024×500
// ignore_for_file: invalid_use_of_visible_for_testing_member
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reaction_duel/app.dart';
import 'package:reaction_duel/app_scope.dart';
import 'package:reaction_duel/config/app_config.dart';
import 'package:reaction_duel/config/tokens.dart';
import 'package:reaction_duel/engine/clock.dart';
import 'package:reaction_duel/engine/duel_engine.dart';
import 'package:reaction_duel/engine/duel_state.dart';
import 'package:reaction_duel/engine/rng.dart';
import 'package:reaction_duel/game/duel_screen.dart';
import 'package:reaction_duel/screens/home_screen.dart';
import 'package:reaction_duel/screens/how_to_play_screen.dart';
import 'package:reaction_duel/screens/match_setup_screen.dart';
import 'package:reaction_duel/services/settings_service.dart';
import 'package:reaction_duel/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size _phoneCanvas = Size(1080, 1920);
const Size _tabletCanvas = Size(1440, 2560);
const Size _featureCanvas = Size(1024, 500);
const Size _phoneLogical = Size(390, 844);
const String _outRoot = 'play/gorseller';

const List<String> _fontFallback = AppFonts.fallback;

const Map<String, Map<String, String>> _phoneSlogans = {
  'en': {
    'home': 'TAP FIRST',
    'duel': 'WAIT FOR THE COLOR',
    'setup': 'PICK YOUR MATCH',
    'howto': 'LEARN IN SECONDS',
    'over': 'WIN THE DUEL',
  },
  'es': {
    'home': 'TOCA PRIMERO',
    'duel': 'ESPERA EL COLOR',
    'setup': 'ELIGE TU PARTIDA',
    'howto': 'APRENDE AL INSTANTE',
    'over': 'GANA EL DUELO',
  },
  'pt': {
    'home': 'TOQUE PRIMEIRO',
    'duel': 'ESPERE A COR',
    'setup': 'ESCOLHA A PARTIDA',
    'howto': 'APRENDA EM SEGUNDOS',
    'over': 'VENÇA O DUELO',
  },
  'zh': {
    'home': '抢先点击',
    'duel': '等待变色',
    'setup': '选择对局',
    'howto': '几秒学会',
    'over': '赢得对决',
  },
  'ja': {
    'home': '先にタップ',
    'duel': '色を待つ',
    'setup': '試合を選ぶ',
    'howto': 'すぐ覚えられる',
    'over': 'デュエルに勝て',
  },
  'de': {
    'home': 'ZUERST TIPPEN',
    'duel': 'WARTE AUF DIE FARBE',
    'setup': 'WÄHLE DEIN MATCH',
    'howto': 'IN SEKUNDEN LERNEN',
    'over': 'GEWINNE DAS DUELL',
  },
  'fr': {
    'home': 'TAPEZ EN PREMIER',
    'duel': 'ATTENDEZ LA COULEUR',
    'setup': 'CHOISISSEZ LE MATCH',
    'howto': 'APPRENEZ EN SECONDES',
    'over': 'GAGNEZ LE DUEL',
  },
  'ko': {
    'home': '먼저 탭하세요',
    'duel': '색을 기다리세요',
    'setup': '경기를 고르세요',
    'howto': '몇 초면 배워요',
    'over': '결투에서 승리',
  },
  'it': {
    'home': 'TOCCA PER PRIMO',
    'duel': 'ASPETTA IL COLORE',
    'setup': 'SCEGLI LA PARTITA',
    'howto': 'IMPARA IN UN ATTIMO',
    'over': 'VINCI IL DUELLO',
  },
  'tr': {
    'home': 'İLK SEN BAS',
    'duel': 'RENGİ BEKLE',
    'setup': 'MAÇINI SEÇ',
    'howto': 'SANİYELERDE ÖĞREN',
    'over': 'DÜELLOYU KAZAN',
  },
};

const Map<String, String> _tabletSlogan = {
  'en': 'BUILT FOR BIG SCREENS',
  'es': 'PENSADO PARA PANTALLA GRANDE',
  'pt': 'FEITO PARA TELA GRANDE',
  'zh': '为大屏而生',
  'ja': '大画面向け',
  'de': 'FÜR GROSSE DISPLAYS',
  'fr': 'PENSÉ POUR LE GRAND ÉCRAN',
  'ko': '큰 화면에 맞게',
  'it': 'PENSATO PER LO SCHERMO GRANDE',
  'tr': 'BÜYÜK EKRAN İÇİN',
};

const Map<String, String> _featureTagline = {
  'en': 'Wait for the color. Tap first.',
  'es': 'Espera el color. Toca primero.',
  'pt': 'Espere a cor. Toque primeiro.',
  'zh': '等颜色变了再点。',
  'ja': '色を待って、先にタップ。',
  'de': 'Warte auf die Farbe. Tippe zuerst.',
  'fr': 'Attendez la couleur. Tapez en premier.',
  'ko': '색을 기다리세요. 먼저 탭하세요.',
  'it': 'Aspetta il colore. Tocca per primo.',
  'tr': 'Rengi bekle. İlk sen bas.',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play gorsellerini yaz (phone/tablet/feature)', (tester) async {
    await tester.runAsync(_loadFonts);
    PackageInfo.setMockInitialValues(
      appName: AppIdentity.appName,
      packageName: AppIdentity.packageId,
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      PrefsKeys.language: 'en',
      PrefsKeys.onboardingDone: true,
      PrefsKeys.reduceMotion: ReduceMotionPref.on.name,
      PrefsKeys.bestReactionMs: 187,
      PrefsKeys.totalMatches: 12,
    });
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsService(prefs);
    final stats = StatsService(prefs);
    final services = AppServices(settings: settings, stats: stats);
    const config = MatchConfig();

    for (final lang in SettingsService.supportedLanguages) {
      await settings.setLanguage(lang);
      final phone = _phoneSlogans[lang]!;
      final tabletPitch = _tabletSlogan[lang]!;

      for (final entry in _shotBuilders(phone, config)) {
        await _shotFramed(
          tester,
          services: services,
          canvas: _phoneCanvas,
          outPath: '$_outRoot/$lang/${entry.id}.png',
          slogan: entry.slogan,
          buildPhone: entry.build,
        );
      }

      for (final entry in _shotBuilders(phone, config)) {
        await _shotFramed(
          tester,
          services: services,
          canvas: _tabletCanvas,
          outPath: '$_outRoot/$lang/tablet/${entry.id}.png',
          slogan: tabletPitch,
          buildPhone: entry.build,
        );
      }

      await _shotFeature(tester, lang: lang, tagline: _featureTagline[lang]!);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}

class _ShotSpec {
  const _ShotSpec({
    required this.id,
    required this.slogan,
    required this.build,
  });
  final String id;
  final String slogan;
  final Widget Function() build;
}

List<_ShotSpec> _shotBuilders(Map<String, String> slogans, MatchConfig config) {
  return [
    _ShotSpec(
      id: '01-home',
      slogan: slogans['home']!,
      build: () => const HomeScreen(),
    ),
    _ShotSpec(
      id: '02-duel',
      slogan: slogans['duel']!,
      build: () => DuelScreen(
        config: config,
        engine: _engineFor(config, _Scene.signal),
        driveTimers: false,
        showCoach: false,
      ),
    ),
    _ShotSpec(
      id: '03-setup',
      slogan: slogans['setup']!,
      build: () => const MatchSetupScreen(),
    ),
    _ShotSpec(
      id: '04-howto',
      slogan: slogans['howto']!,
      build: () => const HowToPlayScreen(
        initialStep: 2,
        includeDecoyStep: false,
        frozenProgress: 0.52,
      ),
    ),
    _ShotSpec(
      id: '05-over',
      slogan: slogans['over']!,
      build: () => DuelScreen(
        config: config,
        engine: _engineFor(config, _Scene.matchEnd),
        driveTimers: false,
        showCoach: false,
      ),
    ),
  ];
}

enum _Scene { signal, matchEnd }

DuelEngine _engineFor(MatchConfig config, _Scene scene) {
  final clock = FakeClock();
  final engine = DuelEngine(
    clock: clock,
    rng: SeededRng(21),
    settings: config.rules,
  )..start();

  void runTo(DuelPhase phase) {
    for (var i = 0; i < 40 && engine.state.phase != phase; i++) {
      final deadline = engine.nextDeadline;
      if (deadline == null) return;
      clock.set(deadline);
      engine.tick();
    }
  }

  void win(Player p, int ms, int otherMs) {
    runTo(DuelPhase.signal);
    final s = engine.state.signalAt!;
    engine.tap(p, at: s + Duration(milliseconds: ms));
    engine.tap(p.other, at: s + Duration(milliseconds: otherMs));
  }

  win(Player.p1, 231, 284);
  win(Player.p2, 268, 305);

  switch (scene) {
    case _Scene.signal:
      runTo(DuelPhase.signal);
    case _Scene.matchEnd:
      runTo(DuelPhase.waiting);
      engine.tap(Player.p2);
      win(Player.p1, 219, 251);
      win(Player.p1, 204, 262);
  }
  return engine;
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');
  final dir = '$root/bin/cache/artifacts/material_fonts';

  Future<ByteData> fileBytes(String path) async {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'Font yok: $path');
    return ByteData.sublistView(await file.readAsBytes());
  }

  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(fileBytes(path));
    }
    await loader.load();
  }

  Future<void> loadIfExists(String family, String path) async {
    if (File(path).existsSync()) await load(family, [path]);
  }

  await load('MaterialIcons', ['$dir/MaterialIcons-Regular.otf']);
  await load('Baloo2', [
    'assets/fonts/Baloo2-Bold.ttf',
    'assets/fonts/Baloo2-ExtraBold.ttf',
  ]);
  await load('Nunito', [
    'assets/fonts/Nunito-Regular.ttf',
    'assets/fonts/Nunito-SemiBold.ttf',
    'assets/fonts/Nunito-Bold.ttf',
  ]);
  await load('ZenMaruGothic', ['assets/fonts/ZenMaruGothic-Bold.ttf']);
  await load('Jua', ['assets/fonts/Jua-Regular.ttf']);
  await load('ZCOOLKuaiLe', ['assets/fonts/ZCOOLKuaiLe-Regular.ttf']);

  await load('Apple Color Emoji', [
    '/System/Library/Fonts/Apple Color Emoji.ttc',
  ]);
  await loadIfExists(
    'PingFang SC',
    '/System/Library/PrivateFrameworks/FontServices.framework/Versions/A/Resources/Reserved/PingFangUI.ttc',
  );
  await loadIfExists(
    'Hiragino Sans GB',
    '/System/Library/Fonts/Hiragino Sans GB.ttc',
  );
  await loadIfExists('Hiragino Sans', '/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc');
  await loadIfExists(
    'Apple SD Gothic Neo',
    '/System/Library/Fonts/AppleSDGothicNeo.ttc',
  );
  await loadIfExists('STHeiti', '/System/Library/Fonts/STHeiti Medium.ttc');
}

Future<void> _shotFramed(
  WidgetTester tester, {
  required AppServices services,
  required Size canvas,
  required String outPath,
  required String slogan,
  required Widget Function() buildPhone,
}) async {
  _setView(tester, canvas);
  final frameKey = GlobalKey();

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    RepaintBoundary(
      key: frameKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StoreFrame(
          slogan: slogan,
          phone: _phoneHost(services, buildPhone),
        ),
      ),
    ),
  );
  await _pumpFrames(tester);
  await _writePng(tester, frameKey, outPath);
}

Widget _phoneHost(AppServices services, Widget Function() buildPhone) {
  return MediaQuery(
    data: const MediaQueryData(
      size: _phoneLogical,
      devicePixelRatio: 1,
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
      disableAnimations: true,
    ),
    child: SizedBox(
      width: _phoneLogical.width,
      height: _phoneLogical.height,
      child: ReactionDuelApp(services: services, home: buildPhone()),
    ),
  );
}

Future<void> _shotFeature(
  WidgetTester tester, {
  required String lang,
  required String tagline,
}) async {
  _setView(tester, _featureCanvas);
  final key = GlobalKey();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _FeatureGraphic(tagline: tagline),
      ),
    ),
  );
  await tester.pump();
  await _writePng(tester, key, '$_outRoot/$lang/feature.png');
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<Uint8List?> _pngBytes(WidgetTester tester, GlobalKey key) {
  return tester.binding.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  final bytes = await _pngBytes(tester, key);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.slogan, required this.phone});

  final String slogan;
  final Widget phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFD6EAF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(
              color: AppColors.accent.withValues(alpha: 0.28),
              size: 320,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFFA8D8F0).withValues(alpha: 0.5),
              size: 280,
            ),
          ),
          Positioned(
            top: 220,
            left: 40,
            child: Transform.rotate(
              angle: -0.35,
              child: Icon(
                Icons.bolt_rounded,
                size: 72,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: 36,
            child: Icon(
              Icons.timer_outlined,
              size: 64,
              color: AppColors.accent.withValues(alpha: 0.45),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 40),
              child: Column(
                children: [
                  Text(
                    slogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: _fontFallback,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0B2A4A),
                      letterSpacing: 1.2,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 19.5,
                        child: _DeviceBezel(child: phone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBezel extends StatelessWidget {
  const _DeviceBezel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: const Color(0xFF2A2A32), width: 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2A4A).withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.tagline});
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0E1A26),
            AppColors.background,
            const Color(0xFF26250E),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(-0.88, 0),
            child: Icon(
              Icons.bolt_rounded,
              size: 150,
              color: PlayerHue.blue.ink.withValues(alpha: 0.28),
            ),
          ),
          Align(
            alignment: const Alignment(0.88, 0),
            child: Icon(
              Icons.bolt_rounded,
              size: 150,
              color: PlayerHue.yellow.ink.withValues(alpha: 0.28),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'REACTION RIVALS',
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontFamilyFallback: _fontFallback,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontFamilyFallback: _fontFallback,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
