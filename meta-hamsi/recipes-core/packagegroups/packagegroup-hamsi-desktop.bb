# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux Plasma desktop, graphics and media services"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup

RDEPENDS:${PN} = " \
    packagegroup-plasma-desktop-workspace \
    sddm \
    discover \
    flatpak \
    xdg-desktop-portal xdg-desktop-portal-kde \
    xdg-user-dirs xdg-utils \
    pipewire pipewire-pulse pipewire-alsa pipewire-tools wireplumber \
    alsa-utils \
    gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    mesa mesa-demos vulkan-loader vulkan-tools \
    fontconfig ttf-dejavu ttf-liberation ttf-noto-emoji \
    accountsservice \
"
