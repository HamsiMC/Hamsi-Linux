# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux graphical UEFI/GPT installer"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://hamsi-installer \
    file://hamsi-installer.desktop \
    file://org.hamsi.installer.policy \
"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${libexecdir} ${D}${datadir}/applications \
               ${D}${datadir}/polkit-1/actions ${D}${sysconfdir}
    install -m 0755 ${UNPACKDIR}/hamsi-installer \
        ${D}${libexecdir}/hamsi-installer
    install -m 0644 ${UNPACKDIR}/hamsi-installer.desktop \
        ${D}${datadir}/applications/hamsi-installer.desktop
    install -m 0644 ${UNPACKDIR}/org.hamsi.installer.policy \
        ${D}${datadir}/polkit-1/actions/org.hamsi.installer.policy
    touch ${D}${sysconfdir}/hamsi-live
}

RDEPENDS:${PN} = " \
    bash coreutils util-linux util-linux-blkid util-linux-lsblk \
    e2fsprogs dosfstools parted gptfdisk rsync systemd shadow \
    polkit zenity grep sed gawk findutils \
"

CONFFILES:${PN} += "${sysconfdir}/hamsi-live"
