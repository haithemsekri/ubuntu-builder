#!/bin/bash

source $(dirname $(realpath $0))/20-cross-compiler-env.sh
source $(dirname $(realpath $0))/50-loader-env.sh

[ ! -f $UBOOT_DL_FILE ] && wget $UBOOT_DL_URL -O $UBOOT_DL_FILE
[ ! -f $ATF_DL_FILE ] && wget $ATF_DL_URL -O $ATF_DL_FILE

[ ! -f $UBOOT_DL_FILE ] && echo "$UBOOT_DL_FILE : not found"  && exit 0
[ ! -f $ATF_DL_FILE ] && echo "$ATF_DL_FILE : not found"  && exit 0

UBOOT_BUILD_DIR="$BUILD_DIR/uboot"
ATF_BUILD_DIR="$BUILD_DIR/atf"

if [ "$1" == "--rebuild" ]; then
   echo "delete $UBOOT_ATF_IMAGE_FILE"
   rm -rf "$UBOOT_ATF_IMAGE_FILE"
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $UBOOT_ATF_IMAGE_FILE"
   rm -rf "$UBOOT_ATF_IMAGE_FILE"
   echo "delete $UBOOT_BUILD_DIR"
   rm -rf "$UBOOT_BUILD_DIR"
   echo "delete $ATF_BUILD_DIR"
   rm -rf "$ATF_BUILD_DIR"
fi

echo "Setup: $UBOOT_BUILD_DIR"
if [ ! -d $UBOOT_BUILD_DIR ]; then
   echo "Based on: $UBOOT_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xf $UBOOT_DL_FILE -C $TMP_DIR
   mv $TMP_DIR/* $UBOOT_BUILD_DIR
   rm -rf $TMP_DIR
fi

echo "Setup: $ATF_BUILD_DIR"
if [ ! -d $ATF_BUILD_DIR ]; then
   echo "Based on: $ATF_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xzf $ATF_DL_FILE -C $TMP_DIR
   mv $TMP_DIR/* $ATF_BUILD_DIR
   rm -rf $TMP_DIR
fi

[ ! -d $UBOOT_BUILD_DIR ] && echo "$UBOOT_BUILD_DIR : not found"  && exit 0
[ ! -d $ATF_BUILD_DIR ] && echo "$ATF_BUILD_DIR : not found"  && exit 0


echo "Build: $UBOOT_ATF_IMAGE_FILE"
if [ ! -f $UBOOT_ATF_IMAGE_FILE ]; then
   source $SCRIPTS_DIR/22-cross-compiler-build-env.sh

   make -j8 PLAT=$ATF_TARGET_PLAT DEBUG=1 bl31 -C $ATF_BUILD_DIR
   CK_PATH=$ATF_BUILD_DIR/build/$ATF_TARGET_PLAT/debug/bl31.bin [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0
   cp $ATF_BUILD_DIR/build/$ATF_TARGET_PLAT/debug/bl31.bin $UBOOT_BUILD_DIR/

   make $UBOOT_TARGET_CONFIG -C $UBOOT_BUILD_DIR
   if [ "$TARGET_ARCH" == "aarch64" ]; then
      make -j8 ARCH=arm MARCH=armv8a CFLAGS="-march=armv8-a -march=armv8-a -Os -pipe -fstack-protector-strong -fno-plt" -C $UBOOT_BUILD_DIR
   fi

   CK_PATH=$UBOOT_BUILD_DIR/$UBOOT_ATF_BIN_NAME [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0

   cd $UBOOT_BUILD_DIR
   ln -s $UBOOT_ATF_BIN_NAME u-boot-spl
   tar -czf $UBOOT_ATF_IMAGE_FILE bl31.bin u-boot.itb u-boot-spl $UBOOT_ATF_BIN_NAME
   cd -
fi

echo "UBOOT_ATF_IMAGE_FILE: $UBOOT_ATF_IMAGE_FILE"
