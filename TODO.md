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

## APK boyutu
- [ ] Release APK ~57 MB, biraz küçültülmeli (şimdilik değil):
  - Evrensel APK 3 ABI içeriyor (armeabi-v7a, arm64-v8a, x86_64); test için `flutter build apk --release --split-per-abi` ile her biri ~18–20 MB olur. Play'e zaten AAB gidiyor (ABI'ye göre bölünür).
  - En büyük fontlar: ZenMaruGothic-Bold ~3.5 MB, Jua ~2.1 MB, ZCOOLKuaiLe ~1.5 MB (ja/ko/zh için); yalnızca kullanılan karakterlere alt küme (subset) yap veya gerekmeyen ağırlıkları çıkar.
  - `play/` görselleri pakete girmiyor, sorun değil; `assets/` altını kontrol et.

## Android release açılış hatası (çözüldü)
- [x] Release APK splash'te takılıyordu: R8, shared_preferences_android 2.5.x'in JNI ile çağrılan Kotlin metodlarını (ve kotlin.coroutines sınıflarını) siliyordu → `SharedPreferences.getInstance` NoSuchMethodError → `runApp` hiç çalışmıyordu. Ayrıca WorkManager `WorkDatabase` (google_mobile_ads) R8 yüzünden açılışta çöküyordu. `android/app/proguard-rules.pro` keep kuralları + `lib/app.dart` `bootstrap()` başlangıç korumaları (hata/zaman aşımı runApp'i engellemez; prefs açılamazsa bellek içi varsayılanlarla açılır).
