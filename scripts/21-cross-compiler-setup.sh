#!/bin/bash

source $(dirname $(realpath $0))/20-cross-compiler-env.sh

if [ "$1" == "--rebuild" ]; then
   echo -n ""
fi

if [ "$1" == "--clean-rebuild" ]; then
   echo "delete $TOOLCHAIN_PATH"
   rm -rf "$TOOLCHAIN_PATH"
fi

echo "DISTRO_CC_VERSION: $DISTRO_CC_VERSION"

if [[ $DISTRO_CC_VERSION == 4* ]] && [[ "$TARGET_ARCH" == "arm64" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/aarch64-linux-gnu/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="aarch64-linux-gnu"
elif [[ $DISTRO_CC_VERSION == 4* ]] && [[ "$TARGET_ARCH" == "arm32" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/arm-linux-gnueabihf/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="arm-linux-gnueabihf"
elif [[ $DISTRO_CC_VERSION == 7* ]] && [[ "$TARGET_ARCH" == "arm64" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="aarch64-linux-gnu"
elif [[ $DISTRO_CC_VERSION == 7* ]] && [[ "$TARGET_ARCH" == "arm32" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="arm-linux-gnueabihf"
elif [[ $DISTRO_CC_VERSION == 8* ]] && [[ "$TARGET_ARCH" == "arm64" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="aarch64-linux-gnu"
elif [[ $DISTRO_CC_VERSION == 8* ]] && [[ "$TARGET_ARCH" == "arm32" ]]; then
   [ -z $TOOLCHAIN_DL_URL ]  && TOOLCHAIN_DL_URL="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz"
   [ -z $CROSS_PREFIX ]  && CROSS_PREFIX="arm-linux-gnueabihf"
else
   echo "Unknown toolchain name: $DISTRO_CC_VERSION-$TARGET_ARCH"
   exit -1
fi
#TOOLCHAIN_DL_URL="https://releases.linaro.org/archive/15.06/components/toolchain/binaries/4.8/arm-linux-gnueabihf/gcc-linaro-4.8-2015.06-x86_64_arm-linux-gnueabihf.tar.xz"
[ -z $TOOLCHAIN_DL_TAR ] && TOOLCHAIN_DL_TAR="$DL_DIR/$(basename $TOOLCHAIN_DL_URL)"
[ ! -f $TOOLCHAIN_DL_TAR ] && wget $TOOLCHAIN_DL_URL -O $TOOLCHAIN_DL_TAR
[ ! -f $TOOLCHAIN_DL_TAR ] && echo "$TOOLCHAIN_DL_TAR : file not found"

if [ ! -d $TOOLCHAIN_PATH ]; then
   echo "Setup toolchain: $TOOLCHAIN_PATH"
   TMP_DIR="$BUILD_DIR/tar.xf.tmp"
   mkdir -p $TMP_DIR
   tar -xf $TOOLCHAIN_DL_TAR -C $TMP_DIR/
   sync
   mv $TMP_DIR/* $TOOLCHAIN_PATH
   rm -rf $TMP_DIR
   cd $TOOLCHAIN_PATH
fi
[ ! -f ${TOOLCHAIN_PATH}/bin/${CROSS_PREFIX}-gcc ] && echo "${TOOLCHAIN_PATH}/bin/${CROSS_PREFIX}-gcc : file not found"
${TOOLCHAIN_PATH}/bin/${CROSS_PREFIX}-gcc --version | head -1

rm -rf $TOOLCHAIN_ENV_FILE

cat <<EOF > $TOOLCHAIN_ENV_FILE
#!/bin/bash
export L_TCC="$TOOLCHAIN_PATH/bin/$CROSS_PREFIX-"
export L_TARGET_ARCH="$TARGET_ARCH"
export L_TCC_ARCH="$CROSS_PREFIX"
EOF

cat $(dirname $(realpath $0))/22-cross-compiler-build-env.sh >> $TOOLCHAIN_ENV_FILE

echo "Toolchain-env: $TOOLCHAIN_ENV_FILE"
echo "Sanity Check ..."
