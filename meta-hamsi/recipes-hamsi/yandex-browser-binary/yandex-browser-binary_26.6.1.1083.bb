# SPDX-License-Identifier: MIT

SUMMARY = "Official Yandex Browser stable x86-64 binary package"
HOMEPAGE = "https://browser.yandex.com/"
LICENSE = "CLOSED"
LICENSE_FLAGS = "commercial_yandex"

SRC_URI = " \
    https://repo.yandex.ru/yandex-browser/rpm/stable/x86_64/yandex-browser-stable-${PV}-1.x86_64.rpm;subdir=yandex-rpm \
    file://yandex-browser.desktop \
"
SRC_URI[sha256sum] = "4ee50674722598608e61ca40479e98c3be119e630d6cd79f6e8339c52fa07f0a"

S = "${UNPACKDIR}/yandex-rpm"
COMPATIBLE_HOST = "x86_64.*-linux"

do_install() {
    for top in opt usr etc; do
        if [ -e ${S}/$top ]; then
            cp -a ${S}/$top ${D}/
        fi
    done

    install -d ${D}${bindir} ${D}${datadir}/applications
    if [ ! -e ${D}${bindir}/yandex-browser ]; then
        ln -s /opt/yandex/browser/yandex-browser ${D}${bindir}/yandex-browser
    fi
    install -m 0644 ${UNPACKDIR}/yandex-browser.desktop \
        ${D}${datadir}/applications/yandex-browser.desktop

    if [ -e ${D}/opt/yandex/browser/chrome-sandbox ]; then
        chmod 4755 ${D}/opt/yandex/browser/chrome-sandbox
    fi
    if [ -e ${D}/opt/yandex/browser/yandex_sandbox ]; then
        chmod 4755 ${D}/opt/yandex/browser/yandex_sandbox
    fi

    rm -f ${D}${sysconfdir}/cron.daily/yandex-browser || true
}

RDEPENDS:${PN} += " \
    alsa-lib atk at-spi2-atk cairo ca-certificates cups curl dbus expat \
    fontconfig gtk+3 jq libdrm libgcc libstdc++ libx11 libxcomposite \
    libxdamage libxext libxfixes libxrandr libxcb libxkbcommon mesa \
    nspr nss pango squashfs-tools vulkan-loader wget xdg-utils \
"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP:${PN} += "already-stripped buildpaths file-rdeps ldflags libdir rpaths staticdev"
FILES:${PN} = "/opt/yandex ${bindir} ${datadir}/applications ${datadir}/icons ${sysconfdir}"
