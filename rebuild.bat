@echo off
setlocal EnableDelayedExpansion

rem Set default build type to Release if not specified
set "BUILD_TYPE=Debug"
if not "%~1"=="" set "BUILD_TYPE=%~1"

rem 使用 vswhere 获取最新的 Visual Studio 安装路径
for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VSPATH=%%i"
)

if not defined VSPATH (
    echo Visual Studio not found
    exit /b 1
)

rem 调用 vcvars64.bat 脚本设置环境变量
call "%VSPATH%\VC\Auxiliary\Build\vcvars64.bat"

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

echo Building in %BUILD_TYPE% mode...
cmake -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_TOOLCHAIN_FILE=%VCPKG_DIR%/scripts/buildsystems/vcpkg.cmake

cd build
ninja
if errorlevel 1 (
    echo Build failed
    cd ..
    exit /b 1
)
cd ..
