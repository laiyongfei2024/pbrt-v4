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

cd build
ninja
if errorlevel 1 (
    echo Build failed
    cd ..
    exit /b 1
)
cd ..
