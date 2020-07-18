#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

rm -rf $ROOTFS_TARGET_DISK
rm -rf $SD_DISK_IMG

####################################################################### ROOTFSA
build_rootfs_image() {
   echo -e "\e[30;48;5;82mSetup rootfs image \e[0m"
   $SCRIPTS_DIR/10-tar-to-disk-image.sh $ROOTFS_BASE_TAR $ROOTFS_TARGET_DISK $ROOTFS_SIZE_MB
   [ ! -f $ROOTFS_TARGET_DISK ]  && echo "$ROOTFS_TARGET_DISK : file not found"  && exit 0
   sync

   export ROOTFS_DISK_PATH=$ROOTFS_TARGET_DISK
   source $SCRIPTS_DIR/12-chroot-run.sh

   tar --skip-old-file -xf $LINUX_DOM0_PACKAGE_TAR -C $RTFS_MNT_DIR
   if [ -f "$RTFS_MNT_DIR/post-install-chroot.sh" ]; then
      chroot_run_script "$RTFS_MNT_DIR/post-install-chroot.sh"
      rm -rf "$RTFS_MNT_DIR/post-install-chroot.sh"
   fi

   tar --skip-old-file -xf $XEN_TOOLS_PACKAGE_TAR -C $RTFS_MNT_DIR
   if [ -f "$RTFS_MNT_DIR/post-install-chroot.sh" ]; then
      chroot_run_script "$RTFS_MNT_DIR/post-install-chroot.sh"
      rm -rf "$RTFS_MNT_DIR/post-install-chroot.sh"
   fi

   tar --skip-old-file -xf $XEN_DISTRO_PACKAGE_TAR -C $RTFS_MNT_DIR
   if [ -f "$RTFS_MNT_DIR/post-install-chroot.sh" ]; then
      chroot_run_script "$RTFS_MNT_DIR/post-install-chroot.sh"
      rm -rf "$RTFS_MNT_DIR/post-install-chroot.sh"
   fi

   if [ -f "$TARGET_FILES/$DISTRO_NAME-rootfs-overlays.sh" ]; then
      chroot_run_script "$TARGET_FILES/$DISTRO_NAME-rootfs-overlays.sh"
   fi

   cp $BOOT_XEN_SCRIPT     $RTFS_MNT_DIR/boot/xen-boot.cmd
   cp $BOOT_LINUX_SCRIPT  $RTFS_MNT_DIR/boot/kernel-boot.cmd

   cd $RTFS_MNT_DIR/boot/
   mkimage -C none -A arm -T script -d xen-boot.cmd xen-boot.scr  1> /dev/null
   mkimage -C none -A arm -T script -d kernel-boot.cmd kernel-boot.scr  1> /dev/null
   ln -sf xen-boot.scr boot.scr

   cd $WORKSPACE
   chroot_umount_pseudo_fs

   if [ "$1" == "--all" ]; then
      cd $RTFS_MNT_DIR
      echo -e "\e[30;48;5;82mSetup rootfs tar \e[0m"
      tar -I 'pxz -T 0 -1' -cf $ROOTFS_TARGET_TAR .
      cd $WORKSPACE
   fi

   cleanup_on_exit
}

####################################################################### BOOTFS
build_bootfs_image() {
   echo -e "\e[30;48;5;82mSetup bootfs image \e[0m"
   rm -rf $BOOTFS_DISK
   fallocate -l $((1024*1024*32)) $BOOTFS_DISK  1> /dev/null
   mkfs.ext3 $BOOTFS_DISK  1> /dev/null
   TMP_MNT_DIR="$BUILD_DIR/mount-tmp"
   rm -rf $TMP_MNT_DIR
   mkdir -p $TMP_MNT_DIR
   mount -o loop $BOOTFS_DISK $TMP_MNT_DIR
   MTAB_ENTRY="$(mount | egrep "$BOOTFS_DISK" | egrep "$TMP_MNT_DIR")"
   [ -z "$MTAB_ENTRY" ] &&  echo "Failed to mount disk" && umount -f -l $TMP_MNT_DIR &&  exit 1
   cp $BOOT_RTFS_SCRIPT  $TMP_MNT_DIR/boot.cmd
   mkimage -C none -A arm -T script -d $TMP_MNT_DIR/boot.cmd $TMP_MNT_DIR/boot.scr  1> /dev/null
   cd $WORKSPACE
   sync
   umount $TMP_MNT_DIR
   rm -rf $TMP_MNT_DIR

   e2fsck -y -f $BOOTFS_DISK
   resize2fs -M $BOOTFS_DISK
}


