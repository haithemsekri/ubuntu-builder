#!/bin/bash

source 20-cross-compiler-setup-env.sh
source 00-rootfs-setup-env.sh

[ ! -f $BASE_DISK_FILE ] && echo "$BASE_DISK_FILE : file not found"  && exit 0
[ ! -f $DL_COMPILER_FILE ] && wget $DL_COMPILER_URL -O $DL_COMPILER_FILE
[ ! -f $DL_COMPILER_FILE ] && echo "$DL_COMPILER_FILE : not found"  && exit 0


if [ "$1" == "--rebuild" ]; then
   echo "delete $SYSROOT_PATH"
   rm -rf "$SYSROOT_PATH"
   echo "delete $TARGET_COMPILER_PATH"
   rm -rf "$TARGET_COMPILER_PATH"
fi

if [ ! -d $TARGET_COMPILER_PATH ]; then
echo "Setup target-cc: $TARGET_COMPILER_PATH"
mkdir tar.xf.tmp
tar -xf $DL_COMPILER_FILE -C tar.xf.tmp/
sync
mv tar.xf.tmp/* $TARGET_COMPILER_PATH
rm -rf tar.xf.tmp
fi

[ ! -d $TARGET_COMPILER_PATH ] && echo "$TARGET_COMPILER_PATH : not found"  && exit 0



if [ ! -d $SYSROOT_PATH ]; then
   echo "Setup target-sysroot: $SYSROOT_PATH"
   TMP_DIR="cross-compiler-setup.tmp"
   [ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
   sudo umount $TMP_DIR 2>/dev/null
   sudo mount -o loop $BASE_DISK_FILE $TMP_DIR
   MTAB_ENTRY="$(mount | egrep "$BASE_DISK_FILE" | egrep "$TMP_DIR")"
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

source 22-cross-compiler-build-env.sh
