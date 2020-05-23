#!/bin/bash

source 00-rootfs-setup-env.sh
[ ! -d "$(pwd)/sources" ] && mkdir $(pwd)/sources
[ ! -f $DL_ROOTFS_FILE ] && wget $DL_ROOTFS_URL -O $DL_ROOTFS_FILE
