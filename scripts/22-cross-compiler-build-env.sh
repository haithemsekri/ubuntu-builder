
[ -z "$L_TCC" ] && echo "L_TCC: not defined" && exit 1
[ -z "$L_TARGET_ARCH" ] && echo "L_TARGET_ARCH: not defined" && exit 1
[ -z "$L_TCC_ARCH" ] && echo "L_TCC_ARCH: not defined" && exit 1
[ -z "$L_TSYSROOT" ] && echo "L_TSYSROOT: not defined" && exit 1

export L_SYS_C_INC=$(find ${L_TSYSROOT} -type f -name "pthread.h" 2>/dev/null | grep "include" | tail -1 | xargs dirname)
[ -z "$L_SYS_C_INC" ] && echo "L_SYS_C_INC: not defined" && exit 1
export L_SYS_CXX_INC=$(find ${L_TSYSROOT} -type f -name "iostream" 2>/dev/null | grep "include" | tail -1 | xargs dirname)
[ -z "$L_SYS_CXX_INC" ] && echo "L_SYS_CXX_INC: not defined" && exit 1
export L_SYS_LIB=$(find ${L_TSYSROOT} -type f -name "libpthread*.so*" 2>/dev/null | grep "lib" | xargs dirname | awk '{ORS="" ;print " -Wl,-rpath-link="$1}')
[ -z "$L_SYS_LIB" ] && echo "L_SYS_LIB: not defined" && exit 1
export L_SYS_PKG=$(find ${L_TSYSROOT} -type d -name "pkgconfig"  2>/dev/null | grep "lib" | tr '\n' ':')
[ -z "$L_SYS_PKG" ] && echo "L_SYS_PKG: not defined" && exit 1
export L_PKG_CONFIG="$(which pkg-config)"
[ -z "$L_SYS_PKG" ] && echo "L_SYS_PKG: not defined" && exit 1
export L_INTLTOOL_PERL="$(which perl)"

export L_PKG_CONFIG_SYSROOT_DIR="${L_TSYSROOT}"
export L_PKG_CONFIG_LIBDIR="${L_SYS_PKG}"
export L_CC="${L_TCC}gcc"
export L_LDFLAGS="--sysroot=${L_TSYSROOT} ${L_SYS_LIB}"
export L_CFLAGS="--sysroot=${L_TSYSROOT} -I${L_SYS_C_INC}"
export L_CXXFLAGS="$L_CFLAGS -I${L_SYS_CXX_INC}"
