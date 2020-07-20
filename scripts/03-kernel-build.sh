#!/bin/bash
#apt-get install -y libssl-dev libncurses-dev

if [ "$TARGET_ARCH" == "arm64" ]; then
   [ -z $L_ARCH ]        && export L_ARCH="arm64"
elif [ "$TARGET_ARCH" == "arm32" ]; then
   [ -z $L_ARCH ]        && export L_ARCH="arm"
fi

if [ "$1" == "--all" ] || [ "$1" == "--kernel-dom0-build" ]; then
   echo -e "\e[30;48;5;82mSetup kernel dom0\e[0m"
   [ -z $LINUX_DOM0_URL ]           && echo "LINUX_DOM0_URL not defined" && exit 0
   [ -z $LINUX_DOM0_DL_FILE ]       && LINUX_DOM0_DL_FILE="$DL_DIR/$(basename $LINUX_DOM0_URL)"
   [ ! -f $LINUX_DOM0_DL_FILE ]     && wget $LINUX_DOM0_URL -O $LINUX_DOM0_DL_FILE
   [ ! -f $LINUX_DOM0_DL_FILE ]     && echo "$LINUX_DOM0_DL_FILE : file not found"
   [ ! -f "$L_CROSS_COMPILE"gcc ]   &&  echo "L_CROSS_COMPILEgcc: file not found" && exit 0
   echo "delete $LINUX_DOM0_PACKAGE_TAR"
   rm -rf "$LINUX_DOM0_PACKAGE_TAR"
   BUILD_TMP_DIR="$BUILD_DIR/linux-dom0-build"
   CONFIGURE_CMD="make menuconfig ARCH=$L_ARCH CROSS_COMPILE=$L_CROSS_COMPILE -C $BUILD_TMP_DIR"
   MAKE_CMD="make -j$BUILD_CPU_CORE ARCH=$L_ARCH CROSS_COMPILE=$L_CROSS_COMPILE -C $BUILD_TMP_DIR"
   echo "CONFIGURE_CMD: $CONFIGURE_CMD"
   echo "MAKE_CMD: $MAKE_CMD"
   if [ ! -d $BUILD_TMP_DIR ]; then
      echo "Setup: $BUILD_TMP_DIR"
      mkdir -p $BUILD_TMP_DIR
      tar -xf $LINUX_DOM0_DL_FILE -C $BUILD_TMP_DIR
      [ -f $LINUX_DOM0_PATCH ] &&  echo "linux dom0 patch" && patch --verbose -d $BUILD_TMP_DIR -p1 < $LINUX_DOM0_PATCH
      cp $LINUX_DOM0_CONFIG $BUILD_TMP_DIR/.config
      # $CONFIGURE_CMD
   fi

   $MAKE_CMD 1> /dev/null
   [ ! -f "$BUILD_TMP_DIR/$LINUX_DOM0_IMG" ] && echo "$BUILD_TMP_DIR/$LINUX_DOM0_IMG : not found"  && exit 0
   [ ! -f "$BUILD_TMP_DIR/$LINUX_DOM0_DTB" ] && echo "$BUILD_TMP_DIR/$LINUX_DOM0_DTB : not found"  && exit 0

   TMP_INSTALL_DIR="$BUILD_DIR/kernel-install-tmp"
   rm -rf $TMP_INSTALL_DIR
   mkdir -p $TMP_INSTALL_DIR/boot
   mkdir -p $TMP_INSTALL_DIR/lib/modules
   make modules_install -C $BUILD_TMP_DIR INSTALL_MOD_PATH=$TMP_INSTALL_DIR/lib/modules > $TMP_INSTALL_DIR/lib/modules/modules_install.log
   cp $BUILD_TMP_DIR/$LINUX_DOM0_IMG $TMP_INSTALL_DIR/boot/$LINUX_DOM0_PACKAGE_NAME.bin
   cp $BUILD_TMP_DIR/$LINUX_DOM0_DTB $TMP_INSTALL_DIR/boot/$LINUX_DOM0_PACKAGE_NAME.dtb
   cd $TMP_INSTALL_DIR/boot/
   ln -sf $LINUX_DOM0_PACKAGE_NAME.bin kernel
   ln -sf $LINUX_DOM0_PACKAGE_NAME.dtb dtb
   cd $TMP_INSTALL_DIR
   $TAR_CXF_CMD $LINUX_DOM0_PACKAGE_TAR .
   cd $WORKSPACE
   rm -rf $TMP_INSTALL_DIR
   [ ! -f $LINUX_DOM0_PACKAGE_TAR ] && echo "$LINUX_DOM0_PACKAGE_TAR : not found"  && exit 0
