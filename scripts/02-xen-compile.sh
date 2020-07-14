#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

[ -z $DL_DIR ]                 && echo "DL_DIR not defined" && exit 0
[ -z $DISTRO_NAME ]            && echo "DISTRO_NAME not defined" && exit 0
[ -z $TARGET_ARCH ]            && echo "TARGET_ARCH not defined" && exit 0
[ -z $SCRIPTS_DIR ]            && echo "SCRIPTS_DIR not defined" && exit 0
[ -z $ROOTFS_TARGET_DISK ]     && echo "ROOTFS_TARGET_DISK not defined" && exit 0
[ ! -f $ROOTFS_TARGET_DISK ]   &&  echo "$ROOTFS_TARGET_DISK not found" && exit 0

[ -z $XEN_DL_URL ]    && XEN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/xen-4.11.4.tar.xz"
[ -z $XEN_DL_FILE ]   && XEN_DL_FILE="$DL_DIR/$(basename $XEN_DL_URL)"
[ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
[ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0

if [ "$1" == "--xen-build-distro" ]; then
   [ "$TARGET_NAME" == "opipc2" ] && XEN_EARLY_PRINTK="sun7i"
   [ -z "$XEN_EARLY_PRINTK" ] &&  echo "XEN_EARLY_PRINTK: not defined" && exit 0

   echo "delete $XEN_DISTRO_IMAGE_FILE"
   rm -rf $XEN_DISTRO_IMAGE_FILE

   TMP_BUILD_DIR="$BUILD_DIR/build-tmp"
   rm -rf $TMP_BUILD_DIR
   mkdir -p $TMP_BUILD_DIR
   tar -xf $XEN_DL_FILE -C $TMP_BUILD_DIR
   cd $TMP_BUILD_DIR
   /usr/bin/make -j dist-xen XEN_TARGET_ARCH="$L_CROSS_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK="$XEN_EARLY_PRINTK"
   [ ! -f $TMP_BUILD_DIR/xen/xen ] && echo "$TMP_BUILD_DIR/xen/xen : file not found"  && exit 1

   TMP_TAR_DIR="$BUILD_DIR/tar-tmp"
   rm -rf $TMP_TAR_DIR
   mkdir -p $TMP_TAR_DIR/boot
   cp $TMP_BUILD_DIR/xen/xen $TMP_TAR_DIR/boot/xen
   cd $TMP_TAR_DIR
   tar -I 'pxz -T 0 -9' -cf $XEN_DISTRO_IMAGE_FILE .
   chmod 666 $XEN_DISTRO_IMAGE_FILE
   cd $WORKSPACE
   rm -rf $TMP_BUILD_DIR
   rm -rf $TMP_TAR_DIR
   echo "Xen Distro Image: $XEN_DISTRO_IMAGE_FILE"
fi

if [ "$1" == "--xen-build-tools" ]; then
   if [ "$USE_SYSTEMD" == "YES" ]; then
      export L_CONF_EXTRA_FLAGS="--enable-systemd"
   else
      export L_CONF_EXTRA_FLAGS="--disable-systemd"
   fi
   echo "delete $XEN_TOOLS_IMAGE_FILE"
   rm -rf $XEN_TOOLS_IMAGE_FILE
   TMP_BUILD_DIR="$BUILD_DIR/xen-build-tmp"
   rm -rf $TMP_BUILD_DIR
   mkdir -p $TMP_BUILD_DIR
   tar -xf $XEN_DL_FILE -C $TMP_BUILD_DIR
   patch --verbose $TMP_BUILD_DIR/xen/include/public/arch-arm.h $SCRIPTS_DIR/files/libgcc-4-xen-arm.patch

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

   TMP_TAR_DIR="$BUILD_DIR/xen-install-tmp"
   rm -rf $TMP_TAR_DIR
   mkdir -p $TMP_TAR_DIR

cat <<EOF > $BUILD_DIR/xen-tools-compile.sh
#!/bin/bash

cd $TMP_BUILD_DIR

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
/usr/bin/make dist-tools -j \
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
/usr/bin/make install-tools DESTDIR="$TMP_TAR_DIR" \
CC="${L_CC} ${L_CFLAGS}" \
CXX="${L_CXX} ${L_CXXFLAGS}" \
LD="${L_LD} ${L_LDFLAGS}" \
AR="${L_AR}" \
STRIP="${L_STRIP}" \
RC="${L_RC}" \
AS="${L_AS}"
echo "Installed to: $TMP_TAR_DIR"
EOF

   #Start compilation in clean environment (a conflict found with TARGET_ARCH).
   chmod 755 $BUILD_DIR/xen-tools-compile.sh
   env -i bash -l -c $BUILD_DIR/xen-tools-compile.sh
   umount $L_SYSROOT
   rm -rf $L_SYSROOT

   [ ! -f $TMP_TAR_DIR/usr/local/lib/xen/bin/qemu-system-i386 ] && echo "$TMP_TAR_DIR/usr/local/lib/xen/bin/qemu-system-i386 : not found"  && exit 0

   cd $TMP_TAR_DIR
   tar -I 'pxz -T 0 -9' -cf $XEN_TOOLS_IMAGE_FILE .
   chmod 666 $XEN_TOOLS_IMAGE_FILE
   cd $WORKSPACE

   rm -rf $TMP_TAR_DIR
   rm -rf $TMP_BUILD_DIR
   rm -rf $BUILD_DIR/xen-tools-compile.sh
   echo "Xen Tools Image: $XEN_TOOLS_IMAGE_FILE"
fi
