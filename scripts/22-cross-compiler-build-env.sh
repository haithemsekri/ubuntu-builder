#!/bin/bash

[ -z $CCOMPILER_PATH ] && echo "CCOMPILER_PATH : not found"  && exit 0
[ ! -d $CCOMPILER_PATH ] && echo "$CCOMPILER_PATH : not found"  && exit 0
[ -z $SYSROOT_PATH ] && echo "SYSROOT_PATH : not found"  && exit 0
[ ! -d $SYSROOT_PATH ] && echo "$SYSROOT_PATH : not found"  && exit 0

if [ "$TARGET_ARCH" == "aarch64" ]; then
export TARGET_COMPILER="aarch64-linux-gnu"
export PATH="$PATH:$CCOMPILER_PATH/bin"
export ARCH="arm64"
export CROSS_COMPILE="$TARGET_COMPILER-"
export CROSS_PREFIX="$TARGET_COMPILER"
fi

CHECK_PATH=${SYSROOT_PATH}/lib/${TARGET_COMPILER} [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/include/c++/${CC_PV} [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/include/${TARGET_COMPILER} [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/include/c++/${CC_PV}/backward [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${CCOMPILER_PATH}/bin/${CROSS_PREFIX}-gcc [ ! -f $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/include/${TARGET_COMPILER}/c++/${CC_PV} [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0
CHECK_PATH=${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include-fixed [ ! -d $CHECK_PATH ] && echo "-d $CHECK_PATH : not found"  && exit 0

## sudo chroot ${SYSROOT_PATH} bash -c "echo | g++ -x c++ -E -Wp,-v -o /dev/null - 2>&1" | grep "^ " | sed "s|^ /| -I${SYSROOT_PATH}|"
SYSROOT_CFLAGS=$(cat <<EOF
--sysroot=${SYSROOT_PATH}/ -nostdinc \
-isystem${SYSROOT_PATH}/usr/include/c++/${CC_PV} \
-isystem${SYSROOT_PATH}/usr/include/${TARGET_COMPILER}/c++/${CC_PV} \
-isystem${SYSROOT_PATH}/usr/include/c++/${CC_PV}/backward \
-isystem${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include \
-isystem${SYSROOT_PATH}/usr/local/include \
-isystem${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include-fixed \
-isystem${SYSROOT_PATH}/usr/include/${TARGET_COMPILER} \
-isystem${SYSROOT_PATH}/usr/include \
-I${SYSROOT_PATH}/usr/include/c++/${CC_PV} \
-I${SYSROOT_PATH}/usr/include/${TARGET_COMPILER}/c++/${CC_PV} \
-I${SYSROOT_PATH}/usr/include/c++/${CC_PV}/backward \
-I${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include \
-I${SYSROOT_PATH}/usr/local/include \
-I${SYSROOT_PATH}/usr/lib/gcc/${TARGET_COMPILER}/${CC_PV}/include-fixed \
-I${SYSROOT_PATH}/usr/include/${TARGET_COMPILER} \
-I${SYSROOT_PATH}/usr/include \
-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
EOF
)

SYSROOT_CPPFLAGS=$SYSROOT_CFLAGS

SYSROOT_LDFLAGS="--sysroot=${SYSROOT_PATH} -Wl,-rpath-link=${SYSROOT_PATH}/lib/${TARGET_COMPILER} -Wl,-rpath-link=${SYSROOT_PATH}/usr/lib/${TARGET_COMPILER}"

CROSS_COMPILE_ENV=$(cat <<EOF
PATH="$PATH:${CCOMPILER_PATH}/bin" \
AR="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-ar" \
AS="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-as" \
LD="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-ld" \
NM="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-nm" \
CC="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-gcc" \
GCC="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-gcc" \
CPP="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-cpp" \
CXX="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-g++" \
FC="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-gfortran" \
F77="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-gfortran" \
RANLIB="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-ranlib" \
READELF="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-readelf" \
STRIP="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-strip" \
OBJCOPY="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-objcopy" \
OBJDUMP="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-objdump" \
DEFAULT_ASSEMBLER="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-as" \
DEFAULT_LINKER="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-ld" \
CROSS_COMPILE="${CCOMPILER_PATH}/bin/${TARGET_COMPILER}-" \
CPPFLAGS="$SYSROOT_CPPFLAGS" \
CFLAGS="$SYSROOT_CFLAGS" \
CXXFLAGS="$SYSROOT_CPPFLAGS" \
LDFLAGS="$SYSROOT_LDFLAGS" \
FCFLAGS=" -Os " \
FFLAGS=" -Os " \
AR_FOR_BUILD="/usr/bin/ar" \
AS_FOR_BUILD="/usr/bin/as" \
CC_FOR_BUILD="/usr/bin/gcc" \
GCC_FOR_BUILD="/usr/bin/gcc" \
CXX_FOR_BUILD="/usr/bin/g++" \
LD_FOR_BUILD="/usr/bin/ld" \
CPPFLAGS_FOR_BUILD="-I/include" \
CFLAGS_FOR_BUILD="-O2 -I/include" \
CXXFLAGS_FOR_BUILD="-O2 -I/include" \
LDFLAGS_FOR_BUILD="-L/lib -Wl,-rpath,/lib" \
FCFLAGS_FOR_BUILD="" \
PKG_CONFIG="pkg-config" \
PKG_CONFIG_LIBDIR="${SYSROOT_PATH}/usr/lib/${TARGET_COMPILER}/pkgconfig:${SYSROOT_PATH}/usr/share/pkgconfig" \
PKG_CONFIG_SYSROOT_DIR="${SYSROOT_PATH}" \
STAGING_DIR="${SYSROOT_PATH}"
EOF
)