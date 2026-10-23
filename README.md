# Reaction Rivals

Two-player reflex duel on one phone — ARU SOFT, `com.arusoft.reactionduel`. Spec: `rfc.md`; studio rules: `../lib/MOBILE_APP_RULES.md`.

## Run

```bash
APP_ROOT=. ../lib/scripts/run_web.sh       # web (Chrome, port 8080)
flutter run                                 # device
flutter test                                # engine + widget tests
flutter test tool/capture_design_shots.dart # design/shots/*.png (1080×2340)
```

## Layout

- `lib/engine/` — pure Dart state machine (`DuelEngine`, injectable `Clock` / `FakeClock`, seeded `Rng`, palette + OKLab/CVD distance).
- `lib/game/` — duel screen, `HalfPad` (`Listener.onPointerDown`), `SignalOrb`, pause / match-end overlays.
- `lib/screens/` — home, match setup, settings, how to play (live demo built from `DuelBoard`).
- `lib/config/` — `app_config.dart` (rules/timing, pure Dart), `tokens.dart`, `app_theme.dart`, `ad_config.dart`.
- `lib/services/` — settings / stats (SharedPreferences), ads (Google **test** ids only).
- `lib/l10n/` — gen-l10n ARBs for 10 locales.

## Phase 1 status

- Localization: `en` and `tr` complete. `es, pt, zh, ja, de, fr, ko, it` are **English copies** (keys complete, translation pending).
- Ads: Google test ids everywhere; real `ca-app-pub-1508520223269936/<TBD>` ids go in `lib/config/ad_config.dart`, `AndroidManifest.xml`, `gma_ad_services_config.xml`, iOS `Info.plist`.
- Fonts bundled: Baloo 2 + Nunito, plus Zen Maru Gothic / Jua / ZCOOL KuaiLe (OFL, `assets/fonts/`).
