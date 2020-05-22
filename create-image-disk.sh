#!/bin/bash

[ -z $1 ] &&  echo "empty arg1 for source .tar.gz file" && exit 0
[ -z $2 ] &&  echo "empty arg2 for destination .ext3 file" && exit 0
[ -z $3 ] &&  echo "empty arg3 for destination .ext3 file size in Mega" && exit 0

dd if=/dev/zero of=$2 bs=1M count=$3
sync
mkfs.ext3 $2

TMP_DIR="rootfs.tmp"
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
sudo umount $TMP_DIR 2>/dev/null
sudo mount -o loop $2 $TMP_DIR
sudo tar xzf $1 -C $TMP_DIR
sync
sudo umount $TMP_DIR
rm -rf $TMP_DIR
e2fsck -f -y $2
