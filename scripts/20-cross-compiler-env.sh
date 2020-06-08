#!/bin/bash

[ -z $TARGET_ARCH ] && echo "TARGET_ARCH not defined" && exit -1
[ -z $DL_DIR ] && echo "DL_DIR not defined" && exit -1
[ -z $BUILD_DIR ] && echo "BUILD_DIR not defined" && exit -1

[ -z $TOOLCHAIN_NAME ]  && export TOOLCHAIN_NAME="gcc-$TARGET_ARCH-linux"
[ -z $TOOLCHAIN_PATH ]  && export TOOLCHAIN_PATH="$BUILD_DIR/$TOOLCHAIN_NAME"
[ -z $TOOLCHAIN_ENV_FILE ]  && export TOOLCHAIN_ENV_FILE="$TOOLCHAIN_PATH/target-env.sh"
