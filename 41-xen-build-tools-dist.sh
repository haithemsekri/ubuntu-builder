#!/bin/bash

source 00-rootfs-setup-env.sh
source 40-xen-setup-env.sh

[ ! -f $DEV_DISK_FILE ] &&  echo "$DEV_DISK_FILE not found" && exit 0
[ ! -f $DL_XEN_FILE ] && wget $DL_XEN_URL -O $DL_XEN_FILE
[ ! -f $DL_XEN_FILE ] &&  echo "$DL_XEN_FILE not found" && exit 0

build_xen() {

CHROOT_SCRIPT="/tmp/chroot-script.sh"
rm -rf  $CHROOT_SCRIPT
cat <<EOF > $CHROOT_SCRIPT
if [ -d /build/xen-dist ]; then
   echo "##=================================================dist-xen=============================================>>"
   cd /build/xen-dist
   ./configure --enable-xen

   make dist-xen XEN_TARGET_ARCH=arm64 CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK=sun7i -j20

   mkdir -p /build/xen-overlay/boot
   cp xen/xen /build/xen-overlay/boot/
fi

if [ -d /build/xen-tools ]; then
   echo "##=================================================dist-tools=============================================>>"
   cd /build/xen-tools
   ./configure --disable-xen  \
      --disable-gtk-doc --disable-gtk-doc-html \
      --enable-systemd \
      --prefix="" \
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
      --with-extra-qemuu-configure-args="--disable-sdl --disable-opengl --disable-werror"

   make dist-tools -j20

   mkdir -p /build/xen-overlay/
   make install-tools DESTDIR=/build/xen-overlay/
fi

EOF

   export ROOTFS_DISK_PATH=$DEV_DISK_FILE
   source 12-chroot-run.sh

   if [ "$1" == "--rebuild" ]; then
      echo "rebuild everything"
      sudo rm -rf "$TMP_DIR/build/xen*"
   fi

   if [ ! -d $TMP_DIR/build/xen-overlay ]; then
      [ ! -d $TMP_DIR/build ] && sudo mkdir -p $TMP_DIR/build

      sudo rm -rf $TMP_DIR/build/xen-tools
      sudo tar -xzf $DL_XEN_FILE -C $TMP_DIR/build/
      sudo mv $TMP_DIR/build/$XEN_TAR_DIR_NAME $TMP_DIR/build/xen-tools

      sudo rm -rf $TMP_DIR/build/xen-dist
      sudo tar -xzf $DL_XEN_FILE -C $TMP_DIR/build/
      sudo mv $TMP_DIR/build/$XEN_TAR_DIR_NAME $TMP_DIR/build/xen-dist

      chroot_run_script $CHROOT_SCRIPT
   fi

   if [ -d $TMP_DIR/build/xen-overlay ]; then
      cd $TMP_DIR/build/xen-overlay
      sudo tar -czf $XEN_IMAGE_TAR_FILE .
      cd -
      sudo chmod 666 $XEN_IMAGE_TAR_FILE
   fi

   cleanup_on_exit
   rm -rf  $CHROOT_SCRIPT
}

if [ "$1" == "--rebuild" ]; then
   echo "delete $XEN_IMAGE_TAR_FILE"
   rm -rf "$XEN_IMAGE_TAR_FILE"
fi

echo "Building $XEN_IMAGE_TAR_FILE"
[ ! -f $XEN_IMAGE_TAR_FILE ] && build_xen $1