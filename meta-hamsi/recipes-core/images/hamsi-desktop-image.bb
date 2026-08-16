# SPDX-License-Identifier: MIT

SUMMARY = "Hamsi Linux professional live desktop and installation image"
DESCRIPTION = "Independent Hamsi Linux userland with Plasma, applications, live boot and installer"
LICENSE = "MIT"

inherit core-image extrausers

IMAGE_FEATURES += "package-management ssh-server-openssh splash"
IMAGE_INSTALL:append = " \
    packagegroup-hamsi-base \
    packagegroup-hamsi-desktop \
    packagegroup-hamsi-apps \
    hamsi-branding \
    hamsi-installer \
    hamsi-store \
"

SYSTEMD_DEFAULT_TARGET = "graphical.target"

# A compressed read-only root is embedded in the hybrid ISO. The Wic image is
# writable and can be placed directly on USB/NVMe for development and testing.
IMAGE_FSTYPES = "squashfs iso wic.gz wic.bmap"
LIVE_ROOTFS_TYPE = "squashfs"
INITRD_IMAGE_LIVE = "core-image-minimal-initramfs"
INITRAMFS_FSTYPES = "cpio.gz"

EFI_PROVIDER = "systemd-boot"
SYSTEMD_BOOT_TIMEOUT = "5"
WKS_FILE = "hamsi-uefi.wks.in"

IMAGE_ROOTFS_EXTRA_SPACE = "4194304"
IMAGE_OVERHEAD_FACTOR = "1.15"

# The live account has no password and can administer the live session. The
# installer removes this exception, asks for a password and enables wheel.
EXTRA_USERS_PARAMS = " \
    groupadd -f wheel; \
    useradd -m -s /bin/bash -G wheel,audio,video,input,render,lp,disk,dialout hamsi; \
    passwd -d hamsi; \
    usermod -L root; \
"

BAD_RECOMMENDATIONS += "packagegroup-core-x11-xserver"
