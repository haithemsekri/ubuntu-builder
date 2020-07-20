#!/bin/bash

# Rootfs :############################################
[ -z $ROOTFS_PACKAGE_NAME ]      && ROOTFS_PACKAGE_NAME="$TARGET_NAME-$ROOTFS_NAME"
[ -z $ROOTFS_BASE_DISK ]         && ROOTFS_BASE_DISK="$BUILD_DIR/$ROOTFS_PACKAGE_NAME-rootfs-base.$EXT_FS_TYPE"
[ -z $ROOTFS_BASE_TAR ]          && ROOTFS_BASE_TAR="$BUILD_DIR/$ROOTFS_PACKAGE_NAME-rootfs-base.tar.xz"
[ -z $ROOTFS_TARGET_DISK ]       && ROOTFS_TARGET_DISK="$IMAGES_DIR/$ROOTFS_PACKAGE_NAME-rootfs-target.$EXT_FS_TYPE"
[ -z $ROOTFS_TARGET_TAR ]        && ROOTFS_TARGET_TAR="$IMAGES_DIR/$ROOTFS_PACKAGE_NAME-rootfs-target.tar.xz"

# Xen :############################################
[ -z $XEN_PACKAGE_NAME ]         && XEN_PACKAGE_NAME="$XEN_NAME"
[ -z $XEN_TOOLS_PACKAGE_TAR ]    && XEN_TOOLS_PACKAGE_TAR="$IMAGES_DIR/$TARGET_NAME-$XEN_PACKAGE_NAME-tools.tar.xz"
[ -z $XEN_DISTRO_PACKAGE_TAR ]   && XEN_DISTRO_PACKAGE_TAR="$IMAGES_DIR/$TARGET_NAME-$XEN_PACKAGE_NAME-distro.tar.xz"
[ -z $XEN_DISTRO_CONFIG ]        && XEN_DISTRO_CONFIG="$TARGET_FILES/$XEN_NAME-distro.config"

# Linux-dom0 :############################################
[ -z $LINUX_DOM0_PACKAGE_NAME ]  && LINUX_DOM0_PACKAGE_NAME="$LINUX_DOM0_NAME-dom0"
[ -z $LINUX_DOM0_CONFIG ]        && LINUX_DOM0_CONFIG="$TARGET_FILES/$LINUX_DOM0_PACKAGE_NAME.config"
[ -z $LINUX_DOM0_PATCH ]         && LINUX_DOM0_PATCH="$TARGET_FILES/$LINUX_DOM0_PACKAGE_NAME.patch"
[ -z $LINUX_DOM0_PACKAGE_TAR ]   && LINUX_DOM0_PACKAGE_TAR="$IMAGES_DIR/$TARGET_NAME-$LINUX_DOM0_PACKAGE_NAME.tar.xz"

# Linux-domu :############################################
[ -z $LINUX_DOMU_PACKAGE_NAME ]  && LINUX_DOMU_PACKAGE_NAME="$LINUX_DOM0_NAME-domu"
[ -z $LINUX_DOMU_CONFIG ]        && LINUX_DOMU_CONFIG="$TARGET_FILES/$LINUX_DOM0_PACKAGE_NAME.config"
[ -z $LINUX_DOMU_PATCH ]         && LINUX_DOMU_PATCH="$TARGET_FILES/$LINUX_DOM0_PACKAGE_NAME.patch"
[ -z $LINUX_DOMU_PACKAGE_TAR ]   && LINUX_DOMU_PACKAGE_TAR="$IMAGES_DIR/$TARGET_NAME-$LINUX_DOMU_PACKAGE_NAME.tar.xz"

# Bootfs && MBR :############################################
[ -z $BOOT_LINUX_SCRIPT ]        && BOOT_LINUX_SCRIPT="$TARGET_FILES/loader-kernel-boot-env.cmd"
[ -z $BOOT_XEN_SCRIPT ]          && BOOT_XEN_SCRIPT="$TARGET_FILES/loader-xen-boot-env.cmd"
[ -z $BOOT_RTFS_SCRIPT ]         && BOOT_RTFS_SCRIPT="$TARGET_FILES/loader-boot-env.cmd"
[ -z $MBR_DISK ]                 && MBR_DISK="$IMAGES_DIR/$TARGET_NAME-$BOOT_LOADER_NAME-mbr.raw"
[ -z $MBR_BOOTFS_DISK ]          && MBR_BOOTFS_DISK="$IMAGES_DIR/$TARGET_NAME-$BOOT_LOADER_NAME-mbr-bootfs.raw"
[ -z $BOOTFS_DISK ]              && BOOTFS_DISK="$IMAGES_DIR/$TARGET_NAME-bootfs.$EXT_FS_TYPE"
[ -z $UBOOT_SPL_IMG ]            && UBOOT_SPL_IMG="$IMAGES_DIR/$TARGET_NAME-$BOOT_LOADER_NAME.bin"
[ -z $BOOT_PACKAGE_TAR ]         && BOOT_PACKAGE_TAR="$IMAGES_DIR/$TARGET_NAME-$BOOT_LOADER_NAME.tar.xz"

# SD Images :############################################
[ -z $SD_DISK_IMG ]              && SD_DISK_IMG="$IMAGES_DIR/$TARGET_NAME-$DISTRO_NAME-$LINUX_DOM0_NAME-$XEN_NAME-sd-image.raw"
