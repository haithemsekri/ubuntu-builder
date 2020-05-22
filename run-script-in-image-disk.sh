#!/bin/bash

CHROOT_DISK_PATH=$1
CHROOT_SCRIPT_PATH=$2

[ ! -f $CHROOT_DISK_PATH ] &&  echo "invalid arg1 for image disk" && exit 0
[ ! -f $CHROOT_SCRIPT_PATH ] &&  echo "invalid arg2 for script to run in chroot" && exit 0

TMP_DIR="rootfs.tmp"
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
sudo umount $TMP_DIR 2>/dev/null
sudo mount -o loop $CHROOT_DISK_PATH $TMP_DIR
[ ! -f $TMP_DIR/bin/sh ] && echo "/bin/sh not find in the rootfs" && exit 0
[ ! -f $TMP_DIR/usr/bin/qemu-aarch64-static ] && sudo cp /usr/bin/qemu-aarch64-static $TMP_DIR/usr/bin/qemu-aarch64-static

sudo cp $CHROOT_SCRIPT_PATH $TMP_DIR/chroot-script.sh
sudo chmod 755 $TMP_DIR/chroot-script.sh

chroot_run_script_cleanup_on_exit () {
   echo "chroot_run_script_cleanup_on_exit"
   sync
   sudo umount ${TMP_DIR}/proc ${TMP_DIR}/dev/pts ${TMP_DIR}/dev ${TMP_DIR}/sys ${TMP_DIR}/tmp 2>/dev/null
   sudo umount ${TMP_DIR}/proc ${TMP_DIR}/dev/pts ${TMP_DIR}/dev ${TMP_DIR}/sys ${TMP_DIR}/tmp 2>/dev/null

   sudo umount $TMP_DIR

   if [[ "$(findmnt -n -o SOURCE --target $TMP_DIR)" == *"/dev/loop"* ]]; then
      echo "partition is mounted : umounting"
      sudo umount $(findmnt -n -o SOURCE --target $TMP_DIR)
   fi

   rm -rf $TMP_DIR
   e2fsck -f -y $CHROOT_DISK_PATH
}

trap chroot_run_script_cleanup_on_exit EXIT

sudo mount -o bind /proc ${TMP_DIR}/proc
sudo mount -o bind /dev ${TMP_DIR}/dev
sudo mount -o bind /dev/pts ${TMP_DIR}/dev/pts
sudo mount -o bind /sys ${TMP_DIR}/sys
sudo mount -o bind /tmp ${TMP_DIR}/tmp

sudo chroot $TMP_DIR /bin/sh /chroot-script.sh

