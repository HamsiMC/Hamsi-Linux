# SPDX-License-Identifier: MIT

SUMMARY = "Official Blender Foundation x86-64 binary distribution"
HOMEPAGE = "https://www.blender.org/"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0-only;md5=c79ff39f19dfec6d293b95dea7b07891"

SRC_URI = " \
    https://download.blender.org/release/Blender5.2/blender-${PV}-linux-x64.tar.xz \
    file://blender.desktop \
"
SRC_URI[sha256sum] = "96f6c181a30f4950607839dc84d42a354b250d8a0231b098b59b7bc69c351c48"

S = "${UNPACKDIR}/blender-${PV}-linux-x64"

COMPATIBLE_HOST = "x86_64.*-linux"

do_install() {
    install -d ${D}/opt/blender ${D}${bindir} ${D}${datadir}/applications
    cp -a ${S}/. ${D}/opt/blender/
    ln -s /opt/blender/blender ${D}${bindir}/blender
    install -m 0644 ${UNPACKDIR}/blender.desktop \
        ${D}${datadir}/applications/blender.desktop

    install -d ${D}${datadir}/icons/hicolor/scalable/apps
    if [ -f ${S}/blender.svg ]; then
        install -m 0644 ${S}/blender.svg \
            ${D}${datadir}/icons/hicolor/scalable/apps/blender.svg
    fi
}

RDEPENDS:${PN} += " \
    glibc libgcc libstdc++ libx11 libxi libxfixes libxrender libxxf86vm \
    libxkbcommon libxcb mesa vulkan-loader alsa-lib dbus fontconfig \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP:${PN} += "already-stripped buildpaths file-rdeps ldflags libdir rpaths staticdev"
FILES:${PN} = "/opt/blender ${bindir}/blender ${datadir}/applications/blender.desktop ${datadir}/icons"
