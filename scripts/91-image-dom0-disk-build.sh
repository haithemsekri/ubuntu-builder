#!/bin/bash
source $(dirname $(realpath $0))/90-image-disk-env.sh

echo "delete $SD_IMAGE_DISK_TAR"
rm -rf "$SD_IMAGE_DISK_TAR"

SCRIPT=$SCRIPTS_DIR/01-rootfs-build-base-image.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/21-cross-compiler-setup.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/32-kernel-build-dom0.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/41-xen-build.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/05-rootfs-build-dom0.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/53-bootfs-build-disk.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/51-loader-build-image.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

SCRIPT=$SCRIPTS_DIR/52-loader-build-disk.sh
echo -e "\e[30;48;5;82mRun: $SCRIPT \e[0m"; $SCRIPT $1

[ ! -f $LOADER_DISK ] && echo -e "\e[41mFailed: failed not found : $LOADER_DISK \e[0m" && exit 0
[ ! -f $BOOTFS_DISK ] && echo -e "\e[41mFailed: failed not found : $BOOTFS_DISK \e[0m" && exit 0
[ ! -f $ROOTFS_BASE_DISK ] && echo -e "\e[41mFailed: failed not found : $ROOTFS_BASE_DISK \e[0m" && exit 0

rm -rf $IMAGES_DIR
mkdir -p $IMAGES_DIR

cp $LOADER_DISK $IMAGES_DIR/loader.img
cp $BOOTFS_DISK $IMAGES_DIR/bootfs.$EXT_FS_TYPE
cp $ROOTFS_BASE_DISK $IMAGES_DIR/rootfs.$EXT_FS_TYPE
cp $SCRIPTS_DIR/files/91-prod-image-flash.sh $IMAGES_DIR/flash.sh

chmod 755 $IMAGES_DIR/flash.sh

cd $IMAGES_DIR/
ln -s loader.img loader
ln -s bootfs.$EXT_FS_TYPE bootfs
ln -s rootfs.$EXT_FS_TYPE rootfs

e2fsck -y -f bootfs
resize2fs -M bootfs
e2fsck -y -f rootfs
resize2fs -M rootfs

cd -
echo -e "\e[30;48;5;82mImage: $IMAGES_DIR \e[0m"

