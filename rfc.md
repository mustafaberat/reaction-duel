# RFC V1 — Reaction Duel

Aynı telefonda iki kişilik refleks düellosu. Backend yok, offline. Flutter, Android / iOS / web.

Kimlik: **Reaction Duel** (TR: **Refleks Düellosu**), ARU SOFT, `com.arusoft.reactionduel`.
Ortak kurallar: `lib/MOBILE_APP_RULES.md` (10 dil, Settings, How to play, onboarding, safe area, background pause).

---

## 1. Oyun özü

Ekran ikiye bölünür. Ortadaki işaret **hedef renge** dönünce ilk basan turu alır. Erken basan turu kaybeder. Hedef skora (varsayılan 3) ilk ulaşan maçı kazanır → tek tuşla **Rövanş**.

- Portrait sabit.
- Alt yarı = Oyuncu 1, üst yarı = Oyuncu 2 (UI 180° döndürülmüş, iki kişi karşılıklı oturur).
- Her yarının kendi skoru, adı/rengi ve son reaksiyon süresi (ms) vardır.

---

## 2. Ekran yerleşimi (tek oyun ekranı)

```
┌──────────────────────────┐
│  P2 skor ●●○   312 ms    │  ← 180° döndürülmüş
│                          │
│        P2 dokunma alanı  │
├──────────── ◯ ───────────┤  ← orta işaret (signal orb)
│        P1 dokunma alanı  │
│                          │
│  P1 skor ●○○   287 ms    │
└──────────────────────────┘
       [ ⏸ ]  (köşede küçük)
```

- Dokunma alanı = yarının tamamı (kenardan kenara). Skor/ms metinleri dokunmayı engellemez.
- Pause butonu küçük, köşede, iki yarının ortak sınırında değil (yanlış basmayı önle). Pause sırasında tur iptal edilir; devam edince yeni bekleme başlar.
- **Oyun ekranında banner yok** (bkz. §9).

### 2.1 Orta animasyon (signal orb)

Amaç: bekleme sırasında uygulama “donmuş” görünmesin. Sade, minimal, dikkat dağıtmayan.

| Durum | Görünüm |
|---|---|
| `ready` (tur arası) | Nötr gri halka, yavaş **nefes** (scale 0.96↔1.04, ~2.4 s periyot, easeInOut) |
| `waiting` (sinyal bekleniyor) | Aynı sakin nefes. Dönen yay yok (basılacak kontrol sanılıyor). İki yöne okunan **BEKLE** + dokunma ikonu |
| `signal` | Arka plan anında hedef renge geçer (fade yok). Ortada iki yöne **BAS!** — renk yetmez, yazı ve şekil de taşır |
| `decoy` (Hedef Renk modu) | Orb yanlış renge döner, yazı yok. Hedef ile tuzak **şekille** ayrılır (renk körü de oynar) |
| `scored` | Sonuç **aynı karede** görünür (giriş animasyonu bekletmez). Kazanan +1, ms, “kazandı” |
| `foul` | Erken basan yarı ~300 ms sallanır + kırmızı flaş + “ERKEN!”. Reduce Motion’da sadece flaş |

Kurallar:
- Animasyon ritmi **sinyalle senkron olmamalı** (nefes döngüsünün belli fazında sinyal gelirse oyuncu öğrenir). Sinyal zamanı nefesten bağımsız rastgele.
- Reduce Motion açıksa: nefes yerine statik halka + çok hafif opacity değişimi.
- Parçacık, konfeti, gradient şov yok. Konfeti sadece maç sonu overlay’de (kısa).

---

## 3. Tur akışı (state machine)

```
ready ──(cooldown biter)──▶ waiting ──(rastgele gecikme)──▶ signal ──(ilk geçerli dokunuş)──▶ scored ──▶ ready
                              │                               │
                              └──(dokunuş)──▶ foul ──▶ ready   └──(timeout)──▶ noContest ──▶ ready
```

| Adım | Kural | Varsayılan |
|---|---|---|
| sonuç bekleme | Skor anında görünür, ekranda kalır, input kilitli (konuşsunlar) | **2.2 s** |
| `waiting` | Sonra rastgele gecikme `uniform(min, max)`. Normal **2.0–3.5 s**, Kısa 1.2–2.5, Uzun 3.0–6.0. RNG her maçta gerçek rastgele (testler sabit seed) | **2.0 – 3.5 s** |
| `signal` timeout | Kimse basmazsa tur sayılmaz | **3.0 s** |
| Aynı gecikmeyi tekrar etme | Ardışık iki gecikme farkı ≥ 0.6 s (dar aralıkta ≥ 0.4 s) | — |

