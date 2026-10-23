#!/usr/bin/env python3
"""Check bundled fonts against every character used in lib/l10n/*.arb."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parents[1]
ARB_DIR = ROOT / "lib" / "l10n"
FONTS_DIR = ROOT / "assets" / "fonts"

def arb_strings() -> dict[str, set[str]]:
    by_locale: dict[str, set[str]] = {}
    for path in sorted(ARB_DIR.glob("app_*.arb")):
        if path.name.startswith("app_localizations"):
            continue
        data = json.loads(path.read_text())
        locale = data.get("@@locale", path.stem.replace("app_", ""))
        chars: set[str] = set()
        for key, value in data.items():
            if key.startswith("@") or not isinstance(value, str):
                continue
            chars.update(ch for ch in value if not ch.isspace())
        by_locale[locale] = chars
    return by_locale


def extra_chars() -> set[str]:
    extras = set("0123456789.,:;!?¿¡·–—−+×÷%/()[]'\"VS●")
    extras.update("POW!ARU SOFT")
    extras.update("EspañolPortuguês简体中文日本語DeutschFrançais한국어ItalianoTürkçeEnglish")
    extras.update("şŞğĞıİöÖüÜçÇßÄÖÜäöüœŒæÆãõñÑàâéèêëïîôùûÿ")
    return {ch for ch in extras if not ch.isspace()}


def cmap_of(path: Path) -> set[str]:
    font = TTFont(path)
    chars: set[str] = set()
    for table in font["cmap"].tables:
        chars.update(chr(cp) for cp in table.cmap if cp > 0)
    font.close()
    return chars


def main() -> int:
    locales = arb_strings()
    all_needed = extra_chars()
    for chars in locales.values():
        all_needed |= chars

    print(f"Locales: {', '.join(sorted(locales))}")
    print(f"Unique needed chars: {len(all_needed)}")
    latin = {ch for ch in all_needed if ord(ch) < 0x300 or 0x1E00 <= ord(ch) <= 0x1EFF}
    cjk = all_needed - latin
    print(f"  Latin-ish: {len(latin)}  other/CJK: {len(cjk)}")

    fonts = sorted(p for p in FONTS_DIR.glob("*.ttf"))
    if not fonts:
        print("No fonts found")
        return 1

    for font_path in fonts:
        covered = cmap_of(font_path)
        missing = sorted(all_needed - covered, key=ord)
        latin_missing = [ch for ch in missing if ch in latin]
        other_missing = [ch for ch in missing if ch not in latin]
        print(f"\n{font_path.name}  glyphs={len(covered)}  size={font_path.stat().st_size/1024:.0f}KB")
        if latin_missing:
            sample = " ".join(f"U+{ord(ch):04X}({ch})" for ch in latin_missing[:40])
            print(f"  MISSING Latin ({len(latin_missing)}): {sample}")
        else:
            print("  Latin: complete")
        if other_missing:
            print(f"  missing other: {len(other_missing)}")
        for locale, chars in sorted(locales.items()):
            miss = sorted(chars - covered, key=ord)
            if miss:
                shown = "".join(miss[:24])
                print(f"    {locale}: missing {len(miss)}  e.g. {shown!r}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
