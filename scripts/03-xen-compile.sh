#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $DL_DIR ]                 && echo "DL_DIR not defined" && exit 0
[ -z $DISTRO_NAME ]            && echo "DISTRO_NAME not defined" && exit 0
[ -z $TARGET_ARCH ]            && echo "TARGET_ARCH not defined" && exit 0
[ -z $SCRIPTS_DIR ]            && echo "SCRIPTS_DIR not defined" && exit 0
[ -z $ROOTFS_TARGET_DISK ]     && echo "ROOTFS_TARGET_DISK not defined" && exit 0
[ ! -f $ROOTFS_TARGET_DISK ]   &&  echo "$ROOTFS_TARGET_DISK not found" && exit 0

[ -z $XEN_DL_URL ]  && XEN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/xen-4.11.4.tar.xz"
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
   TMP_DIR=$BUILD_DIR/tar.xz.tmp
   mkdir $TMP_DIR
   tar -xf $XEN_DL_FILE -C $TMP_DIR
   mv $TMP_DIR $XEN_DIST_BUILD_PATH
fi
[ ! -d $XEN_DIST_BUILD_PATH ] && echo "$XEN_DIST_BUILD_PATH : not found"  && exit 0

echo "Setup: $XEN_TOOLS_BUILD_PATH"
if [ ! -d $XEN_TOOLS_BUILD_PATH ]; then
   echo "Based on: $XEN_DL_FILE"
   TMP_DIR=$BUILD_DIR/tar.xz.tmp
   mkdir $TMP_DIR
   tar -xf $XEN_DL_FILE -C $TMP_DIR/
   mv  $TMP_DIR $XEN_TOOLS_BUILD_PATH
   patch --verbose $XEN_TOOLS_BUILD_PATH/xen/include/public/arch-arm.h $SCRIPTS_DIR/files/libgcc-4-xen-arm.patch
fi
[ ! -d $XEN_TOOLS_BUILD_PATH ] && echo "$XEN_TOOLS_BUILD_PATH : not found"  && exit 0

