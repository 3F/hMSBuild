@echo off

:: hMSBuild
:: Copyright (c) 2017  Denis Kuzmin [ entry.reg@gmail.com ]
:: https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion

:::: Settings by default

set vswhereVersion=1.0.50
set vswhereCache=%temp%\hMSBuild_vswhere

set notamd64=0
set novs=0
set nonet=0
set novswhere=0
set nocachevswhere=0
set args=%* 

::


:::
:: Help command

set cargs=%args%

set cargs=%cargs:-help =%
set cargs=%cargs:-h =%
set cargs=%cargs:-? =%
set cargs=%cargs:/? =%

if not "%args%"=="%cargs%" goto printhelp
goto mainCommands


:printhelp

echo.
echo   https://github.com/3F/hMSBuild
echo   Based on GetNuTool - https://github.com/3F/GetNuTool
echo   [ entry.reg@gmail.com :: github.com/3F ]
echo.
echo Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
echo ------
echo.
echo ----------
echo Arguments:
echo ----------
echo hMSBuild -novswhere            - Do not search via vswhere.
echo hMSBuild -novs                 - Disable searching from Visual Studio.
echo hMSBuild -nonet                - Disable searching from .NET Framework.
echo hMSBuild -vswhereVersion {num} - To use special version of vswhere. Use `latest` keyword to get latest version.
echo hMSBuild -nocachevswhere       - Do not cache vswhere. Use this also for reset cache.
echo hMSBuild -notamd64             - To use x32 bit version of found msbuild.exe if it's possible.
echo hMSBuild -eng                  - Try to use english language for all build messages.
echo hMSBuild -GetNuTool {args}     - Access to GetNuTool core.
echo hMSBuild -help                 - Shows this help. Aliases: -help -h /? -?
echo.
echo. 
echo -------- 
echo Samples:
echo -------- 
echo hMSBuild -vswhereVersion 1.0.50 -notamd64 "Conari.sln" /t:Rebuild
echo hMSBuild -vswhereVersion latest "Conari.sln"
echo.
echo hMSBuild -novswhere -novs -notamd64 "Conari.sln"
echo hMSBuild -novs "DllExport.sln"
echo hMSBuild vsSolutionBuildEvent.sln
echo.
echo hMSBuild -GetNuTool -unpack
echo hMSBuild -GetNuTool /p:ngpackages="Conari;regXwild"
echo.
echo "hMSBuild -novs "DllExport.sln" || goto err"
echo.
echo ---------------------
echo Possible Error Codes: ERROR_FILE_NOT_FOUND (0x2), ERROR_PATH_NOT_FOUND 3 (0x3), ERROR_SUCCESS (0x0)
echo ---------------------
echo.

exit /B 0

:::
:: Main commands for user

:mainCommands

set /a idx=1 & set cmdMax=8
:loopargs

    if "!args:~0,11!"=="-GetNuTool " (
        call :popars %1 & shift
        goto gntcall
    )
    
    if "!args:~0,11!"=="-novswhere " (
        call :popars %1 & shift
        set novswhere=1
    )
    
    if "!args:~0,14!"=="-nocachevswhere " (
        call :popars %1 & shift
        set nocachevswhere=1
    )
    
    if "!args:~0,6!"=="-novs " (
        call :popars %1 & shift
        set novs=1
    )
    
    if "!args:~0,7!"=="-nonet " (
        call :popars %1 & shift
        set nonet=1
    )
    
    if "!args:~0,16!"=="-vswhereVersion " (
        call :popars %1 & shift
        set vswhereVersion=%2
        echo selected new vswhere version: !vswhereVersion!
        call :popars %2 & shift
    )
    
    if "!args:~0,10!"=="-notamd64 " (
        call :popars %1 & shift
        set notamd64=1
    )
    
    if "!args:~0,5!"=="-eng " (
        call :popars %1 & shift
        chcp 437 >nul
    )
    
