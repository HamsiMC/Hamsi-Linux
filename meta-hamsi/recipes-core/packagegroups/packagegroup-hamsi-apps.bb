# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux daily, creative and professional applications"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup

HAMSI_YANDEX_PACKAGE = "${@bb.utils.contains('HAMSI_INCLUDE_YANDEX', '1', 'yandex-browser-binary', '', d)}"

RDEPENDS:${PN} = " \
    ${HAMSI_YANDEX_PACKAGE} \
    blender-binary \
    angelfish dolphin konsole okular gwenview elisa dragon \
    kdeconnect-kde kdialog kio-extras ffmpegthumbs \
    gnome-text-editor file-roller \
    gparted \
    vlc transmission remmina freerdp3 \
    cups cups-filters cups-pk-helper gutenprint \
    jq python3 python3-pip cmake ninja \
"
