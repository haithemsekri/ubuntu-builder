#!/bin/bash

source $(dirname $(realpath $0))/20-cross-compiler-env.sh
source $(dirname $(realpath $0))/30-kernel-env.sh

[ ! -f $KERNEL_DL_FILE ] && wget $KERNEL_DL_URL -O $KERNEL_DL_FILE
[ ! -f $KERNEL_DL_FILE ] && echo "$KERNEL_DL_FILE : not found"  && exit 0

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
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xzf $KERNEL_DL_FILE -C $TMP_DIR/
   mv $TMP_DIR/* $KERNEL_DOMU_BUILD_PATH
   rm -rf $TMP_DIR

   patch $KERNEL_DOMU_BUILD_PATH/include/xen/interface/io/blkif.h $SCRIPTS_DIR/32-kernel-patch-blkif.patch
   cp $SCRIPTS_DIR/33-kernel-config-domu.config $KERNEL_DOMU_BUILD_PATH/.config
fi

[ ! -d $KERNEL_DOMU_BUILD_PATH ] && echo "$KERNEL_DOMU_BUILD_PATH : not found"  && exit 0

echo "Building: $KERNEL_DOMU_IMAGE_FILE"
if [ ! -f $KERNEL_DOMU_IMAGE_FILE ]; then
   echo "Based on: $KERNEL_DOMU_IMAGE_FILE"
   source $SCRIPTS_DIR/22-cross-compiler-build-env.sh

   make menuconfig -C $KERNEL_DOMU_BUILD_PATH
   make -j 20 -C $KERNEL_DOMU_BUILD_PATH

   [ ! -f $KERNEL_DOMU_BIN_FILE ] && echo "$KERNEL_DOMU_BIN_FILE : not found"  && exit 0

   TMP_DIR=$BUILD_DIR/kernel.domu.overlay
   rm -rf $TMP_DIR

   mkdir -p $TMP_DIR/boot
   cp $KERNEL_DOMU_BIN_FILE $TMP_DIR/boot/$KERNEL_DOMU_BIN_NAME
   cd $TMP_DIR/boot/
   ln -s $KERNEL_DOMU_BIN_NAME kernel
   cd -

   mkdir -p $TMP_DIR/lib/modules
   make modules_install -C $KERNEL_DOMU_BUILD_PATH INSTALL_MOD_PATH=$TMP_DIR/lib/modules/ > $TMP_DIR/lib/modules/modules_install.log

   cd $TMP_DIR
   tar -czf $KERNEL_DOMU_IMAGE_FILE .
   cd -
   rm -rf $TMP_DIR
fi

echo "Kernel-domu Image: $KERNEL_DOMU_IMAGE_FILE"