####################################################################### SD_IMAGE
build_sd_image() {
   echo -e "\e[30;48;5;82mSetup sd image \e[0m"
   $SCRIPTS_DIR/16-create-image-disk.sh $SD_DISK_IMG $BOOTFS_SIZE_MB $ROOTFS_SIZE_MB $ROOTFS_SIZE_MB $DATAFS_SIZE_MB
   [ ! -f $SD_DISK_IMG ] && echo "$SD_DISK_IMG : file not found"  && exit 0

   TAR_TMP_DIR="$BUILD_DIR/tar-tmp"
   rm -rf $TAR_TMP_DIR
   mkdir -p $TAR_TMP_DIR
   tar -xf $BOOT_PACKAGE_TAR -C $TAR_TMP_DIR
   [ ! -f $TAR_TMP_DIR/uboot-spl ] && echo "$TAR_TMP_DIR/uboot-spl : file not found" && exit 0
   cp $TAR_TMP_DIR/uboot-spl $UBOOT_SPL_IMG
   dd if=$TAR_TMP_DIR/uboot-spl of=$SD_DISK_IMG seek=16 conv=notrunc
   rm -rf $TAR_TMP_DIR
   dd if=$SD_DISK_IMG of=$MBR_DISK bs=1M count=$MBR_SIZE_MB

   cp $MBR_DISK $MBR_BOOTFS_DISK
   cat $BOOTFS_DISK >> $MBR_BOOTFS_DISK

   if [ "$1" == "--all" ]; then
      LOOPDEVS="$(kpartx -avs $SD_DISK_IMG | cut -d' ' -f 3)"
      LOOPDEV="$(echo ${LOOPDEVS} | cut -d' ' -f 1 | sed s/p1//)"
      [ -z "$LOOPDEV" ]       && "$LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0
      [ ! -b "/dev/$LOOPDEV" ]  && "/dev/$LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0

      BOOT_LOOPDEV=/dev/mapper/"$LOOPDEV"p1
      ROOTA_LOOPDEV=/dev/mapper/"$LOOPDEV"p2
      ROOTB_LOOPDEV=/dev/mapper/"$LOOPDEV"p3
      DATA_LOOPDEV=/dev/mapper/"$LOOPDEV"p4
      [ ! -b $BOOT_LOOPDEV ]  &&  "$BOOT_LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0
      [ ! -b $ROOTA_LOOPDEV ] && "$ROOTA_LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0
      [ ! -b $ROOTB_LOOPDEV ] && "$ROOTB_LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0
      [ ! -b $DATA_LOOPDEV ]  &&  "$DATA_LOOPDEV: device not found" && kpartx -dvs $SD_DISK_IMG && exit 0

      mkfs.ext3 $BOOT_LOOPDEV    1> /dev/null;  e2label $BOOT_LOOPDEV  boot
      mkfs.ext3 $ROOTA_LOOPDEV   1> /dev/null;  e2label $ROOTA_LOOPDEV rootA
      mkfs.ext3 $ROOTB_LOOPDEV   1> /dev/null;  e2label $ROOTB_LOOPDEV rootB
      mkfs.ext3 $DATA_LOOPDEV    1> /dev/null;  e2label $DATA_LOOPDEV  data

      dd if=$BOOTFS_DISK of=$BOOT_LOOPDEV
      dd if=$ROOTFS_TARGET_DISK of=$ROOTA_LOOPDEV
      sync
      echo "Delete /dev/$LOOPDEV"
      kpartx -dvs $DATA_LOOPDEV
      kpartx -dvs $ROOTB_LOOPDEV
      kpartx -dvs $ROOTA_LOOPDEV
      kpartx -dvs $BOOT_LOOPDEV
      losetup -d /dev/$LOOPDEV
      kpartx -dvs /dev/$LOOPDEV
   fi
}


####################################################################### Build
build_rootfs_image $1 $2
build_bootfs_image $1 $2
build_sd_image $1 $2

ln -sf $BOOTFS_DISK $IMAGES_DIR/bootfs
ln -sf $ROOTFS_TARGET_DISK $IMAGES_DIR/rootfs
ln -sf $MBR_DISK $IMAGES_DIR/mbr
ln -sf $MBR_BOOTFS_DISK $IMAGES_DIR/mbr-bootfs

symlinks -c $IMAGES_DIR/

echo -e "\e[30;48;5;82mFinished...\e[0m"
echo -e "ROOTFS_TARGET_DISK: $ROOTFS_TARGET_DISK"
echo -e "ROOTFS_TARGET_TAR:  $ROOTFS_TARGET_TAR"
echo -e "SD_DISK_IMG:        $SD_DISK_IMG"
echo -e "MBR_DISK:           $MBR_DISK"
