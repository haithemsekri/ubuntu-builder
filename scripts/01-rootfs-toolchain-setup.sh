#!/bin/bash

if [ "$1" == "--rootfs-base-build" ]; then
   [ ! -f $ROOTFS_DL_TAR ]     && echo "$ROOTFS_DL_TAR : file not found"
   [ -z $ROOTFS_DL_TAR ]       && ROOTFS_DL_TAR="$DL_DIR/$(basename $ROOTFS_DL_TAR_URL)"
   [ ! -f $ROOTFS_DL_TAR ]     && wget $ROOTFS_DL_TAR_URL -O $ROOTFS_DL_TAR
   echo "Setup $ROOTFS_BASE_DISK"
   rm -rf $ROOTFS_BASE_DISK
   rm -rf $ROOTFS_BASE_TAR
   $SCRIPTS_DIR/10-tar-to-disk-image.sh $ROOTFS_DL_TAR $ROOTFS_BASE_DISK $ROOTFS_SIZE_MB
   cp $ROOTFS_DL_TAR $ROOTFS_BASE_TAR
   chmod 666 $ROOTFS_BASE_TAR
fi

if [ "$1" == "--toolchain-build" ]; then
   [ -z $TOOLCHAIN_DL_TAR ]      && TOOLCHAIN_DL_TAR="$DL_DIR/$(basename $TOOLCHAIN_DL_URL)"
   [ ! -f $TOOLCHAIN_DL_TAR ]    && wget $TOOLCHAIN_DL_URL -O $TOOLCHAIN_DL_TAR
   [ ! -f $TOOLCHAIN_DL_TAR ]    && echo "$TOOLCHAIN_DL_TAR : file not found"
   echo "Setup toolchain: $TOOLCHAIN_PATH"
   rm -rf "$TOOLCHAIN_PATH"
   TMP_DIR="$BUILD_DIR/tar-xf-tmp"
   mkdir -p $TMP_DIR
   tar -xf $TOOLCHAIN_DL_TAR -C $TMP_DIR/
   sync
   mv $TMP_DIR/* $TOOLCHAIN_PATH
   rm -rf $TMP_DIR
fi
