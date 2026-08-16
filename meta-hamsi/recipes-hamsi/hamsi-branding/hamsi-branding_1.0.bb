# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux visual identity and first-session defaults"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://hamsi-wallpaper.svg \
    file://hamsi-logo.svg \
    file://metadata.json \
    file://defaults \
    file://layout.js \
    file://hamsi-apply-theme \
    file://hamsi-first-session.desktop \
    file://20-hamsi-live.conf \
    file://theme.conf.user \
    file://90-hamsi-live \
    file://welcome.html \
    file://hamsi-welcome.desktop \
"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${datadir}/wallpapers/Hamsi/contents/images
    install -m 0644 ${UNPACKDIR}/hamsi-wallpaper.svg \
        ${D}${datadir}/wallpapers/Hamsi/contents/images/3840x2160.svg

    install -d ${D}${datadir}/icons/hicolor/scalable/apps
    install -m 0644 ${UNPACKDIR}/hamsi-logo.svg \
        ${D}${datadir}/icons/hicolor/scalable/apps/hamsi-logo.svg

    install -d ${D}${datadir}/plasma/look-and-feel/org.hamsi.desktop/contents/layouts
    install -m 0644 ${UNPACKDIR}/metadata.json \
        ${D}${datadir}/plasma/look-and-feel/org.hamsi.desktop/metadata.json
    install -m 0644 ${UNPACKDIR}/defaults \
        ${D}${datadir}/plasma/look-and-feel/org.hamsi.desktop/contents/defaults
    install -m 0644 ${UNPACKDIR}/layout.js \
        ${D}${datadir}/plasma/look-and-feel/org.hamsi.desktop/contents/layouts/org.kde.plasma.desktop-layout.js

    install -d ${D}${bindir} ${D}${sysconfdir}/xdg/autostart
    install -m 0755 ${UNPACKDIR}/hamsi-apply-theme ${D}${bindir}/hamsi-apply-theme
    install -m 0644 ${UNPACKDIR}/hamsi-first-session.desktop \
        ${D}${sysconfdir}/xdg/autostart/hamsi-first-session.desktop

    install -d ${D}${sysconfdir}/sddm.conf.d
    install -m 0644 ${UNPACKDIR}/20-hamsi-live.conf \
        ${D}${sysconfdir}/sddm.conf.d/20-hamsi-live.conf
    install -d ${D}${datadir}/sddm/themes/breeze
    install -m 0644 ${UNPACKDIR}/theme.conf.user \
        ${D}${datadir}/sddm/themes/breeze/theme.conf.user

    install -d ${D}${sysconfdir}/sudoers.d
    install -m 0440 ${UNPACKDIR}/90-hamsi-live ${D}${sysconfdir}/sudoers.d/90-hamsi-live

    install -d ${D}${datadir}/hamsi/welcome ${D}${datadir}/applications
    install -m 0644 ${UNPACKDIR}/welcome.html ${D}${datadir}/hamsi/welcome/index.html
    install -m 0644 ${UNPACKDIR}/hamsi-welcome.desktop \
        ${D}${datadir}/applications/hamsi-welcome.desktop
}

RDEPENDS:${PN} += "bash plasma-workspace xdg-utils"

CONFFILES:${PN} += " \
    ${sysconfdir}/sddm.conf.d/20-hamsi-live.conf \
    ${sysconfdir}/sudoers.d/90-hamsi-live \
"

FILES:${PN} += "${datadir}/wallpapers ${datadir}/plasma/look-and-feel \
                ${datadir}/sddm ${datadir}/hamsi ${datadir}/icons \
                ${datadir}/applications ${sysconfdir}/xdg/autostart \
                ${sysconfdir}/sddm.conf.d ${sysconfdir}/sudoers.d"
