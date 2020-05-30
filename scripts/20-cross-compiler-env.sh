#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

if [ "$TARGET_ARCH" == "aarch64" ]; then
   [ -z $CCOMPILER_DL_URL ]  && export CCOMPILER_DL_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
   [ -z $CCOMPILER_NAME ]  && export CCOMPILER_NAME="gcc-linaro-aarch64-linux-gnu"
   [ -z $CC_PV ]  && export CC_PV="7"
fi

[ -z $CCOMPILER_DL_FILE ] && export CCOMPILER_DL_FILE="$DL_DIR/$CCOMPILER_NAME.tar.xz"
[ -z $CCOMPILER_PATH ]  && export CCOMPILER_PATH="$BUILD_DIR/$CCOMPILER_NAME"
[ -z $SYSROOT_PATH ]  && export SYSROOT_PATH="$CCOMPILER_PATH/target-sysroot"
