#!/bin/bash

source 00-rootfs-setup-env.sh
source 40-xen-setup-env.sh

[ ! -f $XEN_IMAGE_TAR_FILE ] &&  echo "$XEN_IMAGE_TAR_FILE not found" && exit 0
[ ! -f $TARGET_DISK_FILE ] &&  echo "$TARGET_DISK_FILE not found" && exit 0

rm -rf $TARGET_ROOTFS_DISK_FILE
cp $TARGET_DISK_FILE $TARGET_ROOTFS_DISK_FILE

CHROOT_SCRIPT="/tmp/chroot-script.sh"
rm -rf  $CHROOT_SCRIPT
cat <<EOF > $CHROOT_SCRIPT
/lib/systemd/systemd-sysv-install enable xendomains
/lib/systemd/systemd-sysv-install enable xendriverdomain
/lib/systemd/systemd-sysv-install enable xen-watchdog

mkdir -p etc/systemd/system/multi-user.target.wants
cd etc/systemd/system/multi-user.target.wants/
ln -s /lib/systemd/system/xenconsoled.service
ln -s /lib/systemd/system/xen-init-dom0.service
ln -s /lib/systemd/system/xen-qemu-dom0-disk-backend.service
ln -s /lib/systemd/system/xenstored.service
cd -
EOF
export ROOTFS_DISK_PATH=$TARGET_ROOTFS_DISK_FILE
source 12-chroot-run.sh
sudo tar -xzf $XEN_IMAGE_TAR_FILE -C $TMP_DIR
chroot_run_script $CHROOT_SCRIPT
ls -l $TMP_DIR/etc/systemd/system/multi-user.target.wants/
rm -rf $CHROOT_SCRIPT
cleanup_on_exit

