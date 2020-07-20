#!/bin/bash

source $(dirname $(realpath $0))/00-common-env.sh

if [ "$1" == "--help" ]; then
   echo "Available commands:"
   echo "   --all"
   echo "   --rootfs-base-build"
   echo "   --toolchain-build"
   echo "   --xen-distro-build"
   echo "   --xen-tools-build"
   echo "   --kernel-dom0-build"
   echo "   --kernel-domu-build"
   echo "   --loader-build"
   exit 0
fi

source $(dirname $(realpath $0))/01-rootfs-toolchain-setup.sh
source $(dirname $(realpath $0))/02-xen-compile.sh
source $(dirname $(realpath $0))/03-kernel-build.sh
source $(dirname $(realpath $0))/04-loader-compile.sh
source $(dirname $(realpath $0))/05-target-image.sh
