#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

min_disk_bytes=$((200 * 1024 * 1024 * 1024))
min_ram_kib=$((30 * 1024 * 1024))
min_cpus=8

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="${KAS_WORK_DIR:-$project_dir/.work/kas}"
mkdir -p "$work_dir"

missing=()
for tool in bash git python3 kas gcc g++ make tar gzip bzip2 xz cpio file patch diffstat \
            chrpath socat perl wget; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done

if (( ${#missing[@]} > 0 )); then
    printf 'Eksik derleme araçları: %s\n' "${missing[*]}" >&2
    printf 'Yocto ana bilgisayar bağımlılıklarını ve kas paketini kurun.\n' >&2
    exit 1
fi

available_bytes="$(df -PB1 "$work_dir" | awk 'NR == 2 {print $4}')"
ram_kib="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
cpu_count="$(getconf _NPROCESSORS_ONLN)"

(( available_bytes >= min_disk_bytes )) || {
    printf 'En az 200 GiB boş alan gerekir; kullanılabilir: %s GiB\n' "$((available_bytes / 1024 / 1024 / 1024))" >&2
    exit 1
}
(( ram_kib >= min_ram_kib )) || {
    printf 'En az 30 GiB RAM gerekir; kullanılabilir: %s GiB\n' "$((ram_kib / 1024 / 1024))" >&2
    exit 1
}
(( cpu_count >= min_cpus )) || {
    printf 'En az %s işlemci iş parçacığı gerekir; kullanılabilir: %s\n' "$min_cpus" "$cpu_count" >&2
    exit 1
}

printf 'Derleyici uygun: %s CPU, %s GiB RAM, %s GiB boş alan.\n' \
    "$cpu_count" "$((ram_kib / 1024 / 1024))" "$((available_bytes / 1024 / 1024 / 1024))"
