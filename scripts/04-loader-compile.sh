#!/bin/bash
## apt-get --no-install-recommends install python python-dev python3-dev lib32z1 swig device-tree-compiler

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $UBOOT_DL_URL ]  && UBOOT_DL_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/u-boot-2020.04.tar.xz"
[ -z $UBOOT_DL_FILE ] && UBOOT_DL_FILE="$DL_DIR/$(basename $UBOOT_DL_URL)"
[ ! -f $UBOOT_DL_FILE ] && wget $UBOOT_DL_URL -O $UBOOT_DL_FILE
[ ! -f $UBOOT_DL_FILE ] && echo "$UBOOT_DL_FILE : file not found"  && exit 0

[ -z $ATF_DL_URL ]  && ATF_DL_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/arm-trusted-firmware-2.3.tar.xz"
[ -z $ATF_DL_FILE ] && ATF_DL_FILE="$DL_DIR/$(basename $ATF_DL_URL)"
[ ! -f $ATF_DL_FILE ] && wget $ATF_DL_URL -O $ATF_DL_FILE
[ ! -f $ATF_DL_FILE ] && echo "$ATF_DL_FILE : file not found"  && exit 0

if [ "$TARGET_NAME" == "opipc2" ]; then
   [ -z $UBOOT_CONFIG ]       &&  UBOOT_CONFIG="orangepi_pc2_defconfig"
   [ -z $ATF_PLAT ]           &&  ATF_PLAT="sun50i_a64"
   [ -z $UBOOT_ATF_BIN_ ]     &&  UBOOT_ATF_BIN="u-boot-sunxi-with-spl.bin"
   [ -z $ATF_MAKE_ARGS ]      &&  ATF_MAKE_ARGS="PLAT=$ATF_PLAT DEBUG=1 bl31 CROSS_COMPILE=$L_CROSS_COMPILE"
   [ -z $UBOOT_CFLAGS ]       &&  UBOOT_CFLAGS="-march=armv8-a -march=armv8-a -Os -pipe -fstack-protector-strong -fno-plt"
   [ -z $UBOOT_MAKE_ARGS ]    &&  UBOOT_MAKE_ARGS="ARCH=arm CROSS_COMPILE=$L_CROSS_COMPILE MARCH=armv8a"
fi

if [ "$1" == "--loader-build" ]; then
   echo "delete $BOOT_DISTRO_TAR"
   rm -rf "$BOOT_DISTRO_TAR"

   UBOOT_BUILD_DIR="$BUILD_DIR/uboot-build"
   if [ ! -d $UBOOT_BUILD_DIR ]; then
      echo "Setup: $UBOOT_BUILD_DIR"
      mkdir -p $UBOOT_BUILD_DIR
      tar -xf $UBOOT_DL_FILE -C $UBOOT_BUILD_DIR
      make $UBOOT_CONFIG -C $UBOOT_BUILD_DIR
   fi

   ATF_BUILD_DIR="$BUILD_DIR/atf-build"
   if [ ! -d $ATF_BUILD_DIR ]; then
      echo "Setup: $ATF_BUILD_DIR"
      mkdir -p $ATF_BUILD_DIR
      tar -xf $ATF_DL_FILE -C $ATF_BUILD_DIR
   fi

   make -j 8 $ATF_MAKE_ARGS -C $ATF_BUILD_DIR
   CK_PATH=$ATF_BUILD_DIR/build/$ATF_PLAT/debug/bl31.bin [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0
   cp $ATF_BUILD_DIR/build/$ATF_PLAT/debug/bl31.bin $UBOOT_BUILD_DIR/

   make -j8 $UBOOT_MAKE_ARGS CFLAGS="$UBOOT_CFLAGS" -C $UBOOT_BUILD_DIR
   CK_PATH=$UBOOT_BUILD_DIR/$UBOOT_ATF_BIN [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0

   cd $UBOOT_BUILD_DIR
   ln -sf $UBOOT_ATF_BIN uboot-spl
   tar -I 'pxz -T 0 -9' -cf $BOOT_DISTRO_TAR bl31.bin u-boot.itb uboot-spl $UBOOT_ATF_BIN
   cd $WORKSPACE
   echo "Boot Image: $BOOT_DISTRO_TAR"
fi
