#!/bin/bash
set -x -e
cd build
if [[ $(uname) == Darwin ]]; then
  PATH=${PWD}/clang-bootstrap/bin:${PATH}
fi
make install ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/install_${PKG_NAME}.log

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib
cp lib2/${PKG_NAME}.* lib/
rm -rf lib2
