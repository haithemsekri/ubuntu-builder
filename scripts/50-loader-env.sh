#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh
source $(dirname $(realpath $0))/00-rootfs-env.sh

if [ "$TARGET_NAME" == "opipc2" ]; then
   [ -z $UBOOT_TARGET_CONFIG ] && UBOOT_TARGET_CONFIG="orangepi_pc2_defconfig"
   [ -z $ATF_TARGET_PLAT ]     && ATF_TARGET_PLAT="sun50i_a64"
   [ -z $UBOOT_ATF_BIN_NAME ]  && UBOOT_ATF_BIN_NAME="u-boot-sunxi-with-spl.bin"
   [ -z $BOOT_KERNEL_ADDR ]  && BOOT_KERNEL_ADDR="0x50000000"
   [ -z $BOOT_XEN_ADDR ]     &&    BOOT_XEN_ADDR="0x46000000"
   [ -z $BOOT_DTB_ADDR ]     &&    BOOT_DTB_ADDR="0x45000000"
   [ -z $BOOT_SRC_ADDR ]     &&    BOOT_SRC_ADDR="0x44000000"
fi

[ -z $UBOOT_DL_URL ]  && UBOOT_DL_URL="ftp://ftp.denx.de/pub/u-boot/u-boot-2020.04.tar.bz2"
[ -z $UBOOT_DL_FILE ] && UBOOT_DL_FILE="$DL_DIR/u-boot-2020.04.tar.bz2"

[ -z $ATF_DL_URL ]  && ATF_DL_URL="https://github.com/ARM-software/arm-trusted-firmware/archive/v2.3.tar.gz"
[ -z $ATF_DL_FILE ] && ATF_DL_FILE="$DL_DIR/atf-v2.3.tar.gz"

[ -z $UBOOT_ATF_IMAGE_FILE ] && UBOOT_ATF_IMAGE_FILE="$BUILD_DIR/uboot-atf.tar.gz"
[ -z $LOADER_DISK ] && LOADER_DISK="$BUILD_DIR/loader-disk.img"
[ -z $BOOTFS_DISK ] && BOOTFS_DISK="$BUILD_DIR/boot-disk.$EXT_FS_TYPE"


[ -z "$BOOTFS_LOAD_CMD" ]  && BOOTFS_LOAD_CMD="ext4load usb 0:1"
[ -z "$ROOTFS_DISK_PART" ] && ROOTFS_DISK_PART="/dev/sda1"

[ -z $LOADER_PART_SIZE ] && LOADER_PART_SIZE=2     ##MegaBytes
[ -z $BOOT_PART_SIZE ]   && BOOT_PART_SIZE=64      ##MegaBytes
[ -z $ROOTA_PART_SIZE ]  && ROOTA_PART_SIZE=1024   ##MegaBytes
[ -z $ROOTB_PART_SIZE ]  && ROOTB_PART_SIZE=1024   ##MegaBytes
[ -z $DATA_PART_SIZE ]   && DATA_PART_SIZE=8192    ##-1 to use the rest of the disk

