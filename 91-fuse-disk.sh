#!/bin/bash

source 00-rootfs-setup-env.sh

DEVICE_PATH=$1

[ -z $DEVICE_PATH ] && echo "Invalid argument" && exit 0
[ ! -b $DEVICE_PATH ] && echo "$DEVICE_PATH : file not found" && exit 0
[ ! -f $TARGET_ROOTFS_DISK_FILE ] && echo "$TARGET_ROOTFS_DISK_FILE : file not found" && exit 0

IMAGE_PATH="build/sd-disk.img"

IMAGE_FREE_SIZE="268435456"
IMAGE_SIZE=$(stat --printf="%s" $TARGET_ROOTFS_DISK_FILE)
IMAGE_SIZE="$(expr "$IMAGE_SIZE" + 2097152)"
IMAGE_SIZE="$(expr "$IMAGE_SIZE" + $IMAGE_FREE_SIZE)"

if [ ! -f $IMAGE_PATH ]; then
   dd if=/dev/zero of=$IMAGE_PATH bs=$IMAGE_SIZE count=1
   /sbin/parted $IMAGE_PATH --script -- mklabel msdos
   /sbin/parted $IMAGE_PATH --script -- mkpart primary ext3 4096s -1s
   dd if=uboot-spl.bin of=$IMAGE_PATH seek=16 conv=notrunc
fi

e2fsck -f -y $TARGET_ROOTFS_DISK_FILE
resize2fs -M $TARGET_ROOTFS_DISK_FILE
dd if=$TARGET_ROOTFS_DISK_FILE of=$IMAGE_PATH seek=4096

sudo dd if=$IMAGE_PATH of=$DEVICE_PATH status=progress
sync
sudo umount "$DEVICE_PATH"1
sudo e2fsck -f -y "$DEVICE_PATH"1
sudo resize2fs "$DEVICE_PATH"1
