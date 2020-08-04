#!/bin/bash
set -x -e

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++

if [[ "$variant" == "hcc" ]]; then
  ln -s $PREFIX/bin/clang++  $PREFIX/bin/hcc
fi
