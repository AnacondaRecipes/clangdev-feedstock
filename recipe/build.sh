#!/bin/bash

set -x

if [[ $(uname) == Darwin ]]; then
  ${SYS_PREFIX}/bin/conda create -y -p ${SRC_DIR}/bootstrap clangxx_osx-64 -c https://repo.continuum.io/pkgs/main
  export PATH=${SRC_DIR}/bootstrap/bin:${PATH}
  CONDA_PREFIX=${SRC_DIR}/bootstrap \
    . ${SRC_DIR}/bootstrap/etc/conda/activate.d/*
  export CONDA_BUILD_SYSROOT=${CONDA_BUILD_SYSROOT:-/opt/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk}
  export CXXFLAGS=${CFLAGS}" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  export CFLAGS=${CFLAGS}" -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
  SYSROOT_DIR=${CONDA_BUILD_SYSROOT}
  CFLAG_SYSROOT="--sysroot ${SYSROOT_DIR}"
  # We do not want to build using the llvm of the bootstrap compilers
  rm ${SRC_DIR}/bootstrap/bin/llvm-config
  # .. Maybe -DLLVM_CONFIG=${PREFIX}/bin/llvm-config instead?
  # Avoid the build prefixes libclang.dylib getting linked instead of the host prefixes.
  # This is because we add this path to the front of the linker search path so that
  # libc++.dylib and libc++-abi.dylib get found there. This matters at present because
  # the compilers are clang 4.0.1 while QtCreator needs clang >= 5
  # Also remove the old libclang and libLLVM static libraries from the build prefix as they will
  # be found instead of the newer ones in the host prefix. We may want to prevent these from
  # existing in the first place. They are part of the macOS compilers.
  if [[ ${target_platform} == osx-64 ]]; then
    rm ${BUILD_PREFIX}/bin/llvm-config
    mv ${BUILD_PREFIX}/lib/libclang.dylib ${BUILD_PREFIX}/lib/libclang.dylib.nothanks || true
    rm -rf ${BUILD_PREFIX}/lib/libclang*.a || true
    rm -rf ${BUILD_PREFIX}/lib/libLLVM*.a || true
    rm -rf ${BUILD_PREFIX}/include/clang* || true
  fi
fi

if [[ ${MACOSX_DEPLOYMENT_TARGET} == 10.9 ]]; then
  DARWIN_TARGET=x86_64-apple-darwin13.4.0
fi

declare -a _cmake_config
_cmake_config+=(-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX})
_cmake_config+=(-DCMAKE_BUILD_TYPE:STRING=Release)
# The bootstrap clang I use was built with a static libLLVMObject.a and I trying to get the same here
# _cmake_config+=(-DBUILD_SHARED_LIBS:BOOL=ON)
_cmake_config+=(-DLLVM_ENABLE_ASSERTIONS:BOOL=OFF)
_cmake_config+=(-DLINK_POLLY_INTO_TOOLS:BOOL=ON)
# Urgh, llvm *really* wants to link to ncurses / terminfo and we *really* do not want it to.
_cmake_config+=(-DHAVE_TERMINFO_CURSES=OFF)
# Sometimes these are reported as unused. Whatever.
_cmake_config+=(-DHAVE_TERMINFO_NCURSES=OFF)
_cmake_config+=(-DHAVE_TERMINFO_NCURSESW=OFF)
_cmake_config+=(-DHAVE_TERMINFO_TERMINFO=OFF)
_cmake_config+=(-DHAVE_TERMINFO_TINFO=OFF)
_cmake_config+=(-DHAVE_TERMIOS_H=OFF)
_cmake_config+=(-DCLANG_ENABLE_LIBXML=ON)
# Even with -DCLANG_ENABLE_LIBXML=OFF c-index-test
# will still link to the system libxml2 (since we need it for
# that we may as well turn it on for anything else that wants it)
_cmake_config+=(-DLIBXML2_INCLUDE_DIR=${PREFIX}/include/libxml2)
if [[ ${HOST} =~ .*darwin.* ]]; then
  _cmake_config+=(-DLIBXML2_LIBRARIES=${PREFIX}/lib/libxml2.dylib)
elif [[ ${HOST} =~ .*linux.* ]]; then
  _cmake_config+=(-DLIBXML2_LIBRARIES=${PREFIX}/lib/libxml2.so)
fi
_cmake_config+=(-DLIBOMP_INSTALL_ALIASES=OFF)
_cmake_config+=(-DLLVM_ENABLE_RTTI=ON)
# TODO :: It would be nice if we had a cross-ecosystem 'BUILD_TIME_LIMITED' env var we could use to
#         disable these unnecessary but useful things.
if [[ ${CONDA_FORGE} == yes ]]; then
  _cmake_config+=(-DLLVM_INCLUDE_TESTS=OFF)
  _cmake_config+=(-DLLVM_INCLUDE_UTILS=OFF)
  _cmake_config+=(-DLLVM_INCLUDE_DOCS=OFF)
  _cmake_config+=(-DLLVM_INCLUDE_EXAMPLES=OFF)
fi
# Only valid when using the Ninja Generator AFAICT
# _cmake_config+=(-DLLVM_PARALLEL_LINK_JOBS:STRING=1)
# What about cross-compiling targetting Darwin here? Are any of these needed?
if [[ $(uname) == Darwin ]]; then
  _cmake_config+=(-DCMAKE_OSX_SYSROOT=${SYSROOT_DIR})
  _cmake_config+=(-DDARWIN_macosx_CACHED_SYSROOT=${SYSROOT_DIR})
  _cmake_config+=(-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET})
  _cmake_config+=(-DCMAKE_LIBTOOL=$(which ${DARWIN_TARGET}-libtool))
  _cmake_config+=(-DLD64_EXECUTABLE=$(which ${DARWIN_TARGET}-ld))
  _cmake_config+=(-DCMAKE_INSTALL_NAME_TOOL=$(which ${DARWIN_TARGET}-install_name_tool))
  # Once we are using our libc++ (not until llvm_build_final), it will be single-arch only and not setting
  # this causes link failures building the santizers since they respect DARWIN_osx_ARCHS. We may as well
  # save some compilation time by setting this for all of our llvm builds.
  _cmake_config+=(-DDARWIN_osx_ARCHS=x86_64)
#elif [[ $(uname) == Linux ]]; then
#  _cmake_config+=(-DLLVM_BINUTILS_INCDIR=${PREFIX}/lib/gcc/${cpu_arch}-${vendor}-linux-gnu/${compiler_ver}/plugin/include)
fi

# For when the going gets tough:
# _cmake_config+=(-Wdev)
# _cmake_config+=(--debug-output)
# _cmake_config+=(--trace-expand)
# CPU_COUNT=1

mkdir build || true
cd build

cmake -G'Unix Makefiles'     \
      "${_cmake_config[@]}"  \
      ..

make -j${CPU_COUNT} ${VERBOSE_CM}
make install
