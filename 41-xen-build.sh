#!/bin/bash

source 00-rootfs-setup-env.sh
source 40-xen-setup-env.sh

[ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
[ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0

[ ! -d "cache" ] && mkdir cache
[ ! -d "build" ] && mkdir build

if [ "$1" == "--rebuild" ]; then
   echo "delete $XEN_IMAGE_FILE"
   rm -rf "$XEN_IMAGE_FILE"
fi

XEN_DIST_BUILD_PATH="build/$XEN_TAR_DIR_NAME-dist"

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $XEN_IMAGE_FILE"
   rm -rf "$XEN_IMAGE_FILE"
   echo "delete $XEN_DIST_BUILD_PATH"
   rm -rf "$XEN_DIST_BUILD_PATH"
fi

echo "Setup: $XEN_DIST_BUILD_PATH"
if [ ! -d $XEN_DIST_BUILD_PATH ]; then
   echo "Based on: $XEN_DL_FILE"
   mkdir tar.gz.tmp
   tar -xzf $XEN_DL_FILE -C tar.gz.tmp/
   mv tar.gz.tmp/* $XEN_DIST_BUILD_PATH
   rm -rf tar.gz.tmp

   #source 22-cross-compiler-build-env.sh
   #cd $XEN_DIST_BUILD_PATH
   #./configure --enable-xen $CROSS_CONFIG_ARGS
   #cd -
fi

[ ! -d $XEN_DIST_BUILD_PATH ] && echo "$XEN_DIST_BUILD_PATH : not found"  && exit 0

XEN_OVERLAY_TMP_DIR="xen.overlay.tmp"
rm -rf $XEN_OVERLAY_TMP_DIR

echo "Building: $XEN_IMAGE_FILE"
if [ ! -f $XEN_IMAGE_FILE ]; then
   echo "Based on: $XEN_DIST_BUILD_PATH"
   source 22-cross-compiler-build-env.sh

   make -j 20 -C $XEN_DIST_BUILD_PATH dist-xen XEN_TARGET_ARCH=arm64 CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK=sun7i

   [ ! -f $XEN_DIST_BUILD_PATH/xen/xen ] && echo "$XEN_DIST_BUILD_PATH/xen/xen : not found"  && exit 0
   mkdir -p $XEN_OVERLAY_TMP_DIR/boot
   cp $XEN_DIST_BUILD_PATH/xen/xen $XEN_OVERLAY_TMP_DIR/boot/
fi

if [ -d $XEN_OVERLAY_TMP_DIR ]; then
   cd $XEN_OVERLAY_TMP_DIR
   tar -czf $XEN_IMAGE_FILE .
   cd -
   rm -rf $XEN_OVERLAY_TMP_DIR
fi
