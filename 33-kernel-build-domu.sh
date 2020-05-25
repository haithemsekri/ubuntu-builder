#!/bin/bash

source 30-kernel-setup-env.sh

[ ! -f $KERNEL_DL_FILE ] && wget $KERNEL_DL_URL -O $KERNEL_DL_FILE
[ ! -f $KERNEL_DL_FILE ] && echo "$KERNEL_DL_FILE : not found"  && exit 0

[ ! -d "cache" ] && mkdir cache
[ ! -d "build" ] && mkdir build

if [ "$1" == "--rebuild" ]; then
   echo "delete $KERNEL_DOMU_IMAGE_FILE"
   rm -rf "$KERNEL_DOMU_IMAGE_FILE"
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $KERNEL_DOMU_BUILD_PATH"
   rm -rf "$KERNEL_DOMU_BUILD_PATH"
   echo "delete $KERNEL_DOMU_IMAGE_FILE"
   rm -rf "$KERNEL_DOMU_IMAGE_FILE"
fi

echo "Setup: $KERNEL_DOMU_BUILD_PATH"
if [ ! -d $KERNEL_DOMU_BUILD_PATH ]; then
   echo "Based on: $KERNEL_DL_FILE"
   mkdir tar.gz.tmp
   tar -xzf $KERNEL_DL_FILE -C tar.gz.tmp/
   mv tar.gz.tmp/* $KERNEL_DOMU_BUILD_PATH
   rm -rf tar.gz.tmp

   patch $KERNEL_DOMU_BUILD_PATH/include/xen/interface/io/blkif.h 32-kernel-patch-blkif.patch
   cp 33-kernel-config-domu.config $KERNEL_DOMU_BUILD_PATH/.config
fi

[ ! -d $KERNEL_DOMU_BUILD_PATH ] && echo "$KERNEL_DOMU_BUILD_PATH : not found"  && exit 0

echo "Building: $KERNEL_DOMU_IMAGE_FILE"
if [ ! -f $KERNEL_DOMU_IMAGE_FILE ]; then
   echo "Based on: $KERNEL_DOMU_IMAGE_FILE"
   source 22-cross-compiler-build-env.sh

   make menuconfig -C $KERNEL_DOMU_BUILD_PATH
   make -j 20 -C $KERNEL_DOMU_BUILD_PATH

   [ ! -f $KERNEL_DOMU_BIN_FILE ] && echo "$KERNEL_DOMU_BIN_FILE : not found"  && exit 0

   rm -rf kernel.domu.overlay

   mkdir -p kernel.domu.overlay/boot
   cp $KERNEL_DOMU_BIN_FILE kernel.domu.overlay/boot/$KERNEL_DOMU_BIN_NAME
   cd kernel.domu.overlay/boot/
   ln -s $KERNEL_DOMU_BIN_NAME kernel
   cd -

   mkdir -p kernel.domu.overlay/lib/modules
   make modules_install -C $KERNEL_DOMU_BUILD_PATH INSTALL_MOD_PATH=kernel.domu.overlay/lib/modules/ > kernel.domu.overlay/lib/modules/modules_install.log

   cd kernel.domu.overlay
   tar -czf $KERNEL_DOMU_IMAGE_FILE .
   cd -
   rm -rf kernel.domu.overlay
fi

echo "Kernel-domu Image: $KERNEL_DOMU_IMAGE_FILE"
