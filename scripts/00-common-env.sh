#!/bin/bash

#Platform :##########################################
[ -z $TARGET_ARCH ] && TARGET_ARCH="aarch64"
[ -z $TARGET_NAME ] && TARGET_NAME="opipc2"
[ -z $TARGET_BUILD_NAME ] && TARGET_BUILD_NAME="$TARGET_ARCH-$TARGET_NAME"

#Wrokspace :##########################################
[ -z $WORKSPACE ] && WORKSPACE="$(realpath $(dirname $(realpath $0))/..)"
[ -z $DL_DIR ] && DL_DIR="$WORKSPACE/dl"
[ -z $BUILD_DIR ] && BUILD_DIR="$WORKSPACE/build-$TARGET_BUILD_NAME"
[ -z $SCRIPTS_DIR ] && SCRIPTS_DIR="$WORKSPACE/scripts"

[ ! -d $DL_DIR ] && mkdir $DL_DIR
[ ! -d $BUILD_DIR ] && mkdir $BUILD_DIR
