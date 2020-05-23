#!/bin/bash


[ -z $DL_XEN_FILE ] && DL_XEN_FILE="$(pwd)/sources/xen-4.11.4.tar.gz"
[ -z $DL_XEN_URL ]  && DL_XEN_URL="https://downloads.xenproject.org/release/xen/4.11.4/xen-4.11.4.tar.gz"
[ -z $XEN_IMAGE_TAR_FILE ]  && XEN_IMAGE_TAR_FILE="$(pwd)/cache/xen-overlays-4.11.4.tar.gz"
[ -z $XEN_TAR_DIR_NAME ]  && XEN_TAR_DIR_NAME="xen-4.11.4"

XEN_CHROOT_SCRIPT=$(cat <<EOF
#/lib/systemd/systemd-sysv-install enable xendomains
#/lib/systemd/systemd-sysv-install enable xendriverdomain
#/lib/systemd/systemd-sysv-install enable xen-watchdog
#/lib/systemd/systemd-sysv-install enable xendomains

mkdir -p /etc/systemd/system/multi-user.target.wants
cd /etc/systemd/system/multi-user.target.wants/
ln -s /lib/systemd/system/xenconsoled.service
ln -s /lib/systemd/system/xendriverdomain.service
ln -s /lib/systemd/system/xen-watchdog.service
ln -s /lib/systemd/system/xendomains.service
ln -s /lib/systemd/system/xen-qemu-dom0-disk-backend.service
ln -s /lib/systemd/system/xen-init-dom0.service
ln -s /lib/systemd/system/xenstored.service
cd -
EOF
)

