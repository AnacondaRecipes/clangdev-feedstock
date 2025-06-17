#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

cd $PREFIX
rm -rf lib/cmake include lib/lib*.a libexec share

mv bin bin2
mkdir -p bin

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
mv ${PREFIX}/bin2/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang-${MAJOR_VERSION}
rm -rf bin2