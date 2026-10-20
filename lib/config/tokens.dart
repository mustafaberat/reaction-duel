/// Visual tokens — every color, size, font and duration used by widgets.
library;

import 'package:flutter/material.dart';

import '../engine/signal_palette.dart';
import 'app_config.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0D0E11);
  static const Color surface = Color(0xFF16181C);
  static const Color surfaceHigh = Color(0xFF1E2126);
  static const Color stroke = Color(0xFF2A2E35);
  static const Color hairline = Color(0x1AFFFFFF);
  static const Color text = Color(0xFFF2F3F5);
  static const Color textMuted = Color(0xFF8B919B);
  static const Color textFaint = Color(0xFF5B616B);

  /// The one accent: signal green.
  static const Color accent = Color(PaletteArgb.green);
  static const Color onAccent = Color(0xFF05140B);

  static const Color danger = Color(0xFFFF5A5F);
  static const Color dangerTint = Color(0x33FF5A5F);

  /// Foul half: flash peak, then the tint held with the result.
  static const double foulFlashAlpha = 0.42;
  static const double foulHoldAlpha = 0.14;

  /// Neutral orb ring.
  static const Color orbRing = Color(0xFF4A505A);
  static const Color orbCore = Color(0xFF15171B);

  /// "WAIT" cue next to the neutral orb.
  static const Color waitCue = Color(0xFFB9BEC6);

  /// Text/ink on top of a bright signal color.
  static const Color onSignal = Color(0xFF0B0C0E);
  static const Color onSignalMuted = Color(0x990B0C0E);

  static const Color scrim = Color(0xF00D0E11);
  static const Color transparent = Color(0x00000000);

  static Color signal(SignalColor c) => Color(c.argb);
}

/// Per-player half accent. [ink] for name/dots, [tint] for the half background.
enum PlayerHue {
  navy(Color(0xFF7C9BFF), Color(0xFF121A2E), {
    SignalColor.blue,
    SignalColor.purple,
    SignalColor.cbBlue,
    SignalColor.cbSky,
  }),
  bordeaux(Color(0xFFFF7A93), Color(0xFF2A1219), {SignalColor.pink}),
  teal(Color(0xFF4FD1C5), Color(0xFF0F2524), {SignalColor.green, SignalColor.cbSky}),
  amber(Color(0xFFF2B24C), Color(0xFF29200F), {
    SignalColor.yellow,
    SignalColor.orange,
    SignalColor.cbYellow,
    SignalColor.cbOrange,
  }),
  slate(Color(0xFFB4BCC8), Color(0xFF1A1D22), {SignalColor.cbWhite});

  const PlayerHue(this.ink, this.tint, this.conflicts);

  final Color ink;
  final Color tint;

  /// Signal colors this hue is too close to (auto-switched away, rfc §5).
  final Set<SignalColor> conflicts;

  static const PlayerHue defaultP1 = PlayerHue.navy;
  static const PlayerHue defaultP2 = PlayerHue.bordeaux;

  /// Resolves both hues so they differ from each other and from [target].
  static (PlayerHue, PlayerHue) resolve(PlayerHue p1, PlayerHue p2, SignalColor target) {
    PlayerHue pick(PlayerHue wanted, PlayerHue? taken) {
      bool ok(PlayerHue h) => h != taken && !h.conflicts.contains(target);
      if (ok(wanted)) return wanted;
      final start = PlayerHue.values.indexOf(wanted);
      for (var i = 1; i < PlayerHue.values.length; i++) {
        final h = PlayerHue.values[(start + i) % PlayerHue.values.length];
        if (ok(h)) return h;
      }
      return wanted;
    }

    if (p1.conflicts.contains(target) && !p2.conflicts.contains(target)) {
      final b = pick(p2, null);
      return (pick(p1, b), b);
    }
    final a = pick(p1, null);
    final b = pick(p2, a);
    return (a, b);
  }
}

abstract final class AppFonts {
  static const String display = 'Sora';
  static const String body = 'Inter';

  /// Platform fallbacks for CJK / Hangul native language names.
  static const List<String> fallback = [
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
  static const double bodySmall = 14;
  static const double caption = 12;
  static const double overline = 11;
  static const double button = 16;

  static const double resultMs = 52;
  static const double resultLabel = 28;
  static const double resultSub = 18;
  static const double endScore = 44;
  static const double endName = 26;
  static const double halfName = 15;
  static const double halfMs = 15;
  static const double cueWait = 17;
  static const double cueGo = 46;
  static const double cueTracking = 3;
  static const double resultBadge = 13;
  static const double idleScore = 132;
  static const double idleScoreAlpha = 0.06;

  static const double heroHeight = 1.05;
  static const double bodyHeight = 1.4;
  static const double tightTracking = -0.6;
  static const double overlineTracking = 1.6;
  static const double buttonTracking = 0.2;
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
  static const double buttonRadius = 18;
  static const double cardRadius = 20;
  static const double chipRadius = 14;
  static const double segmentHeight = 44;
  static const double segmentRadius = 12;
  static const double segmentInset = 3;
  static const double tileMinHeight = 56;
  static const double iconButton = 44;
  static const double icon = 22;
  static const double iconSmall = 18;
  static const double hairline = 1;
  static const double maxContentWidth = 520;

  static const double orbDuel = 108;
  static const double orbHome = 176;
  static const double orbRingWidth = 2.5;
  static const double orbWaitDot = 10;
  static const double orbShapeFactor = 0.34;
  static const double orbGlowBlur = 36;
  static const double orbPulseTravel = 120;
  static const double orbPulseGrow = 1.9;

  static const double dot = 9;
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
}

/// Language-neutral glyphs used to join localized pieces.
abstract final class AppGlyphs {
  static const String separator = '  ·  ';
  static const String scoreDash = ' – ';
}

abstract final class AppMotion {
  static const Duration hapticGap = Duration(milliseconds: 120);

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
}
