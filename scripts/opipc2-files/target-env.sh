#!/bin/bash

################################################################### Toolchain
[ -z "$TARGET_ARCH" ]            && TARGET_ARCH="arm64"
[ -z $TOOLCHAIN_NAME ]           && TOOLCHAIN_NAME="aarch64-linux-gnu-gcc-8.3"
[ -z $TOOLCHAIN_DL_URL ]         && TOOLCHAIN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz"
[ -z $CROSS_PREFIX ]             && CROSS_PREFIX="aarch64-linux-gnu"
[ -z $TOOLCHAIN_PATH ]           && TOOLCHAIN_PATH="$BUILD_DIR/$CROSS_PREFIX"
[ -z $L_CROSS_COMPILE ]          && L_CROSS_COMPILE="$TOOLCHAIN_PATH/bin/$CROSS_PREFIX-"
[ -z $L_CROSS_PREFIX ]           && L_CROSS_PREFIX="$CROSS_PREFIX"
[ -z $L_CROSS_ARCH ]             && L_CROSS_ARCH="$TARGET_ARCH"

####################################################################### Rootfs
[ -z $ROOTFS_NAME ]              && ROOTFS_NAME="$DISTRO_NAME"
[ -z $ROOTFS_DL_TAR_URL ]        && ROOTFS_DL_TAR_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/$DISTRO_NAME-$TARGET_ARCH-base.tar.xz"
[ -z $ROOTFS_PACKAGE_NAME ]      && ROOTFS_PACKAGE_NAME="$TARGET_NAME-$ROOTFS_NAME"

####################################################################### Xen
[ -z $XEN_NAME ]                 && XEN_NAME="xen-4.11.4"
[ -z $XEN_EARLY_PRINTK ]         && XEN_EARLY_PRINTK="sun7i"
[ -z $XEN_DL_URL ]               && XEN_DL_URL="https://iweb.dl.sourceforge.net/project/arm-rootfs-ressources/xen-4.11.4.tar.xz"

####################################################################### Linux-dom0
[ -z $LINUX_DOM0_NAME ]          && LINUX_DOM0_NAME="linux-4.19.75"
[ -z $LINUX_DOM0_URL ]           && LINUX_DOM0_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/linux-4.19.75.tar.xz"
[ -z $LINUX_DOM0_IMG ]           && LINUX_DOM0_IMG="arch/arm64/boot/Image"
[ -z $LINUX_DOM0_DTB ]           && LINUX_DOM0_DTB="arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dtb"

####################################################################### Linux-domu
[ -z $LINUX_DOMU_NAME ]          && LINUX_DOMU_NAME="linux-4.19.75"
[ -z $LINUX_DOMU_URL ]           && LINUX_DOMU_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/linux-4.19.75.tar.xz"
[ -z $LINUX_DOMU_IMG ]           && LINUX_DOMU_IMG="arch/arm64/boot/Image"
[ -z $LINUX_DOMU_DTB ]           && LINUX_DOMU_DTB="arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dtb"

####################################################################### ATF
[ -z $ATF_DL_URL ]               && ATF_DL_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/arm-trusted-firmware-2.3.tar.xz"
[ -z $ATF_PLAT ]                 && ATF_PLAT="sun50i_a64"
[ -z $ATF_MAKE_ARGS ]            && ATF_MAKE_ARGS="PLAT=$ATF_PLAT DEBUG=1 bl31 CROSS_COMPILE=$L_CROSS_COMPILE"

####################################################################### UBoot
[ -z $BOOT_LOADER_NAME ]         && BOOT_LOADER_NAME="uboot-spl-2020.04"
[ -z $UBOOT_DL_URL ]             && UBOOT_DL_URL="https://master.dl.sourceforge.net/project/arm-rootfs-ressources/u-boot-2020.04.tar.xz"
[ -z $UBOOT_CONFIG ]             && UBOOT_CONFIG="orangepi_pc2_defconfig"
[ -z $UBOOT_ATF_BIN_ ]           && UBOOT_ATF_BIN="u-boot-sunxi-with-spl.bin"
[ -z $UBOOT_CFLAGS ]             && UBOOT_CFLAGS="-march=armv8-a -march=armv8-a -Os -pipe -fstack-protector-strong -fno-plt"
[ -z $UBOOT_MAKE_ARGS ]          && UBOOT_MAKE_ARGS="ARCH=arm CROSS_COMPILE=$L_CROSS_COMPILE MARCH=armv8a"
