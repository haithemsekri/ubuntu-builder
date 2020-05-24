#!/bin/bash

source 20-cross-compiler-setup-env.sh
[ ! -d $TARGET_COMPILER_PATH ] && echo "$TARGET_COMPILER_PATH : not found"  && exit 0

export TARGET_COMPILER="aarch64-linux-gnu"
export PATH="$PATH:$TARGET_COMPILER_PATH/bin"
export STAGING_DIR="$TARGET_COMPILER_PATH/aarch64-linux-gnu"
export ARCH="arm64"
export CROSS_COMPILE="$TARGET_COMPILER-"

####################### env setup
TARGET_COMPILER_ENV=$(cat <<EOF
AR="$TARGET_COMPILER-ar" \
AS="$TARGET_COMPILER-as" \
LD="$TARGET_COMPILER-ld" \
NM="$TARGET_COMPILER-nm" \
CC="$TARGET_COMPILER-gcc" \
GCC="$TARGET_COMPILER-gcc" \
CPP="$TARGET_COMPILER-cpp" \
CXX="$TARGET_COMPILER-g++" \
FC="$TARGET_COMPILER-gfortran" \
F77="$TARGET_COMPILER-gfortran" \
RANLIB="$TARGET_COMPILER-ranlib" \
READELF="$TARGET_COMPILER-readelf" \
STRIP="$TARGET_COMPILER-strip" \
OBJCOPY="$TARGET_COMPILER-objcopy" \
OBJDUMP="$TARGET_COMPILER-objdump" \
AR_FOR_BUILD="/usr/bin/ar" \
AS_FOR_BUILD="/usr/bin/as" \
CC_FOR_BUILD=" /usr/bin/gcc" \
GCC_FOR_BUILD=" /usr/bin/gcc" \
CXX_FOR_BUILD=" /usr/bin/g++" \
LD_FOR_BUILD="/usr/bin/ld" \
CPPFLAGS_FOR_BUILD="-I$STAGING_DIR/libc/usr/include" \
CFLAGS_FOR_BUILD="-I$STAGING_DIR/libc/usr/include" \
CXXFLAGS_FOR_BUILD="-I$STAGING_DIR/libc/usr/include" \
LDFLAGS_FOR_BUILD="-L$STAGING_DIR/libc/lib -Wl,-rpath,$STAGING_DIR/libc/lib" \
FCFLAGS_FOR_BUILD="" \
DEFAULT_ASSEMBLER="$TARGET_COMPILER-as" \
DEFAULT_LINKER="$TARGET_COMPILER-ld" \
CPPFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" \
CFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" \
CXXFLAGS="-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" \
LDFLAGS="" \
FCFLAGS="" \
FFLAGS=""
EOF
)

####################### configure
CROSS_CONFIGURE_ENV=$(cat <<EOF
$TARGET_COMPILER_ENV \
CONFIG_SITE="/dev/null" \
INTLTOOL_PERL="/usr/bin/perl ac_cv_lbl_unaligned_fail=yes
EOF
)

CROSS_CONFIG_ARGS=$(cat <<EOF
--target=$TARGET_COMPILER \
--host=$TARGET_COMPILER \
--build=x86_64-pc-linux-gnu --prefix=/usr \
--exec-prefix=/usr --sysconfdir=/etc --localstatedir=/var --program-prefix=""
EOF
)

