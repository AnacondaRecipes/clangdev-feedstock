#!/bin/bash
set -x -e
# . ${RECIPE_DIR}/bootstrap-macos-clang
pushd build
  make install ${VERBOSE_CM} 2>&1 | tee ${SRC_DIR}/install_${PKG_NAME}.log
popd
