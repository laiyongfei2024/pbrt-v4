@echo off
setlocal EnableDelayedExpansion

for %%v in (2022 2019 2017) do (
    set "VCVARS_PATH=C:\Program Files\Microsoft Visual Studio\%%v\Community\VC\Auxiliary\Build\vcvars64.bat"
    echo Checking for Visual Studio at: !VCVARS_PATH!
    if exist "!VCVARS_PATH!" (
        @REM echo !VCVARS_PATH!
        call "!VCVARS_PATH!"
        goto :vsfound
    )
)

echo Visual Studio not found
exit /b 1

:vsfound
@REM echo Found Visual Studio at: %VS_PATH%

set "VCPKG_DIR=%~dp0..\vcpkg"

if not exist VCPKG_DIR (
    for %%p in (
        "%~dp0..\vcpkg"
        "C:\vcpkg"
        "%USERPROFILE%\vcpkg"
        "%LOCALAPPDATA%\vcpkg"
    ) do (
        if exist "%%~p" (
            set "VCPKG_DIR=%%~p"
            goto :found_vcpkg
        )
    )
    echo VCPKG_DIR not set and vcpkg not found in common locations
    exit /b 1
)

:found_vcpkg

@REM echo %VCPKG_DIR%

set "CURRENT_DIR=%~dp0"

cd /d %VCPKG_DIR%
for /f %%i in ('.\vcpkg.exe list ^| findstr zlib') do set "HAS_ZLIB=%%i"
if not defined HAS_ZLIB (
    echo Installing zlib...
    call .\bootstrap-vcpkg.bat
    call .\vcpkg.exe install zlib:x64-windows
) else (
    echo zlib already installed
)

cd /d %CURRENT_DIR%

if exist "build" (
    rmdir /s /q "build"
)

cmake -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_TOOLCHAIN_FILE=%VCPKG_DIR%/scripts/buildsystems/vcpkg.cmake

cd build
ninja
if errorlevel 1 (
    echo Build failed
    cd ..
    exit /b 1
)
cd ..
