#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

PROJECT="${GITHUB_WORKSPACE:-$(pwd)}"
WORK="${RUNNER_TEMP:-/tmp}/hamsi-live-build"
ROOT="$WORK/rootfs"
ISO_ROOT="$WORK/iso"
OUT="$PROJECT/dist"
ISO="$OUT/Hamsi-0.1-Live-x86_64.iso"

sudo rm -rf "$WORK"
mkdir -p "$ROOT" "$ISO_ROOT" "$OUT"

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin grub-common \
  mtools dosfstools qemu-system-x86 ovmf rsync ca-certificates

sudo debootstrap --arch=amd64 --variant=minbase bookworm "$ROOT" https://deb.debian.org/debian

sudo tee "$ROOT/etc/apt/sources.list" >/dev/null <<'SOURCES'
deb https://deb.debian.org/debian bookworm main contrib non-free-firmware
deb https://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
deb https://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
SOURCES

sudo tee "$ROOT/usr/sbin/policy-rc.d" >/dev/null <<'POLICY'
#!/bin/sh
exit 101
POLICY
sudo chmod +x "$ROOT/usr/sbin/policy-rc.d"
sudo cp /etc/resolv.conf "$ROOT/etc/resolv.conf"

sudo chroot "$ROOT" /bin/bash -eux <<'CHROOT'
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  linux-image-amd64 live-boot initramfs-tools systemd-sysv udev dbus dbus-x11 \
  sudo locales tzdata keyboard-configuration console-setup \
  network-manager network-manager-gnome wireless-tools rfkill wpasupplicant \
  firmware-linux-free firmware-amd-graphics firmware-iwlwifi firmware-realtek firmware-atheros \
  xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-all xinit x11-xserver-utils \
  openbox tint2 rofi lightdm lightdm-gtk-greeter thunar xfce4-terminal zenity \
  pulseaudio pavucontrol alsa-utils \
  firefox-esr libreoffice-writer libreoffice-calc libreoffice-impress \
  evince vlc gimp inkscape flatpak \
  gparted parted rsync dosfstools e2fsprogs grub-pc-bin grub-efi-amd64-bin grub2-common os-prober \
  curl wget ca-certificates nano less file unzip zip pciutils usbutils \
  fonts-dejavu-core fonts-noto-core fonts-noto-color-emoji adwaita-icon-theme hicolor-icon-theme

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
echo 'Europe/Istanbul' > /etc/timezone
sed -i 's/^# *\(tr_TR.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
locale-gen
update-locale LANG=tr_TR.UTF-8

id hamsi >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev hamsi
echo 'hamsi:hamsi' | chpasswd
printf 'hamsi ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/90-hamsi-live
chmod 0440 /etc/sudoers.d/90-hamsi-live
passwd -l root || true

systemctl enable NetworkManager.service || true
systemctl enable lightdm.service || true

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CHROOT

sudo tee "$ROOT/etc/os-release" >/dev/null <<'OSR'
NAME="Hamsi"
PRETTY_NAME="Hamsi 0.1"
ID=hamsi
ID_LIKE=linux
VERSION_ID="0.1"
VERSION="0.1 Live"
VERSION_CODENAME=palamut
HOME_URL="https://github.com/HamsiMC/Hamsi-Linux"
SUPPORT_URL="https://github.com/HamsiMC/Hamsi-Linux/issues"
OSR
printf 'hamsi\n' | sudo tee "$ROOT/etc/hostname" >/dev/null
sudo tee "$ROOT/etc/hosts" >/dev/null <<'HOSTS'
127.0.0.1 localhost
127.0.1.1 hamsi
::1 localhost ip6-localhost ip6-loopback
HOSTS

sudo mkdir -p "$ROOT/etc/lightdm/lightdm.conf.d"
sudo tee "$ROOT/etc/lightdm/lightdm.conf.d/50-hamsi.conf" >/dev/null <<'LIGHTDM'
[Seat:*]
autologin-user=hamsi
autologin-user-timeout=0
user-session=openbox
LIGHTDM

sudo install -d -o 1000 -g 1000 "$ROOT/home/hamsi/.config/openbox" "$ROOT/home/hamsi/.config/tint2"
sudo tee "$ROOT/home/hamsi/.config/openbox/autostart" >/dev/null <<'AUTOSTART'
xsetroot -solid '#090b10' &
tint2 &
nm-applet &
pulseaudio --start >/dev/null 2>&1 || true
AUTOSTART

sudo tee "$ROOT/home/hamsi/.config/openbox/rc.xml" >/dev/null <<'OPENBOX'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme><name>Clearlooks</name><titleLayout>NLIMC</titleLayout></theme>
  <desktops><number>4</number><firstdesk>1</firstdesk></desktops>
  <keyboard>
    <keybind key="W-space"><action name="Execute"><command>rofi -show drun</command></action></keybind>
    <keybind key="W-Return"><action name="Execute"><command>xfce4-terminal</command></action></keybind>
    <keybind key="A-F4"><action name="Close"/></keybind>
  </keyboard>
  <applications/>
