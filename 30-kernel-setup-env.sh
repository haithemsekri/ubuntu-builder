#!/bin/bash

[ -z $KERNEL_DL_FILE ] && KERNEL_DL_FILE="$(pwd)/sources/linux-4.19.75.tar.gz"
[ -z $KERNEL_DL_URL ]  && KERNEL_DL_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.75.tar.gz"

[ -z $KERNEL_DOM0_BUILD_PATH ] && KERNEL_DOM0_BUILD_PATH="$(pwd)/build/linux-4.19.75"
[ -z $KERNEL_DOM0_IMAGE_FILE ] && KERNEL_DOM0_IMAGE_FILE="$(pwd)/cache/linux-4.19.75-dom0.tar.gz"
[ -z $KERNEL_DOM0_BIN_FILE ] && KERNEL_DOM0_BIN_FILE="$KERNEL_DOM0_BUILD_PATH/arch/arm64/boot/Image"
[ -z $KERNEL_DOM0_DTB_FILE ] && KERNEL_DOM0_DTB_FILE="$KERNEL_DOM0_BUILD_PATH/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dtb"
[ -z $KERNEL_DOM0_BOOT_FILE ] && KERNEL_DOM0_BOOT_FILE="32-kernel-boot-env.cmd"

[ -z $KERNEL_DOMU_BUILD_PATH ] && KERNEL_DOMU_BUILD_PATH="$(pwd)/build/linux-4.19.75"
[ -z $KERNEL_DOMU_IMAGE_FILE ] && KERNEL_DOMU_IMAGE_FILE="$(pwd)/cache/linux-4.19.75-domu.tar.gz"
[ -z $KERNEL_DOMU_BIN_FILE ] && KERNEL_DOMU_BIN_FILE="$KERNEL_DOMU_BUILD_PATH/arch/arm64/boot/Image"
