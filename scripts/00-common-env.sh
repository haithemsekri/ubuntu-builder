#!/bin/bash

#Platform :##########################################
[ -z "$DISTRO_NAME" ]           && DISTRO_NAME="centos-7"
[ -z "$TARGET_ARCH" ]           && TARGET_ARCH="arm64"
[ -z "$USE_SYSTEMD" ]           && USE_SYSTEMD="YES"
[ -z "$TARGET_NAME" ]           && TARGET_NAME="opipc2"
[ -z "$EXT_FS_TYPE" ]           && EXT_FS_TYPE="ext3"
[ -z "$ROOTFS_TARGET_SIZE_MB" ] && ROOTFS_TARGET_SIZE_MB="1024"

#Wrokspace :##########################################
[ -z $TARGET_BUILD_NAME ]     && TARGET_BUILD_NAME="$DISTRO_NAME-$TARGET_ARCH-$TARGET_NAME"
[ -z $WORKSPACE ]       && WORKSPACE="$(realpath $(dirname $(realpath $0))/..)"
[ -z $DL_DIR ]          && DL_DIR="$WORKSPACE/dl"
[ -z $SCRIPTS_DIR ]     && SCRIPTS_DIR="$WORKSPACE/scripts"
[ -z $BUILD_DIR ]       && BUILD_DIR="$WORKSPACE/$TARGET_BUILD_NAME"
[ -z $MKFS_CMD ]        && MKFS_CMD="mkfs.$EXT_FS_TYPE"

[ -z $ROOTFS_BASE_DISK ]   && ROOTFS_BASE_DISK="$BUILD_DIR/$TARGET_BUILD_NAME-base.$EXT_FS_TYPE"
[ -z $ROOTFS_BASE_TAR ]    && ROOTFS_BASE_TAR="$BUILD_DIR/$TARGET_BUILD_NAME-base.tar.xz"
[ -z $ROOTFS_TARGET_DISK ] && ROOTFS_TARGET_DISK="$BUILD_DIR/$TARGET_BUILD_NAME-target.$EXT_FS_TYPE"
[ -z $ROOTFS_TARGET_TAR ]  && ROOTFS_TARGET_TAR="$BUILD_DIR/$TARGET_BUILD_NAME-target.tar.xz"
[ -z $BOOTFS_DISK ]        && BOOTFS_DISK="$BUILD_DIR/bootfs.$EXT_FS_TYPE"
[ -z $LOADER_DISK ]        && LOADER_DISK="$BUILD_DIR/loader.raw"
[ -z $SD_DISK_IMG ]        && SD_DISK_IMG="$BUILD_DIR/$TARGET_BUILD_NAME.img"
[ -z $TOOLCHAIN_PATH ]     && TOOLCHAIN_PATH="$BUILD_DIR/linux-gnu-gcc"
[ ! -d $DL_DIR ]           && mkdir $DL_DIR
[ ! -d $BUILD_DIR ]        && mkdir $BUILD_DIR

if [ "$TARGET_ARCH" == "arm64" ]; then
   [ -z $CROSS_PREFIX ]       && export CROSS_PREFIX="aarch64-linux-gnu"
elif [ "$TARGET_ARCH" == "arm32" ]; then
   [ -z $CROSS_PREFIX ]       && export CROSS_PREFIX="arm-linux-gnueabihf"
fi

[ -z $L_CROSS_COMPILE ]  && export L_CROSS_COMPILE="$TOOLCHAIN_PATH/bin/$CROSS_PREFIX-"
[ -z $L_CROSS_PREFIX ]   && export L_CROSS_PREFIX="$CROSS_PREFIX"
[ -z $L_CROSS_ARCH ]     && export L_CROSS_ARCH="$TARGET_ARCH"

[ -z $XEN_TOOLS_IMAGE_FILE ]  && XEN_TOOLS_IMAGE_FILE="$BUILD_DIR/xen-tools-$TARGET_ARCH.tar.xz"
[ -z $XEN_DISTRO_IMAGE_FILE ] && XEN_DISTRO_IMAGE_FILE="$BUILD_DIR/xen-distro-$TARGET_ARCH-$TARGET_NAME.tar.xz"

if [ "$TARGET_NAME" == "opipc2" ]; then
   [ -z $KERNEL_DOM0_URL ]           && KERNEL_DOM0_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/linux-4.19.75.tar.xz"
   [ -z $KERNEL_DOM0_IMG ]           && KERNEL_DOM0_IMG="arch/arm64/boot/Image"
   [ -z $KERNEL_DOM0_DTB ]           && KERNEL_DOM0_DTB="arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dtb"
   [ -z $KERNEL_DOM0_DISTRO_NAME ]   && KERNEL_DOM0_DISTRO_NAME="linux-4.19.75-dom0-opipc2"
   [ -z $KERNEL_DOM0_CONFIG ]        && KERNEL_DOM0_CONFIG="$SCRIPTS_DIR/files/kernel-config-dom0-opipc2.config"
   [ -z $KERNEL_DOM0_PATCH ]         && KERNEL_DOM0_PATCH="$SCRIPTS_DIR/files/kernel-patch-blkif.patch"
   [ -z $KERNEL_DOM0_DISTRO ]        && KERNEL_DOM0_DISTRO="$BUILD_DIR/$KERNEL_DOM0_DISTRO_NAME.tar.xz"

   [ -z $KERNEL_DOMU_URL ]           && KERNEL_DOMU_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/linux-4.19.75.tar.xz"
   [ -z $KERNEL_DOMU_IMG ]           && KERNEL_DOMU_IMG="arch/arm64/boot/Image"
   [ -z $KERNEL_DOMU_DISTRO_NAME ]   && KERNEL_DOMU_DISTRO_NAME="linux-4.19.75-domu-opipc2"
   [ -z $KERNEL_DOMU_CONFIG ]        && KERNEL_DOMU_CONFIG="$SCRIPTS_DIR/files/kernel-config-dom0-opipc2.config"
   [ -z $KERNEL_DOMU_PATCH ]         && KERNEL_DOMU_PATCH="$SCRIPTS_DIR/files/kernel-patch-blkif.patch"
   [ -z $KERNEL_DOMU_DISTRO ]        && KERNEL_DOMU_DISTRO="$BUILD_DIR/$KERNEL_DOMU_DISTRO_NAME.tar.xz"
   [ -z $BOOT_DISTRO_TAR ]           &&  BOOT_DISTRO_TAR="$BUILD_DIR/loader-arm64-opic2.tar.xz"

   [ -z $BOOT_KERNEL_SCRIPT ]    &&  BOOT_KERNEL_SCRIPT="$SCRIPTS_DIR/files/opipc2-kernel-boot-env.cmd"
   [ -z $BOOT_XEN_SCRIPT ]       &&  BOOT_XEN_SCRIPT="$SCRIPTS_DIR/files/opipc2-xen-boot-env.cmd"
   [ -z $BOOT_RTFS_SCRIPT ]      &&  BOOT_RTFS_SCRIPT="$SCRIPTS_DIR/files/opipc2-boot-env.cmd"
fi

