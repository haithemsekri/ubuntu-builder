#!/bin/bash

[ ! -f $ROOTFS_DISK_PATH ] &&  echo "invalid arg1 for image disk" && exit 0

TMP_DIR="$(pwd)/chroot-run-shell.tmp"
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
sudo umount $TMP_DIR 2>/dev/null
sudo mount -o loop $ROOTFS_DISK_PATH $TMP_DIR
MTAB_ENTRY="$(mount | egrep "$ROOTFS_DISK_PATH" | egrep "$TMP_DIR")"
[ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $TMP_DIR  && exit 0

chroot_mount_pseudo_fs () {
   sudo mkdir ${TMP_DIR}/proc ${TMP_DIR}/dev ${TMP_DIR}/dev/pts ${TMP_DIR}/sys ${TMP_DIR}/tmp 2>/dev/null
   sudo mount -o bind /proc ${TMP_DIR}/proc
   sudo mount -o bind /dev ${TMP_DIR}/dev
   sudo mount -o bind /dev/pts ${TMP_DIR}/dev/pts
   sudo mount -o bind /sys ${TMP_DIR}/sys
   sudo mount -o bind /tmp ${TMP_DIR}/tmp
}

chroot_umount_pseudo_fs () {
   sudo umount ${TMP_DIR}/proc ${TMP_DIR}/dev/pts ${TMP_DIR}/dev ${TMP_DIR}/sys ${TMP_DIR}/tmp 2>/dev/null
   sudo umount ${TMP_DIR}/* 2>/dev/null
   sudo umount ${TMP_DIR}/proc ${TMP_DIR}/dev/pts ${TMP_DIR}/dev ${TMP_DIR}/sys ${TMP_DIR}/tmp 2>/dev/null
   sudo umount ${TMP_DIR}/* 2>/dev/null
}

cleanup_on_exit () {
   MTAB_ENTRY="$(mount | egrep "$ROOTFS_DISK_PATH" | egrep "$TMP_DIR")"
   if [ ! -z "$MTAB_ENTRY" ]; then
      echo "cleanup_on_exit"
      sync
      chroot_umount_pseudo_fs
      sudo chroot $TMP_DIR /bin/bash -c "chown -R root:root /; rm -rf /tmp/*; rm -rf /sys/*; rm -rf /proc/*"
      sudo umount $TMP_DIR
      rm -rf $TMP_DIR
   fi
}

chroot_run_script () {
   CHROOT_SCRIPT_PATH=$1
   [ ! -f $CHROOT_SCRIPT_PATH ] &&  echo "Invalid arg1 for script to run in chroot" && exit 0
   sudo cp $CHROOT_SCRIPT_PATH $TMP_DIR/chroot-script.sh
   sudo chmod 755 $TMP_DIR/chroot-script.sh
   sudo chroot $TMP_DIR /bin/bash /chroot-script.sh
   sudo rm -rf $TMP_DIR/chroot-script.sh
}

trap cleanup_on_exit EXIT

[ ! -f $TMP_DIR/usr/bin/qemu-aarch64-static ] && sudo cp /usr/bin/qemu-aarch64-static $TMP_DIR/usr/bin/qemu-aarch64-static
chroot_mount_pseudo_fs
