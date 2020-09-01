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
  cp lib2/${PKG_NAME}.* lib/
  rm -rf lib2
  cp -rf * ${PREFIX}/
popd

