#!/bin/bash

if [ "$1" == "--xen-distro-build" ]; then
   [ -z "$XEN_EARLY_PRINTK" ] &&  echo "XEN_EARLY_PRINTK: not defined" && exit 0
   [ -z $XEN_DL_FILE ]   && XEN_DL_FILE="$DL_DIR/$(basename $XEN_DL_URL)"
   [ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
   [ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0
   [ ! -f "$L_CROSS_COMPILE"gcc ] &&  echo "L_CROSS_COMPILEgcc: file not found" && exit 0
   echo "delete $XEN_DISTRO_PACKAGE_TAR"
   rm -rf $XEN_DISTRO_PACKAGE_TAR
   TMP_BUILD_DIR="$BUILD_DIR/xen-distro-build"
   if [ ! -d $TMP_BUILD_DIR ]; then
      echo "Setup: $TMP_BUILD_DIR"
      mkdir -p $TMP_BUILD_DIR
      tar -xf $XEN_DL_FILE -C $TMP_BUILD_DIR
   fi
   cd $TMP_BUILD_DIR
   /usr/bin/make -j4 dist-xen XEN_TARGET_ARCH="$L_CROSS_ARCH" CROSS_COMPILE="$L_CROSS_COMPILE" CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK="$XEN_EARLY_PRINTK"
   [ ! -f $TMP_BUILD_DIR/xen/xen ] && echo "$TMP_BUILD_DIR/xen/xen : file not found"  && exit 1
   TMP_TAR_DIR="$BUILD_DIR/tar-tmp"
   rm -rf $TMP_TAR_DIR
   mkdir -p $TMP_TAR_DIR/boot
   cp $TMP_BUILD_DIR/xen/xen $TMP_TAR_DIR/boot/$XEN_PACKAGE_NAME.bin
   cd $TMP_TAR_DIR/boot/
   ln -sf $XEN_PACKAGE_NAME.bin xen
   cd $TMP_TAR_DIR
   tar -I 'pxz -T 0 -9' -cf $XEN_DISTRO_PACKAGE_TAR .
   chmod 666 $XEN_DISTRO_PACKAGE_TAR
   cd $WORKSPACE
   rm -rf $TMP_TAR_DIR
   echo "Xen Distro Image: $XEN_DISTRO_PACKAGE_TAR"
fi

if [ "$1" == "--xen-tools-build" ]; then
   [ -z $XEN_DL_FILE ]   && XEN_DL_FILE="$DL_DIR/$(basename $XEN_DL_URL)"
   [ ! -f $XEN_DL_FILE ] && wget $XEN_DL_URL -O $XEN_DL_FILE
   [ ! -f $XEN_DL_FILE ] &&  echo "$XEN_DL_FILE not found" && exit 0
   [ ! -f $ROOTFS_BASE_DISK ]   &&  echo "$ROOTFS_BASE_DISK not found" && exit 0
   [ ! -f "$L_CROSS_COMPILE"gcc ] &&  echo "L_CROSS_COMPILEgcc: file not found" && exit 0
   echo "delete $XEN_TOOLS_PACKAGE_TAR"
   rm -rf $XEN_TOOLS_PACKAGE_TAR
   TMP_BUILD_DIR="$BUILD_DIR/xen-tools-build"
   if [ ! -d $TMP_BUILD_DIR ]; then
      echo "Setup: $TMP_BUILD_DIR"
      mkdir -p $TMP_BUILD_DIR
      tar -xf $XEN_DL_FILE -C $TMP_BUILD_DIR
      patch --verbose $TMP_BUILD_DIR/xen/include/public/arch-arm.h $TARGET_FILES/xen-arm-libgcc-4.patch
   fi

   if [ "$USE_SYSTEMD" == "YES" ]; then
      export L_CONF_EXTRA_FLAGS="--enable-systemd"
   else
      export L_CONF_EXTRA_FLAGS="--disable-systemd"
   fi

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
   mount -o loop $ROOTFS_BASE_DISK $L_SYSROOT
   sync
   MTAB_ENTRY="$(mount | egrep "$ROOTFS_BASE_DISK" | egrep "$L_SYSROOT")"
   [ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" &&  exit 1
   [ ! -f "$L_SYSROOT/cross-build-env.sh" ] &&  echo "L_SYSROOT/cross-build-env.sh : file not found" && exit 1

   source "$L_SYSROOT/cross-build-env.sh"
   TMP_TAR_DIR="$BUILD_DIR/xen-install-tmp"

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
/usr/bin/make dist-tools -j4 \
CC="${L_CC} ${L_CFLAGS}" \
CXX="${L_CXX} ${L_CXXFLAGS}" \
LD="${L_LD} ${L_LDFLAGS}" \
AR="${L_AR}" \
STRIP="${L_STRIP}" \
RC="${L_RC}" \
AS="${L_AS}"
[ ! -f tools/qemu-xen-build/i386-softmmu/qemu-system-i386 ] && echo "tools/qemu-xen-build/i386-softmmu/qemu-system-i386 : not found"  && exit 1

rm -rf $TMP_TAR_DIR
mkdir -p $TMP_TAR_DIR
PKG_CONFIG="${L_PKG_CONFIG}" \
PKG_CONFIG_LIBDIR="${L_PKG_CONFIG_LIBDIR}" \
PKG_CONFIG_SYSROOT_DIR="${L_PKG_CONFIG_SYSROOT_DIR}" \
XEN_TARGET_ARCH="${L_CROSS_ARCH}" \
LDFLAGS="${L_LDFLAGS}" \
PYTHON="/usr/bin/python2" \
LD_LIBRARY_PATH="${L_SYSROOT}/lib" \
/usr/bin/make -j4 install-tools DESTDIR="$TMP_TAR_DIR" \
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

if [ "$USE_SYSTEMD" == "YES" ]; then
cat <<EOF > $TMP_TAR_DIR/post-install-chroot.sh
#!/bin/bash
/lib/systemd/systemd-sysv-install enable xendomains
/lib/systemd/systemd-sysv-install enable xendriverdomain
/lib/systemd/systemd-sysv-install enable xen-watchdog
/lib/systemd/systemd-sysv-install enable xendomains
systemctl enable xenconsoled.service
systemctl enable xendriverdomain.service
systemctl enable xen-watchdog.service
systemctl enable xendomains.service
systemctl enable xen-qemu-dom0-disk-backend.service
systemctl enable xen-init-dom0.service
systemctl enable xenstored.service
rm /usr/local/lib/modules-load.d/xen.conf
ldconfig /usr/local/lib/
echo "/usr/local/lib/" > /etc/ld.so.conf.d/usr-local-lib.conf
ldconfig

EOF
else
cat <<EOF > $TMP_TAR_DIR/post-install-chroot.sh
#!/bin/bash
update-rc.d xencommons defaults 19 18
update-rc.d xendomains defaults 21 20
update-rc.d xen-watchdog defaults 22 23
update-rc.d xen-watchdog defaults 25 24
rm /usr/local/lib/modules-load.d/xen.conf
ldconfig /usr/local/lib/
echo "/usr/local/lib/" > /etc/ld.so.conf.d/usr-local-lib.conf
ldconfig

EOF
fi

   cd $TMP_TAR_DIR
   tar -I 'pxz -T 0 -9' -cf $XEN_TOOLS_PACKAGE_TAR .
   chmod 666 $XEN_TOOLS_PACKAGE_TAR
   cd $WORKSPACE
   rm -rf $TMP_TAR_DIR
   rm -rf $BUILD_DIR/xen-tools-compile.sh
   echo "Xen Tools Image: $XEN_TOOLS_PACKAGE_TAR"
fi
