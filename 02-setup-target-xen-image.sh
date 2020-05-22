#!/bin/bash

SRC_TAR_FILE="$(pwd)/cache/ubuntu-18.04-base-arm64.tar.gz"
DISK_FILE="$(pwd)/build/ubuntu-18.04-target-xen-arm64.ext3"
DISK_TAR_FILE="$(pwd)/cache/ubuntu-18.04-target-xen-arm64.tar.gz"
DISK_SIZE_MB=1024
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
apt-get -y update
apt-get -q -y install --no-install-recommends libyajl-dev libfdt-dev libaio-dev libpixman-1-dev libglib2.0-dev
EOF
   export ROOTFS_DISK_PATH=$DISK_FILE
   source run-script-in-image-disk-template.sh
   chroot_run_script $CHROOT_SCRIPT
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
