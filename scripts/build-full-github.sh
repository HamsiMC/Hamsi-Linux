#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive

PROJECT="${GITHUB_WORKSPACE:-$(pwd)}"
WORK="${RUNNER_TEMP:-/tmp}/hamsi-full-build"
ROOT="$WORK/rootfs"
ISO_ROOT="$WORK/iso"
OUT="$PROJECT/dist"
ISO="$OUT/Hamsi-0.2-Full-x86_64.iso"

sudo rm -rf "$WORK"
mkdir -p "$ROOT" "$ISO_ROOT" "$OUT"

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin grub-common \
  mtools dosfstools qemu-system-x86 ovmf rsync ca-certificates file

sudo debootstrap --arch=amd64 --variant=minbase bookworm "$ROOT" https://deb.debian.org/debian
sudo tee "$ROOT/etc/apt/sources.list" >/dev/null <<'SOURCES'
deb https://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb https://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
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
  linux-image-amd64 live-boot initramfs-tools systemd-sysv udev dbus dbus-x11 sudo locales tzdata \
  keyboard-configuration console-setup plymouth plymouth-themes \
  network-manager network-manager-gnome wireless-tools rfkill wpasupplicant modemmanager \
  firmware-linux firmware-linux-nonfree firmware-misc-nonfree firmware-amd-graphics \
  firmware-iwlwifi firmware-realtek firmware-atheros firmware-brcm80211 \
  xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-all xinit x11-xserver-utils \
  xfce4 xfce4-goodies xfce4-whiskermenu-plugin lightdm lightdm-gtk-greeter \
  thunar thunar-archive-plugin thunar-volman gvfs gvfs-backends udisks2 tumbler \
  arc-theme papirus-icon-theme desktop-base zenity \
  pipewire pipewire-pulse wireplumber libspa-0.2-bluetooth pavucontrol alsa-utils \
  bluez blueman \
  cups cups-client system-config-printer printer-driver-all sane-utils sane-airscan simple-scan \
  mesa-vulkan-drivers mesa-va-drivers mesa-vdpau-drivers intel-media-va-driver vainfo vulkan-tools \
  firefox-esr chromium thunderbird \
  libreoffice libreoffice-gtk3 libreoffice-l10n-tr hunspell-tr \
  blender gimp inkscape krita vlc audacity obs-studio kdenlive handbrake ffmpeg \
  gstreamer1.0-libav gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
  gnome-software gnome-software-plugin-flatpak packagekit flatpak synaptic \
  mousepad atril ristretto parole catfish flameshot cheese keepassxc qalculate-gtk filezilla \
  gparted gnome-disk-utility parted rsync dosfstools e2fsprogs ntfs-3g exfatprogs \
  btrfs-progs xfsprogs f2fs-tools smartmontools nvme-cli hdparm timeshift deja-dup \
  grub-pc-bin grub-efi-amd64-bin grub2-common os-prober efibootmgr \
  curl wget ca-certificates git openssh-client nano vim-tiny less file unzip zip p7zip-full unrar-free \
  pciutils usbutils lshw dmidecode htop btop lm-sensors acpi powertop \
  python3 python3-pip build-essential cmake geany \
  fonts-dejavu-core fonts-dejavu-extra fonts-noto-core fonts-noto-color-emoji fonts-liberation2

ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
echo 'Europe/Istanbul' > /etc/timezone
sed -i 's/^# *\(tr_TR.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
locale-gen
update-locale LANG=tr_TR.UTF-8 LANGUAGE=tr_TR:tr:en_US:en

id hamsi >/dev/null 2>&1 || useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,lp,scanner,bluetooth hamsi
echo 'hamsi:hamsi' | chpasswd
printf 'hamsi ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/90-hamsi-live
chmod 0440 /etc/sudoers.d/90-hamsi-live
passwd -l root || true

systemctl enable NetworkManager.service || true
systemctl enable bluetooth.service || true
systemctl enable cups.service || true
systemctl enable lightdm.service || true

flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CHROOT

sudo tee "$ROOT/etc/os-release" >/dev/null <<'OSR'
NAME="Hamsi"
PRETTY_NAME="Hamsi 0.2 Full"
ID=hamsi
ID_LIKE=linux
VERSION_ID="0.2"
VERSION="0.2 Full"
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
sudo tee "$ROOT/etc/lightdm/lightdm.conf.d/50-hamsi-live.conf" >/dev/null <<'LIGHTDM'
[Seat:*]
autologin-user=hamsi
autologin-user-timeout=0
user-session=xfce
LIGHTDM

