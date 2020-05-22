#!/bin/bash

[ ! -d "cache" ] && mkdir cache
[ ! -d "build" ] && mkdir build

source 00-setup-packages.sh

SRC_TAR_FILE=$DL_ROOTFS_FILE
DISK_FILE="$(pwd)/build/ubuntu-18.04-base-arm64.ext3"
DISK_TAR_FILE="$(pwd)/cache/ubuntu-18.04-base-arm64.tar.gz"
DISK_SIZE_MB=512
[ ! -f $SRC_TAR_FILE ] &&  echo "$SRC_TAR_FILE not found" && exit 0

create_rootfs_disk() {
if [ -f $DISK_TAR_FILE ]; then
   echo "Based on: $DISK_TAR_FILE"
   ./tar-to-disk-image.sh $DISK_TAR_FILE $DISK_FILE $DISK_SIZE_MB
else
   echo "Based on: $SRC_TAR_FILE"
   ./tar-to-disk-image.sh $SRC_TAR_FILE $DISK_FILE $DISK_SIZE_MB
   CHROOT_SCRIPT="/tmp/chroot-script.sh"
   rm -rf  $CHROOT_SCRIPT
cat <<EOF >> $CHROOT_SCRIPT
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 2001:4860:4860::8888" >> /etc/resolv.conf
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/30norecommends
echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/30norecommends

passwd
apt-get -y clean
apt-get -y update
apt-get -y install --no-install-recommends apt-utils dialog
apt-get -y install --no-install-recommends locales
locale-gen en_US.UTF-8

apt-get -y upgrade
apt-get -y install --no-install-recommends util-linux nano openssh-server
apt-get -y install --no-install-recommends systemd udev systemd-sysv
apt-get -y install --no-install-recommends net-tools iproute2 iputils-ping ethtool isc-dhcp-client
rm /*.sh
EOF
   export ROOTFS_DISK_PATH=$DISK_FILE
   source run-script-in-image-disk-template.sh
   chroot_run_script $CHROOT_SCRIPT
   sudo rsync -avlz  overlays/  ${TMP_DIR}/
   cleanup_on_exit
fi
}

backup_rootfs_disk() {
   echo "Based on: $DISK_FILE"
   ./disk-image-to-tar.sh $DISK_FILE $DISK_TAR_FILE
}

echo "Building $DISK_FILE"
[ ! -f $DISK_FILE ] && create_rootfs_disk
echo "Building $DISK_TAR_FILE"
[ ! -f $DISK_TAR_FILE ] && backup_rootfs_disk
