#!/usr/bin/env python3
"""Download OFL theme fonts, instantiate weights, subset CJK, write assets/fonts."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "fonts"
ARB_DIR = ROOT / "lib" / "l10n"
RAW = "https://raw.githubusercontent.com/google/fonts/main/ofl"

DOWNLOADS = {
    "Baloo2[wght].ttf": f"{RAW}/baloo2/Baloo2%5Bwght%5D.ttf",
    "Nunito[wght].ttf": f"{RAW}/nunito/Nunito%5Bwght%5D.ttf",
    "ZenMaruGothic-Bold.ttf": f"{RAW}/zenmarugothic/ZenMaruGothic-Bold.ttf",
    "Jua-Regular.ttf": f"{RAW}/jua/Jua-Regular.ttf",
    "ZCOOLKuaiLe-Regular.ttf": f"{RAW}/zcoolkuaile/ZCOOLKuaiLe-Regular.ttf",
    "OFL-Baloo2.txt": f"{RAW}/baloo2/OFL.txt",
    "OFL-Nunito.txt": f"{RAW}/nunito/OFL.txt",
    "OFL-Jua.txt": f"{RAW}/jua/OFL.txt",
    "OFL-ZCOOLKuaiLe.txt": f"{RAW}/zcoolkuaile/OFL.txt",
    "OFL-ZenMaruGothic.txt": f"{RAW}/zenmarugothic/OFL.txt",
}


def arb_chars() -> set[str]:
    chars: set[str] = set()
    for path in ARB_DIR.glob("app_*.arb"):
        if path.name.startswith("app_localizations"):
            continue
        data = json.loads(path.read_text())
        for key, value in data.items():
            if key.startswith("@") or not isinstance(value, str):
                continue
            chars.update(value)
    extras = (
        "VS POW! ARU SOFT 0123456789.,:;!?¿¡·–—−+×÷%/()[]'\""
        "EspañolPortuguês简体中文日本語DeutschFrançais한국어ItalianoTürkçeEnglish"
        "şŞğĞıİöÖüÜçÇßÄÖÜäöüœŒæÆàâéèêëïîôùûÿçÀÂÉÈÊËÏÎÔÙÛŸÇ"
        "ãõáéíóúâêôàÃÕÁÉÍÓÚÂÊÔÀñÑ●"
    )
    chars.update(extras)
    chars.update(" \t\n")
    return chars


def decode_dbcs(encoding: str) -> set[int]:
    cps: set[int] = set()
    for b1 in range(0xA1, 0xFF):
        for b2 in range(0xA1, 0xFF):
            try:
                text = bytes([b1, b2]).decode(encoding)
            except UnicodeDecodeError:
                continue
            cps.update(ord(ch) for ch in text if ch != "\ufffd")
    return cps


def latin_cps() -> set[int]:
    cps = set(range(0x20, 0x7F))
    cps.update(range(0xA0, 0x250))  # Latin-1 + Extended-A
    cps.update(range(0x1E00, 0x1F00))  # Latin Extended Additional
    cps.update({0x2013, 0x2014, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2026, 0x2212, 0x25CF})
    return cps


def cjk_sets() -> dict[str, set[int]]:
    arb = {ord(ch) for ch in arb_chars()}
    latin = latin_cps()
    # JIS X 0208 via EUC-JP + kana
    ja = decode_dbcs("euc_jp") | set(range(0x3040, 0x30A0)) | set(range(0x30A0, 0x3100)) | set(range(0xFF00, 0xFFEF))
    # KS X 1001 via EUC-KR
    ko = decode_dbcs("euc_kr") | set(range(0x1100, 0x1200)) | set(range(0x3130, 0x3190))
    # GB2312
    zh = decode_dbcs("gb2312") | set(range(0x3000, 0x3040)) | set(range(0xFF00, 0xFFEF))
    return {
        "ja": ja | arb | latin,
        "ko": ko | arb | latin,
        "zh": zh | arb | latin,
    }


def download(url: str, dest: Path) -> None:
    print(f"  get {dest.name}")
    req = urllib.request.Request(url, headers={"User-Agent": "reaction-rivals-kids-font-prep"})
    with urllib.request.urlopen(req, timeout=120) as resp, dest.open("wb") as out:
        shutil.copyfileobj(resp, out)


def instantiate(src: Path, dest: Path, axes: dict[str, float]) -> None:
    font = TTFont(src)
    inst = instantiateVariableFont(font, axes, overlap=True)
    inst.save(dest)
    font.close()
    print(f"  instanced {dest.name} ({dest.stat().st_size / 1024:.0f} KB)")


def subset(src: Path, dest: Path, unicodes: set[int]) -> None:
    uni_file = src.with_suffix(".unicodes.txt")
    uni_file.write_text(",".join(f"U+{cp:04X}" for cp in sorted(unicodes)))
    cmd = [
        sys.executable,
        "-m",
        "fontTools.subset",
        str(src),
        f"--unicodes-file={uni_file}",
        f"--output-file={dest}",
        "--layout-features=*",
        "--glyph-names",
        "--symbol-cmap",
        "--legacy-cmap",
        "--notdef-glyph",
        "--notdef-outline",
        "--recommended-glyphs",
        "--name-IDs=*",
        "--name-legacy",
        "--name-languages=*",
        "--drop-tables+=",
    ]
    subprocess.check_call(cmd)
    uni_file.unlink(missing_ok=True)
    print(f"  subset {dest.name} ({dest.stat().st_size / 1024:.0f} KB) from {src.stat().st_size / 1024:.0f} KB")


def cmap(path: Path) -> set[str]:
    font = TTFont(path)
    chars: set[str] = set()
    for table in font["cmap"].tables:
        chars.update(chr(cp) for cp in table.cmap if cp > 0)
    font.close()
    return chars


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        for name, url in DOWNLOADS.items():
            download(url, tmp_path / name)

        instantiate(tmp_path / "Baloo2[wght].ttf", tmp_path / "Baloo2-Bold.ttf", {"wght": 700})
        instantiate(tmp_path / "Baloo2[wght].ttf", tmp_path / "Baloo2-ExtraBold.ttf", {"wght": 800})
        instantiate(tmp_path / "Nunito[wght].ttf", tmp_path / "Nunito-Regular.ttf", {"wght": 400})
        instantiate(tmp_path / "Nunito[wght].ttf", tmp_path / "Nunito-SemiBold.ttf", {"wght": 600})
        instantiate(tmp_path / "Nunito[wght].ttf", tmp_path / "Nunito-Bold.ttf", {"wght": 700})

        latin = latin_cps() | {ord(ch) for ch in arb_chars()}
        for name in [
            "Baloo2-Bold.ttf",
            "Baloo2-ExtraBold.ttf",
            "Nunito-Regular.ttf",
            "Nunito-SemiBold.ttf",
            "Nunito-Bold.ttf",
        ]:
            subset(tmp_path / name, tmp_path / f"{Path(name).stem}.subset.ttf", latin)
            shutil.move(tmp_path / f"{Path(name).stem}.subset.ttf", tmp_path / name)

        sets = cjk_sets()
        subset(tmp_path / "ZenMaruGothic-Bold.ttf", tmp_path / "ZenMaruGothic-Bold.subset.ttf", sets["ja"])
        subset(tmp_path / "Jua-Regular.ttf", tmp_path / "Jua-Regular.subset.ttf", sets["ko"])
        subset(tmp_path / "ZCOOLKuaiLe-Regular.ttf", tmp_path / "ZCOOLKuaiLe-Regular.subset.ttf", sets["zh"])

        keep = [
            "Baloo2-Bold.ttf",
            "Baloo2-ExtraBold.ttf",
            "Nunito-Regular.ttf",
            "Nunito-SemiBold.ttf",
            "Nunito-Bold.ttf",
            "OFL-Baloo2.txt",
            "OFL-Nunito.txt",
            "OFL-Jua.txt",
            "OFL-ZCOOLKuaiLe.txt",
            "OFL-ZenMaruGothic.txt",
        ]
        for name in keep:
            shutil.copy2(tmp_path / name, OUT / name)
        shutil.copy2(tmp_path / "ZenMaruGothic-Bold.subset.ttf", OUT / "ZenMaruGothic-Bold.ttf")
        shutil.copy2(tmp_path / "Jua-Regular.subset.ttf", OUT / "Jua-Regular.ttf")
        shutil.copy2(tmp_path / "ZCOOLKuaiLe-Regular.subset.ttf", OUT / "ZCOOLKuaiLe-Regular.ttf")

    stale = [
        "Inter-Regular.ttf",
        "Inter-Medium.ttf",
        "Inter-SemiBold.ttf",
        "Inter-Bold.ttf",
        "Sora-SemiBold.ttf",
        "Sora-Bold.ttf",
        "Sora-ExtraBold.ttf",
        "LuckiestGuy-Regular.ttf",
        "LilitaOne-Regular.ttf",
        "Fredoka-SemiBold.ttf",
        "Fredoka-Bold.ttf",
        "OFL-Fredoka.txt",
        "MPLUSRounded1c-Bold.ttf",
        "OFL-MPlusRounded1c.txt",
        "OFL-Inter.txt",
        "OFL-Sora.txt",
        "OFL-LilitaOne.txt",
        "LICENSE-LuckiestGuy.txt",
    ]
    for name in stale:
        path = OUT / name
        if path.exists():
            path.unlink()
            print(f"  removed {name}")

    needed = arb_chars() | set(
        "şŞğĞıİöÖüÜçÇßÄÖÜäöüœŒæÆãõñÑ¿¡●"
        "EspañolPortuguês简体中文日本語한국어Türkçe"
    )
    latin_needed = {ch for ch in needed if ord(ch) < 0x300 or 0x1E00 <= ord(ch) <= 0x1EFF or ch in "ßœŒæÆñÑ¿¡●–—−"}
    print("\nCoverage after prep:")
    total = 0
    for path in sorted(OUT.glob("*.ttf")):
        total += path.stat().st_size
        covered = cmap(path)
        missing = sorted(latin_needed - covered, key=ord)
        print(f"  {path.name:32} {path.stat().st_size/1024:7.0f} KB  latin_missing={len(missing)} {''.join(missing)[:40]!r}")
    print(f"  TOTAL TTF {total / 1024 / 1024:.2f} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
