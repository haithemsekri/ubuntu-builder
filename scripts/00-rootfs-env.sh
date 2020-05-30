#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $EXT_FS_TYPE ]    && EXT_FS_TYPE="ext3"
[ -z $MKFS_CMD ]       && MKFS_CMD="mkfs.$EXT_FS_TYPE"

if [ "$TARGET_ARCH" == "aarch64" ]; then
   DISTRO_NAME="ubuntu-18.04-arm64"
   [ -z $ROOTFS_DL_URL ]  && ROOTFS_DL_URL="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.1-base-arm64.tar.gz"
fi

[ -z $ROOTFS_DL_FILE ] && ROOTFS_DL_FILE="$DL_DIR/$DISTRO_NAME-base.tar.gz"

[ -z $ROOTFS_BASE_DISK ] && ROOTFS_BASE_DISK="$BUILD_DIR/$DISTRO_NAME-base.$EXT_FS_TYPE"
[ -z $ROOTFS_BASE_TAR ]  && ROOTFS_BASE_TAR="$BUILD_DIR/$DISTRO_NAME-base.tar.gz"

[ -z $ROOTFS_TARGET_DISK ] && ROOTFS_TARGET_DISK="$BUILD_DIR/$DISTRO_NAME-target.$EXT_FS_TYPE"
[ -z $BOOTFS_TARGET_IMAGE ] && BOOTFS_TARGET_IMAGE="$BUILD_DIR/bootfs-target.tar.gz"
