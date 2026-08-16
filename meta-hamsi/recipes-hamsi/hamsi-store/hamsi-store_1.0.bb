# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Store launcher backed by Plasma Discover and Flatpak"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://hamsi-store \
    file://hamsi-store.desktop \
    file://hamsi-app-bundles \
    file://hamsi-app-bundles.desktop \
"
S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${bindir} ${D}${datadir}/applications
    install -m 0755 ${UNPACKDIR}/hamsi-store ${D}${bindir}/hamsi-store
    install -m 0755 ${UNPACKDIR}/hamsi-app-bundles ${D}${bindir}/hamsi-app-bundles
    install -m 0644 ${UNPACKDIR}/hamsi-store.desktop \
        ${D}${datadir}/applications/hamsi-store.desktop
    install -m 0644 ${UNPACKDIR}/hamsi-app-bundles.desktop \
        ${D}${datadir}/applications/hamsi-app-bundles.desktop
}

RDEPENDS:${PN} = "bash flatpak discover ca-certificates zenity"
