#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $DL_DIR ]               && echo "DL_DIR not defined" && exit 0
[ -z $DISTRO_NAME ]          && echo "DISTRO_NAME not defined" && exit 0
[ -z $TARGET_ARCH ]          && echo "TARGET_ARCH not defined" && exit 0
[ -z $SCRIPTS_DIR ]          && echo "SCRIPTS_DIR not defined" && exit 0
[ -z $ROOTFS_TARGET_TAR ]    && echo "ROOTFS_TARGET_TAR not defined" && exit 0

[ -z $ROOTFS_BASE_TAR_URL ]  && ROOTFS_BASE_TAR_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/$DISTRO_NAME-$TARGET_ARCH-base.tar.xz"
[ -z $ROOTFS_BASE_TAR ]      && ROOTFS_BASE_TAR="$DL_DIR/$(basename $ROOTFS_BASE_TAR_URL)"
[ ! -f $ROOTFS_BASE_TAR ]    && wget $ROOTFS_BASE_TAR_URL -O $ROOTFS_BASE_TAR
[ ! -f $ROOTFS_BASE_TAR ]    && echo "$ROOTFS_BASE_TAR : file not found"

if [ "$1" == "--rebuild" ]; then
   echo -n ""
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $ROOTFS_TARGET_DISK"
   rm -rf "$ROOTFS_TARGET_DISK"
fi

if [ ! -f $ROOTFS_TARGET_DISK ]; then
   echo "Setup $ROOTFS_TARGET_DISK"
   $SCRIPTS_DIR/10-tar-to-disk-image.sh $ROOTFS_BASE_TAR $ROOTFS_TARGET_DISK $ROOTFS_TARGET_SIZE_MB
fi

