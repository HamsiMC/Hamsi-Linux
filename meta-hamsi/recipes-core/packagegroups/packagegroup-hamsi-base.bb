# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux base operating-system services"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    packagegroup-core-ssh-openssh \
    packagegroup-core-buildessential \
    kernel-modules \
    kernel-image \
    linux-firmware \
    bash bash-completion coreutils findutils grep sed gawk less nano vim \
    git curl wget ca-certificates openssl gnupg \
    sudo polkit dbus shadow \
    procps iproute2 iputils ethtool pciutils usbutils hwdata lsof strace \
    rsync unzip zip tar xz zstd cpio \
    e2fsprogs e2fsprogs-resize2fs dosfstools btrfs-tools ntfs-3g exfatprogs \
    util-linux util-linux-blkid util-linux-lsblk parted gptfdisk \
    smartmontools hdparm lvm2 mdadm cryptsetup \
    networkmanager networkmanager-nmtui wpa-supplicant iwd \
    bluez5 bluez5-obex avahi-daemon \
    nftables firewalld wireguard-tools \
    fwupd upower udisks2 power-profiles-daemon \
    audit \
    chrony \
"
