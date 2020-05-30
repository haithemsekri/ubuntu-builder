#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh
source $(dirname $(realpath $0))/00-rootfs-env.sh
source $(dirname $(realpath $0))/50-loader-env.sh

[ ! -f $BOOTFS_TARGET_IMAGE ] && echo "$BOOTFS_TARGET_IMAGE : file not found" && exit 0
[ ! -f $UBOOT_ATF_IMAGE_FILE ] && echo "$UBOOT_ATF_IMAGE_FILE : file not found" && exit 0

rm -rf LOADER_DISK

echo "BOOTFS_TARGET_IMAGE: $BOOTFS_TARGET_IMAGE"
echo "UBOOT_ATF_IMAGE_FILE: $UBOOT_ATF_IMAGE_FILE"
echo "Building: $LOADER_DISK"

IMAGE_SIZE=0
IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$LOADER_PART_SIZE")
IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$BOOT_PART_SIZE")
IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$ROOTA_PART_SIZE")
IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$ROOTB_PART_SIZE")
IMAGE_SIZE=$(expr "$IMAGE_SIZE" + "$DATA_PART_SIZE")

[ "$IMAGE_SIZE" == "0" ] && echo "IMAGE_SIZE : cannot create an empty image" && exit 0

dd if=/dev/zero of=$LOADER_DISK bs=1M count=$IMAGE_SIZE
/sbin/parted $LOADER_DISK --script -- mklabel msdos

START_BLOCKS=0
END_BLOCKS=$((2048*$LOADER_PART_SIZE+$START_BLOCKS-1))
echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
TRUNC_BLOCK=$((2048*$LOADER_PART_SIZE))

if [ $BOOT_PART_SIZE != 0 ]; then
START_BLOCKS=$(($END_BLOCKS+1))
END_BLOCKS=$((2048*$BOOT_PART_SIZE+$START_BLOCKS-1))
#TRUNC_BLOCK=$(($END_BLOCKS+1))
echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
/sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
fi

if [ $ROOTA_PART_SIZE != 0 ]; then
START_BLOCKS=$(($END_BLOCKS+1))
END_BLOCKS=$((2048*$ROOTA_PART_SIZE+$START_BLOCKS-1))
echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
/sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
fi

if [ $ROOTB_PART_SIZE != 0 ]; then
START_BLOCKS=$(($END_BLOCKS+1))
END_BLOCKS=$((2048*$ROOTB_PART_SIZE+$START_BLOCKS-1))
echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
/sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
fi

if [ $DATA_PART_SIZE != 0 ]; then
START_BLOCKS=$(($END_BLOCKS+1))
END_BLOCKS=$((2048*$DATA_PART_SIZE+$START_BLOCKS-1))
echo "START_BLOCKS: $START_BLOCKS, END_BLOCKS: $END_BLOCKS"
/sbin/parted $LOADER_DISK --script -- mkpart primary $EXT_FS_TYPE "$START_BLOCKS"s "$END_BLOCKS"s
fi

TMP_DIR=$BUILD_DIR/build.bootfs.disk.tmp
rm -rf $TMP_DIR
mkdir $TMP_DIR
tar -xzf $UBOOT_ATF_IMAGE_FILE -C $TMP_DIR
[ ! -f $TMP_DIR/u-boot-spl ] && echo "$TMP_DIR/u-boot-spl : file not found" && rm -rf $TMP_DIR && exit 0

echo "Writing uboot-spl"
dd if=$TMP_DIR/u-boot-spl of=$LOADER_DISK seek=16 conv=notrunc
rm -rf $TMP_DIR

echo "TRUNC_BLOCK: $TRUNC_BLOCK"
truncate -s $((512*$TRUNC_BLOCK)) $LOADER_DISK
