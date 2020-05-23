#!/bin/bash

source 00-rootfs-setup-env.sh
source 40-xen-setup-env.sh

[ ! -f $XEN_IMAGE_TAR_FILE ] &&  echo "$XEN_IMAGE_TAR_FILE not found" && exit 0
[ ! -f $TARGET_DISK_FILE ] &&  echo "$TARGET_DISK_FILE not found" && exit 0

echo "Building: $TARGET_ROOTFS_DISK_FILE"

rm -rf $TARGET_ROOTFS_DISK_FILE
cp $TARGET_DISK_FILE $TARGET_ROOTFS_DISK_FILE

CHROOT_SCRIPT="/tmp/chroot-script.sh"
rm -rf  $CHROOT_SCRIPT
cat <<EOF > $CHROOT_SCRIPT
$XEN_CHROOT_SCRIPT
apt-get -y clean
apt-get -y remove python3
apt-get -y remove perl

apt-get -y remove  binutils-aarch64-linux-gnu libc-dev-bin \
   zlib1g-dev linux-libc-dev libpcre3-dev libc6-dev \
   make libsqlite3-0 patch perl-modules-5.26 python3-minimal python3.6 \
   python3.6-minimal libperl5.26 libpython3-stdlib libpython3.6-minimal libpython3.6-stdlib \
   binutils  binutils-common libbinutils libexpat1 libgdbm-compat4 libgdbm5 libmpdec2 libpcre16-3 \
   libpcre32-3 libpcrecpp0v5 libreadline7 mime-support readline-common

#libglib2.0-0 libglib2.0-bin libglib2.0-data


rm -rf /var/cache/apt
rm -rf /var/lib/apt
rm -rf /var/log/apt
rm /usr/lib/apt/apt.systemd.daily
rm -rf /usr/include/*
rm -rf /include
rm -rf /usr/locale
rm -rf /lib/*.a
rm -rf /usr/lib/aarch64-linux-gnu/*.a
rm -rf /usr/share/*
rm -rf /share/*
rm -rf /usr/lib/aarch64-linux-gnu/perl-base

rm -rf /var/run/
ln -s /run /var/
EOF
export ROOTFS_DISK_PATH=$TARGET_ROOTFS_DISK_FILE
source 12-chroot-run.sh
sudo tar -xzf $XEN_IMAGE_TAR_FILE -C $TMP_DIR
chroot_run_script $CHROOT_SCRIPT
rm -rf $CHROOT_SCRIPT
cleanup_on_exit