fi

if [ "$1" == "--all" ] || [ "$1" == "--kernel-domu-build" ]; then
   echo -e "\e[30;48;5;82mSetup kernel domu\e[0m"
   [ -z $LINUX_DOMU_URL ]           && echo "LINUX_DOMU_URL not defined" && exit 0
   [ -z $LINUX_DOMU_DL_FILE ]       && LINUX_DOMU_DL_FILE="$DL_DIR/$(basename $LINUX_DOMU_URL)"
   [ ! -f $LINUX_DOMU_DL_FILE ]     && wget $LINUX_DOMU_URL -O $LINUX_DOMU_DL_FILE
   [ ! -f $LINUX_DOMU_DL_FILE ]     && echo "$LINUX_DOMU_DL_FILE : file not found"
   [ ! -f "$L_CROSS_COMPILE"gcc ]   &&  echo "L_CROSS_COMPILEgcc: file not found" && exit 0
   echo "delete $LINUX_DOMU_PACKAGE_TAR"
   rm -rf "$LINUX_DOMU_PACKAGE_TAR"
   BUILD_TMP_DIR="$BUILD_DIR/linux-domu-build"
   CONFIGURE_CMD="make menuconfig ARCH=$L_ARCH CROSS_COMPILE=$L_CROSS_COMPILE -C $BUILD_TMP_DIR"
   MAKE_CMD="make -j$BUILD_CPU_CORE ARCH=$L_ARCH CROSS_COMPILE=$L_CROSS_COMPILE -C $BUILD_TMP_DIR"
   echo "CONFIGURE_CMD: $CONFIGURE_CMD"
   echo "MAKE_CMD: $MAKE_CMD"
   if [ ! -d $BUILD_TMP_DIR ]; then
      echo "Setup: $BUILD_TMP_DIR"
      mkdir -p $BUILD_TMP_DIR
      tar -xf $LINUX_DOMU_DL_FILE -C $BUILD_TMP_DIR
      cp $LINUX_DOMU_CONFIG $BUILD_TMP_DIR/.config
      [ -f $LINUX_DOMU_PATCH ] &&  echo "linux domu patch" && patch --verbose -d $BUILD_TMP_DIR -p1 < $LINUX_DOMU_PATCH
      # $CONFIGURE_CMD
   fi

   $MAKE_CMD 1> /dev/null
   [ ! -f "$BUILD_TMP_DIR/$LINUX_DOMU_IMG" ] && echo "$BUILD_TMP_DIR/$LINUX_DOMU_IMG : not found"  && exit 0

   TMP_INSTALL_DIR="$BUILD_DIR/kernel-install-tmp"
   rm -rf $TMP_INSTALL_DIR
   mkdir -p $TMP_INSTALL_DIR/boot
   mkdir -p $TMP_INSTALL_DIR/lib/modules
   make modules_install -C $BUILD_TMP_DIR INSTALL_MOD_PATH=$TMP_INSTALL_DIR/lib/modules > $TMP_INSTALL_DIR/lib/modules/modules_install.log
   cp $BUILD_TMP_DIR/$LINUX_DOMU_IMG $TMP_INSTALL_DIR/boot/$LINUX_DOMU_PACKAGE_NAME.bin

   cd $TMP_INSTALL_DIR/boot/
   ln -sf $LINUX_DOMU_PACKAGE_NAME.bin kernel
   cd $TMP_INSTALL_DIR
   $TAR_CXF_CMD $LINUX_DOMU_PACKAGE_TAR .
   cd $WORKSPACE
   rm -rf $TMP_INSTALL_DIR
   [ ! -f $LINUX_DOMU_PACKAGE_TAR ] && echo "$LINUX_DOMU_PACKAGE_TAR : not found"  && exit 0
fi
