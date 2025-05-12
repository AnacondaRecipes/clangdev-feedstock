@echo on
setlocal enabledelayedexpansion

:: Create a staging install directory
set STAGING_DIR=%SRC_DIR%\clang\install_clang_tools

cd %SRC_DIR%\clang\build
cmake --install . --prefix "%STAGING_DIR%"
if %ERRORLEVEL% neq 0 exit 1

rmdir /s /q "%STAGING_DIR%\include\clang" "%STAGING_DIR%\include\clang-c" "%STAGING_DIR%\include\clang-tidy" "%STAGING_DIR%\lib"

robocopy "%STAGING_DIR%" "%LIBRARY_PREFIX%" /E /MOVE
if %ERRORLEVEL% GEQ 8 exit 1

endlocal