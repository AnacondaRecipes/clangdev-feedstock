@echo on
setlocal enabledelayedexpansion

:: Create a staging install directory
set STAGING_DIR=%SRC_DIR%\clang\install_clang

cd %SRC_DIR%\clang\build
cmake --install . --prefix "%STAGING_DIR%"
if %ERRORLEVEL% neq 0 exit 1

rmdir /s /q "%STAGING_DIR%\lib\cmake" "%STAGING_DIR%\libexec" "%STAGING_DIR%\share" "%STAGING_DIR%\include"
del /q /f "%STAGING_DIR%\lib\*.lib"

robocopy "%STAGING_DIR%" "%LIBRARY_PREFIX%" /E /MOVE
if %ERRORLEVEL% GEQ 8 exit 1

for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  copy "%LIBRARY_PREFIX%\bin\clang.exe" "%LIBRARY_PREFIX%\bin\clang-%%a.exe"
)

endlocal