@echo off & echo Incomplete script. Compile it first via 'build.bat' - github.com/3F/hMSBuild 1>&2 & exit /B 1

:: hMSBuild - $-version-$
:: Copyright (c) 2017  Denis Kuzmin [ entry.reg@gmail.com ]
:: -
:: Distributed under the MIT license
:: https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion


::::
::   Settings by default

set vswhereVersion=1.0.62
set vswhereCache=%temp%\hMSBuild_vswhere

set notamd64=0
set novs=0
set nonet=0
set novswhere=0
set nocachevswhere=0
set hMSBuildDebug=0

set ERROR_SUCCESS=0
set ERROR_FILE_NOT_FOUND=2
set ERROR_PATH_NOT_FOUND=3

:: leave for this at least 1 trailing whitespace -v
set args=%* 


::::
::   Help command

set cargs=%args%

set cargs=%cargs:-help =%
set cargs=%cargs:-h =%
set cargs=%cargs:-? =%

if not "%args%"=="%cargs%" goto printhelp
goto mainCommands


:printhelp

echo.
echo :: hMSBuild - $-version-$
echo Copyright (c) 2017  Denis Kuzmin [ entry.reg@gmail.com :: github.com/3F ]
echo Distributed under the MIT license
echo https://github.com/3F/hMSBuild 
echo.
echo.
echo Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
echo ------
echo.
echo Arguments:
echo ----------
echo  -novswhere             - Do not search via vswhere.
echo  -novs                  - Disable searching from Visual Studio.
echo  -nonet                 - Disable searching from .NET Framework.
echo  -vswhere-version {num} - To use special version of vswhere. Use `latest` keyword to get newer.
echo  -nocachevswhere        - Do not cache vswhere. Use this also for reset cache.
echo  -notamd64              - To use 32bit version of found msbuild.exe if it's possible.
echo  -eng                   - Try to use english language for all build messages.
echo  -GetNuTool {args}      - Access to GetNuTool core. https://github.com/3F/GetNuTool
echo  -debug                 - To show additional information from hMSBuild.
echo  -version               - To show version of hMSBuild.
echo  -help                  - Display this help. Aliases: -help -h -?
echo.
echo. 
echo -------- 
echo Samples:
echo -------- 
echo hMSBuild -vswhere-version 1.0.50 -notamd64 "Conari.sln" /t:Rebuild
echo hMSBuild -vswhere-version latest "Conari.sln"
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
echo Possible Error Codes: ERROR_FILE_NOT_FOUND (0x2), ERROR_PATH_NOT_FOUND (0x3), ERROR_SUCCESS (0x0)
echo ---------------------
echo.

exit /B 0

::::
::   Main commands for user

:mainCommands

