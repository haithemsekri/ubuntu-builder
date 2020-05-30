#!/bin/bash

source $(dirname $(realpath $0))/20-cross-compiler-env.sh
source $(dirname $(realpath $0))/00-rootfs-env.sh

[ ! -f $ROOTFS_BASE_DISK ] && echo "$ROOTFS_BASE_DISK : file not found"  && exit 0
[ ! -f $CCOMPILER_DL_FILE ] && wget $CCOMPILER_DL_URL -O $CCOMPILER_DL_FILE
[ ! -f $CCOMPILER_DL_FILE ] && echo "$CCOMPILER_DL_FILE : not found"  && exit 0

if [ "$1" == "--rebuild" ]; then
   echo -n ""
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $SYSROOT_PATH"
   rm -rf "$SYSROOT_PATH"
   echo "delete $CCOMPILER_PATH"
   rm -rf "$CCOMPILER_PATH"
fi

echo "Building target-cc: $CCOMPILER_PATH"

if [ ! -d $CCOMPILER_PATH ]; then
echo "Setup target-cc: $CCOMPILER_PATH"
TMP_DIR="$BUILD_DIR/tar.xf.tmp"
mkdir -p $TMP_DIR
tar -xf $CCOMPILER_DL_FILE -C $TMP_DIR/
sync
mv $TMP_DIR/* $CCOMPILER_PATH
rm -rf $TMP_DIR
fi

[ ! -d $CCOMPILER_PATH ] && echo "$CCOMPILER_PATH : not found"  && exit 0

if [ ! -d $SYSROOT_PATH ]; then
   echo "Setup target-sysroot: $SYSROOT_PATH"
   TMP_DIR="$BUILD_DIR/cross-compiler-setup.tmp"
   [ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
   sudo umount $TMP_DIR 2>/dev/null
   sudo mount -o loop $ROOTFS_BASE_DISK $TMP_DIR
   MTAB_ENTRY="$(mount | egrep "$ROOTFS_BASE_DISK" | egrep "$TMP_DIR")"
   [ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $TMP_DIR  && exit 0
   mkdir -p $SYSROOT_PATH
   mkdir -p $SYSROOT_PATH/usr
   mkdir -p $SYSROOT_PATH/usr/local/

   [ -d $TMP_DIR/lib  ] && echo "Installing $TMP_DIR/lib ---> $SYSROOT_PATH/"  && cp -r $TMP_DIR/lib $SYSROOT_PATH/
   [ -d $TMP_DIR/include  ] && echo "Installing $TMP_DIR/include ---> $SYSROOT_PATH/"  && cp -r $TMP_DIR/include $SYSROOT_PATH/
   [ -d $TMP_DIR/usr/lib  ] && echo "Installing $TMP_DIR/usr/lib ---> $SYSROOT_PATH/usr/"  && cp -r $TMP_DIR/usr/lib $SYSROOT_PATH/usr/
   [ -d $TMP_DIR/usr/include  ] && echo "Installing $TMP_DIR/usr/include ---> $SYSROOT_PATH/usr/"  && cp -r $TMP_DIR/usr/include $SYSROOT_PATH/usr/
   [ -d $TMP_DIR/usr/local/lib  ] && echo "Installing $TMP_DIR/usr/local/lib ---> $SYSROOT_PATH/usr/local/"  && cp -r $TMP_DIR/usr/local/lib $SYSROOT_PATH/usr/local/
   [ -d $TMP_DIR/usr/local/include  ] && echo "Installing $TMP_DIR/usr/local/include ---> $SYSROOT_PATH/usr/local/"  && cp -r $TMP_DIR/usr/local/include $SYSROOT_PATH/usr/local/

   sync
   sudo umount $TMP_DIR
   rm -rf $TMP_DIR
fi

source $SCRIPTS_DIR/22-cross-compiler-build-env.sh

echo "CC-compiler: $CCOMPILER_PATH"
