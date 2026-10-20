/// Signal colors, OKLab distance and red-green CVD simulation (pure Dart).
library;

import 'dart:math' as math;

import '../config/app_config.dart';

enum SignalColor {
  green(PaletteArgb.green),
  blue(PaletteArgb.blue),
  yellow(PaletteArgb.yellow),
  orange(PaletteArgb.orange),
  pink(PaletteArgb.pink),
  purple(PaletteArgb.purple),
  cbBlue(PaletteArgb.cbBlue),
  cbYellow(PaletteArgb.cbYellow),
  cbWhite(PaletteArgb.cbWhite),
  cbOrange(PaletteArgb.cbOrange),
  cbSky(PaletteArgb.cbSky);

  const SignalColor(this.argb);

  final int argb;
}

/// Shape drawn inside a filled orb: the signal is always ● and decoys are
/// ▲ ■ ✕ (`cross` is drawn diagonally), so no state relies on color alone.
enum SignalShape { circle, triangle, square, cross }

abstract final class SignalPalette {
  static const List<SignalColor> standard = [
    SignalColor.green,
    SignalColor.blue,
    SignalColor.yellow,
    SignalColor.orange,
    SignalColor.pink,
    SignalColor.purple,
  ];

  static const List<SignalColor> colorBlind = [
    SignalColor.cbBlue,
    SignalColor.cbYellow,
    SignalColor.cbWhite,
    SignalColor.cbOrange,
    SignalColor.cbSky,
  ];

  static const List<SignalShape> decoyShapes = [
    SignalShape.triangle,
    SignalShape.square,
    SignalShape.cross,
  ];

  static List<SignalColor> forMode({required bool colorBlind}) =>
      colorBlind ? SignalPalette.colorBlind : standard;

  static const Map<SignalColor, SignalColor> _toColorBlind = {
    SignalColor.green: SignalColor.cbSky,
    SignalColor.blue: SignalColor.cbBlue,
    SignalColor.yellow: SignalColor.cbYellow,
    SignalColor.orange: SignalColor.cbOrange,
    SignalColor.pink: SignalColor.cbWhite,
    SignalColor.purple: SignalColor.cbBlue,
  };

  static const Map<SignalColor, SignalColor> _toStandard = {
    SignalColor.cbSky: SignalColor.green,
    SignalColor.cbBlue: SignalColor.blue,
    SignalColor.cbYellow: SignalColor.yellow,
    SignalColor.cbOrange: SignalColor.orange,
    SignalColor.cbWhite: SignalColor.pink,
  };

  /// Maps a stored target onto the active palette (closest counterpart).
  static SignalColor resolveTarget(SignalColor target, {required bool colorBlind}) {
    final palette = forMode(colorBlind: colorBlind);
    if (palette.contains(target)) return target;
    final mapped = colorBlind ? _toColorBlind[target] : _toStandard[target];
    return mapped ?? palette.first;
  }

  /// Perceptual distance; in color-blind mode the worst case of deutan/protan.
  static double distance(SignalColor a, SignalColor b, {required bool colorBlind}) {
    final ra = _Rgb.fromArgb(a.argb);
    final rb = _Rgb.fromArgb(b.argb);
    if (!colorBlind) return _oklabDistance(ra, rb);
    return math.min(
      _oklabDistance(_simulate(ra, _deutan), _simulate(rb, _deutan)),
      _oklabDistance(_simulate(ra, _protan), _simulate(rb, _protan)),
    );
  }

  /// Palette colors far enough from [target] to be used as decoys.
  static List<SignalColor> decoysFor(SignalColor target, {required bool colorBlind}) {
    final palette = forMode(colorBlind: colorBlind);
    final far = [
      for (final c in palette)
        if (c != target &&
            distance(c, target, colorBlind: colorBlind) >= GameRules.decoyMinDistance)
          c,
    ];
    if (far.isNotEmpty) return far;
    final rest = [...palette]..remove(target);
    rest.sort(
      (a, b) => distance(
        b,
        target,
        colorBlind: colorBlind,
      ).compareTo(distance(a, target, colorBlind: colorBlind)),
    );
    return rest.take(1).toList();
  }
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  factory _Rgb.fromArgb(int argb) =>
      _Rgb(((argb >> 16) & 0xFF) / 255.0, ((argb >> 8) & 0xFF) / 255.0, (argb & 0xFF) / 255.0);

  final double r;
  final double g;
  final double b;
}

double _linearize(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _delinearize(double c) =>
    c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;

double _cbrt(double v) => v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();

List<double> _oklab(_Rgb c) {
  final r = _linearize(c.r);
  final g = _linearize(c.g);
  final b = _linearize(c.b);
  final l = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  final m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  final s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  return [
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  ];
}

double _oklabDistance(_Rgb a, _Rgb b) {
  final la = _oklab(a);
  final lb = _oklab(b);
  final dl = la[0] - lb[0];
  final da = la[1] - lb[1];
  final db = la[2] - lb[2];
  return math.sqrt(dl * dl + da * da + db * db);
}

// Machado, Oliveira, Fernandes 2009 — full dichromacy, linear sRGB.
const List<double> _deutan = [
  0.367322, 0.860646, -0.227968, //
  0.280085, 0.672501, 0.047413, //
  -0.011820, 0.042940, 0.968881,
];
const List<double> _protan = [
  0.152286, 1.052583, -0.204868, //
  0.114503, 0.786281, 0.099216, //
  -0.003882, -0.048116, 1.051998,
];

_Rgb _simulate(_Rgb c, List<double> m) {
  final r = _linearize(c.r);
  final g = _linearize(c.g);
  final b = _linearize(c.b);
  double out(int row) =>
      _delinearize((m[row] * r + m[row + 1] * g + m[row + 2] * b).clamp(0.0, 1.0));
  return _Rgb(out(0), out(3), out(6));
}
