pushd %SRC_DIR%\build
  ninja install
popd

pushd %LIBRARY_PREFIX%
  rmdir /s /q lib libexec share include
  move lib lib2
  mkdir lib
  if %PKG_NAME%==libclang-cpp (
    move lib2\%PKG_NAME%%SHLIB_EXT% lib\
  ) else (
    move lib2\libclang-cpp.*.* lib\
  )
  rmdir /s / q lib2
popd
