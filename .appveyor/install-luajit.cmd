REM Do a minimalistic build of LUAJIT using the MinGW compiler

set PATH=C:\MinGW\bin;%PATH%

set targetdir=%2

REM retrieve and unpack source
curl -fLsS -o %1.zip http://LUAjit.org/download/%1.zip
unzip -q %1

REM tweak Makefile for a static LUAJIT build (Windows defaults to "dynamic" otherwise)
sed -i "s/BUILDMODE=.*mixed/BUILDMODE=static/" %1\src\Makefile

mingw32-make TARGET_SYS=Windows -C %1\src

REM copy LUAjit.exe to project dir
mkdir %APPVEYOR_BUILD_FOLDER%\%targetdir%
copy %1\src\LUAjit.exe %APPVEYOR_BUILD_FOLDER%\%targetdir%\

REM clean up (remove source folders and archive)
rm -rf %1/*
rm -f %1.zip
