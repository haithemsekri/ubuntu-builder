#!/bin/bash

#Platform :##########################################
[ -z $DISTRO_NAME ]           && DISTRO_NAME="centos-7"
[ -z $TARGET_ARCH ]           && TARGET_ARCH="arm64"
[ -z $USE_SYSTEMD ]           && USE_SYSTEMD="YES"
[ -z $TARGET_NAME ]           && TARGET_NAME="opipc2"
[ -z $EXT_FS_TYPE ]           && EXT_FS_TYPE="ext3"
[ -z $ROOTFS_TARGET_SIZE_MB ] && ROOTFS_TARGET_SIZE_MB="1024"
[ -z $BOOTFS_LOAD_CMD ]       && BOOTFS_LOAD_CMD="ext4load usb 0:1" ## Kernel+dtb+xen are located on USB-part1
[ -z $ROOTFS_DISK_PART ]      && ROOTFS_DISK_PART="/dev/sda1" ## Userland rootfs device
[ -z $TARGET_BUILD_NAME ]     && TARGET_BUILD_NAME="$DISTRO_NAME-$TARGET_ARCH-$TARGET_NAME"

#Wrokspace :##########################################
[ -z $WORKSPACE ]       && WORKSPACE="$(realpath $(dirname $(realpath $0))/..)"
[ -z $DL_DIR ]          && DL_DIR="$WORKSPACE/dl"
[ -z $BUILD_DIR ]       && BUILD_DIR="$WORKSPACE/$TARGET_BUILD_NAME"
[ -z $SCRIPTS_DIR ]     && SCRIPTS_DIR="$WORKSPACE/scripts"
[ -z $MKFS_CMD ]        && MKFS_CMD="mkfs.$EXT_FS_TYPE"

[ -z $ROOTFS_TARGET_DISK ]       && ROOTFS_TARGET_DISK="$BUILD_DIR/$TARGET_BUILD_NAME.$EXT_FS_TYPE"
[ -z $ROOTFS_TARGET_TAR ]        && ROOTFS_TARGET_TAR="$BUILD_DIR/$TARGET_BUILD_NAME.tar.xz"
[ -z $TOOLCHAIN_PATH ]           && TOOLCHAIN_PATH="$BUILD_DIR/linux-gnu-gcc"

[ ! -d $DL_DIR ]                 && mkdir $DL_DIR
[ ! -d $BUILD_DIR ]              && mkdir $BUILD_DIR

if [ "$TARGET_ARCH" == "arm64" ]; then
   [ -z $CROSS_PREFIX ]       && export CROSS_PREFIX="aarch64-linux-gnu"
elif [ "$TARGET_ARCH" == "arm32" ]; then
   [ -z $CROSS_PREFIX ]       && export CROSS_PREFIX="arm-linux-gnueabihf"
fi

export L_CROSS_COMPILE="$TOOLCHAIN_PATH/bin/$CROSS_PREFIX-"
export L_CROSS_PREFIX="$CROSS_PREFIX"
export L_CROSS_ARCH="$TARGET_ARCH"

[ -z $XEN_IMAGE_FILE ]  && XEN_IMAGE_FILE="$BUILD_DIR/xen-$TARGET_ARCH.tar.xz"