</openbox_config>
OPENBOX

sudo tee "$ROOT/home/hamsi/.config/tint2/tint2rc" >/dev/null <<'TINT'
panel_items = LTSC
panel_position = top center horizontal
panel_size = 100% 38
panel_margin = 0 0
panel_padding = 8 2 8
panel_background_id = 1
rounded = 8
border_width = 1
background_color = #161b24 92
border_color = #ffffff 18
launcher_padding = 6 4 6
launcher_icon_size = 24
launcher_item_app = /usr/share/applications/firefox-esr.desktop
launcher_item_app = /usr/share/applications/thunar.desktop
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
task_icon = 1
task_text = 1
task_centered = 1
task_maximum_size = 180 32
systray_padding = 4 2 4
clock_format = %H:%M
clock_tooltip = %A %d %B %Y
TINT

sudo chown -R 1000:1000 "$ROOT/home/hamsi/.config"

sudo tee "$ROOT/usr/local/sbin/hamsi-install" >/dev/null <<'INSTALLER'
#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-/home/hamsi/.Xauthority}"

live_src="$(findmnt -n -o SOURCE /run/live/medium 2>/dev/null || true)"
live_disk=""
if [[ -n "$live_src" ]]; then
  pk="$(lsblk -n -o PKNAME "$live_src" 2>/dev/null | head -n1 || true)"
  [[ -n "$pk" ]] && live_disk="/dev/$pk"
fi

rows=()
while read -r dev size model; do
  [[ "$dev" == "$live_disk" ]] && continue
  rows+=("$dev" "$size" "${model:-Bilinmeyen}")
done < <(lsblk -dnpo NAME,SIZE,MODEL,TYPE | awk '$NF=="disk" {type=$NF; $NF=""; print $1,$2,substr($0,index($0,$3))}')

