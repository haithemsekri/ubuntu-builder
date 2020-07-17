#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $DL_DIR ]               && echo "DL_DIR not defined" && exit 0
[ -z $DISTRO_NAME ]          && echo "DISTRO_NAME not defined" && exit 0
[ -z $TARGET_ARCH ]          && echo "TARGET_ARCH not defined" && exit 0
[ -z $SCRIPTS_DIR ]          && echo "SCRIPTS_DIR not defined" && exit 0
[ -z $ROOTFS_TARGET_TAR ]    && echo "ROOTFS_TARGET_TAR not defined" && exit 0

if [ "$TARGET_ARCH" == "arm64" ]; then
   [ -z $TOOLCHAIN_DL_URL ]   && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz"
elif [ "$TARGET_ARCH" == "arm32" ]; then
   [ -z $TOOLCHAIN_DL_URL ]   && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz"
else
   echo "Unknown toolchain arch name: $TARGET_ARCH"
   exit -1
fi
[ -z $TOOLCHAIN_DL_TAR ]      && TOOLCHAIN_DL_TAR="$DL_DIR/$(basename $TOOLCHAIN_DL_URL)"
[ ! -f $TOOLCHAIN_DL_TAR ]    && wget $TOOLCHAIN_DL_URL -O $TOOLCHAIN_DL_TAR
[ ! -f $TOOLCHAIN_DL_TAR ]    && echo "$TOOLCHAIN_DL_TAR : file not found"

[ -z $ROOTFS_DL_TAR_URL ]   && ROOTFS_DL_TAR_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/$DISTRO_NAME-$TARGET_ARCH-base.tar.xz"
[ -z $ROOTFS_DL_TAR ]       && ROOTFS_DL_TAR="$DL_DIR/$(basename $ROOTFS_DL_TAR_URL)"
[ ! -f $ROOTFS_DL_TAR ]     && wget $ROOTFS_DL_TAR_URL -O $ROOTFS_DL_TAR
[ ! -f $ROOTFS_DL_TAR ]     && echo "$ROOTFS_DL_TAR : file not found"

if [ "$1" == "--rootfs-base-build" ]; then
   echo "Setup $ROOTFS_BASE_DISK"
   rm -rf $ROOTFS_BASE_DISK
   $SCRIPTS_DIR/10-tar-to-disk-image.sh $ROOTFS_DL_TAR $ROOTFS_BASE_DISK $ROOTFS_TARGET_SIZE_MB
   cp $ROOTFS_DL_TAR $ROOTFS_BASE_TAR
fi

if [ "$1" == "--toolchain-build" ]; then
   echo "Setup toolchain: $TOOLCHAIN_PATH"
   rm -rf "$TOOLCHAIN_PATH"
   TMP_DIR="$BUILD_DIR/tar-xf-tmp"
   mkdir -p $TMP_DIR
   tar -xf $TOOLCHAIN_DL_TAR -C $TMP_DIR/
   sync
   mv $TMP_DIR/* $TOOLCHAIN_PATH
   rm -rf $TMP_DIR
fi
