#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh
source $(dirname $(realpath $0))/00-rootfs-env.sh
source $(dirname $(realpath $0))/50-loader-env.sh

[ ! -f $BOOTFS_TARGET_IMAGE ] && echo "$BOOTFS_TARGET_IMAGE : file not found" && exit 0

echo "Build: $BOOTFS_DISK"
echo "Based on: $BOOTFS_TARGET_IMAGE"
$SCRIPTS_DIR/10-tar-to-disk-image.sh $BOOTFS_TARGET_IMAGE $BOOTFS_DISK $BOOT_PART_SIZE

RTFS_MNT_DIR=$BUILD_DIR/boot.build.disk.tmp
mkdir -p $RTFS_MNT_DIR
sudo mount $BOOTFS_DISK $RTFS_MNT_DIR
MTAB_ENTRY="$(mount | egrep "$BOOTFS_DISK" | egrep "$RTFS_MNT_DIR")"
[ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && rm -rf $RTFS_MNT_DIR  && exit 0

sudo touch $RTFS_MNT_DIR/boot.cmd
sudo chmod 666 $RTFS_MNT_DIR/boot.cmd

cat <<EOF > $RTFS_MNT_DIR/boot.cmd

# mkimage -C none -A arm -T script -d boot.cmd boot.scr
setenv load_cmd "$BOOTFS_LOAD_CMD"
setenv rootfs_path $ROOTFS_DISK_PART
setenv kernel_addr_r $BOOT_KERNEL_ADDR
setenv src_addr_r $BOOT_SRC_ADDR
setenv xen_addr_r $BOOT_XEN_ADDR
setenv dtb_addr_r $BOOT_DTB_ADDR
setenv src_path boot/boot.scr

\$load_cmd \$src_addr_r \$src_path
source \$src_addr_r

EOF

sudo mkimage -C none -A arm -T script -d $RTFS_MNT_DIR/boot.cmd $RTFS_MNT_DIR/boot.scr

cat $RTFS_MNT_DIR/boot.cmd
sudo umount $RTFS_MNT_DIR
rm -rf $RTFS_MNT_DIR

echo "Bootfs disk: $BOOTFS_DISK"