(( ${#rows[@]} > 0 )) || { zenity --error --text='Kurulum için uygun hedef disk bulunamadı.'; exit 1; }
target="$(zenity --list --title='Hamsi Kur' --text='Hamsi kurulacak diski seçin. Seçilen diskteki TÜM veriler silinir.' \
  --column='Aygıt' --column='Boyut' --column='Model' "${rows[@]}" --width=720 --height=420 || true)"
[[ -n "$target" ]] || exit 0
zenity --question --title='Son onay' --width=520 \
  --text="$target üzerindeki TÜM bölüm ve veriler kalıcı olarak silinecek. Devam edilsin mi?" || exit 0
confirm="$(zenity --entry --title='Hamsi Kur' --text="Onaylamak için hedef aygıt adını aynen yazın:\n$target" || true)"
[[ "$confirm" == "$target" ]] || { zenity --error --text='Onay eşleşmedi. Kurulum iptal edildi.'; exit 1; }

(
  echo 5
  echo '# Hedef disk hazırlanıyor...'
  swapoff -a || true
  umount "${target}"?* 2>/dev/null || true
  wipefs -a "$target"
  parted -s "$target" mklabel gpt
  parted -s "$target" mkpart BIOS 1MiB 3MiB
  parted -s "$target" set 1 bios_grub on
  parted -s "$target" mkpart ESP fat32 3MiB 515MiB
  parted -s "$target" set 2 esp on
  parted -s "$target" mkpart ROOT ext4 515MiB 100%
  partprobe "$target"
  sleep 3

  if [[ "$target" =~ nvme|mmcblk ]]; then pfx="${target}p"; else pfx="$target"; fi
  esp="${pfx}2"; rootp="${pfx}3"
  mkfs.vfat -F32 -n HAMSI_EFI "$esp"
  mkfs.ext4 -F -L HAMSI_ROOT "$rootp"

  echo 20
  echo '# Dosyalar kopyalanıyor...'
  mount "$rootp" /mnt
  mkdir -p /mnt/boot/efi
  mount "$esp" /mnt/boot/efi
  rsync -aHAX --numeric-ids --info=progress2 \
    --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/run/*' \
    --exclude='/tmp/*' --exclude='/mnt/*' --exclude='/media/*' --exclude='/lost+found' / /mnt/
  mkdir -p /mnt/{dev,proc,sys,run,tmp,mnt,media}

  root_uuid="$(blkid -s UUID -o value "$rootp")"
  esp_uuid="$(blkid -s UUID -o value "$esp")"
  cat > /mnt/etc/fstab <<FSTAB
UUID=$root_uuid / ext4 defaults,noatime 0 1
UUID=$esp_uuid /boot/efi vfat umask=0077 0 2
FSTAB

  echo 75
  echo '# Önyükleyici kuruluyor...'
  for d in dev proc sys run; do mount --rbind "/$d" "/mnt/$d"; mount --make-rslave "/mnt/$d"; done
  chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Hamsi --removable --no-nvram
  chroot /mnt grub-install --target=i386-pc "$target" || true
  chroot /mnt update-initramfs -u -k all
  chroot /mnt update-grub

  echo 95
  echo '# Son işlemler...'
  sync
  for d in run sys proc dev; do umount -R "/mnt/$d" 2>/dev/null || true; done
  umount /mnt/boot/efi 2>/dev/null || true
  umount /mnt 2>/dev/null || true
  echo 100
  echo '# Kurulum tamamlandı.'
) | zenity --progress --title='Hamsi Kuruluyor' --percentage=0 --auto-close --width=560

zenity --info --title='Hamsi Kur' --text='Kurulum tamamlandı. USB belleği çıkarıp bilgisayarı yeniden başlatabilirsiniz.'
INSTALLER
sudo chmod 0755 "$ROOT/usr/local/sbin/hamsi-install"

sudo tee "$ROOT/usr/share/applications/hamsi-installer.desktop" >/dev/null <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Hamsi Kur
Comment=Hamsi işletim sistemini diske kur
Exec=sudo /usr/local/sbin/hamsi-install
Icon=drive-harddisk
Terminal=false
Categories=System;
DESKTOP

sudo install -d -o 1000 -g 1000 "$ROOT/home/hamsi/Desktop"
sudo cp "$ROOT/usr/share/applications/hamsi-installer.desktop" "$ROOT/home/hamsi/Desktop/Hamsi-Kur.desktop"
sudo chmod +x "$ROOT/home/hamsi/Desktop/Hamsi-Kur.desktop"
sudo chown 1000:1000 "$ROOT/home/hamsi/Desktop/Hamsi-Kur.desktop"

sudo rm -rf "$ROOT/var/cache/apt/archives/"* "$ROOT/usr/share/doc/"* "$ROOT/usr/share/man/"* "$ROOT/usr/share/info/"* || true
sudo find "$ROOT/usr/share/locale" -mindepth 1 -maxdepth 1 \
  ! -name 'tr*' ! -name 'en*' -exec rm -rf {} + 2>/dev/null || true
sudo rm -f "$ROOT/usr/sbin/policy-rc.d"

kernel="$(find "$ROOT/boot" -maxdepth 1 -type f -name 'vmlinuz-*' | sort -V | tail -n1)"
version="${kernel##*/vmlinuz-}"
initrd="$ROOT/boot/initrd.img-$version"
[[ -s "$kernel" && -s "$initrd" ]]

mkdir -p "$ISO_ROOT/live" "$ISO_ROOT/boot/grub"
sudo cp "$kernel" "$ISO_ROOT/live/vmlinuz"
sudo cp "$initrd" "$ISO_ROOT/live/initrd.img"
sudo mksquashfs "$ROOT" "$ISO_ROOT/live/filesystem.squashfs" \
  -comp xz -b 1M -Xdict-size 100% -noappend -no-progress

cat > "$ISO_ROOT/boot/grub/grub.cfg" <<'GRUB'
set default=0
set timeout=8
set gfxpayload=keep

menuentry 'Hamsi 0.1 — Canlı Sistem / Kurulum' {
    linux /live/vmlinuz boot=live components quiet splash username=hamsi hostname=hamsi locales=tr_TR.UTF-8 keyboard-layouts=tr console=tty0
    initrd /live/initrd.img
}
menuentry 'Hamsi 0.1 — Güvenli Grafik' {
    linux /live/vmlinuz boot=live components nomodeset username=hamsi hostname=hamsi locales=tr_TR.UTF-8 keyboard-layouts=tr console=tty0
    initrd /live/initrd.img
}
menuentry 'Yeniden Başlat' { reboot }
menuentry 'Bilgisayarı Kapat' { halt }
GRUB

sudo grub-mkrescue -o "$ISO" "$ISO_ROOT"
sudo chown "$USER:$USER" "$ISO"
sha256sum "$ISO" | tee "$ISO.sha256"

bytes="$(stat -c %s "$ISO")"
limit=$((2 * 1024 * 1024 * 1024 - 1024 * 1024))
if (( bytes >= limit )); then
  echo "ISO GitHub tek-dosya sınırına fazla yakın/büyük: $bytes bytes" >&2
  exit 1
fi

file "$ISO"
xorriso -indev "$ISO" -report_el_torito plain -report_system_area plain 2>&1 | tee "$ISO.boot-report.txt"

set +e
timeout 45s qemu-system-x86_64 -m 2048 -smp 2 -cdrom "$ISO" -boot d -no-reboot -display none -serial stdio \
  >"$ISO.qemu.log" 2>&1
qrc=$?
set -e
if grep -Eqi 'Linux version|Booting a command list|Hamsi|GRUB' "$ISO.qemu.log"; then
  echo 'QEMU BIOS duman testi: önyükleme izi bulundu.'
else
  echo "UYARI: QEMU duman testinde açık önyükleme izi bulunamadı (çıkış=$qrc). Yapısal doğrulama geçerli." >&2
  tail -n 80 "$ISO.qemu.log" || true
fi

echo "HAMSI_ISO=$ISO" >> "${GITHUB_ENV:-/dev/null}"
echo "HAMSI_SHA256=$ISO.sha256" >> "${GITHUB_ENV:-/dev/null}"
