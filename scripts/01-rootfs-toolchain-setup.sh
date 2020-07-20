#!/bin/bash

if [ "$1" == "--all" ] || [ "$1" == "--rootfs-base-build" ]; then
   echo -e "\e[30;48;5;82mSetup base rootfs\e[0m"
   [ ! -f $ROOTFS_DL_TAR ]     && echo "$ROOTFS_DL_TAR : file not found"
   [ -z $ROOTFS_DL_TAR ]       && ROOTFS_DL_TAR="$DL_DIR/$(basename $ROOTFS_DL_TAR_URL)"
   [ ! -f $ROOTFS_DL_TAR ]     && wget $ROOTFS_DL_TAR_URL -O $ROOTFS_DL_TAR
   if [ ! -f $ROOTFS_BASE_DISK ]; then
      rm -rf $ROOTFS_BASE_DISK
      rm -rf $ROOTFS_BASE_TAR
      $SCRIPTS_DIR/10-tar-to-disk-image.sh $ROOTFS_DL_TAR $ROOTFS_BASE_DISK $ROOTFS_SIZE_MB
      cp $ROOTFS_DL_TAR $ROOTFS_BASE_TAR
      chmod 666 $ROOTFS_BASE_TAR
   fi
fi

if [ "$1" == "--all" ] || [ "$1" == "--toolchain-build" ]; then
   echo -e "\e[30;48;5;82mSetup toolchain\e[0m"
   [ -z $TOOLCHAIN_DL_TAR ]      && TOOLCHAIN_DL_TAR="$DL_DIR/$(basename $TOOLCHAIN_DL_URL)"
   [ ! -f $TOOLCHAIN_DL_TAR ]    && wget $TOOLCHAIN_DL_URL -O $TOOLCHAIN_DL_TAR
   [ ! -f $TOOLCHAIN_DL_TAR ]    && echo "$TOOLCHAIN_DL_TAR : file not found"
   if [ ! -d $TOOLCHAIN_PATH ]; then
      rm -rf "$TOOLCHAIN_PATH"
      mkdir -p $TOOLCHAIN_PATH
      tar -xf $TOOLCHAIN_DL_TAR -C $TOOLCHAIN_PATH/
   fi
fi
