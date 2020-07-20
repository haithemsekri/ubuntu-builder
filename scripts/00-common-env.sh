#!/bin/bash

# Platform :##########################################
[ -z "$TARGET_NAME" ]            && TARGET_NAME="opipc2"
[ -z "$TARGET_ARCH" ]            && TARGET_ARCH="arm64"
[ -z "$DISTRO_NAME" ]            && DISTRO_NAME="ubuntu-18.04"
[ -z "$GCC_NAME" ]               && GCC_NAME="gcc-8"
[ -z "$USE_SYSTEMD" ]            && USE_SYSTEMD="YES"
[ -z "$EXT_FS_TYPE" ]            && EXT_FS_TYPE="ext3"
[ -z "$MBR_SIZE_MB" ]            && MBR_SIZE_MB="2"
[ -z "$BOOTFS_SIZE_MB" ]         && BOOTFS_SIZE_MB="32"
[ -z "$ROOTFS_SIZE_MB" ]         && ROOTFS_SIZE_MB="1024"
[ -z "$DATAFS_SIZE_MB" ]         && DATAFS_SIZE_MB="4096"
[ -z "$BUILD_CPU_CORE" ]         && BUILD_CPU_CORE="3"

# Target Env :############################################
source "$(dirname $(realpath $0))/00-common-env-lv1.sh"
source "$TARGET_FILES/target-env.sh"
source "$SCRIPTS_DIR/00-common-env-lv2.sh"