echo "Building: $XEN_IMAGE_FILE"
if [ ! -f $XEN_IMAGE_FILE ]; then

   #XEN_TOOLS_EXTRA="--enable-systemd"
   [ "$TARGET_NAME" == "opipc2" ] && XEN_EARLY_PRINTK="sun7i"

   if [ "$USE_SYSTEMD" == "YES" ]; then
      export L_CONF_EXTRA_FLAGS="--enable-systemd"
   else
      export L_CONF_EXTRA_FLAGS="--disable-systemd"
   fi

   [ -z "$XEN_EARLY_PRINTK" ] &&  echo "XEN_EARLY_PRINTK: not defined" && exit 0

   export L_SYSROOT="$BUILD_DIR/cc-rootfs-tmp"
   mkdir -p $L_SYSROOT
   if_mounted_umount() {
      MTAB_ENTRY="$(mount | egrep "$1")"
      [ ! -z "$MTAB_ENTRY" ] && echo "umount $1" && umount $1
      MTAB_ENTRY="$(mount | egrep "$1")"
      [ ! -z "$MTAB_ENTRY" ] && echo "force umount $1" && umount -f -l $1
   }

   cleanup_on_exit () {
      echo "cleanup_on_exit"
      if_mounted_umount ${L_SYSROOT}
      rm -rf ${L_SYSROOT}
   }
   trap cleanup_on_exit EXIT
   mount -o loop $ROOTFS_TARGET_DISK $L_SYSROOT
   MTAB_ENTRY="$(mount | egrep "$ROOTFS_TARGET_DISK" | egrep "$L_SYSROOT")"
   [ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" &&  exit 1
   [ ! -f "$L_SYSROOT/cross-build-env.sh" ] &&  echo "L_SYSROOT/cross-build-env.sh : file not found" && exit 1
   source "$L_SYSROOT/cross-build-env.sh"

cat <<EOF > $BUILD_DIR/xen-cross-compile.sh
#!/bin/bash

mkdir -p $XEN_OVERLAY_TMP_DIR/boot

cd $XEN_DIST_BUILD_PATH
/usr/bin/make  -j dist-xen XEN_TARGET_ARCH="$L_CROSS_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK="$XEN_EARLY_PRINTK"
[ ! -f xen/xen ] && echo "xen/xen : not found"  && exit 1
cp xen/xen $XEN_OVERLAY_TMP_DIR/boot/xen

cd $XEN_TOOLS_BUILD_PATH

./configure \
CC="${L_CC} ${L_CFLAGS}" \
CXX="${L_CXX} ${L_CXXFLAGS}" \
LD="${L_LD} ${L_LDFLAGS}" \
LDFLAGS="${L_LDFLAGS}" \
PKG_CONFIG="${L_PKG_CONFIG}" \
PKG_CONFIG_LIBDIR="${L_PKG_CONFIG_LIBDIR}" \
PKG_CONFIG_SYSROOT_DIR="${L_PKG_CONFIG_SYSROOT_DIR}" \
PYTHON="/usr/bin/python2" \
$L_CONF_EXTRA_FLAGS \
--disable-xen \
--enable-tools \
--build=x86_64-linux-gnu \
--host="$L_CROSS_PREFIX" \
--target="$L_CROSS_PREFIX" \
--disable-gtk-doc --disable-gtk-doc-html  --disable-stubdom --disable-ioemu-stubdom --disable-pv-grub \
--disable-xenstore-stubdom --disable-rombios --disable-ocamltools --disable-qemu-traditional --disable-doc \
--disable-docs --disable-documentation --with-xmlto=no --with-fop=no --disable-dependency-tracking --enable-ipv6 --disable-blobs \
--disable-nls --disable-static --enable-shared --with-initddir=/etc/init.d --disable-ocamltools --disable-vnc --disable-gtk --disable-monitors \
--with-extra-qemuu-configure-args="--disable-vnc --disable-gtk --disable-sdl --disable-opengl --disable-werror --disable-libusb"
[ ! -f config.status ] && echo "config.status : not found"  && exit 1

PKG_CONFIG="${L_PKG_CONFIG}" \
PKG_CONFIG_LIBDIR="${L_PKG_CONFIG_LIBDIR}" \
PKG_CONFIG_SYSROOT_DIR="${L_PKG_CONFIG_SYSROOT_DIR}" \
XEN_TARGET_ARCH="$L_CROSS_ARCH" \
LDFLAGS="${L_LDFLAGS}" \
PYTHON="/usr/bin/python2" \
LD_LIBRARY_PATH="${L_SYSROOT}/lib" \
/usr/bin/make dist-tools -j3 \
CC="${L_CC} ${L_CFLAGS}" \
CXX="${L_CXX} ${L_CXXFLAGS}" \
LD="${L_LD} ${L_LDFLAGS}" \
AR="${L_AR}" \
STRIP="${L_STRIP}" \
RC="${L_RC}" \
AS="${L_AS}"
[ ! -f tools/qemu-xen-build/i386-softmmu/qemu-system-i386 ] && echo "tools/qemu-xen-build/i386-softmmu/qemu-system-i386 : not found"  && exit 1

PKG_CONFIG="${L_PKG_CONFIG}" \
PKG_CONFIG_LIBDIR="${L_PKG_CONFIG_LIBDIR}" \
PKG_CONFIG_SYSROOT_DIR="${L_PKG_CONFIG_SYSROOT_DIR}" \
XEN_TARGET_ARCH="${L_CROSS_ARCH}" \
LDFLAGS="${L_LDFLAGS}" \
PYTHON="/usr/bin/python2" \
LD_LIBRARY_PATH="${L_SYSROOT}/lib" \
/usr/bin/make install-tools DESTDIR="$XEN_OVERLAY_TMP_DIR" \
CC="${L_CC} ${L_CFLAGS}" \
CXX="${L_CXX} ${L_CXXFLAGS}" \
LD="${L_LD} ${L_LDFLAGS}" \
AR="${L_AR}" \
STRIP="${L_STRIP}" \
RC="${L_RC}" \
AS="${L_AS}"
echo "Installed to: $XEN_OVERLAY_TMP_DIR"
EOF

   #Start compilation in clean environment (a conflict found with TARGET_ARCH).
   chmod 755 $BUILD_DIR/xen-cross-compile.sh
   env -i bash -l -c $BUILD_DIR/xen-cross-compile.sh
   umount $L_SYSROOT

   [ ! -f $XEN_OVERLAY_TMP_DIR/boot/xen ] && echo "$XEN_OVERLAY_TMP_DIR/boot/xen : not found"  && exit 0
   [ ! -f $XEN_OVERLAY_TMP_DIR/usr/local/lib/xen/bin/qemu-system-i386 ] && echo "$XEN_OVERLAY_TMP_DIR/usr/local/lib/xen/bin/qemu-system-i386 : not found"  && exit 0

   cd $XEN_OVERLAY_TMP_DIR
   tar -I 'pxz -T 0 -9' -cf $XEN_IMAGE_FILE .
   cd -

   echo "Xen Image: $XEN_IMAGE_FILE"
   cp $XEN_DIST_BUILD_PATH/xen/xen $XEN_OVERLAY_TMP_DIR/boot/xen

   rm -rf $XEN_OVERLAY_TMP_DIR
   rm -rf $XEN_DIST_BUILD_PATH
   rm -rf $XEN_TOOLS_BUILD_PATH
   rm -rf $BUILD_DIR/xen-cross-compile.sh
   rm -rf $L_SYSROOT
fi

exit 0

   #cp $SCRIPTS_DIR/files/41-xen-boot-env.cmd $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd
   #mkimage -C none -A arm -T script -d $XEN_OVERLAY_TMP_DIR/boot/xen-boot.cmd $XEN_OVERLAY_TMP_DIR/boot/boot.scr
   #ln -s boot/boot.scr; cd -

cat <<EOF > $BUILD_DIR/xen-cross-compile.sh
#!/bin/bash

mkdir -p $XEN_OVERLAY_TMP_DIR/boot

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