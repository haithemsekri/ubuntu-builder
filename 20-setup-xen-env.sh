#!/bin/bash


[ -z $DL_XEN_FILE ] && DL_XEN_FILE="$(pwd)/sources/xen-4.11.4.tar.gz"
[ -z $DL_XEN_URL ]  && DL_XEN_URL="https://downloads.xenproject.org/release/xen/4.11.4/xen-4.11.4.tar.gz"
[ -z $XEN_IMAGE_TAR_FILE ]  && XEN_IMAGE_TAR_FILE="$(pwd)/cache/xen-overlays-4.11.4.tar.gz"
[ -z $XEN_TAR_DIR_NAME ]  && XEN_TAR_DIR_NAME="xen-4.11.4"

