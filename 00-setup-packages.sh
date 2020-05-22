#!/bin/bash

[ ! -d "sources" ] && mkdir sources

DL_XEN_FILE="$(pwd)/sources/xen-4.11.4.tar.gz"
[ ! -f $DL_XEN_FILE ] && wget https://downloads.xenproject.org/release/xen/4.11.4/xen-4.11.4.tar.gz -O $DL_XEN_FILE


DL_ROOTFS_FILE="$(pwd)/sources/ubuntu-base-18.04.1-base-arm64.tar.gz"
[ ! -f $DL_ROOTFS_FILE ] && wget http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.1-base-arm64.tar.gz -O $DL_ROOTFS_FILE


DL_KERNEL_FILE="$(pwd)/sources/linux-4.19.75.tar.xz"
[ ! -f $DL_KERNEL_FILE ] && wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.75.tar.xz -O $DL_KERNEL_FILE
