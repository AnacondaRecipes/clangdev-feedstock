pushd %SRC_DIR%\build
  ninja install
popd

pushd %LIBRARY_PREFIX%
  rmdir /s /q lib libexec share include
  move bin bin2

  mkdir bin

  move bin2\libclang.dll bin\
  rmdir /s /q bin2
popd
