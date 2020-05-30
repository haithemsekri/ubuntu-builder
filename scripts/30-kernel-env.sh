#!/bin/bash

source $(dirname $(realpath $0))/00-rootfs-env.sh

if [ "$TARGET_NAME" == "opipc2" ]; then
   [ -z $KERNEL_DL_FILE ] && KERNEL_DL_FILE="$DL_DIR/linux-kernel-4.19.75.tar.gz"
   [ -z $KERNEL_DL_URL ]  && KERNEL_DL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.75.tar.gz"

   [ -z $KERNEL_DOM0_BIN_NAME ] && KERNEL_DOM0_BIN_NAME="linux-4.19-dom0"
   [ -z $KERNEL_DOM0_BUILD_PATH ] && KERNEL_DOM0_BUILD_PATH="$BUILD_DIR/$KERNEL_DOM0_BIN_NAME"
   [ -z $KERNEL_DOM0_IMAGE_FILE ] && KERNEL_DOM0_IMAGE_FILE="$BUILD_DIR/$KERNEL_DOM0_BIN_NAME-opipc2.tar.gz"
   [ -z $KERNEL_DOM0_BIN_FILE ] && KERNEL_DOM0_BIN_FILE="$KERNEL_DOM0_BUILD_PATH/arch/arm64/boot/Image"
   [ -z $KERNEL_DOM0_DTB_FILE ] && KERNEL_DOM0_DTB_FILE="$KERNEL_DOM0_BUILD_PATH/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dtb"
   [ -z $KERNEL_DOM0_DTB_NAME ] && KERNEL_DOM0_DTB_NAME="linux-4.19-dtb"
   [ -z $KERNEL_DOM0_BOOT_FILE ] && KERNEL_DOM0_BOOT_FILE="$SCRIPTS_DIR/files/32-kernel-boot-env-opipc2.cmd"
   [ -z $KERNEL_DOM0_CONFIG_FILE ] && KERNEL_DOM0_CONFIG_FILE="$SCRIPTS_DIR/files/32-kernel-config-dom0-opipc2.config"

   [ -z $KERNEL_DOMU_BIN_NAME ] && KERNEL_DOMU_BIN_NAME="linux-4.19-domu"
   [ -z $KERNEL_DOMU_BUILD_PATH ] && KERNEL_DOMU_BUILD_PATH="$BUILD_DIR/$KERNEL_DOMU_BIN_NAME"
   [ -z $KERNEL_DOMU_IMAGE_FILE ] && KERNEL_DOMU_IMAGE_FILE="$BUILD_DIR/$KERNEL_DOMU_BIN_NAME-opipc2.tar.gz"
   [ -z $KERNEL_DOMU_BIN_FILE ] && KERNEL_DOMU_BIN_FILE="$KERNEL_DOMU_BUILD_PATH/arch/arm64/boot/Image"
fi
