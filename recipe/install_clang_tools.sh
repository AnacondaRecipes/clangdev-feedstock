#!/bin/bash
set -x -e
cd build
if [[ $(uname) == Darwin ]]; then
  PATH=${PWD}/clang-bootstrap/bin:${PATH}
fi
make install DESTDIR=/tmp ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/install_${PKG_NAME}.log
pushd /tmp$PREFIX
  rm -rf lib/cmake include lib/lib*.a
  cp -Rf * $PREFIX
popd
