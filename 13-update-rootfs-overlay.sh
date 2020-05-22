#!/bin/bash

[ ! -f $1 ] &&  echo "Invalid arg1 for image file" && exit 0
[ ! -d $2 ] &&  echo "Invalid arg2 for overlay directory" && exit 0

DISK_IMAGE_PATH="$(realpath $1)"
OVERLAY_DIR=$2
TMP_DIR="$(pwd)/update-rootfs-overlay.tmp"

[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
sudo umount $TMP_DIR 2>/dev/null
sudo mount -o loop $DISK_IMAGE_PATH $TMP_DIR
MTAB_ENTRY="$(mount | egrep "$ROOTFS_DISK_PATH" | egrep "$TMP_DIR")"
[ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $TMP_DIR  && exit 0
sudo rsync -avlz $OVERLAY_DIR/ ${TMP_DIR}/
sync
sudo umount $TMP_DIR
rm -rf $TMP_DIR
