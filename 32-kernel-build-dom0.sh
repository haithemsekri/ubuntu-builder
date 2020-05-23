#!/bin/bash

source 30-kernel-setup-env.sh

[ ! -d "cache" ] && mkdir cache
[ ! -d "build" ] && mkdir build

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
   mkdir tar.gz.tmp
   tar -xzf $KERNEL_DL_FILE -C tar.gz.tmp/
   mv tar.gz.tmp/* $KERNEL_DOM0_BUILD_PATH
   rm -rf tar.gz.tmp

   patch $KERNEL_DOM0_BUILD_PATH/include/xen/interface/io/blkif.h 32-kernel-patch-blkif.patch
   cp 32-kernel-config-dom0.config $KERNEL_DOM0_BUILD_PATH/.config
fi

[ ! -d $KERNEL_DOM0_BUILD_PATH ] && echo "$KERNEL_DOM0_BUILD_PATH : not found"  && exit 0

echo "Building: $KERNEL_DOM0_IMAGE_FILE"
if [ ! -f $KERNEL_DOM0_IMAGE_FILE ]; then
   echo "Based on: $KERNEL_DOM0_IMAGE_FILE"
   source 22-cross-compiler-build-env.sh

   make menuconfig -C $KERNEL_DOM0_BUILD_PATH

   make -j 20 -C $KERNEL_DOM0_BUILD_PATH
   [ ! -f $KERNEL_DOM0_BIN_FILE ] && echo "$KERNEL_DOM0_BIN_FILE : not found"  && exit 0
   [ ! -f $KERNEL_DOM0_DTB_FILE ] && echo "$KERNEL_DOM0_DTB_FILE : not found"  && exit 0

   mkdir -p kernel.dom0.overlay/boot
   cp $KERNEL_DOM0_BIN_FILE kernel.dom0.overlay/boot/kernel.bin
   cp $KERNEL_DOM0_DTB_FILE kernel.dom0.overlay/boot/device-tree.dtb
   mkimage -C none -A arm -T script -d $KERNEL_DOM0_BOOT_FILE kernel.dom0.overlay/boot/boot.scr
   cd kernel.dom0.overlay
   tar -czf $KERNEL_DOM0_IMAGE_FILE .
   cd -
   rm -rf kernel.dom0.overlay
fi
