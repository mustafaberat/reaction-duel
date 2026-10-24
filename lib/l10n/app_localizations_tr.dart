// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Reaction Rivals';

  @override
  String get homeTagline => 'Rengi bekle. İlk sen bas.';

  @override
  String homeRecord(int ms) {
    return 'Rekor $ms ms';
  }

  @override
  String homeMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maç',
    );
    return '$_temp0';
  }

  @override
  String get play => 'Oyna';

  @override
  String get settings => 'Ayarlar';

  @override
  String get howToPlay => 'Nasıl oynanır';

  @override
  String get back => 'Geri';

  @override
  String get setupTitle => 'Maç ayarları';

  @override
  String get setupMode => 'Mod';

  @override
  String get modeClassic => 'Klasik';

  @override
  String get modeTarget => 'Hedef Renk';

  @override
  String get modeClassicHint => 'Ortada BAS! yazıp yeşile döndüğü an bas.';

  @override
  String get modeTargetHint =>
      'Sadece kendi renginde, ● şeklinde bas. Diğer renk ve şekiller tuzak.';

  @override
  String get setupTargetColor => 'Hedef renk';

  @override
  String get setupColorBlindNote => 'Renk körü paleti · şekiller açık';

  @override
  String get setupWinScore => 'Kazanma skoru';

  @override
  String get setupWait => 'Bekleme süresi';

  @override
  String get waitShort => 'Kısa';

  @override
  String get waitNormal => 'Normal';

  @override
  String get waitLong => 'Uzun';

  @override
  String secondsRange(String min, String max) {
    return '$min–$max sn';
  }

  @override
  String get setupPenalty => 'Erken basma cezası';

  @override
  String get penaltyOpponent => 'Rakip +1';

  @override
  String get penaltySelf => 'Kendi −1';

  @override
  String get penaltyRound => 'Sadece tur';

  @override
  String get setupGuessGuard => 'Tahmin koruması';

  @override
  String get setupGuessGuardHint =>
      '80 ms altındaki dokunuşlar tahmin sayılır.';

  @override
  String get setupPlayers => 'Oyuncular';

  @override
  String get player1 => 'Oyuncu 1';

  @override
  String get player2 => 'Oyuncu 2';

  @override
  String get start => 'Başla';

  @override
  String get colorGreen => 'Yeşil';

  @override
  String get colorBlue => 'Mavi';

  @override
  String get colorYellow => 'Sarı';

  @override
  String get colorOrange => 'Turuncu';

  @override
  String get colorPink => 'Pembe';

  @override
  String get colorPurple => 'Mor';

  @override
  String get colorWhite => 'Beyaz';

  @override
  String get colorSky => 'Açık mavi';

  @override
  String get duelEarly => 'ERKEN!';

  @override
  String get duelGuess => 'TAHMİN!';

  @override
  String get duelDecoy => 'TUZAK!';

  @override
  String get duelTie => 'Berabere';

  @override
  String get duelTieSub => 'Tur tekrar';

  @override
  String get duelNoContest => 'Kimse basmadı';

  @override
  String get duelPlusOne => '+1';

  @override
  String get duelMinusOne => '−1';

  @override
  String get duelRoundLost => 'Tur kaybedildi';

  @override
  String duelMs(int ms) {
    return '$ms ms';
  }

  @override
  String get duelNoTime => '—';

  @override
  String get duelTarget => 'Hedef';

  @override
  String get duelCoach => 'BEKLE yazarken dokunma · BAS! çıkınca bas';

  @override
  String get duelWait => 'BEKLE';

  @override
  String get duelGo => 'BAS!';

  @override
  String get duelWinner => 'KAZANDI';

  @override
  String get duelTooSlow => 'GEÇ KALDI';

  @override
  String get duelRivalFoul => 'Rakip erken bastı';

  @override
  String get duelGuessSub => '80 ms\'den hızlı';

  @override
  String get duelPause => 'Duraklat';

  @override
  String get pauseTitle => 'Duraklatıldı';

  @override
  String get pauseResume => 'Devam';

  @override
  String get pauseRestart => 'Yeniden başlat';

  @override
  String get home => 'Ana sayfa';

  @override
  String endWinner(String name) {
    return '$name kazandı';
  }

  @override
  String get endBest => 'En iyi';

  @override
  String get endAverage => 'Ortalama';

  @override
  String get endFouls => 'Faul';

  @override
  String get endSeries => 'Seri';

  @override
  String get endNewRecord => 'Yeni rekor';

  @override
  String get endRematch => 'Rövanş';

  @override
  String get endChangeSettings => 'Ayarları değiştir';

  @override
  String get settingsGame => 'Oyun';

  @override
  String get settingsGeneral => 'Genel';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystem => 'Sistem dili';

  @override
  String get settingsColorBlind => 'Renk körü modu';

  @override
  String get settingsColorBlindHint =>
      'Renk körü dostu palet. Hedef Renk modunda şekiller hep açık.';

  @override
  String get settingsReduceMotion => 'Hareketi azalt';

  @override
  String get settingsAccessibility => 'Erişilebilirlik';

  @override
  String get motionSystem => 'Sistem';

  @override
  String get motionOn => 'Açık';

  @override
  String get motionOff => 'Kapalı';

  @override
  String get settingsShowTips => 'İlk oyun ipuçlarını tekrar göster';

  @override
  String get settingsTipsReset => 'İpuçları bir sonraki maçta görünecek.';

  @override
  String get settingsPrivacy => 'Gizlilik politikası';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get howStep1Title => 'Karşılıklı otur';

  @override
  String get howStep1Body =>
      'Telefonu aranıza koyun. Herkes kendi yarısına basar.';

  @override
  String get howStep2Title => 'Bekle';

  @override
  String get howStep2Body => 'Ortada BEKLE yazarken dokunma.';

  @override
  String get howStep3Title => 'BAS! = bas';

  @override
  String get howStep3Body => 'BAS! çıkınca ilk basan puanı alır.';

  @override
  String get howStep4Title => 'Erken basma';

  @override
  String get howStep4Body => 'Erken basarsan puan rakibe gider.';

  @override
  String get howStep5Title => 'Tuzak renkler';

  @override
  String get howStep5Body =>
      'Sadece kendi renginde, ● şeklinde bas. Diğer şekiller tuzak.';

  @override
  String get howNext => 'İleri';

  @override
  String get howSkip => 'Atla';

  @override
  String get howPlayNow => 'Şimdi oyna';

  @override
  String get howClose => 'Kapat';

  @override
  String howStepOf(int step, int total) {
    return '$step / $total';
  }
}
