#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh
source $(dirname $(realpath $0))/00-rootfs-env.sh
source $(dirname $(realpath $0))/50-loader-env.sh

[ -z "$SD_IMAGE_DISK_TAR" ] && SD_IMAGE_DISK_TAR="$IMAGES_DIR/image-$TARGET_BUILD_NAME.tar.gz"
