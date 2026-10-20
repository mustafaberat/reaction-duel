import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Reaction Duel'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Wait for the color. Tap first.'**
  String get homeTagline;

  /// No description provided for @homeRecord.
  ///
  /// In en, this message translates to:
  /// **'Best {ms} ms'**
  String homeRecord(int ms);

  /// No description provided for @homeMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String homeMatches(int count);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Match setup'**
  String get setupTitle;

  /// No description provided for @setupMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get setupMode;

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassic;

  /// No description provided for @modeTarget.
  ///
  /// In en, this message translates to:
  /// **'Target Color'**
  String get modeTarget;

  /// No description provided for @modeClassicHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the moment the center says GO! and turns green.'**
  String get modeClassicHint;

  /// No description provided for @modeTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap only on your color, shown with the ● shape. Other colors and shapes are traps.'**
  String get modeTargetHint;

  /// No description provided for @setupTargetColor.
  ///
  /// In en, this message translates to:
  /// **'Target color'**
  String get setupTargetColor;

  /// No description provided for @setupColorBlindNote.
  ///
  /// In en, this message translates to:
  /// **'Color-blind palette · shapes on'**
  String get setupColorBlindNote;

  /// No description provided for @setupWinScore.
  ///
  /// In en, this message translates to:
  /// **'Points to win'**
  String get setupWinScore;

  /// No description provided for @setupWait.
  ///
  /// In en, this message translates to:
  /// **'Wait time'**
  String get setupWait;

  /// No description provided for @waitShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get waitShort;

  /// No description provided for @waitNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get waitNormal;

  /// No description provided for @waitLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get waitLong;

  /// No description provided for @secondsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} s'**
  String secondsRange(String min, String max);

  /// No description provided for @setupPenalty.
  ///
  /// In en, this message translates to:
  /// **'Early tap penalty'**
  String get setupPenalty;

  /// No description provided for @penaltyOpponent.
  ///
  /// In en, this message translates to:
  /// **'Rival +1'**
  String get penaltyOpponent;

  /// No description provided for @penaltySelf.
  ///
  /// In en, this message translates to:
  /// **'Self −1'**
  String get penaltySelf;

  /// No description provided for @penaltyRound.
  ///
  /// In en, this message translates to:
  /// **'Round only'**
  String get penaltyRound;

  /// No description provided for @setupGuessGuard.
  ///
  /// In en, this message translates to:
  /// **'Anticipation guard'**
  String get setupGuessGuard;

  /// No description provided for @setupGuessGuardHint.
  ///
  /// In en, this message translates to:
  /// **'Taps under 80 ms count as a guess.'**
  String get setupGuessGuardHint;

  /// No description provided for @setupPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get setupPlayers;

  /// No description provided for @player1.
  ///
  /// In en, this message translates to:
  /// **'Player 1'**
  String get player1;

  /// No description provided for @player2.
  ///
  /// In en, this message translates to:
  /// **'Player 2'**
  String get player2;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @duelEarly.
  ///
  /// In en, this message translates to:
  /// **'TOO EARLY!'**
  String get duelEarly;

  /// No description provided for @duelGuess.
  ///
  /// In en, this message translates to:
  /// **'GUESS!'**
  String get duelGuess;

  /// No description provided for @duelDecoy.
  ///
  /// In en, this message translates to:
  /// **'DECOY!'**
  String get duelDecoy;

  /// No description provided for @duelTie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get duelTie;

  /// No description provided for @duelTieSub.
  ///
  /// In en, this message translates to:
  /// **'Replay the round'**
  String get duelTieSub;

  /// No description provided for @duelNoContest.
  ///
  /// In en, this message translates to:
  /// **'No one tapped'**
  String get duelNoContest;

  /// No description provided for @duelPlusOne.
  ///
  /// In en, this message translates to:
  /// **'+1'**
  String get duelPlusOne;

  /// No description provided for @duelMinusOne.
  ///
  /// In en, this message translates to:
  /// **'−1'**
  String get duelMinusOne;

  /// No description provided for @duelRoundLost.
  ///
  /// In en, this message translates to:
  /// **'Round lost'**
  String get duelRoundLost;

  /// No description provided for @duelMs.
  ///
  /// In en, this message translates to:
  /// **'{ms} ms'**
  String duelMs(int ms);

  /// No description provided for @duelNoTime.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get duelNoTime;

  /// No description provided for @duelTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get duelTarget;

  /// No description provided for @duelCoach.
  ///
  /// In en, this message translates to:
  /// **'Don\'t tap on WAIT · Tap on GO!'**
  String get duelCoach;

  /// No description provided for @duelWait.
  ///
  /// In en, this message translates to:
  /// **'WAIT'**
  String get duelWait;

  /// No description provided for @duelGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get duelGo;

  /// No description provided for @duelWinner.
  ///
  /// In en, this message translates to:
  /// **'WINNER'**
  String get duelWinner;

  /// No description provided for @duelTooSlow.
  ///
  /// In en, this message translates to:
  /// **'TOO SLOW'**
  String get duelTooSlow;

  /// No description provided for @duelRivalFoul.
  ///
  /// In en, this message translates to:
  /// **'Rival tapped early'**
  String get duelRivalFoul;

  /// No description provided for @duelGuessSub.
  ///
  /// In en, this message translates to:
  /// **'Faster than 80 ms'**
  String get duelGuessSub;

  /// No description provided for @duelPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get duelPause;

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pauseResume;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get pauseRestart;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @endWinner.
  ///
  /// In en, this message translates to:
  /// **'{name} wins'**
  String endWinner(String name);

  /// No description provided for @endBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get endBest;

  /// No description provided for @endAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get endAverage;

  /// No description provided for @endFouls.
  ///
  /// In en, this message translates to:
  /// **'Fouls'**
  String get endFouls;

  /// No description provided for @endSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get endSeries;

  /// No description provided for @endNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New device record'**
  String get endNewRecord;

  /// No description provided for @endRematch.
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get endRematch;

  /// No description provided for @endChangeSettings.
  ///
  /// In en, this message translates to:
  /// **'Change settings'**
  String get endChangeSettings;

  /// No description provided for @settingsGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get settingsGame;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsColorBlind.
  ///
  /// In en, this message translates to:
  /// **'Color-blind mode'**
  String get settingsColorBlind;

  /// No description provided for @settingsColorBlindHint.
  ///
  /// In en, this message translates to:
  /// **'Color-blind safe palette. Target Color always shows shapes.'**
  String get settingsColorBlindHint;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @motionSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get motionSystem;

  /// No description provided for @motionOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get motionOn;

  /// No description provided for @motionOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get motionOff;

  /// No description provided for @settingsShowTips.
  ///
  /// In en, this message translates to:
  /// **'Show first-game tips again'**
  String get settingsShowTips;

  /// No description provided for @settingsTipsReset.
  ///
  /// In en, this message translates to:
  /// **'Tips will show in your next match.'**
  String get settingsTipsReset;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @howStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Sit face to face'**
  String get howStep1Title;

  /// No description provided for @howStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Put the phone between you. Each player taps their own half.'**
  String get howStep1Body;

  /// No description provided for @howStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get howStep2Title;

  /// No description provided for @howStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Don\'t touch while the center says WAIT.'**
  String get howStep2Body;

  /// No description provided for @howStep3Title.
  ///
  /// In en, this message translates to:
  /// **'GO! means tap'**
  String get howStep3Title;

  /// No description provided for @howStep3Body.
  ///
  /// In en, this message translates to:
  /// **'When GO! appears, the first tap wins the point.'**
  String get howStep3Body;

  /// No description provided for @howStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Don\'t jump the gun'**
  String get howStep4Title;

  /// No description provided for @howStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Tap too early and the point goes to your rival.'**
  String get howStep4Body;

  /// No description provided for @howStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Decoy colors'**
  String get howStep5Title;

  /// No description provided for @howStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Only tap on your color — the ● shape. Other shapes are traps.'**
  String get howStep5Body;

  /// No description provided for @howNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get howNext;

  /// No description provided for @howSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get howSkip;

  /// No description provided for @howPlayNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get howPlayNow;

  /// No description provided for @howClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get howClose;

  /// No description provided for @howStepOf.
  ///
  /// In en, this message translates to:
  /// **'{step} / {total}'**
  String howStepOf(int step, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
