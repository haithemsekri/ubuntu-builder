#!/bin/bash

[ -z $DL_COMPILER_FILE ] && DL_COMPILER_FILE="$(pwd)/sources/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
[ -z $TARGET_COMPILER_PATH ]  && TARGET_COMPILER_PATH="$(pwd)/build/gcc-linaro-aarch64-linux-gnu"
[ -z $DL_COMPILER_URL ]  && DL_COMPILER_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
