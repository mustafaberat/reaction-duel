/// Visual tokens — every color, size, font and duration used by widgets.
///
/// Dino Pals is the app theme. Widgets read [AppColors], [AppFonts] and
/// [AppDimens] directly.
library;

import 'package:flutter/material.dart';

import '../engine/signal_palette.dart';

enum CharacterMood { waiting, ready, pouncing, happy, oops, surprised, nextTime }

class PlayerSwatch {
  const PlayerSwatch(this.ink, this.tint);

  final Color ink;
  final Color tint;
}

const _playerHues = [
  PlayerSwatch(Color(0xFFD4A000), Color(0xFFFFF6C8)),
  PlayerSwatch(Color(0xFF2E8B3C), Color(0xFFD0EEC8)),
  PlayerSwatch(Color(0xFFD46828), Color(0xFFFFD8B8)),
  PlayerSwatch(Color(0xFF2E74C0), Color(0xFFC8E0F8)),
];

abstract final class AppColors {
  static const Color background = Color(0xFFFFF4C0);
  static const Color backgroundTop = Color(0xFF87D6F0);
  static const Color backgroundBottom = Color(0xFFFFF0A0);
  static const Color surface = Color(0xFFFFF8DC);
  static const Color surfaceHigh = Color(0xFFFFE078);
  static const Color stroke = Color(0xFFC8A04A);
  static const Color hairline = Color(0x44604018);
  static const Color text = Color(0xFF2E220C);
  static const Color textMuted = Color(0xFF7A5C28);
  static const Color textFaint = Color(0xFFB49458);

  /// Themed UI accent (buttons, chips). Signal colors stay on [signal].
  static const Color accent = Color(0xFF3D9E45);
  static const Color onAccent = Color(0xFF0E2410);

  static const Color danger = Color(0xFFD6453D);
  static const Color dangerTint = Color(0x33D6453D);

  /// Foul half: flash peak, then the tint held with the result.
  static const double foulFlashAlpha = 0.42;
  static const double foulHoldAlpha = 0.14;

  static const Color orbRing = Color(0xFFC8A04A);
  static const Color orbCore = Color(0xFFFFFBE8);

  static const Color waitCue = Color(0xFF5A4018);

  /// Text/ink on top of a bright signal color.
  static const Color onSignal = Color(0xFF0B0C0E);
  static const Color onSignalMuted = Color(0x990B0C0E);

  static const Color scrim = Color(0xF2FFF4C0);
  static const Color transparent = Color(0x00000000);

  static const Color outline = Color(0xFF3A280C);
  static const Color highlight = Color(0xFFFFFBE8);

  /// Sunny sticker fill for display type sitting on the sky.
  static const Color displaySkyFill = Color(0xFFFFE566);

  static Color signal(SignalColor c) => Color(c.argb);
}

/// Per-player half accent. [ink] for name/dots, [tint] for the half background.
enum PlayerHue {
  yellow,
  green,
  cream,
  blue;

  Color get ink => _playerHues[index].ink;
  Color get tint => _playerHues[index].tint;

  static const PlayerHue defaultP1 = PlayerHue.blue;
  static const PlayerHue defaultP2 = PlayerHue.yellow;

  /// Keeps the two halves on different colors. A shared pick leaves player 1
  /// and moves player 2 to the next hue.
  static (PlayerHue, PlayerHue) resolve(PlayerHue p1, PlayerHue p2) {
    if (p1 != p2) return (p1, p2);
    final next = values[(values.indexOf(p1) + 1) % values.length];
    return (p1, next);
  }
}

abstract final class AppFonts {
  static const String display = 'LuckiestGuy';
  static const String body = 'LilitaOne';

  /// Platform fallbacks for CJK / Hangul native language names.
  static const List<String> fallback = [
    'Inter',
    'PingFang SC',
    'Hiragino Sans',
    'Apple SD Gothic Neo',
    'Noto Sans CJK SC',
    'Noto Sans CJK JP',
    'Noto Sans CJK KR',
  ];

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

abstract final class AppType {
  static const double hero = 40;
  static const double display = 30;
  static const double title = 20;
  static const double body = 16;
  static const double bodySmall = 15;
  static const double caption = 14;
  static const double overline = 13;
  static const double button = 16;

  static const double resultMs = 52;
  static const double resultLabel = 28;
  static const double resultSub = 18;
  static const double endScore = 44;
  static const double endName = 26;
  static const double halfName = 18;
  static const double halfMs = 17;
  static const double cueWait = 19;
  static const double cueGo = 42;
  static const double cueTracking = 3;
  static const double resultBadge = 15;
  static const double idleScore = 132;
  static const double idleScoreAlpha = 0.06;

  static const double heroHeight = 1.05;
  static const double bodyHeight = 1.4;
  static const double tightTracking = -0.6;
  static const double displayTracking = 0.8;
  static const double overlineTracking = 1.6;
  static const double buttonTracking = 0.2;

