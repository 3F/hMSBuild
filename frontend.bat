@echo off & echo Incomplete script. Compile it first via 'build.bat' - github.com/3F/hMSBuild 1>&2 & exit /B 1

:: hMSBuild - $-version-$
:: Copyright (c) 2017  Denis Kuzmin [ entry.reg@gmail.com ]
:: -
:: Distributed under the MIT license
:: https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion


:: - - -
:: Settings by default

set vswhereByDefault=1.0.62
set vswhereCache=%temp%\hMSBuild_vswhere

set /a notamd64=0
set /a novs=0
set /a nonet=0
set /a novswhere=0
set /a nocachevswhere=0
set /a hMSBuildDebug=0
set "displayOnlyPath="
set "vswVersion="

set ERROR_SUCCESS=0
set ERROR_FILE_NOT_FOUND=2
set ERROR_PATH_NOT_FOUND=3

set "args=%* "


:: - - -
:: Help command

set _hl=%args:"=%
set _hr=%_hl%

set _hr=%_hr:-help =%
set _hr=%_hr:-h =%
set _hr=%_hr:-? =%

if not "%_hl%"=="%_hr%" goto usage
goto commands

:usage

echo.
@echo :: hMSBuild - $-version-$
@echo Copyright (c) 2017  Denis Kuzmin [ entry.reg@gmail.com :: github.com/3F ]
echo Distributed under the MIT license
@echo https://github.com/3F/hMSBuild 
echo.
@echo.
@echo Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
echo ------
echo.
echo Arguments:
echo ----------
echo  -novswhere             - Do not search via vswhere.
echo  -novs                  - Disable searching from Visual Studio.
echo  -nonet                 - Disable searching from .NET Framework.
echo  -vswhere-version {num} - Specific version of vswhere. Where {num}:
echo                           * Versions: 1.0.50 ...
echo                           * Keywords: 
echo                             `latest` to get latest available version; 
echo                             `local`  to use only local versions: 
echo                                      (.bat;.exe /or from +15.2.26418.1 VS-build);
echo.
echo  -nocachevswhere        - Do not cache vswhere. Use this also for reset cache.
echo  -notamd64              - To use 32bit version of found msbuild.exe if it's possible.
echo  -eng                   - Try to use english language for all build messages.
echo  -GetNuTool {args}      - Access to GetNuTool core. https://github.com/3F/GetNuTool
echo  -only-path             - Only display fullpath to found MSBuild.
echo  -debug                 - To show additional information from hMSBuild.
echo  -version               - Display version of hMSBuild.
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

:: - - -
:: Handler of user commands

:commands

call :isEmptyOrWhitespace args _is
if [!_is!]==[1] goto action

set /a idx=1 & set cmdMax=12
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
        set "_OrConditionVSWVer="
        call :popars %1 & shift
        set vswVersion=%2
        echo selected new vswhere version: !vswVersion!
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

    if "!args:~0,11!"=="-only-path " (
        call :popars %1 & shift
        set displayOnlyPath=1
    )

    if "!args:~0,7!"=="-debug " (
        call :popars %1 & shift
        set hMSBuildDebug=1
    )
    
    if "!args:~0,9!"=="-version " (
        @echo hMSBuild - $-version-$
        exit /B 0
    )
    
set /a "idx+=1"
if !idx! LSS %cmdMax% goto loopargs

goto action

:popars
set args=!!args:%1 ^=!!
call :trim args
set "args=!args! "
exit /B 0

:: - - -
:: Main logic of searching
:action

