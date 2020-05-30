#!/bin/bash

source $(dirname $(realpath $0))/00-rootfs-env.sh

SRC_DISK_PATH=$1
DEST_TAR_PATH=$2
TMP_DIR="$BUILD_DIR/disk-image-to-tar.tmp"

[ ! -f "$SRC_DISK_PATH" ] &&  echo "Invalid arg1 for source image file" && exit 0
[ -z $DEST_TAR_PATH ] &&  echo "Invalid arg2 for destination tar file" && exit 0
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR

sudo umount $TMP_DIR 2>/dev/null
sudo mount -o loop $SRC_DISK_PATH $TMP_DIR
MTAB_ENTRY="$(mount | egrep "$SRC_DISK_PATH" | egrep "$TMP_DIR")"
[ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $TMP_DIR  && exit 0

cd $TMP_DIR
sudo tar --exclude="lost+found" -czf $DEST_TAR_PATH .
sudo chmod 666 $DEST_TAR_PATH
cd -
sync
sudo umount $TMP_DIR
rm -rf $TMP_DIR
