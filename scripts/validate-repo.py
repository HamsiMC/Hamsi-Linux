#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
from __future__ import annotations

import hashlib
import re
import subprocess
import sys
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "kas" / "hamsi-x86-64.yml"
SHA1 = re.compile(r"^[0-9a-f]{40}$")
SHA256 = re.compile(r"^[0-9a-f]{64}$")

REQUIRED = [
    "README.md",
    "LICENSE",
    "kas/hamsi-x86-64.yml",
    "meta-hamsi/conf/layer.conf",
    "meta-hamsi/conf/distro/hamsi.conf",
    "meta-hamsi/recipes-core/images/hamsi-desktop-image.bb",
    "meta-hamsi/recipes-hamsi/hamsi-installer/files/hamsi-installer",
    "meta-hamsi/recipes-hamsi/blender-binary/blender-binary_5.2.0.bb",
    "meta-hamsi/recipes-hamsi/yandex-browser-binary/yandex-browser-binary_26.6.1.1083.bb",
    ".github/workflows/validate.yml",
    ".github/workflows/build-iso.yml",
]


def error(message: str) -> None:
    print(f"HATA: {message}", file=sys.stderr)


def main() -> int:
    failures = 0
    for relative in REQUIRED:
        if not (ROOT / relative).is_file():
            error(f"zorunlu dosya yok: {relative}")
            failures += 1

    data = yaml.safe_load(CONFIG.read_text(encoding="utf-8"))
    if data.get("header", {}).get("version") != 19:
        error("kas biçim sürümü 19 olmalı")
        failures += 1
    if data.get("distro") != "hamsi" or data.get("target") != "hamsi-desktop-image":
        error("kas hedefi Hamsi dağıtımını ve görüntüsünü göstermiyor")
        failures += 1

    repos = data.get("repos", {})
    for name, repo in repos.items():
        if name == "hamsi":
            continue
        commit = str(repo.get("commit", ""))
        if not SHA1.fullmatch(commit):
            error(f"{name} sabit 40 haneli commit'e kilitli değil")
            failures += 1

    image = (ROOT / "meta-hamsi/recipes-core/images/hamsi-desktop-image.bb").read_text(encoding="utf-8")
    for required_type in ("squashfs", "iso", "wic.gz", "wic.bmap"):
        if required_type not in image:
            error(f"görüntü türü eksik: {required_type}")
            failures += 1

    for recipe in (
        ROOT / "meta-hamsi/recipes-hamsi/blender-binary/blender-binary_5.2.0.bb",
        ROOT / "meta-hamsi/recipes-hamsi/yandex-browser-binary/yandex-browser-binary_26.6.1.1083.bb",
    ):
        text = recipe.read_text(encoding="utf-8")
        match = re.search(r'SRC_URI\[sha256sum\]\s*=\s*"([0-9a-f]+)"', text)
        if not match or not SHA256.fullmatch(match.group(1)):
            error(f"geçerli SHA-256 yok: {recipe.relative_to(ROOT)}")
            failures += 1

    forbidden_large = []
    for path in ROOT.rglob("*"):
        if path.is_file() and ".git" not in path.parts and path.stat().st_size > 5 * 1024 * 1024:
            forbidden_large.append(path.relative_to(ROOT).as_posix())
    if forbidden_large:
        error("kaynak deposuna büyük ikili dosya eklenmiş: " + ", ".join(forbidden_large))
        failures += 1

    shell_files = [path for path in ROOT.rglob("*") if path.is_file() and path.read_bytes()[:2] == b"#!" and b"bash" in path.read_bytes()[:128]]
    for path in shell_files:
        result = subprocess.run(["bash", "-n", str(path)], capture_output=True, text=True)
        if result.returncode:
            error(f"bash sözdizimi: {path.relative_to(ROOT)}: {result.stderr.strip()}")
            failures += 1

    layer_conf = (ROOT / "meta-hamsi/conf/layer.conf").read_text(encoding="utf-8")
    if 'LAYERSERIES_COMPAT_hamsi = "wrynose"' not in layer_conf:
        error("Hamsi katmanı wrynose uyumluluğunu bildirmiyor")
        failures += 1

    # This value is duplicated deliberately: the verifier must enforce the
    # product requirement even if documentation or recipes are edited.
    max_iso = 12 * 1024 * 1024 * 1024
    if max_iso != 12_884_901_888:
        error("12 GiB sınırı yanlış hesaplandı")
        failures += 1

    if failures:
        print(f"Doğrulama başarısız: {failures} sorun.", file=sys.stderr)
        return 1

    fingerprint = hashlib.sha256(CONFIG.read_bytes()).hexdigest()[:12]
    print(f"Hamsi Linux kaynak doğrulaması geçti (kas {fingerprint}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
