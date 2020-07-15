#!/bin/bash
#apt-get install -y chrpath gawk texinfo libsdl1.2-dev whiptail diffstat cpio libssl-dev
source $(dirname $(realpath $0))/00-common-env.sh

[ -z $KERNEL_DOM0_URL ]           && echo "KERNEL_DOM0_URL not defined" && exit 0
[ -z $KERNEL_DOM0_DL_FILE ]       && KERNEL_DOM0_DL_FILE="$DL_DIR/$(basename $KERNEL_DOM0_URL)"
[ ! -f $KERNEL_DOM0_DL_FILE ]     && wget $KERNEL_DOM0_URL -O $KERNEL_DOM0_DL_FILE
[ ! -f $KERNEL_DOM0_DL_FILE ]     && echo "$KERNEL_DOM0_DL_FILE : file not found"
[ -z $KERNEL_DOMU_URL ]           && echo "KERNEL_DOMU_URL not defined" && exit 0
[ -z $KERNEL_DOMU_DL_FILE ]       && KERNEL_DOMU_DL_FILE="$DL_DIR/$(basename $KERNEL_DOMU_URL)"
[ ! -f $KERNEL_DOMU_DL_FILE ]     && wget $KERNEL_DOMU_URL -O $KERNEL_DOMU_DL_FILE
[ ! -f $KERNEL_DOMU_DL_FILE ]     && echo "$KERNEL_DOMU_DL_FILE : file not found"

if [ "$TARGET_ARCH" == "arm64" ]; then
   [ -z $L_ARCH ]        && export L_ARCH="arm64"
elif [ "$TARGET_ARCH" == "arm32" ]; then
   [ -z $L_ARCH ]        && export L_ARCH="arm"
fi

if [ "$1" == "--kernel-dom0-build" ]; then
   echo "delete $KERNEL_DOM0_DISTRO"
   rm -rf "$KERNEL_DOM0_DISTRO"
   BUILD_TMP_DIR="$BUILD_DIR/linux-dom0-build"
   if [ ! -d $BUILD_TMP_DIR ]; then
      echo "Setup: $BUILD_TMP_DIR"
      mkdir -p $BUILD_TMP_DIR
      tar -xf $KERNEL_DOM0_DL_FILE -C $BUILD_TMP_DIR
      patch --verbose $BUILD_TMP_DIR/include/xen/interface/io/blkif.h $KERNEL_DOM0_PATCH
      cp $KERNEL_DOM0_CONFIG $BUILD_TMP_DIR/.config
   fi

   make menuconfig ARCH="$L_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" -C $BUILD_TMP_DIR
   make -j 8 ARCH="$L_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" -C $BUILD_TMP_DIR
   [ ! -f "$BUILD_TMP_DIR/$KERNEL_DOM0_IMG" ] && echo "$BUILD_TMP_DIR/$KERNEL_DOM0_IMG : not found"  && exit 0
   [ ! -f "$BUILD_TMP_DIR/$KERNEL_DOM0_DTB" ] && echo "$BUILD_TMP_DIR/$KERNEL_DOM0_DTB : not found"  && exit 0

   TMP_INSTALL_DIR="$BUILD_DIR/kernel-install-tmp"
   rm -rf $TMP_INSTALL_DIR
   mkdir -p $TMP_INSTALL_DIR/boot
   mkdir -p $TMP_INSTALL_DIR/lib/modules
   make modules_install -C $BUILD_TMP_DIR INSTALL_MOD_PATH=$TMP_INSTALL_DIR/lib/modules > $TMP_INSTALL_DIR/lib/modules/modules_install.log
   cp $BUILD_TMP_DIR/$KERNEL_DOM0_IMG $TMP_INSTALL_DIR/boot/$KERNEL_DOM0_DISTRO_NAME.bin
   cp $BUILD_TMP_DIR/$KERNEL_DOM0_DTB $TMP_INSTALL_DIR/boot/$KERNEL_DOM0_DISTRO_NAME.dtb
   cp $SCRIPTS_DIR/files/kernel-boot-env.cmd $TMP_INSTALL_DIR/boot/kernel-boot.cmd
   cd $TMP_INSTALL_DIR/boot/
   mkimage -C none -A arm -T script -d kernel-boot.cmd kernel-boot.scr
   ln -sf kernel-boot.scr boot.scr
   ln -sf $KERNEL_DOM0_DISTRO_NAME.bin kernel
   ln -sf $KERNEL_DOM0_DISTRO_NAME.dtb dtb
   cd $TMP_INSTALL_DIR
   tar -I 'pxz -T 0 -9' -cf $KERNEL_DOM0_DISTRO .
   cd $WORKSPACE
   rm -rf $TMP_INSTALL_DIR
   [ ! -f $KERNEL_DOM0_DISTRO ] && echo "$KERNEL_DOM0_DISTRO : not found"  && exit 0
   echo "Kernel-dom0 Image: $KERNEL_DOM0_DISTRO"
fi

if [ "$1" == "--kernel-domu-build" ]; then
   echo "delete $KERNEL_DOMU_DISTRO"
   rm -rf "$KERNEL_DOMU_DISTRO"
   BUILD_TMP_DIR="$BUILD_DIR/linux-domu-build"
   if [ ! -d $BUILD_TMP_DIR ]; then
      echo "Setup: $BUILD_TMP_DIR"
      mkdir -p $BUILD_TMP_DIR
      tar -xf $KERNEL_DOMU_DL_FILE -C $BUILD_TMP_DIR
      patch --verbose $BUILD_TMP_DIR/include/xen/interface/io/blkif.h $KERNEL_DOMU_PATCH
      cp $KERNEL_DOMU_CONFIG $BUILD_TMP_DIR/.config
   fi

   make menuconfig ARCH="$L_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" -C $BUILD_TMP_DIR
   make -j 8 ARCH="$L_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" -C $BUILD_TMP_DIR
   [ ! -f "$BUILD_TMP_DIR/$KERNEL_DOMU_IMG" ] && echo "$BUILD_TMP_DIR/$KERNEL_DOMU_IMG : not found"  && exit 0

   TMP_INSTALL_DIR="$BUILD_DIR/kernel-install-tmp"
   rm -rf $TMP_INSTALL_DIR
   mkdir -p $TMP_INSTALL_DIR/boot
   mkdir -p $TMP_INSTALL_DIR/lib/modules
   make modules_install -C $BUILD_TMP_DIR INSTALL_MOD_PATH=$TMP_INSTALL_DIR/lib/modules > $TMP_INSTALL_DIR/lib/modules/modules_install.log
   cp $BUILD_TMP_DIR/$KERNEL_DOMU_IMG $TMP_INSTALL_DIR/boot/$KERNEL_DOMU_DISTRO_NAME.bin

   cd $TMP_INSTALL_DIR/boot/
   ln -sf $KERNEL_DOMU_DISTRO_NAME.bin kernel
   cd $TMP_INSTALL_DIR
   tar -I 'pxz -T 0 -9' -cf $KERNEL_DOMU_DISTRO .
   cd $WORKSPACE
   rm -rf $TMP_INSTALL_DIR
   [ ! -f $KERNEL_DOMU_DISTRO ] && echo "$KERNEL_DOMU_DISTRO : not found"  && exit 0
   echo "Kernel-domu Image: $KERNEL_DOMU_DISTRO"
fi
