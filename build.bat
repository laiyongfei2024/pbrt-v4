@echo off
setlocal EnableDelayedExpansion

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

cd build
ninja
if errorlevel 1 (
    echo Build failed
    cd ..
    exit /b 1
)
cd ..
