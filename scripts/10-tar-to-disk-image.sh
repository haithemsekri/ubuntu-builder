#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

SRC_TAR_FILE=$1
DEST_DISK_FILE=$2
DEST_DISK_SIZE=$3
TMP_DIR="$BUILD_DIR/tar-to-disk-image.tmp"

[ ! -f $SRC_TAR_FILE ] &&  echo "Invalid arg1 for source tar file" && exit 1
[ -z $DEST_DISK_FILE ] &&  echo "Invalid arg2 for destination disk file" && exit 1
[ -z $DEST_DISK_SIZE ] &&  echo "Invalid arg3 for destination file size in Mega" && exit 1
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR

fallocate -l $((1024*1024*$DEST_DISK_SIZE)) $DEST_DISK_FILE  1> /dev/null
$MKFS_CMD $DEST_DISK_FILE  &> /dev/null

umount $TMP_DIR 2>/dev/null
mount -o loop $DEST_DISK_FILE $TMP_DIR
MTAB_ENTRY="$(mount | egrep "$DEST_DISK_FILE" | egrep "$TMP_DIR")"
[ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $TMP_DIR  && exit 1
tar -xf $SRC_TAR_FILE -C $TMP_DIR
sync
umount $TMP_DIR
e2fsck -f -y $DEST_DISK_FILE  &> /dev/null
rm -rf $TMP_DIR
