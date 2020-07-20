#!/bin/bash

####################################################################### Wrokspace
[ -z "$MKFS_CMD" ]               && MKFS_CMD="mkfs.$EXT_FS_TYPE -T small"
#-I 'pxz -T 0 -1'
[ -z "$TAR_CXF_CMD" ]            && TAR_CXF_CMD="tar -cf"
[ -z "$TARGET_BUILD_NAME" ]      && TARGET_BUILD_NAME="$DISTRO_NAME-$TARGET_NAME"
[ -z $WORKSPACE ]                && WORKSPACE="$(realpath $(dirname $(realpath $0))/..)"
[ -z $DL_DIR ]                   && DL_DIR="$WORKSPACE/dl"
[ -z $SCRIPTS_DIR ]              && SCRIPTS_DIR="$WORKSPACE/scripts"
[ -z $TARGET_FILES ]             && TARGET_FILES="$WORKSPACE/scripts/$TARGET_NAME-files"
[ -z $BUILD_DIR ]                && BUILD_DIR="$WORKSPACE/$TARGET_BUILD_NAME/build"
[ -z $IMAGES_DIR ]               && IMAGES_DIR="$WORKSPACE/$TARGET_BUILD_NAME"
[ ! -d $DL_DIR ]                 && mkdir -p $DL_DIR
[ ! -d $BUILD_DIR ]              && mkdir -p $BUILD_DIR
[ ! -d $IMAGES_DIR ]             && mkdir -p $IMAGES_DIR

####################################################################### Rootfs
[ -z $ROOTFS_NAME ]              && ROOTFS_NAME="$DISTRO_NAME"
[ -z $ROOTFS_DL_TAR_URL ]        && ROOTFS_DL_TAR_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/$DISTRO_NAME-$TARGET_ARCH-base.tar.xz"
[ -z $ROOTFS_PACKAGE_NAME ]      && ROOTFS_PACKAGE_NAME="$TARGET_NAME-$ROOTFS_NAME"

####################################################################### Toolchain
[ -z $TOOLCHAIN_NAME ]        && TOOLCHAIN_NAME="$TARGET_ARCH-linux-$GCC_NAME"
if [ "$TOOLCHAIN_NAME" == "arm64-linux-gcc-9" ]; then
   [ -z $TOOLCHAIN_DL_URL ]   && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]       && CROSS_PREFIX="aarch64-none-linux-gnu"
elif [ "$TOOLCHAIN_NAME" == "arm64-linux-gcc-8" ]; then
   [ -z $TOOLCHAIN_DL_URL ]   && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]       && CROSS_PREFIX="aarch64-linux-gnu"
elif [ "$TOOLCHAIN_NAME" == "arm64-linux-gcc-7" ]; then
   [ -z $TOOLCHAIN_DL_URL ]   && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]       && CROSS_PREFIX="aarch64-linux-gnu"
fi
[ -z $TOOLCHAIN_PATH ]        && TOOLCHAIN_PATH="$BUILD_DIR/$TOOLCHAIN_NAME"
[ -z $L_CROSS_COMPILE ]       && L_CROSS_COMPILE="$TOOLCHAIN_PATH/bin/$CROSS_PREFIX-"
[ -z $L_CROSS_PREFIX ]        && L_CROSS_PREFIX="$CROSS_PREFIX"
[ -z $L_CROSS_ARCH ]          && L_CROSS_ARCH="$TARGET_ARCH"
