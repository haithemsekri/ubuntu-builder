#!/bin/bash

echo "=============> 01-rootfs-toolchain-setup.sh"
source $(dirname $(realpath $0))/01-rootfs-toolchain-setup.sh
echo "=============> 02-xen-compile.sh"
source $(dirname $(realpath $0))/02-xen-compile.sh
echo "=============> 03-kernel-build.sh"
source $(dirname $(realpath $0))/03-kernel-build.sh
echo "=============> 04-loader-compile.sh"
source $(dirname $(realpath $0))/04-loader-compile.sh
