#!/bin/bash

SRC_TAR_FILE="$(pwd)/cache/ubuntu-18.04-target-xen-arm64.tar.gz"
DISK_FILE="$(pwd)/build/ubuntu-18.04-dev-xen-arm64.ext3"
DISK_TAR_FILE="$(pwd)/cache/ubuntu-18.04-dev-xen-arm64.tar.gz"
DISK_SIZE_MB=3000
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
apt-get -q -y install --no-install-recommends build-essential gettext \
   libc6-dev libncurses-dev libssl-dev uuid-dev  util-linux \
   libpython2.7-dev gcc git autoconf ccache python iasl python-dev pkg-config wget flex bison libsystemd-dev

/usr/sbin/update-ccache-symlinks
mkdir -p /home/$(whoami)/
mkdir -p /home/root/
touch ~/.bashrc
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
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
