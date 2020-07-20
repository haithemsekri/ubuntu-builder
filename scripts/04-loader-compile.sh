#!/bin/bash
## apt-get --no-install-recommends install python python-dev python3-dev lib32z1 swig device-tree-compiler

if [ "$1" == "--all" ] || [ "$1" == "--loader-build" ]; then
   echo -e "\e[30;48;5;82mSetup boot loader\e[0m"
   echo "delete $BOOT_PACKAGE_TAR"
   rm -rf "$BOOT_PACKAGE_TAR"

   UBOOT_BUILD_DIR="$BUILD_DIR/uboot-build"
   if [ ! -d $UBOOT_BUILD_DIR ]; then
      [ -z $UBOOT_DL_FILE ] && UBOOT_DL_FILE="$DL_DIR/$(basename $UBOOT_DL_URL)"
      [ ! -f $UBOOT_DL_FILE ] && wget $UBOOT_DL_URL -O $UBOOT_DL_FILE
      [ ! -f $UBOOT_DL_FILE ] && echo "$UBOOT_DL_FILE : file not found"  && exit 0
      echo "Setup: $UBOOT_BUILD_DIR"
      mkdir -p $UBOOT_BUILD_DIR
      tar -xf $UBOOT_DL_FILE -C $UBOOT_BUILD_DIR
      make $UBOOT_CONFIG -C $UBOOT_BUILD_DIR
   fi

   ATF_BUILD_DIR="$BUILD_DIR/atf-build"
   if [ ! -d $ATF_BUILD_DIR ]; then
      [ -z $ATF_DL_FILE ]     && ATF_DL_FILE="$DL_DIR/$(basename $ATF_DL_URL)"
      [ ! -f $ATF_DL_FILE ]   && wget $ATF_DL_URL -O $ATF_DL_FILE
      [ ! -f $ATF_DL_FILE ]   && echo "$ATF_DL_FILE : file not found"  && exit 0
      echo "Setup: $ATF_BUILD_DIR"
      mkdir -p $ATF_BUILD_DIR
      tar -xf $ATF_DL_FILE -C $ATF_BUILD_DIR
   fi

   make -j$BUILD_CPU_CORE $ATF_MAKE_ARGS -C $ATF_BUILD_DIR 1> /dev/null
   CK_PATH=$ATF_BUILD_DIR/build/$ATF_PLAT/debug/bl31.bin [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0
   cp $ATF_BUILD_DIR/build/$ATF_PLAT/debug/bl31.bin $UBOOT_BUILD_DIR/

   make -j$BUILD_CPU_CORE $UBOOT_MAKE_ARGS CFLAGS="$UBOOT_CFLAGS" -C $UBOOT_BUILD_DIR 1> /dev/null
   CK_PATH=$UBOOT_BUILD_DIR/$UBOOT_ATF_BIN [ ! -f $CK_PATH ] && echo "$CK_PATH : not found"  && exit 0

   cd $UBOOT_BUILD_DIR
   cp $UBOOT_ATF_BIN $TARGET_NAME-$BOOT_LOADER_NAME.bin
   ln -sf $TARGET_NAME-$BOOT_LOADER_NAME.bin uboot-spl
   $TAR_CXF_CMD $BOOT_PACKAGE_TAR bl31.bin u-boot.itb uboot-spl $TARGET_NAME-$BOOT_LOADER_NAME.bin
   cd $WORKSPACE
fi
