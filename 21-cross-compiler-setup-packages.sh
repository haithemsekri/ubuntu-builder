#!/bin/bash

source 20-cross-compiler-setup-env.sh

[ ! -f $DL_COMPILER_FILE ] && wget $DL_COMPILER_URL -O $DL_COMPILER_FILE
[ ! -f $DL_COMPILER_FILE ] && echo "$DL_COMPILER_FILE : not found"  && exit 0

if [ ! -d $TARGET_COMPILER_PATH ]; then
echo "Setup target-cc: $TARGET_COMPILER_PATH"
mkdir tar.xf.tmp
tar -xf $DL_COMPILER_FILE -C tar.xf.tmp/
mv tar.xf.tmp/* $TARGET_COMPILER_PATH
rm -rf tar.xf.tmp
fi


