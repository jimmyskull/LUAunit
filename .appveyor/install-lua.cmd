REM This is a batch file to help with setting up the desired LUA environment.
REM It is intended to be run as "install" step from within AppVeyor.

REM version numbers and file names for binaries from http://sf.net/p/LUAbinaries/
set VER_51=5.1.5
set VER_52=5.2.4
set VER_53=5.3.3
set ZIP_51=LUA-%VER_51%_Win32_bin.zip
set ZIP_52=LUA-%VER_52%_Win32_bin.zip
set ZIP_53=LUA-%VER_53%_Win32_bin.zip

:cinst
@echo off
if NOT "%LUAENV%"=="cinst" goto LUA51
echo Chocolatey install of LUA ...
if NOT EXIST "C:\Program Files (x86)\LUA\5.1\LUA.exe" (
    @echo on
    cinst LUA
) else (
    @echo on
    echo Using cached version of LUA
)
set LUA="C:\Program Files (x86)\LUA\5.1\LUA.exe"
@echo off
goto :EOF

:LUA51
@echo off
if NOT "%LUAENV%"=="LUA51" goto LUA52
echo Setting up LUA 5.1 ...
if NOT EXIST "LUA51\LUA5.1.exe" (
    @echo on
    echo Fetching LUA v5.1 from internet
    curl -fLsS -o %ZIP_51% http://sourceforge.net/projects/LUAbinaries/files/%VER_51%/Tools%%20Executables/%ZIP_51%/download
    unzip -d LUA51 %ZIP_51%
) else (
    echo Using cached version of LUA v5.1
)
set LUA=LUA51\LUA5.1.exe
@echo off
goto :EOF

:LUA52
@echo off
if NOT "%LUAENV%"=="LUA52" goto LUA53
echo Setting up LUA 5.2 ...
if NOT EXIST "LUA52\LUA52.exe" (
    @echo on
    echo Fetching LUA v5.2 from internet
    curl -fLsS -o %ZIP_52% http://sourceforge.net/projects/LUAbinaries/files/%VER_52%/Tools%%20Executables/%ZIP_52%/download
    unzip -d LUA52 %ZIP_52%
) else (
    echo Using cached version of LUA v5.2
)
@echo on
set LUA=LUA52\LUA52.exe
@echo off
goto :EOF

:LUA53
@echo off
if NOT "%LUAENV%"=="LUA53" goto LUAjit
echo Setting up LUA 5.3 ...
if NOT EXIST "LUA53\LUA53.exe" (
    @echo on
    echo Fetching LUA v5.3 from internet
    curl -fLsS -o %ZIP_53% http://sourceforge.net/projects/LUAbinaries/files/%VER_53%/Tools%%20Executables/%ZIP_53%/download
    unzip -d LUA53 %ZIP_53%
) else (
    echo Using cached version of LUA v5.3
)
@echo on
set LUA=LUA53\LUA53.exe
@echo off
goto :EOF

:LUAjit
if NOT "%LUAENV%"=="LUAjit20" goto LUAjit21
echo Setting up LUAJIT 2.0 ...
if NOT EXIST "LUAjit20\LUAjit.exe" (
    call %~dp0install-LUAjit.cmd LUAJIT-2.0.4 LUAjit20
) else (
    echo Using cached version of LUAJIT 2.0
)
set LUA=LUAjit20\LUAjit.exe
goto :EOF

:LUAjit21
echo Setting up LUAJIT 2.1 ...
if NOT EXIST "LUAjit21\LUAjit.exe" (
    call %~dp0install-LUAjit.cmd LUAJIT-2.1.0-beta2 LUAjit21
) else (
    echo Using cached version of LUAJIT 2.1
)
set LUA=LUAjit21\LUAjit.exe
