#!/bin/bash

[ -z $DL_ROOTFS_FILE ] && DL_ROOTFS_FILE="$(pwd)/sources/ubuntu-base-18.04.1-base-arm64.tar.gz"
[ -z $DL_ROOTFS_URL ]  && DL_ROOTFS_URL="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.1-base-arm64.tar.gz"

[ -z $EXT_FS_TYPE ]    && EXT_FS_TYPE="ext3"
[ -z $MKFS_CMD ]       && MKFS_CMD="mkfs.$EXT_FS_TYPE"

[ -z $BASE_DISK_FILE ] && BASE_DISK_FILE="$(pwd)/build/ubuntu-18.04-base-arm64.$EXT_FS_TYPE"
[ -z $BASE_TAR_FILE ]  && BASE_TAR_FILE="$(pwd)/cache/ubuntu-18.04-base-arm64.tar.gz"

[ -z $TARGET_DISK_FILE ] && TARGET_DISK_FILE=$BASE_DISK_FILE
[ -z $TARGET_TAR_FILE ]  && TARGET_TAR_FILE=$BASE_TAR_FILE

[ -z $DEV_DISK_FILE ] && DEV_DISK_FILE=$BASE_DISK_FILE
[ -z $DEV_TAR_FILE ]  && DEV_TAR_FILE=$BASE_TAR_FILE


[ -z $TARGET_ROOTFS_DISK_FILE ] && TARGET_ROOTFS_DISK_FILE="$(pwd)/build/ubuntu-18.04-rootfs-arm64.$EXT_FS_TYPE"
