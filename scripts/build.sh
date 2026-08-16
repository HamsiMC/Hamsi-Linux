#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -Eeuo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$project_dir/kas/hamsi-x86-64.yml"
export KAS_WORK_DIR="${KAS_WORK_DIR:-$project_dir/.work/kas}"
export HAMSI_INCLUDE_YANDEX="${HAMSI_INCLUDE_YANDEX:-1}"

"$project_dir/scripts/check-runner.sh"
python3 "$project_dir/scripts/validate-repo.py"

mkdir -p "$KAS_WORK_DIR" "$project_dir/dist"
kas build "$config"

deploy_dir="$KAS_WORK_DIR/build/tmp/deploy/images/genericx86-64"
mapfile -t candidates < <(find "$deploy_dir" -maxdepth 1 -type f \
    -name 'hamsi-desktop-image-genericx86-64*.iso' -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)
(( ${#candidates[@]} > 0 )) || {
    printf 'Derleme tamamlandı ancak ISO bulunamadı: %s\n' "$deploy_dir" >&2
    exit 1
}

source_iso="${candidates[-1]}"
output_iso="$project_dir/dist/hamsi-linux-0.1.0-x86_64.iso"
cp --reflink=auto --sparse=always "$source_iso" "$output_iso"

"$project_dir/scripts/verify-iso.sh" "$output_iso"
sha256sum "$output_iso" > "$output_iso.sha256"
"$project_dir/scripts/chunk-iso.sh" "$output_iso"
python3 "$project_dir/scripts/source-manifest.py" \
    "$project_dir" "$project_dir/dist/hamsi-linux-0.1.0-source-manifest.json"

find "$deploy_dir" -maxdepth 1 -type f \
    \( -name '*.spdx.json' -o -name '*.buildinfo' -o -name '*.wic.bmap' \) \
    -exec cp --reflink=auto {} "$project_dir/dist/" \;

printf 'Hamsi Linux ISO hazır: %s\n' "$output_iso"