  /// Cream halo around dark-brown display type on sand / cream screens.
  static const List<Shadow> displayHalo = [
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(-2.2, 0), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(2.2, 0), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(0, -2.2), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(0, 2.2), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(-1.6, -1.6), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(1.6, -1.6), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(-1.6, 1.6), blurRadius: 0),
    Shadow(color: Color(0xFFFFFFF4), offset: Offset(1.6, 1.6), blurRadius: 0),
    Shadow(color: Color(0x553A280C), offset: Offset(0, 3), blurRadius: 4),
  ];

  /// Dark outline around the yellow sky title.
  static const List<Shadow> displaySkyHalo = [
    Shadow(color: Color(0xFF3A280C), offset: Offset(-2.4, 0), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(2.4, 0), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(0, -2.4), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(0, 2.4), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(-1.8, -1.8), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(1.8, -1.8), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(-1.8, 1.8), blurRadius: 0),
    Shadow(color: Color(0xFF3A280C), offset: Offset(1.8, 1.8), blurRadius: 0),
    Shadow(color: Color(0x553A280C), offset: Offset(0, 4), blurRadius: 6),
  ];
}

abstract final class AppDimens {
  static const double page = 24;
  static const double pageTight = 16;
  static const double gapXs = 4;
  static const double gapS = 8;
  static const double gapM = 12;
  static const double gapL = 16;
  static const double gapXl = 24;
  static const double gapXxl = 32;

  static const double buttonHeight = 56;
  static const double buttonHeightSmall = 44;
  static const double buttonRadius = 16;
  static const double cardRadius = 18;
  static const double chipRadius = 12;
  static const double segmentHeight = 44;
  static const double segmentRadius = 12;
  static const double segmentInset = 3;
  static const double tileMinHeight = 56;
  static const double iconButton = 44;
  static const double icon = 22;
  static const double iconSmall = 18;
  static const double hairline = 1;
  static const double maxContentWidth = 520;

  static const double buttonOutline = 4;
  static const double cardOutline = 2.5;
  static const double buttonDepth = 6;

  static const double orbDuel = 108;
  static const double orbHome = 176;
  static const double orbRingWidth = 2.5;
  static const double orbWaitDot = 10;
  static const double orbShapeFactor = 0.34;
  static const double orbGlowBlur = 36;
  static const double orbPulseTravel = 120;
  static const double orbPulseGrow = 1.9;

  static const double dot = 14;
  static const double dotGap = 6;
  static const double dotStroke = 1.5;

  static const double halfPadding = 20;
  static const double halfBarHeight = 44;
  static const double pauseButton = 38;
  static const double centerGap = 14;
  static const double cueGap = 10;
  static const double cueIcon = 18;
  static const double shakeAmplitude = 8;
  static const double foulIcon = 48;
  static const double foulIconStroke = 2.5;
  static const double badgePadH = 10;
  static const double badgePadV = 4;

  static const double colorChip = 44;
  static const double colorChipRing = 2.5;
  static const double colorChipGap = 12;
  static const double targetDot = 14;
  static const double nameFieldWidth = 150;

  static const double demoFrameWidth = 220;
  static const double demoFrameRadius = 28;
  static const double demoFrameBorder = 6;
  static const double demoHand = 44;

  static const double endPanelMaxWidth = 360;
  static const double statsColumn = 88;

  static const double characterHalf = 128;
  static const double characterHome = 138;
  static const double characterResult = 120;
  static const double characterEndWin = 132;
  static const double characterEndLose = 120;
}

/// Language-neutral glyphs used to join localized pieces.
abstract final class AppGlyphs {
  static const String separator = '  ·  ';
  static const String scoreDash = ' – ';
}

abstract final class AppMotion {
  /// Waiting orb: only the ring breathes (fixed period, never synced to the
  /// round schedule). Home orb keeps the full-body breath.
  static const Duration breath = Duration(milliseconds: 2400);
  static const double breathMin = 0.96;
  static const double breathMax = 1.04;
  static const double ringBreathMin = 0.45;
  static const double ringBreathMax = 1;
  static const double reducedOpacityMin = 0.7;

  static const Duration pulse = Duration(milliseconds: 250);
  static const Duration shake = Duration(milliseconds: 300);
  static const int shakeOscillations = 3;

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration matchEndDelay = Duration(milliseconds: 1500);

  static const Duration demoLoop = Duration(milliseconds: 3600);
  static const Duration demoPress = Duration(milliseconds: 140);

  static const Duration tapBurst = Duration(milliseconds: 720);
}

abstract final class AppShadows {
  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x663A280C), blurRadius: 0, offset: Offset(0, 5)),
  ];
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x443A280C), blurRadius: 0, offset: Offset(3, 4)),
  ];
}
