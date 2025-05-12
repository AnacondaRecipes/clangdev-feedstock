@echo on
setlocal enabledelayedexpansion

:: Create a staging install directory
set STAGING_DIR=%SRC_DIR%\clang\install_clang_format

cd %SRC_DIR%\clang\build
cmake --install . --prefix "%STAGING_DIR%"
if %ERRORLEVEL% neq 0 exit 1

move "%STAGING_DIR%\bin\clang-format.exe" "%LIBRARY_BIN%\clang-format.exe"
if %ERRORLEVEL% neq 0 exit 1

endlocal