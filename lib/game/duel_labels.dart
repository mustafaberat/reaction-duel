/// Localized names for engine enums.
library;

import '../engine/duel_settings.dart';
import '../engine/signal_palette.dart';
import '../l10n/app_localizations.dart';

extension SignalColorName on SignalColor {
  String label(AppLocalizations l10n) => switch (this) {
    SignalColor.green => l10n.colorGreen,
    SignalColor.blue || SignalColor.cbBlue => l10n.colorBlue,
    SignalColor.yellow || SignalColor.cbYellow => l10n.colorYellow,
    SignalColor.orange || SignalColor.cbOrange => l10n.colorOrange,
    SignalColor.pink => l10n.colorPink,
    SignalColor.purple => l10n.colorPurple,
    SignalColor.cbWhite => l10n.colorWhite,
    SignalColor.cbSky => l10n.colorSky,
  };
}

extension WaitPresetName on WaitPreset {
  String label(AppLocalizations l10n) => switch (this) {
    WaitPreset.short => l10n.waitShort,
    WaitPreset.normal => l10n.waitNormal,
    WaitPreset.long => l10n.waitLong,
  };
}

extension FoulPenaltyName on FoulPenalty {
  String label(AppLocalizations l10n) => switch (this) {
    FoulPenalty.opponentPlusOne => l10n.penaltyOpponent,
    FoulPenalty.selfMinusOne => l10n.penaltySelf,
    FoulPenalty.roundLossOnly => l10n.penaltyRound,
  };
}
