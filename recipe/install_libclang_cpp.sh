#!/bin/bash
set -x -e
cd build
if [[ $(uname) == Darwin ]]; then
  PATH=${PWD}/clang-bootstrap/bin:${PATH}
fi
mkdir -p $(dirname /tmp${PREFIX}) || true
make install DESTDIR=/tmp ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/install_${PKG_NAME}.log

pushd /tmp${PREFIX}
  rm -rf libexec share bin include
  mv lib lib2
  mkdir lib
  find lib2 2>&1 | tee ${SRC_DIR}/lib2_files_${PKG_NAME}.log
  if [[ "$PKG_NAME" == "libclang-cpp" ]]; then
    cp lib2/${PKG_NAME}${SHLIB_EXT} lib/
  else
    cp lib2/libclang-cpp.*.* lib/
  fi
  rm -rf lib2
  cp -rf * ${PREFIX}/
popd
