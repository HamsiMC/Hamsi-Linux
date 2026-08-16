#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

iso="${1:-}"
[[ -n "$iso" && -f "$iso" ]] || {
    printf 'Kullanım: %s ISO_DOSYASI\n' "$0" >&2
    exit 2
}

parts_dir="${iso}.parts"
mkdir -p "$parts_dir"
find "$parts_dir" -maxdepth 1 -type f -name 'part-*' -delete

split --bytes=1900MiB --numeric-suffixes=1 --suffix-length=3 \
    --additional-suffix=.bin "$iso" "$parts_dir/part-"
(cd "$parts_dir" && sha256sum part-*.bin > SHA256SUMS)

cat > "$parts_dir/BIRLESTIR.txt" <<EOF
Hamsi Linux ISO parçalarını aynı klasöre indirin ve Linux/macOS üzerinde:

  cat part-*.bin > $(basename "$iso")
  sha256sum -c ../$(basename "$iso").sha256

Windows PowerShell üzerinde:

  $parts = Get-ChildItem part-*.bin | Sort-Object Name
  $out = [System.IO.File]::Create('$(basename "$iso")')
  foreach ($p in $parts) { $bytes = [System.IO.File]::ReadAllBytes($p.FullName); $out.Write($bytes, 0, $bytes.Length) }
  $out.Close()
EOF

printf 'ISO %s parçaya ayrıldı: %s\n' "$(find "$parts_dir" -name 'part-*.bin' | wc -l)" "$parts_dir"