sudo install -d -o 1000 -g 1000 "$ROOT/home/hamsi/.config/autostart" "$ROOT/home/hamsi/.local/bin" "$ROOT/home/hamsi/Desktop"
sudo tee "$ROOT/home/hamsi/.local/bin/hamsi-style" >/dev/null <<'STYLE'
#!/bin/sh
sleep 2
xfconf-query -c xsettings -p /Net/ThemeName -s Arc-Dark 2>/dev/null || true
xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus-Dark 2>/dev/null || true
xfconf-query -c xfwm4 -p /general/theme -s Arc-Dark 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 42 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/length -s 100 2>/dev/null || true
xfconf-query -c xfce4-panel -p /panels/panel-1/position -s 'p=6;x=0;y=0' 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/color-style -s 0 2>/dev/null || true
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/rgba1 -s 0.015 -s 0.02 -s 0.03 -s 1.0 2>/dev/null || true
STYLE
sudo chmod +x "$ROOT/home/hamsi/.local/bin/hamsi-style"
sudo tee "$ROOT/home/hamsi/.config/autostart/hamsi-style.desktop" >/dev/null <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Hamsi Görünümü
Exec=/home/hamsi/.local/bin/hamsi-style
X-GNOME-Autostart-enabled=true
AUTOSTART
sudo chown -R 1000:1000 "$ROOT/home/hamsi/.config" "$ROOT/home/hamsi/.local"

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
done < <(lsblk -dnpo NAME,SIZE,MODEL,TYPE | awk '$NF=="disk" {$NF=""; print $1,$2,substr($0,index($0,$3))}')
(( ${#rows[@]} > 0 )) || { zenity --error --text='Kurulum için uygun hedef disk bulunamadı.'; exit 1; }

target="$(zenity --list --title='Hamsi Kur' --text='Hedef diski seçin. Seçilen diskteki TÜM veriler silinir.' \
  --column='Aygıt' --column='Boyut' --column='Model' "${rows[@]}" --width=760 --height=440 || true)"
[[ -n "$target" ]] || exit 0
zenity --question --title='Son onay' --width=560 --text="$target üzerindeki TÜM veriler kalıcı olarak silinecek. Devam edilsin mi?" || exit 0
confirm="$(zenity --entry --title='Hamsi Kur' --text="Onaylamak için hedef aygıtı aynen yazın: $target" || true)"
[[ "$confirm" == "$target" ]] || { zenity --error --text='Onay eşleşmedi.'; exit 1; }

username="$(zenity --entry --title='Kullanıcı hesabı' --text='Kurulu sistem için kullanıcı adı:' --entry-text='hamsiuser' || true)"
[[ "$username" =~ ^[a-z_][a-z0-9_-]{1,30}$ ]] || { zenity --error --text='Geçersiz kullanıcı adı.'; exit 1; }
password="$(zenity --password --title='Kullanıcı parolası' || true)"
[[ -n "$password" ]] || { zenity --error --text='Parola boş bırakılamaz.'; exit 1; }

(
  echo 5; echo '# Disk hazırlanıyor...'
  swapoff -a || true
  umount "${target}"?* 2>/dev/null || true
  wipefs -a "$target"
  parted -s "$target" mklabel gpt
  parted -s "$target" mkpart BIOS 1MiB 3MiB
  parted -s "$target" set 1 bios_grub on
  parted -s "$target" mkpart ESP fat32 3MiB 515MiB
  parted -s "$target" set 2 esp on
  parted -s "$target" mkpart ROOT ext4 515MiB 100%
  partprobe "$target"; sleep 3
  if [[ "$target" =~ nvme|mmcblk ]]; then pfx="${target}p"; else pfx="$target"; fi
  esp="${pfx}2"; rootp="${pfx}3"
  mkfs.vfat -F32 -n HAMSI_EFI "$esp"
  mkfs.ext4 -F -L HAMSI_ROOT "$rootp"

  echo 20; echo '# Hamsi dosyaları kopyalanıyor...'
  mount "$rootp" /mnt
  mkdir -p /mnt/boot/efi
  mount "$esp" /mnt/boot/efi
  rsync -aHAX --numeric-ids \
    --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/run/*' \
    --exclude='/tmp/*' --exclude='/mnt/*' --exclude='/media/*' --exclude='/lost+found' / /mnt/
  mkdir -p /mnt/{dev,proc,sys,run,tmp,mnt,media}
  root_uuid="$(blkid -s UUID -o value "$rootp")"
  esp_uuid="$(blkid -s UUID -o value "$esp")"
  cat > /mnt/etc/fstab <<FSTAB
UUID=$root_uuid / ext4 defaults,noatime 0 1
UUID=$esp_uuid /boot/efi vfat umask=0077 0 2
FSTAB

  echo 70; echo '# Kullanıcı ve önyükleyici yapılandırılıyor...'
  for d in dev proc sys run; do mount --rbind "/$d" "/mnt/$d"; mount --make-rslave "/mnt/$d"; done
  chroot /mnt useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,lp,scanner,bluetooth "$username"
  printf '%s:%s\n' "$username" "$password" | chroot /mnt chpasswd
  cp -a /mnt/home/hamsi/.config /mnt/home/$username/ 2>/dev/null || true
  cp -a /mnt/home/hamsi/.local /mnt/home/$username/ 2>/dev/null || true
  chroot /mnt chown -R "$username:$username" "/home/$username"
  sed -i "s#/home/hamsi#/home/$username#g" /mnt/home/$username/.config/autostart/hamsi-style.desktop 2>/dev/null || true
  chroot /mnt userdel -r hamsi || true
  rm -f /mnt/etc/sudoers.d/90-hamsi-live /mnt/etc/lightdm/lightdm.conf.d/50-hamsi-live.conf

  chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Hamsi --removable --no-nvram
  chroot /mnt grub-install --target=i386-pc "$target" || true
  chroot /mnt update-initramfs -u -k all
  chroot /mnt update-grub

  echo 95; echo '# Son işlemler...'
  sync
  for d in run sys proc dev; do umount -R "/mnt/$d" 2>/dev/null || true; done
  umount /mnt/boot/efi 2>/dev/null || true
  umount /mnt 2>/dev/null || true
  echo 100; echo '# Kurulum tamamlandı.'
) | zenity --progress --title='Hamsi Kuruluyor' --percentage=0 --auto-close --width=580

zenity --info --title='Hamsi Kur' --text='Kurulum tamamlandı. USB belleği çıkarıp yeniden başlatabilirsiniz.'
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
sudo cp "$ROOT/usr/share/applications/hamsi-installer.desktop" "$ROOT/home/hamsi/Desktop/Hamsi-Kur.desktop"
sudo chmod +x "$ROOT/home/hamsi/Desktop/Hamsi-Kur.desktop"
sudo chown -R 1000:1000 "$ROOT/home/hamsi/Desktop"

# ISO'yu küçültürken uygulamaları ve sürücüleri koru.
sudo rm -rf "$ROOT/var/cache/apt/archives/"* "$ROOT/usr/share/doc/"* "$ROOT/usr/share/man/"* "$ROOT/usr/share/info/"* || true
sudo find "$ROOT/usr/share/locale" -mindepth 1 -maxdepth 1 ! -name 'tr*' ! -name 'en*' -exec rm -rf {} + 2>/dev/null || true
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
menuentry 'Hamsi 0.2 Full — Canlı Sistem / Kurulum' {
    linux /live/vmlinuz boot=live components quiet splash username=hamsi hostname=hamsi locales=tr_TR.UTF-8 keyboard-layouts=tr console=tty0
    initrd /live/initrd.img
}
menuentry 'Hamsi 0.2 Full — Güvenli Grafik' {
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
min=$((1024 * 1024 * 1024))
max=$((2 * 1024 * 1024 * 1024 - 16 * 1024 * 1024))
if (( bytes < min )); then
  echo "UYARI: Full ISO beklenenden küçük: $bytes bytes" >&2
fi
if (( bytes >= max )); then
  echo "ISO GitHub tek-dosya sınırına fazla yakın/büyük: $bytes bytes" >&2
  exit 1
fi

file "$ISO"
xorriso -indev "$ISO" -report_el_torito plain -report_system_area plain 2>&1 | tee "$ISO.boot-report.txt"

timeout 50s qemu-system-x86_64 -m 3072 -smp 2 -cdrom "$ISO" -boot d -no-reboot -display none -serial stdio \
  >"$ISO.qemu.log" 2>&1 || true
if grep -Eqi 'Linux version|GRUB|Hamsi' "$ISO.qemu.log"; then
  echo 'QEMU BIOS duman testi: önyükleme izi bulundu.'
else
  echo 'UYARI: QEMU duman testinde açık önyükleme izi bulunamadı; yapısal rapora bakın.' >&2
  tail -n 60 "$ISO.qemu.log" || true
fi

printf 'Hamsi Full ISO hazır: %s (%s bytes)\n' "$ISO" "$bytes"
