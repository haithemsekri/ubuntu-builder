#!/bin/bash

source $(dirname $(realpath $0))/20-cross-compiler-env.sh
source $(dirname $(realpath $0))/40-xen-env.sh

[ -z $XEN_DL_URL ]  && XEN_DL_URL="https://downloads.xenproject.org/release/xen/4.11.4/xen-4.11.4.tar.gz"
[ -z $XEN_DL_FILE ] && XEN_DL_FILE="$DL_DIR/$(basename $XEN_DL_URL)"

[ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
[ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0

XEN_DIST_BUILD_PATH="$BUILD_DIR/xen-dist"
XEN_TOOLS_BUILD_PATH="$BUILD_DIR/xen-tools"
XEN_OVERLAY_TMP_DIR="$BUILD_DIR/xen.overlay.tmp"

rm -rf $XEN_OVERLAY_TMP_DIR
mkdir -p $XEN_OVERLAY_TMP_DIR

if [ "$1" == "--rebuild" ]; then
   echo -n ""
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
fi
[ ! -d $XEN_TOOLS_BUILD_PATH ] && echo "$XEN_TOOLS_BUILD_PATH : not found"  && exit 0


echo "Building: $XEN_IMAGE_FILE"
if [ ! -f $XEN_IMAGE_FILE ]; then

   #XEN_TOOLS_EXTRA="--enable-systemd"
   [ "$TARGET_NAME" == "opipc2" ] && XEN_EARLY_PRINTK="sun7i"
   [ -z "$XEN_EARLY_PRINTK" ] &&  echo "XEN_EARLY_PRINTK: not defined" && exit 0

   mkdir -p $XEN_OVERLAY_TMP_DIR/boot

export L_TSYSROOT="/home/hs/Devel/github/ubuntu-builder6/rootfs"
source $TOOLCHAIN_ENV_FILE

cat <<EOF > $BUILD_DIR/xen-cross-compile.sh
#!/bin/bash

cd $XEN_DIST_BUILD_PATH
$(which make) -j dist-xen XEN_TARGET_ARCH="$L_TARGET_ARCH" CROSS_COMPILE="$L_TCC" CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK="$XEN_EARLY_PRINTK"
[ ! -f xen/xen ] && echo "xen/xen : not found"  && exit 1
cp xen/xen $XEN_OVERLAY_TMP_DIR/boot/xen

cd $XEN_TOOLS_BUILD_PATH
./configure PKG_CONFIG="$L_PKG_CONFIG" \
   PKG_CONFIG_SYSROOT_DIR="$L_PKG_CONFIG_SYSROOT_DIR" PKG_CONFIG_LIBDIR="$L_PKG_CONFIG_LIBDIR" \
   CC="$L_CC" CFLAGS="$L_CFLAGS" CXXFLAGS="$L_CXXFLAGS" LDFLAGS="$L_LDFLAGS" \
   --target="$L_TCC_ARCH" --host="$L_TCC_ARCH" --build=x86_64-pc-linux-gnu --prefix=/usr \
   --disable-gtk-doc --disable-gtk-doc-html  --disable-stubdom --disable-ioemu-stubdom --disable-pv-grub \
   --disable-xenstore-stubdom --disable-rombios --disable-ocamltools --disable-qemu-traditional --disable-doc \
   --disable-docs --disable-documentation --with-xmlto=no --with-fop=no --disable-dependency-tracking --enable-ipv6 \
   --disable-nls --disable-static --enable-shared --with-initddir=/etc/init.d --disable-ocamltools \
   --with-extra-qemuu-configure-args="--disable-sdl --disable-opengl --disable-werror --disable-libusb" $XEN_TOOLS_EXTRA
[ ! -f config.status ] && echo "config.status : not found"  && exit 1

PKG_CONFIG="$L_PKG_CONFIG" \
   PKG_CONFIG_SYSROOT_DIR="$L_PKG_CONFIG_SYSROOT_DIR" \
   PKG_CONFIG_LIBDIR="$L_PKG_CONFIG_LIBDIR" CC="$L_CC" \
   CFLAGS="$L_CFLAGS" CXXFLAGS="$L_CXXFLAGS" LDFLAGS="$L_LDFLAGS" CROSS_COMPILE="$L_TCC" \
   XEN_TARGET_ARCH="$L_TARGET_ARCH" HOST_EXTRACFLAGS="-Wno-error -Wno-declaration-after-statement" INTLTOOL_PERL=$(which perl) $(which make) dist-tools -j3
[ ! -f tools/qemu-xen-build/i386-softmmu/qemu-system-i386 ] && echo "tools/qemu-xen-build/i386-softmmu/qemu-system-i386 : not found"  && exit 1

PKG_CONFIG="$L_PKG_CONFIG" \
   PKG_CONFIG_SYSROOT_DIR="$L_PKG_CONFIG_SYSROOT_DIR" \
   PKG_CONFIG_LIBDIR="$L_PKG_CONFIG_LIBDIR" CC="$L_CC" \
   CFLAGS="$L_CFLAGS" CXXFLAGS="$L_CXXFLAGS" LDFLAGS="$L_LDFLAGS" CROSS_COMPILE="$L_TCC" \
   XEN_TARGET_ARCH="$L_TARGET_ARCH" $(which make) install-tools DESTDIR=$XEN_OVERLAY_TMP_DIR

echo "Installed to: $XEN_OVERLAY_TMP_DIR"
EOF
   #Start compilation in clean environment (a conflict found with TARGET_ARCH).
   chmod 755 $BUILD_DIR/xen-cross-compile.sh
   env -i bash -l -c $BUILD_DIR/xen-cross-compile.sh

   [ ! -f $XEN_OVERLAY_TMP_DIR/boot/xen ] && echo "$XEN_OVERLAY_TMP_DIR/boot/xen : not found"  && exit 0
   [ ! -f $XEN_OVERLAY_TMP_DIR/usr/lib/xen/bin/qemu-system-i386 ] && echo "$XEN_OVERLAY_TMP_DIR/usr/lib/xen/bin/qemu-system-i386 : not found"  && exit 0

   cd $XEN_OVERLAY_TMP_DIR
   tar -czf $XEN_IMAGE_FILE .
   cd -

   echo "Xen Image: $XEN_IMAGE_FILE"
   #cp $XEN_DIST_BUILD_PATH/xen/xen $XEN_OVERLAY_TMP_DIR/boot/$XEN_IMAGE_NAME
   #cp $SCRIPTS_DIR/files/41-xen-boot-env.cmd $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd
   #mkimage -C none -A arm -T script -d $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd $XEN_OVERLAY_TMP_DIR/boot/boot.scr
   #ln -s boot/boot.scr; cd -
fi


rm -rf $XEN_OVERLAY_TMP_DIR
rm -rf $XEN_DIST_BUILD_PATH
rm -rf $XEN_TOOLS_BUILD_PATH