set /a idx=1 & set cmdMax=11
:loopargs

    if "!args:~0,11!"=="-GetNuTool " (
        call :popars %1 & shift
        goto gntcall
    )
    
    if "!args:~0,11!"=="-novswhere " (
        call :popars %1 & shift
        set novswhere=1
    )
    
    if "!args:~0,16!"=="-nocachevswhere " (
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

    :: backward compatibility - version 1.1
    if "!args:~0,16!"=="-vswhereVersion " set _OrConditionVSWVer=1
    if "!args:~0,17!"=="-vswhere-version " set _OrConditionVSWVer=1
    if defined _OrConditionVSWVer (
        set _OrConditionVSWVer=
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
    
    if "!args:~0,7!"=="-debug " (
        call :popars %1 & shift
        set hMSBuildDebug=1
    )
    
    if "!args:~0,9!"=="-version " (
        echo hMSBuild - $-version-$
        exit /B 0
    )
    
set /a "idx=idx+1"
if !idx! LSS %cmdMax% goto loopargs

goto action

:popars
set args=!!args:%1 ^=!!
exit /B 0


:action
::::
::   Main logic of searching

if "!nocachevswhere!"=="1" (
    call :dbgprint "resetting cache of vswhere"
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

echo MSBuild tools was not found. Try to use other settings. Use key `-help` for details.
exit /B %ERROR_FILE_NOT_FOUND%

:dbgprint
if "!hMSBuildDebug!"=="1" (
    set msgfmt=%1
    set msgfmt=!msgfmt:~0,-1! 
    set msgfmt=!msgfmt:~1!
    echo.[%TIME% ] !msgfmt!
)
exit /B 0

:runmsbuild

set xMSBuild="!msbuildPath!"
echo MSBuild Tools ('xMSBuild'): !xMSBuild! 
call :dbgprint "Arguments: !args!"

!xMSBuild! !args!

exit /B 0

:vswhere
::::
::   MSBuild tools from new Visual Studio - VS2017+

call :dbgprint "trying via vswhere..."

if "!nocachevswhere!"=="1" (
    set tvswhere=%temp%\%random%%random%vswhere
) else (
    set tvswhere=%vswhereCache%
)

call :dbgprint "tvswhere: %tvswhere%"

if "!vswhereVersion!"=="latest" (
    set vswpkg=vswhere
) else (
    set vswpkg=vswhere/!vswhereVersion!
)

call :dbgprint "vswpkg: %vswpkg%"

if "!hMSBuildDebug!"=="1" (
    call :gntpoint /p:ngpackages="%vswpkg%:vswhere" /p:ngpath="%tvswhere%"
) else (
    call :gntpoint /p:ngpackages="%vswpkg%:vswhere" /p:ngpath="%tvswhere%" >nul
)
set vswbin="%tvswhere%\vswhere\tools\vswhere"

for /f "usebackq tokens=1* delims=: " %%a in (`%vswbin% -latest -requires Microsoft.Component.MSBuild`) do (
    if /i "%%a"=="installationPath" set vspath=%%b
    if /i "%%a"=="installationVersion" set vsver=%%b
)

call :dbgprint "vspath: !vspath!"
call :dbgprint "vsver: !vsver!"

if "!nocachevswhere!"=="1" (
    call :dbgprint "reset vswhere"
    rmdir /S/Q "%tvswhere%"
)

if [%vsver%]==[] (
    call :dbgprint "VS2017+ was not found via vswhere"
    exit /B %ERROR_PATH_NOT_FOUND%
)

for /f "tokens=1,2 delims=." %%a in ("%vsver%") do (
    set vsver=%%a.%%b
)
set msbuildPath=!vspath!\MSBuild\!vsver!\Bin

call :dbgprint "found path to msbuild: !msbuildPath!"

if exist "!msbuildPath!\amd64" (
    call :dbgprint "found /amd64"
    set msbuildPath=!msbuildPath!\amd64
)
call :msbuildfind 
exit /B 0

:msbvsold
::::
::   MSBuild tools from Visual Studio - 2015, 2013, ...

call :dbgprint "trying via MSBuild tools from Visual Studio - 2015, 2013, ..."

for %%v in (14.0, 12.0) do (
    call :dbgprint "checking of version: %%v"
    
    for /F "usebackq tokens=2* skip=2" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%%v" /v MSBuildToolsPath 2^> nul`
    ) do if exist %%b (
        call :dbgprint "found: %%b"
        
        set msbuildPath=%%b
        call :msbuildfind
        exit /B 0
    )
)

call :dbgprint "msbvsold: unfortenally we didn't find anything."
exit /B %ERROR_FILE_NOT_FOUND%

:msbnetf
::::
::   MSBuild tools from .NET Framework - .net 4.0, ...

call :dbgprint "trying via MSBuild tools from .NET Framework - .net 4.0, ..."

for %%v in (4.0, 3.5, 2.0) do (
    call :dbgprint "checking of version: %%v"
    
    for /F "usebackq tokens=2* skip=2" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%%v" /v MSBuildToolsPath 2^> nul`
    ) do if exist %%b (
        call :dbgprint "found: %%b"
        
        set msbuildPath=%%b
        call :msbuildfind
        exit /B 0
    )
)

call :dbgprint "msbnetf: unfortenally we didn't find anything."
exit /B %ERROR_FILE_NOT_FOUND%


:gntcall
call :dbgprint "direct access to GetNuTool..."
call :gntpoint !args!
exit /B 0

:msbuildfind

set msbuildPath=!msbuildPath!\MSBuild.exe

if not "!notamd64!" == "1" (
    exit /B 0
)

:: 7z & amd64\msbuild - https://github.com/3F/vsSolutionBuildEvent/issues/38
set _amd=!msbuildPath:Framework64=Framework!
set _amd=!_amd:amd64=!

if exist "!_amd!" (
    call :dbgprint "Return 32bit version of MSBuild.exe because you wanted this via -notamd64"
    set msbuildPath=!_amd!
    exit /B 0
)

call :dbgprint "We know that 32bit version of MSBuild.exe is important for you, but we found only this."
exit /B 0

:gntpoint
setlocal disableDelayedExpansion 

:: ========================= GetNuTool =========================

