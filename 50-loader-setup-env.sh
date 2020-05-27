#!/bin/bash

[ -z $UBOOT_DL_FILE ] && UBOOT_DL_FILE="$(pwd)/sources/uboot-v2019.10.tar.gz"
[ -z $UBOOT_DL_URL ]  && UBOOT_DL_URL="https://github.com/u-boot/u-boot/archive/v2019.10.tar.gz"

[ -z $UBOOT_BUILD_PATH ] && UBOOT_BUILD_PATH="$(pwd)/build/uboot-v2019.10"
[ -z $UBOOT_IMAGE_FILE ] && UBOOT_IMAGE_FILE="$(pwd)/cache/uboot-image-v2019.10.tar.gz"
[ -z $UBOOT_LOADER_DISK ] && UBOOT_LOADER_DISK="$(pwd)/loader.bin"
[ -z $UBOOT_BOOT_DISK ] && UBOOT_BOOT_DISK="$(pwd)/build/boot.vfat"
[ -z $UBOOT_BOOT_DISK_SIZE_KB ] && UBOOT_BOOT_DISK_SIZE_KB="49152"
[ -z $UBOOT_BOOT_LOADER_DISK ] && UBOOT_BOOT_LOADER_DISK="$(pwd)/build/boot-loader.bin"


