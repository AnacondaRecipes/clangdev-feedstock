@echo on
setlocal enabledelayedexpansion

:: Create a staging install directory
set STAGING_DIR=%SRC_DIR%\clang\install_libclang

cd %SRC_DIR%\clang\build
cmake --install . --prefix "%STAGING_DIR%"
if %ERRORLEVEL% neq 0 exit 1

if "%PKG_NAME%"=="libclang" (
    REM for unversioned output, keep only import lib; no DLLs
    move "%STAGING_DIR%\lib\libclang.lib" "%LIBRARY_PREFIX%\lib\libclang.lib"
    if %ERRORLEVEL% neq 0 exit /b 1
) else (
    REM for versioned output, keep only versioned DLL; no import lib
    move "%STAGING_DIR%\bin\libclang-%libclang_soversion%.dll" "%LIBRARY_BIN%\libclang-%libclang_soversion%.dll"
    if %ERRORLEVEL% neq 0 exit /b 1
)

endlocal