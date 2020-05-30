#!/bin/bash

source $(dirname $(realpath $0))/00-rootfs-env.sh
source $(dirname $(realpath $0))/20-cross-compiler-env.sh
source $(dirname $(realpath $0))/22-cross-compiler-build-env.sh
source $(dirname $(realpath $0))/40-xen-env.sh

[ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
[ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0

XEN_DIST_BUILD_PATH="$BUILD_DIR/$XEN_TAR_DIR_NAME-dist"
XEN_TOOLS_BUILD_PATH="$BUILD_DIR/$XEN_TAR_DIR_NAME-tools"
XEN_OVERLAY_TMP_DIR="$BUILD_DIR/xen.overlay.tmp"
rm -rf $XEN_OVERLAY_TMP_DIR
mkdir -p $XEN_OVERLAY_TMP_DIR

if [ "$1" == "--rebuild" ]; then
   echo "delete $XEN_IMAGE_FILE"
   rm -rf "$XEN_IMAGE_FILE"
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $XEN_IMAGE_FILE"
   rm -rf "$XEN_IMAGE_FILE"
   echo "delete $XEN_TOOLS_BUILD_PATH"
   rm -rf "$XEN_TOOLS_BUILD_PATH"
   echo "delete $XEN_DIST_BUILD_PATH"
   rm -rf "$XEN_DIST_BUILD_PATH"
fi

echo "Setup: $XEN_DIST_BUILD_PATH"
if [ ! -d $XEN_DIST_BUILD_PATH ]; then
   echo "Based on: $XEN_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xzf $XEN_DL_FILE -C $TMP_DIR
   mv $TMP_DIR/* $XEN_DIST_BUILD_PATH
   rm -rf $TMP_DIR
fi
[ ! -d $XEN_DIST_BUILD_PATH ] && echo "$XEN_DIST_BUILD_PATH : not found"  && exit 0

echo "Setup: $XEN_TOOLS_BUILD_PATH"
if [ ! -d $XEN_TOOLS_BUILD_PATH ]; then
   echo "Based on: $XEN_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.gz.tmp
   mkdir $TMP_DIR
   tar -xzf $XEN_DL_FILE -C $TMP_DIR/
   mv  $TMP_DIR/* $XEN_TOOLS_BUILD_PATH
   rm -rf  $TMP_DIR

cat <<EOF > $XEN_TOOLS_BUILD_PATH/xen-build-tmp.sh
$CROSS_COMPILE_ENV ./configure --target=${CROSS_PREFIX} --host=${CROSS_PREFIX} --build=x86_64-pc-linux-gnu --prefix=/usr \
      --disable-gtk-doc --disable-gtk-doc-html \
      --enable-systemd \
      --disable-stubdom \
      --disable-ioemu-stubdom \
      --disable-pv-grub \
      --disable-xenstore-stubdom \
      --disable-rombios \
      --disable-ocamltools \
      --disable-qemu-traditional \
      --disable-doc --disable-docs --disable-documentation \
      --with-xmlto=no --with-fop=no --disable-dependency-tracking \
      --enable-ipv6 --disable-nls --disable-static --enable-shared --with-initddir=/etc/init.d \
      --disable-ocamltools  \
      --with-extra-qemuu-configure-args="--disable-sdl --disable-opengl --disable-werror --disable-libusb"

$CROSS_COMPILE_ENV XEN_TARGET_ARCH=$ARCH \
HOST_EXTRACFLAGS="-Wno-error" \
INTLTOOL_PERL=/usr/bin/perl /usr/bin/make dist-tools -j20

$CROSS_COMPILE_ENV XEN_TARGET_ARCH=$ARCH make install-tools DESTDIR=${XEN_OVERLAY_TMP_DIR}
EOF
   chmod 755 $XEN_TOOLS_BUILD_PATH/xen-build-tmp.sh
fi
[ ! -d $XEN_TOOLS_BUILD_PATH ] && echo "$XEN_TOOLS_BUILD_PATH : not found"  && exit 0


echo "Building: $XEN_IMAGE_FILE"
if [ ! -f $XEN_IMAGE_FILE ]; then
   if [ "$TARGET_NAME" == "opipc2" ]; then
      make -j 20 -C $XEN_DIST_BUILD_PATH dist-xen XEN_TARGET_ARCH=arm64 CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK=sun7i
   fi
   [ ! -f $XEN_DIST_BUILD_PATH/xen/xen ] && echo "$XEN_DIST_BUILD_PATH/xen/xen : not found"  && exit 0
   mkdir -p $XEN_OVERLAY_TMP_DIR/boot
   cp $XEN_DIST_BUILD_PATH/xen/xen $XEN_OVERLAY_TMP_DIR/boot/$XEN_IMAGE_NAME
   cp $SCRIPTS_DIR/files/41-xen-boot-env.cmd $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd
   mkimage -C none -A arm -T script -d $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd $XEN_OVERLAY_TMP_DIR/boot/boot.scr
   cd $XEN_OVERLAY_TMP_DIR; ln -s boot/boot.scr; cd -
   cd $XEN_OVERLAY_TMP_DIR/boot/
   ln -s $XEN_IMAGE_NAME xen
   cd -

   cd $XEN_TOOLS_BUILD_PATH
   ./xen-build-tmp.sh
   cd -
   [ ! -f $XEN_OVERLAY_TMP_DIR/usr/lib/xen/bin/qemu-system-i386 ] && echo "$XEN_OVERLAY_TMP_DIR/usr/lib/xen/bin/qemu-system-i386 : not found"  && exit 0

   cd $XEN_OVERLAY_TMP_DIR
   tar -czf $XEN_IMAGE_FILE .
   cd -

   echo "Xen Image: $XEN_IMAGE_FILE"
fi


rm -rf $XEN_OVERLAY_TMP_DIR