### 3.1 Dokunuş kuralları

- Sadece `PointerDown` sayılır (GestureDetector değil, `Listener` — gecikme ve tap-slop olmaz). Multi-touch: her yarı bağımsız.
- **Erken basma (foul):** `waiting` sırasında (veya `decoy` sırasında) yarıya dokunan → **rakip 1 puan** alır (varsayılan; §5’te değiştirilebilir).
- **Sinyalden önce parmak ekranda bekletme:** Sinyal anında zaten basılı olan parmak sayılmaz; sinyalden önce indiyse zaten foul’dur. Geçerli dokunuş = sinyal frame’inden **sonra** gelen yeni pointer down.
- **İki oyuncu da erken basarsa:** ilk basan foul’dur; ikinci dokunuş yok sayılır.
- **Eşitlik:** iki geçerli dokunuş farkı < 1 ms → kimse puan almaz, “Berabere” gösterilir, tur tekrarlanır.
- **İnsanüstü reaksiyon:** sinyalden < 80 ms içinde gelen dokunuş = tahmin; foul sayılır (ayar: açık varsayılan). Metin: “Çok erken — tahmin!”.

### 3.2 Zaman ölçümü

- Sinyal zamanı = hedef rengin çizildiği **ilk frame’in** zaman damgası (`SchedulerBinding.addPostFrameCallback` içinde `currentSystemFrameTimeStamp`).
- Dokunuş zamanı = `PointerDownEvent.timeStamp`. Reaksiyon = fark (ms, tam sayı).
- Ekranda gösterim: kazananın ms’i büyük, kaybedenin ms’i küçük (biri basmadıysa “—”).
- Ölçüm hassasiyeti ±1 frame; How to play’de iddia etme, sadece “ms” göster.

---

## 4. Modlar

### 4.1 Klasik

Nötr → **yeşil**. Tek sinyal, tuzak yok.

### 4.2 Hedef Renk modu (renk seçmeli)

Maç başında oyuncular **hangi renkte basılacağını seçer**. Orb sırayla başka renklere de dönebilir (tuzak). Sadece hedef renk gelince basılır. Tuzak renkte basmak = foul.

- Palet (6): Yeşil, Mavi, Sarı, Turuncu, Pembe, Mor. Kırmızı palet dışında (foul rengiyle karışır).
- Seçim: maç başı overlay’de renk çipleri; seçilen renk her iki yarının köşesinde küçük nokta olarak sürekli görünür (“Hedef: ●”).
- Tur içinde 0–3 tuzak, her biri 0.6–1.2 s görünür, sonra tekrar nötr; tuzak sonrası hedef sinyal en erken 0.8 s sonra.
- Tuzak renkleri hedef renge **algısal olarak uzak** seçilir (OKLab ΔE ≥ 0.15) — oyun “görme testi” değil, dikkat testi olsun.
- **Renk körü desteği** (Ayarlar): açıkken palet deuteranopia/protanopia’da ayırt edilebilir set ile değişir (mavi, sarı, beyaz, siyah-üstü-turuncu…) ve orb içine **şekil** eklenir (hedef = ● daire, tuzaklar = ▲ ■ ✚). Renk + şekil birlikte; şekil tek başına da yeterli.

### 4.3 (V2 adayları — V1’de yok)

- **Ses modu:** görsel yerine bip ile sinyal (erişilebilirlik).
- **Ters mod:** renk değişince **basma**, değişmezse 1 s içinde bas.
- **Turnuva:** 3–4 kişi, sırayla düello, bracket.

---

## 5. Maç ayarları (maç öncesi ekran)

Home → **Oyna** → Maç Ayarları (tek ekran, varsayılanlarla hemen “Başla” basılabilir). Son seçim kaydedilir.

| Ayar | Seçenekler | Varsayılan |
|---|---|---|
| Mod | Klasik / Hedef Renk | Klasik |
| Hedef renk | 6 renk (sadece Hedef Renk modunda) | Yeşil |
| Kazanma skoru | 1 / **3** / 5 / 7 / 10 | 3 |
| Bekleme süresi | Kısa (1.0–3.0 s) / **Normal** (1.8–5.0 s) / Uzun (3.0–8.0 s) | Normal |
| Erken basma cezası | **Rakip +1** / Kendi −1 (0’ın altına inmez) / Sadece tur kaybı | Rakip +1 |
| Tahmin koruması (< 80 ms) | Açık / Kapalı | Açık |
| Oyuncu adları | P1 / P2 düzenlenebilir (max 12 karakter) | “Oyuncu 1/2” |
| Oyuncu renkleri | Yarı vurgu rengi (hedef renkle çakışırsa otomatik değişir) | Lacivert / Bordo tonları |

