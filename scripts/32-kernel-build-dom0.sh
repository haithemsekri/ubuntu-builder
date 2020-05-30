#!/bin/bash

source $(dirname $(realpath $0))/30-kernel-env.sh

[ ! -f $KERNEL_DL_FILE ] && wget $KERNEL_DL_URL -O $KERNEL_DL_FILE
[ ! -f $KERNEL_DL_FILE ] && echo "$KERNEL_DL_FILE : not found"  && exit 0

if [ "$1" == "--rebuild" ]; then
   echo "delete $KERNEL_DOM0_IMAGE_FILE"
   rm -rf "$KERNEL_DOM0_IMAGE_FILE"
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $KERNEL_DOM0_BUILD_PATH"
   rm -rf "$KERNEL_DOM0_BUILD_PATH"
   echo "delete $KERNEL_DOM0_IMAGE_FILE"
   rm -rf "$KERNEL_DOM0_IMAGE_FILE"
fi

echo "Setup: $KERNEL_DOM0_BUILD_PATH"
if [ ! -d $KERNEL_DOM0_BUILD_PATH ]; then
   echo "Based on: $KERNEL_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xzf $KERNEL_DL_FILE -C $TMP_DIR/
   mv $TMP_DIR/* $KERNEL_DOM0_BUILD_PATH
   rm -rf $TMP_DIR

   patch $KERNEL_DOM0_BUILD_PATH/include/xen/interface/io/blkif.h $SCRIPTS_DIR/files/32-kernel-patch-blkif.patch
   cp $KERNEL_DOM0_CONFIG_FILE $KERNEL_DOM0_BUILD_PATH/.config
fi

[ ! -d $KERNEL_DOM0_BUILD_PATH ] && echo "$KERNEL_DOM0_BUILD_PATH : not found"  && exit 0

echo "Building: $KERNEL_DOM0_IMAGE_FILE"
if [ ! -f $KERNEL_DOM0_IMAGE_FILE ]; then
   echo "Based on: $KERNEL_DOM0_IMAGE_FILE"
   source $SCRIPTS_DIR/22-cross-compiler-build-env.sh

   make menuconfig -C $KERNEL_DOM0_BUILD_PATH
   make -j 20 -C $KERNEL_DOM0_BUILD_PATH

   [ ! -f $KERNEL_DOM0_BIN_FILE ] && echo "$KERNEL_DOM0_BIN_FILE : not found"  && exit 0
   [ ! -f $KERNEL_DOM0_DTB_FILE ] && echo "$KERNEL_DOM0_DTB_FILE : not found"  && exit 0

   TMP_DIR=$BUILD_DIR/kernel.dom0.overlay
   rm -rf $TMP_DIR
   mkdir -p $TMP_DIR/boot
   mkdir -p $TMP_DIR/lib/modules

   cp $KERNEL_DOM0_BIN_FILE $TMP_DIR/boot/$KERNEL_DOM0_BIN_NAME
   cp $KERNEL_DOM0_DTB_FILE $TMP_DIR/boot/$KERNEL_DOM0_DTB_NAME
   cp $KERNEL_DOM0_BOOT_FILE $TMP_DIR/boot/boot-kernel.cmd
   mkimage -C none -A arm -T script -d $KERNEL_DOM0_BOOT_FILE $TMP_DIR/boot/boot.scr
   cd $TMP_DIR; ln -s boot/boot.scr; cd -
   make modules_install -C $KERNEL_DOM0_BUILD_PATH INSTALL_MOD_PATH=$TMP_DIR/lib/modules/ > $TMP_DIR/lib/modules/modules_install.log
   cd $TMP_DIR/boot/
   ln -s $KERNEL_DOM0_BIN_NAME kernel
   ln -s $KERNEL_DOM0_DTB_NAME dtb
   cd -
   cd $TMP_DIR
   tar -czf $KERNEL_DOM0_IMAGE_FILE .
   cd -
   rm -rf $TMP_DIR
fi

echo "Kernel-dom0 Image: $KERNEL_DOM0_IMAGE_FILE"
