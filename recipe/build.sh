#!/bin/bash

set -x

IFS='.' read -r -a PKG_VER_ARRAY <<< "${PKG_VERSION}"

sed -i.bak "s/libLTO.dylib/libLTO.${PKG_VER_ARRAY[0]}.dylib/g" lib/Driver/ToolChains/Darwin.cpp

mkdir build
cd build

declare -a EXTRA_ARGS=()
if [[ $(uname) == Darwin ]]; then
  conda create -yp ${PWD}/clang-bootstrap clangxx_osx-64
  PATH=${PATH}:${PWD}/clang-bootstrap/bin
fi

if [[ "$variant" == "hcc" ]]; then
  EXTRA_ARGS+=("-DKALMAR_BACKEND=HCC_BACKEND_AMDGPU")
  EXTRA_ARGS+=("-DHCC_VERSION_STRING=2.7-19365-24e69cd8-24e69cd8-24e69cd8")
  EXTRA_ARGS+=("-DHCC_VERSION_MAJOR=2" "-DHCC_VERSION_MINOR=7" "-DHCC_VERSION_PATCH=19365")
  EXTRA_ARGS+=("-DKALMAR_SDK_COMMIT=24e69cd8" "-DKALMAR_FRONTEND_COMMIT=24e69cd8" "-DKALMAR_BACKEND_COMMIT=24e69cd8")
fi

cmake \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RTTI=ON \
  -DCLANG_INCLUDE_TESTS=OFF \
  -DCLANG_INCLUDE_DOCS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_AR=${AR} \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  "${EXTRA_ARGS[@]}" \
  ..

make -j${CPU_COUNT} ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/build.log