“Maç ayarları”ndaki değerler `SharedPreferences` ile saklanır.

---

## 6. Maç sonu ve rövanş döngüsü

Hedef skora ulaşan kazanır. Overlay (iki yarıya da yönlü yazı):

- **Kazanan** adı + skor (3–1)
- Maç istatistikleri: her oyuncu için **en iyi ms**, **ortalama ms**, foul sayısı
- Butonlar: **Rövanş** (büyük, ortada), Ayarları değiştir, Ana sayfa
- Rövanş = aynı ayarlarla skor sıfır, kısa 3-2-1 sayacı yok; direkt `ready` (cooldown) ile başlar.
- Oturum skoru: aynı oturumda kaç maç kim aldı (“Seri: P1 2 – 1 P2”). Ana sayfaya dönünce sıfırlanır.

Kalıcı kayıt (local): tüm zamanların en iyi reaksiyonu (cihaz rekoru), toplam maç sayısı.

---

## 7. How to play (oyun içi)

Ayrı metin sayfası değil; oyun ekranının **canlı mini demosu**. Ayarlar’dan ve Home’daki “?” ikonundan açılır, ilk açılışta otomatik (skip edilebilir).

4 adım, her biri gerçek oyun bileşenleriyle animasyonlu, alt kısımda tek cümle + “İleri”:

1. **Karşılıklı otur.** Telefon masada; iki yarı vurgulanır, üst yarı döner. — “Telefonu aranıza koyun. Herkes kendi yarısına basar.”
2. **Bekle.** Orb nefes alır, el ikonu bekler. — “Ortadaki daire gri iken dokunma.”
3. **Yeşil = bas!** Orb yeşile döner, el ikonu basar, “+1” ve “243 ms”. — “Renk değişince ilk basan puanı alır.”
4. **Erken basma.** El ikonu griyken basar, “Erken!” titreşimi, rakibe +1. — “Erken basarsan puan rakibe gider.”
5. *(Sadece Hedef Renk modu seçiliyse)* **Tuzak renkler.** Orb maviye döner, el basmaz; sonra hedef renk → bas. — “Sadece seçtiğin renkte bas.”

Son adımda: **Şimdi oyna** (maç ayarlarına) ve **Kapat**.

### 7.1 İlk oyun onboarding

İlk maçın ilk turunda yarılarda tek seferlik soluk ipucu: “Gri iken bekle · Renk değişince bas”. İlk geçerli puandan sonra kaybolur. `onboarding_done` bayrağı.

---

## 8. Ekranlar

| Ekran | İçerik |
|---|---|
| **Home** | Logo/ad, nefes alan orb (oyun ekranıyla aynı bileşen), **Oyna**, Ayarlar, “?” How to play. Altta banner |
| **Maç ayarları** | §5 tablosu, “Başla” |
| **Oyun** | §2 |
| **Pause** | Devam, Yeniden başlat, Ana sayfa (iki yöne okunur) |
| **Maç sonu** | §6 |
| **Ayarlar** | Dil (10), ses, titreşim, renk körü modu, Reduce Motion (sistem değerine saygı + override), How to play, gizlilik politikası, sürüm |

Ses: sinyal anında **ses yok** — oyun görsel; ses açık/kapalı ayarı oyunun zorluğunu değiştirmesin. Puan ve foul’da kısa tık sesi. Titreşim: puan alan yarıda kısa, foul’da çift kısa.

---

## 9. Reklam (AdMob)

Publisher: **ARU Soft**, `pub-1508520223269936`, giriş `arusoft.company@gmail.com` (bkz. `lib/admob/account.json`).

AdMob uygulaması ve ad unit’ler **yeni oluşturulacak** (Click Battle’ın unit ID’leri bu pakette kullanılmaz; app ID pakete bağlıdır). Oluşturunca `lib/admob/account.json` → `apps[]` içine eklenir.

