# Reaction Rivals — Yapılacaklar

## En iyi skor
- [x] En iyi skor (en hızlı tepki süresi, ms) şu an cihazda yerel tutuluyor:
  - SharedPreferences anahtarı: `stats_best_ms` (`PrefsKeys.bestReactionMs`); toplam maç: `stats_total_matches`
  - Kayıt: `lib/services/stats_service.dart` → `StatsService.recordMatch()` (maç sonunda, yeni rekor varsa)
  - Okuma: `StatsService` kurucusu; ana ekran `lib/screens/home_screen.dart` içindeki `_StatsLine` widget'ı `stats.bestMs` ile gösteriyor.
- [ ] İleride en iyi skorun veritabanından alınması planlanıyor (şimdilik veritabanı/backend bağlantısı yok).

## Ses ve titreşim
- [x] Ses ve titreşim tamamen kaldırıldı:
  - `FeedbackService` (tık sesi, puan/faul titreşimi, sinyal titreşimi) ve `AppServices.feedback` silindi; düello ekranındaki çağrılar kaldırıldı.
  - Ayarlardan "Ses", "Titreşim" ve "Titreşimli sinyal" seçenekleri, SharedPreferences anahtarları (`sound`, `haptics`, `signal_vibration`) ve ilgili çeviriler kaldırıldı.
