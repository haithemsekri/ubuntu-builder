#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $XEN_IMAGE_FILE ]  && XEN_IMAGE_FILE="$BUILD_DIR/xen-distro.tar.gz"

XEN_CHROOT_SCRIPT=$(cat <<EOF
#/lib/systemd/systemd-sysv-install enable xendomains
#/lib/systemd/systemd-sysv-install enable xendriverdomain
#/lib/systemd/systemd-sysv-install enable xen-watchdog
#/lib/systemd/systemd-sysv-install enable xendomains
rm -rf /usr/lib/modules-load.d/xen.conf
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