| Unit | Tür | Yerleşim | ID |
|---|---|---|---|
| `home_banner` | Banner (adaptive) | Home alt kısmı | `ca-app-pub-1508520223269936/<TBD>` |
| `match_end_interstitial` | Interstitial | Maç sonu → **Ana sayfa** veya **Ayarları değiştir** | `ca-app-pub-1508520223269936/<TBD>` |
| AdMob App ID | — | `AndroidManifest.xml` + `gma_ad_services_config.xml` + iOS `Info.plist` | `ca-app-pub-1508520223269936~<TBD>` |

Geliştirmede Google test ID’leri (banner `ca-app-pub-3940256099942544/6300978111`, interstitial `ca-app-pub-3940256099942544/1033173712`, app `ca-app-pub-3940256099942544~3347511713`). Release build’de config’ten gerçek ID; ikisi `lib/config/ad_config.dart` içinde `kReleaseMode` ile seçilir.

Kurallar:
- **Oyun ekranında, maç ayarlarında ve maç sonu overlay’inde banner yok.** Tüm ekran dokunma alanı → yanlış tıklama = AdMob politika ihlali.
- **Rövanş butonu reklam göstermez** (ana döngü kesilmesin).
- Interstitial frekans sınırı: en fazla **3 maçta 1** ve en az **90 s** arayla; ilk oturumun ilk maçında hiç yok.
- Interstitial yüklenmezse beklemeden devam (Click Battle `AdService.showGameoverHomeButtonFullScreenAd` deseni: 1 s yükleme denemesi + 5 s timeout).
- `FLUTTER_TEST` ortamında MobileAds başlatılmaz (Click Battle ile aynı).
- Aile / çocuk politikası: içerik “Everyone”; kişiselleştirilmemiş reklam isteğine uygun UMP onay akışı.

---

## 10. Kod yapısı

```
lib/
  main.dart
  app.dart
  config/
    app_config.dart        # cooldown, gecikme aralıkları, timeout, 80 ms eşiği, palet
    ad_config.dart
  engine/
    duel_engine.dart       # saf Dart state machine (Flutter import yok)
    duel_state.dart
    duel_settings.dart
    clock.dart             # Clock arayüzü; test için FakeClock
    rng.dart               # seed’lenebilir Random
  game/
    duel_screen.dart
    half_pad.dart          # Listener + yönlü skor
    signal_orb.dart        # §2.1 animasyon
    match_end_overlay.dart
  screens/
    home_screen.dart
    match_setup_screen.dart
    settings_screen.dart
    how_to_play_screen.dart
  services/
    ad_service.dart
    settings_service.dart
    stats_service.dart
  l10n/ app_*.arb          # 10 dil
```

- Ekranda magic number / ham string yok; sabitler `config/`, metinler ARB.
- Motor saf ve test edilebilir: `FakeClock` + seed’li RNG ile foul, eşitlik, timeout, < 80 ms, ardışık gecikme kuralı, cooldown kilidi unit test edilir.
- Background’a geçince (`AppLifecycleState.paused`) tur iptal, pause ekranı açılır.

---

## 11. Mağaza

- Kısa açıklama (EN): “Wait for the color, tap first. Two-player reflex duel on one phone.”
- Kısa açıklama (TR): “Rengi bekle, ilk sen bas. Tek telefonda iki kişilik refleks düellosu.”
- Headline (`MOBILE_APP_RULES.md` §7’ye eklenecek): EN **REACT FIRST** / TR **İLK SEN BAS**.
- `{ACCENT_COLOR}`: sinyal yeşili `#2ECC71`.
- `{GAME_UI_DESCRIPTION}`: “split-screen two-player layout, a minimal glowing circle in the center turning bright green, scores as dots on each half, reaction time in milliseconds”.

---

## 12. Kabul checklist

- [ ] Klasik mod: sinyal → ilk basan +1, ms doğru gösterilir
- [ ] Erken basma → seçili cezaya göre puan
- [ ] Cooldown içinde input kilitli; sinyal pes peşe gelmez
- [ ] Hedef Renk modu: tuzakta basma = foul, hedefte basma = puan; renk körü modunda şekil görünür
- [ ] Kazanma skoru 1/3/5/7/10 çalışır; maç sonu → Rövanş tek dokunuş
- [ ] < 80 ms tahmin koruması, eşitlik tekrarı
- [ ] Orb animasyonu sinyal zamanını ele vermez; Reduce Motion
- [ ] Oyun ekranında reklam yok; interstitial frekans sınırı
- [ ] `MOBILE_APP_RULES.md` §8 checklist (10 dil, Settings, How to play, onboarding, background pause, safe area)
