#!/bin/bash

source 00-setup-env.sh

SRC_TAR_FILE=$BASE_TAR_FILE
DISK_FILE=$TARGET_DISK_FILE
DISK_TAR_FILE=$TARGET_TAR_FILE
DISK_SIZE_MB=1024
[ ! -f $SRC_TAR_FILE ] &&  echo "$SRC_TAR_FILE not found" && exit 0

create_rootfs_disk() {
if [ -f $DISK_TAR_FILE ]; then
   echo "Based on: $DISK_TAR_FILE"
   ./10-tar-to-disk-image.sh $DISK_TAR_FILE $DISK_FILE $DISK_SIZE_MB
else
   echo "Based on: $SRC_TAR_FILE"
   ./10-tar-to-disk-image.sh $SRC_TAR_FILE $DISK_FILE $DISK_SIZE_MB
   CHROOT_SCRIPT="/tmp/chroot-script.sh"
   rm -rf  $CHROOT_SCRIPT
cat <<EOF > $CHROOT_SCRIPT
#!/bin/bash
apt-get -y update
apt-get -q -y install --no-install-recommends libyajl-dev \
   libfdt-dev libaio-dev libpixman-1-dev libglib2.0-dev
EOF
   export ROOTFS_DISK_PATH=$DISK_FILE
   source 12-chroot-run.sh
   chroot_run_script $CHROOT_SCRIPT
   rm -rf $CHROOT_SCRIPT
   sudo rsync -avlz  overlays/  ${TMP_DIR}/
   cleanup_on_exit
fi
}

backup_rootfs_disk() {
   echo "Based on: $DISK_FILE"
   ./11-disk-image-to-tar.sh $DISK_FILE $DISK_TAR_FILE
}

echo "Building $DISK_FILE"
[ ! -f $DISK_FILE ] && create_rootfs_disk
echo "Building $DISK_TAR_FILE"
[ ! -f $DISK_TAR_FILE ] && backup_rootfs_disk
