#!/bin/bash
set -x -e
cd build
if [[ $(uname) == Darwin ]]; then
  PATH=${PWD}/clang-bootstrap/bin:${PATH}
fi
make install ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/install_${PKG_NAME}.log
cd "${PREFIX}"
rm -rf libexec share include
mv bin bin2
mkdir -p bin
maj_version="${PKG_VERSION%%.*}"
cp bin2/clang-${maj_version} bin/
rm -rf bin2

mv lib lib2
mkdir -p lib
cp lib2/libclang-cpp.* lib/
cp -Rf lib2/clang lib/
rm -rf lib2

ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cl"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cpp"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang"
