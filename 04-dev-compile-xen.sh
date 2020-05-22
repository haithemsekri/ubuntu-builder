#!/bin/bash

source 00-setup-packages.sh

TAR_FILE=$DL_XEN_FILE
DISK_FILE="$(pwd)/build/ubuntu-18.04-dev-xen-arm64.ext3"
XEN_DIST_TAR_FILE="$(pwd)/cache/xen-4.11.4-dist.tar.gz"
XEN_TOOLS_TAR_FILE="$(pwd)/cache/xen-4.11.4-tools.tar.gz"
[ ! -f $TAR_FILE ] &&  echo "$TAR_FILE not found" && exit 0
[ ! -f $DISK_FILE ] &&  echo "$DISK_FILE not found" && exit 0

CHROOT_SCRIPT="/tmp/chroot-script.sh"
rm -rf  $CHROOT_SCRIPT
cat <<EOF >> $CHROOT_SCRIPT

if [ ! -d /build/xen-dist/xen-dist-install ]; then
echo "##=================================================dist-xen=============================================>>"
cd /build/xen-dist
./configure --enable-xen

make dist-xen XEN_TARGET_ARCH=arm64 CONFIG_DEBUG=y debug=y CONFIG_EARLY_PRINTK=sun7i -j20

mkdir /build/xen-dist/xen-dist-install
cp xen/xen /build/xen-dist/xen-dist-install/

fi

if [ ! -d /build/xen-tools/xen-tools-install ]; then
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

mkdir -p /build/xen-tools/xen-tools-install
make install-tools DESTDIR=/build/xen-tools/xen-tools-install

fi

EOF

export ROOTFS_DISK_PATH=$DISK_FILE
source run-script-in-image-disk-template.sh

if [ "$1" == "--rebuild" ]; then
echo "clean everything"
sudo rm -rf "$TMP_DIR/build/xen-dist"
sudo rm -rf "$TMP_DIR/build/xen-tools"
fi

if [ ! -d $TMP_DIR/build/xen-tools ]; then
sudo tar -xzf $TAR_FILE -C $TMP_DIR/build/
sudo mv "$TMP_DIR/build/xen-4.11.4" "$TMP_DIR/build/xen-tools"
fi

if [ ! -d $TMP_DIR/build/xen-dist ]; then
sudo tar -xzf $TAR_FILE -C $TMP_DIR/build/
sudo mv "$TMP_DIR/build/xen-4.11.4" "$TMP_DIR/build/xen-dist"
fi

chroot_run_script $CHROOT_SCRIPT

if [ -d $TMP_DIR/build/xen-dist/xen-dist-install ]; then
   cd $TMP_DIR/build/xen-dist/xen-dist-install
   sudo tar -czf $XEN_DIST_TAR_FILE .
   cd -
fi

sudo chmod 666 $XEN_DIST_TAR_FILE

if [ -d $TMP_DIR/build/xen-tools/xen-tools-install ]; then
   cd $TMP_DIR/build/xen-tools/xen-tools-install
   sudo tar -czf $XEN_TOOLS_TAR_FILE .
   cd -
fi

sudo chmod 666 $XEN_TOOLS_TAR_FILE

cleanup_on_exit