#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

iso="${1:-}"
min_bytes=$((1 * 1024 * 1024 * 1024))
max_bytes=$((12 * 1024 * 1024 * 1024))

[[ -n "$iso" && -f "$iso" ]] || {
    printf 'Kullanım: %s ISO_DOSYASI\n' "$0" >&2
    exit 2
}

size="$(stat -c '%s' "$iso")"
(( size >= min_bytes )) || {
    printf 'ISO beklenenden küçük (%s bayt); masaüstü veya uygulamalar eksik olabilir.\n' "$size" >&2
    exit 1
}
(( size <= max_bytes )) || {
    printf 'ISO 12 GiB sınırını aşıyor (%s bayt).\n' "$size" >&2
    exit 1
}

file_output="$(file -b "$iso")"
[[ "$file_output" == *"ISO 9660"* ]] || {
    printf 'Dosya geçerli bir ISO 9660 görüntüsü değil: %s\n' "$file_output" >&2
    exit 1
}

if command -v xorriso >/dev/null 2>&1; then
    report="$(xorriso -indev "$iso" -report_el_torito plain 2>&1)"
    [[ "$report" == *"UEFI"* || "$report" == *"EFI"* ]] || {
        printf 'ISO içinde UEFI El Torito önyükleme girdisi bulunamadı.\n' >&2
        exit 1
    }
fi

printf 'ISO doğrulandı: %.2f GiB, ISO9660, 12 GiB sınırı içinde.\n' \
    "$(awk -v bytes="$size" 'BEGIN {print bytes/1024/1024/1024}')"