if "!nocachevswhere!"=="1" (
    call :dbgprint "resetting cache of vswhere"
    rmdir /S/Q "%vswhereCache%" 2>nul
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

:runmsbuild

call :isEmptyOrWhitespace msbuildPath _is
if [!_is!]==[1] (
    echo Something went wrong. Use `-debug` key for details.
    exit /B %ERROR_FILE_NOT_FOUND%
)

if defined displayOnlyPath (
    echo !msbuildPath!
    exit /B 0
)
set xMSBuild="!msbuildPath!"

echo hMSBuild: !xMSBuild! 
call :dbgprint "Arguments: !args!"

!xMSBuild! !args!
exit /B 0

:: - - -
:: Tools from VS2017+
:vswhere

call :dbgprint "trying via vswhere..."

if defined vswVersion (
    if not "!vswVersion!"=="local" (
        call :vswhereRemote
        call :vswhereBin
        exit /B !ERRORLEVEL!
    )
)

call :vswhereLocal
if "!ERRORLEVEL!"=="%ERROR_PATH_NOT_FOUND%" (
    if "!vswVersion!"=="local" (
        exit /B %ERROR_PATH_NOT_FOUND%
    )
    call :vswhereRemote
)
call :vswhereBin
exit /B !ERRORLEVEL!

:vswhereLocal

:: Only with +15.2.26418.1 VS-build
:: https://github.com/3F/hMSBuild/issues/1

if exist "%~dp0vswhere.bat" set vswbin="%~dp0vswhere" & exit /B 0
if exist "%~dp0vswhere.exe" set vswbin="%~dp0vswhere" & exit /B 0

set rlocalp=Microsoft Visual Studio\Installer
if exist "%ProgramFiles(x86)%\!rlocalp!" set vswbin="%ProgramFiles(x86)%\!rlocalp!\vswhere" & exit /B 0
if exist "%ProgramFiles%\!rlocalp!" set vswbin="%ProgramFiles%\!rlocalp!\vswhere" & exit /B 0

call :dbgprint "local vswhere is not found."
exit /B %ERROR_PATH_NOT_FOUND%

:vswhereRemote

if "!nocachevswhere!"=="1" (
    set tvswhere=%temp%\%random%%random%vswhere
) else (
    set tvswhere=%vswhereCache%
)

call :dbgprint "tvswhere: !tvswhere!"

if "!vswVersion!"=="latest" (
    set vswpkg=vswhere
) else (
    set vswpkg=vswhere/!vswVersion!
)

call :dbgprint "vswpkg: !vswpkg!"

if "!hMSBuildDebug!"=="1" (
    call :gntpoint /p:ngpackages="!vswpkg!:vswhere" /p:ngpath="!tvswhere!"
) else (
    call :gntpoint /p:ngpackages="!vswpkg!:vswhere" /p:ngpath="!tvswhere!" >nul
)
set vswbin="!tvswhere!\vswhere\tools\vswhere"

exit /B 0

:vswhereBin
call :dbgprint "vswbin: "!vswbin!""

for /f "usebackq tokens=1* delims=: " %%a in (`!vswbin! -latest -requires Microsoft.Component.MSBuild`) do (
    if /i "%%a"=="installationPath" set vspath=%%b
    if /i "%%a"=="installationVersion" set vsver=%%b
)

call :dbgprint "vspath: !vspath!"
call :dbgprint "vsver: !vsver!"

if defined tvswhere (
    if "!nocachevswhere!"=="1" (
        call :dbgprint "reset vswhere"
        rmdir /S/Q "!tvswhere!"
    )
)

if [!vsver!]==[] (
    call :dbgprint "VS2017+ was not found via vswhere"
    exit /B %ERROR_PATH_NOT_FOUND%
)

for /f "tokens=1,2 delims=." %%a in ("!vsver!") do (
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

:: - - -
:: Tools from Visual Studio - 2015, 2013, ...
:msbvsold
call :dbgprint "trying via MSBuild tools from Visual Studio - 2015, 2013, ..."

for %%v in (14.0, 12.0) do (
    call :rtools %%v Y & if [!Y!]==[1] exit /B 0
)
call :dbgprint "msbvsold: unfortunately we didn't find anything."
exit /B %ERROR_FILE_NOT_FOUND%

:: - - -
:: Tools from .NET Framework - .net 4.0, ...
:msbnetf

call :dbgprint "trying via MSBuild tools from .NET Framework - .net 4.0, ..."

for %%v in (4.0, 3.5, 2.0) do (
    call :rtools %%v Y & if [!Y!]==[1] exit /B 0
)
call :dbgprint "msbnetf: unfortunately we didn't find anything."
exit /B %ERROR_FILE_NOT_FOUND%

:rtools
call :dbgprint "checking of version: %1"
    
for /F "usebackq tokens=2* skip=2" %%a in (
    `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%1" /v MSBuildToolsPath 2^> nul`
) do if exist %%b (
    call :dbgprint "found: %%b"
        
    set msbuildPath=%%b
    call :msbuildfind
    set /a %2=1
    exit /B 0
)
set /a %2=0
exit /B 0

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

:: =

:dbgprint
if "!hMSBuildDebug!"=="1" (
    set msgfmt=%1
    set msgfmt=!msgfmt:~0,-1! 
    set msgfmt=!msgfmt:~1!
    echo.[%TIME% ] !msgfmt!
)
exit /B 0

:trim
:: Usage: call :trim variable
call :_v %%%1%%
set %1=%_trimv%
exit /B 0
:_v
set "_trimv=%*"
exit /B 0

:isEmptyOrWhitespace
:: Usage: call :isEmptyOrWhitespace input output(1/0)
setlocal enableDelayedExpansion
set "_v=!%1!"

if not defined _v endlocal & set /a %2=1 & exit /B 0
 
set _v=%_v: =%
set "_v= %_v%"
if [^%_v:~1,1%]==[] endlocal & set /a %2=1 & exit /B 0
 
endlocal & set /a %2=0
exit /B 0

:gntpoint
setlocal disableDelayedExpansion 

:: ========================= GetNuTool =========================