set /a "idx=idx+1"
if !idx! LSS %cmdMax% goto loopargs

goto action

:popars
set args=!!args:%1 ^=!!
exit /B 0


:action
:: Start of logic for searching

if "!nocachevswhere!"=="1" (
    rmdir /S/Q "%vswhereCache%"
)

if not "!novswhere!"=="1" if not "!novs!"=="1" (
    call :vswhere
    if "!ERRORLEVEL!"=="0" goto runmsbuild
)

if not "!novs!"=="1" (
    call :msbvsold
    if "!ERRORLEVEL!"=="0" goto runmsbuild
)

if not "!nonet!"=="1" (
    call :msbnetf
    if "!ERRORLEVEL!"=="0" goto runmsbuild
)

echo MSBuild tools was not found.
exit /B 2


:runmsbuild

set selmsbuild="!msbuildPath!"
echo MSBuild Tools: !selmsbuild! 
echo arguments: !args!

!selmsbuild! !args!

exit /B 0

:vswhere
:: MSBuild tools from new Visual Studio - VS2017+

if "!nocachevswhere!"=="1" (
    set tvswhere=%temp%\%random%%random%vswhere
) else (
    set tvswhere=%vswhereCache%
)

if "!vswhereVersion!"=="latest" (
    set vswpkg=vswhere
) else (
    set vswpkg=vswhere/!vswhereVersion!
)

call :gntpoint /p:ngpackages="%vswpkg%:vswhere" /p:ngpath="%tvswhere%" >nul    
set vswbin="%tvswhere%\vswhere\tools\vswhere"

for /f "usebackq tokens=1* delims=: " %%a in (`%vswbin% -latest -requires Microsoft.Component.MSBuild`) do (
    if /i "%%a"=="installationPath" set vspath=%%b
    if /i "%%a"=="installationVersion" set vsver=%%b
)

if "!nocachevswhere!"=="1" (
    rmdir /S/Q "%tvswhere%"
)

if [%vsver%]==[] (
    echo VS2017+ was not found via vswhere
    exit /B 3
)

for /f "tokens=1,2 delims=." %%a in ("%vsver%") do (
    set vsver=%%a.%%b
)
set msbuildPath=!vspath!\MSBuild\!vsver!\Bin

if exist "!msbuildPath!\amd64" (
    set msbuildPath=!msbuildPath!\amd64
)
call :msbuildfind 
exit /B 0

:msbvsold
:: MSBuild tools from Visual Studio - 2015, 2013, ...

for %%v in (14.0, 12.0) do (
    for /F "usebackq tokens=2* skip=2" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%%v" /v MSBuildToolsPath 2^> nul`
    ) do if exist %%b (
        set msbuildPath=%%b
        call :msbuildfind
        ::call :msbuildfind "%%b"
        exit /B 0
    )
)

exit /B 2

:msbnetf
:: MSBuild tools from .NET Framework - .net 4.0, ...

for %%v in (4.0, 3.5, 2.0) do (
    for /F "usebackq tokens=2* skip=2" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%%v" /v MSBuildToolsPath 2^> nul`
    ) do if exist %%b (
        set msbuildPath=%%b
        call :msbuildfind
        ::call :msbuildfind "%%b"
        exit /B 0
    )
)

exit /B 2


:gntcall
call :gntpoint !args!
exit /B 0

:msbuildfind

if not "!notamd64!" == "1" (
    set msbuildPath=!msbuildPath!\MSBuild.exe
    exit /B 0
)

:: 7z & amd64\msbuild - https://github.com/3F/vsSolutionBuildEvent/issues/38
set _amd=..\MSBuild.exe
if exist "!msbuildPath!/!_amd!" (
    set msbuildPath=!msbuildPath!\!_amd!
) else ( 
    set msbuildPath=!msbuildPath!\MSBuild.exe
)

exit /B 0

:gntpoint
setlocal disableDelayedExpansion 

:: ========================= GetNuTool =========================

