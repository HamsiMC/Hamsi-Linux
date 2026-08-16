#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail

iso="${1:-}"
[[ -n "$iso" && -f "$iso" ]] || {
    printf 'Kullanım: %s ISO_DOSYASI\n' "$0" >&2
    exit 2
}
command -v qemu-system-x86_64 >/dev/null 2>&1 || {
    printf 'QEMU bulunamadı; önyükleme duman testi atlandı.\n'
    exit 0
}

ovmf=""
for candidate in /usr/share/OVMF/OVMF_CODE.fd /usr/share/edk2/x64/OVMF_CODE.fd /usr/share/qemu/OVMF.fd; do
    [[ -f "$candidate" ]] && { ovmf="$candidate"; break; }
done
[[ -n "$ovmf" ]] || {
    printf 'OVMF bulunamadı; UEFI duman testi atlandı.\n'
    exit 0
}

set +e
timeout 75 qemu-system-x86_64 \
    -machine q35,accel=tcg -cpu max -m 4096 -smp 4 \
    -drive "if=pflash,format=raw,readonly=on,file=$ovmf" \
    -cdrom "$iso" -boot d -display none -serial stdio -no-reboot
status=$?
set -e

if [[ $status -eq 124 ]]; then
    printf 'QEMU UEFI duman testi geçti: sanal makine 75 saniye çalıştı.\n'
    exit 0
fi

printf 'QEMU beklenenden erken kapandı (durum %s).\n' "$status" >&2
exit 1
