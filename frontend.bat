@echo off & echo Incomplete script. Compile it first via 'build.bat' - github.com/3F/hMSBuild 1>&2 & exit /B 1

:: hMSBuild - $-version-$
:: Copyright (c) 2017-2019  Denis Kuzmin [ entry.reg@gmail.com ] GitHub/3F
:: Copyright (c) the hMSBuild contributors

set "dp0=%~dp0"
set args=%*

:: To skip pre-processing when no arguments
if not defined args setlocal enableDelayedExpansion & goto settings

:: - - -
:: Pre-processing

:: Escaping '^' is not identical for all cases (hMSBuild ... vs call hMSBuild ...)
if not defined __p_call set args=%args:^=^^%

:: When ~ !args! and "!args!"
:: # call hMSBuild  ^  - ^
:: #      hMSBuild  ^  - empty
:: # call hMSBuild  ^^ - ^^
:: #      hMSBuild  ^^ - ^

:: When ~ %args%  (disableDelayedExpansion)
:: # call hMSBuild  ^  - ^^
:: #      hMSBuild  ^  - ^
:: # call hMSBuild  ^^ - ^^^^
:: #      hMSBuild  ^^ - ^^

set esc=%args:!= #__b_ECL## %
set esc=%esc:^= #__b_CRT## %
setlocal enableDelayedExpansion

:: https://github.com/3F/hMSBuild/issues/7
set "E_CARET=^"
set "esc=!esc:%%=%%%%!"
set "esc=!esc:&=%%E_CARET%%&!"


:: - - -
:: Default data
:settings

set "vswVersion=2.5.2"
set vswhereCache=%temp%\hMSBuild_vswhere

set "notamd64="
set "novs="
set "nonet="
set "novswhere="
set "nocachevswhere="
set "resetcache="
set "hMSBuildDebug="
set "displayOnlyPath="
set "vswVersionUsr="
set "vswPriority="
set "kStable="
set "kForce="

set /a ERROR_SUCCESS=0
set /a ERROR_FAILED=1
set /a ERROR_FILE_NOT_FOUND=2
set /a ERROR_PATH_NOT_FOUND=3

:: Current exit code for endpoint
set /a EXIT_CODE=0

:: - - -
:: Initialization of user arguments

if not defined args goto action

:: /? will cause problems for the call commands below, so we just escape this via supported alternative:
set esc=!esc:/?=/h!

call :initargs arg esc amax
goto commands

:usage

echo.
@echo hMSBuild - $-version-$
@echo Copyright (c) 2017-2019  Denis Kuzmin [ entry.reg@gmail.com ] GitHub/3F
@echo Copyright (c) the hMSBuild contributors
echo.
echo Licensed under the MIT License
@echo https://github.com/3F/hMSBuild 
echo.
@echo.
@echo Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
echo ------
echo.
echo Arguments:
echo ----------
echo  -no-vs        - Disable searching from Visual Studio.
echo  -no-netfx     - Disable searching from .NET Framework.
echo  -no-vswhere   - Do not search via vswhere.
echo.
echo  -vsw-priority {IDs} - Non-strict components preference: C++ etc.
echo                        Separated by space: https://aka.ms/vs/workloads
echo.
echo  -vsw-version {arg}  - Specific version of vswhere. Where {arg}:
echo      * 1.0.50 ...
echo      * Keywords:
echo        `latest` - To get latest remote version;
echo        `local`  - To use only local versions;
echo                   (.bat;.exe /or from +15.2.26418.1 VS-build)
echo.
echo  -no-cache         - Do not cache vswhere for this request. 
echo  -reset-cache      - To reset all cached vswhere versions before processing.
echo  -notamd64         - To use 32bit version of found msbuild.exe if it's possible.
echo  -stable           - It will ignore possible beta releases in last attempts.
echo  -eng              - Try to use english language for all build messages.
echo  -GetNuTool {args} - Access to GetNuTool core. https://github.com/3F/GetNuTool
echo  -only-path        - Only display fullpath to found MSBuild.
echo  -force            - Aggressive behavior for -vsw-priority, -notamd64, etc.
echo  -debug            - To show additional information from hMSBuild.
echo  -version          - Display version of hMSBuild.
echo  -help             - Display this help. Aliases: -help -h
echo. 
echo. 
echo ------
echo Flags:
echo ------
echo  __p_call - Tries to eliminate the difference for the call-type invoking %~nx0
echo. 
echo -------- 
echo Samples:
echo -------- 
echo hMSBuild -notamd64 -vsw-version 1.0.50 "Conari.sln" /t:Rebuild
echo hMSBuild -vsw-version latest "Conari.sln"
echo.
echo hMSBuild -no-vswhere -no-vs -notamd64 "Conari.sln"
echo hMSBuild -no-vs "DllExport.sln"
echo hMSBuild vsSolutionBuildEvent.sln
echo.
echo hMSBuild -GetNuTool -unpack
echo hMSBuild -GetNuTool /p:ngpackages="Conari;regXwild"
echo.
echo hMSBuild -no-vs "DllExport.sln" ^|^| goto err

goto endpoint

:: - - -
:: Handler of user commands

:commands

:: arguments to msbuild only
set "msbargs="

set /a idx=0

:loopargs
set key=!arg[%idx%]!

    :: The help command

    if [!key!]==[-help] ( goto usage ) else if [!key!]==[-h] ( goto usage ) else if [!key!]==[-?] ( goto usage )

    :: Aliases

    if [!key!]==[-nocachevswhere] (
        call :obsolete -nocachevswhere -no-cache -reset-cache
        set key=-no-cache
    ) else if [!key!]==[-novswhere] (
        call :obsolete -novswhere -no-vswhere
        set key=-no-vswhere
    ) else if [!key!]==[-novs] (
        call :obsolete -novs -no-vs
        set key=-no-vs
    ) else if [!key!]==[-nonet] (
        call :obsolete -nonet -no-netfx
        set key=-no-netfx
    ) else if [!key!]==[-vswhere-version] (
        call :obsolete -vswhere-version -vsw-version
        set key=-vsw-version
    )

    :: Available keys

    if [!key!]==[-debug] (

        set hMSBuildDebug=1

        goto continue
    ) else if [!key!]==[-GetNuTool] ( 

        call :dbgprint "accessing to GetNuTool ..."
        
        :: invoke GetNuTool with arguments from right side
        for /L %%p IN (0,1,8181) DO (
            if "!escg:~%%p,10!"=="-GetNuTool" (

                set found=!escg:~%%p!
                call :gntpoint !found:~10!

                set /a EXIT_CODE=%ERRORLEVEL%
                goto endpoint
            )
        )

        call :dbgprint "!key! is corrupted: !escg!" 
        set /a EXIT_CODE=%ERROR_FAILED%
        goto endpoint
        
    ) else if [!key!]==[-no-vswhere] ( 
        
        set novswhere=1

        goto continue
    ) else if [!key!]==[-no-cache] ( 

        set nocachevswhere=1

        goto continue
    ) else if [!key!]==[-reset-cache] ( 

        set resetcache=1

        goto continue
    ) else if [!key!]==[-no-vs] ( 

        set novs=1

        goto continue
    ) else if [!key!]==[-no-netfx] ( 

        set nonet=1

        goto continue
    ) else if [!key!]==[-notamd64] ( 

        set notamd64=1

        goto continue
    ) else if [!key!]==[-only-path] ( 

        set displayOnlyPath=1

        goto continue
    ) else if [!key!]==[-eng] ( 

        chcp 437 >nul

        goto continue
    ) else if [!key!]==[-vsw-version] ( set /a "idx+=1" & call :eval arg[!idx!] v
        
        set vswVersion=!v!

        call :dbgprint "selected vswhere version:" v
        set vswVersionUsr=1

        goto continue
    ) else if [!key!]==[-version] ( 

        @echo $-version-$
        goto endpoint

    ) else if [!key!]==[-vsw-priority] ( set /a "idx+=1" & call :eval arg[!idx!] v
        
        set vswPriority=!v!

        goto continue
    ) else if [!key!]==[-stable] ( 

        set kStable=1

        goto continue
    ) else if [!key!]==[-force] ( 

        set kForce=1

        goto continue
    ) else (
        
        call :dbgprint "non-handled key:" arg{%idx%}
        set msbargs=!msbargs! !arg{%idx%}!
    )

:continue
set /a "idx+=1" & if %idx% LSS !amax! goto loopargs

:: - - -
:: Main 
:action

if defined resetcache (
    call :dbgprint "resetting vswhere cache"
    rmdir /S/Q "%vswhereCache%" 2>nul
)

if not defined novswhere if not defined novs (
    call :vswhere msbuildPath
    if defined msbuildPath goto runmsbuild
)

if not defined novs (
    call :msbvsold msbuildPath
    if defined msbuildPath goto runmsbuild
)

if not defined nonet (
    call :msbnetf msbuildPath
    if defined msbuildPath goto runmsbuild
)

echo MSBuild tools was not found. Use `-debug` key for details.
set /a EXIT_CODE=%ERROR_FILE_NOT_FOUND%
goto endpoint

:runmsbuild

if defined displayOnlyPath (
    echo !msbuildPath!
    goto endpoint
)

set xMSBuild="!msbuildPath!"
echo hMSBuild: !xMSBuild! 

:: Do not place below data inside (...) block because of delayed eval, e.g. `if defined msbargs ( ...`
if not defined msbargs goto _msbargs

:: We don't need double quotes (e.g. set "msbargs=...") because this should already 
:: contain special symbols inside "..." (e.g. /p:prop="...").
set msbargs=%msbargs: #__b_CRT## =^%
set msbargs=%msbargs: #__b_ECL## =^!%
set msbargs=!msbargs: #__b_EQ## ==!

:_msbargs
call :dbgprint "Arguments: " msbargs

!xMSBuild! !msbargs!

set /a EXIT_CODE=%ERRORLEVEL%
goto endpoint


:: - - -
:: Post-actions
:endpoint

exit /B !EXIT_CODE!


:: Functions
:: ::

:: - - -
:: Tools from VS2017+
:vswhere {out:toolset}
call :dbgprint "trying via vswhere..."

if defined vswVersionUsr if not "!vswVersion!"=="local" (

    call :vswhereRemote vswbin vswdir
    call :vswhereBin vswbin _msbf vswdir

    set %1=!_msbf!
    exit /B 0
)

call :vswhereLocal vswbin
set "vswdir="

if not defined vswbin (
    if "!vswVersion!"=="local" (
        set "%1=" & exit /B %ERROR_FILE_NOT_FOUND%
    )
    call :vswhereRemote vswbin vswdir
)
call :vswhereBin vswbin _msbf vswdir

set %1=!_msbf!
exit /B 0
:: :vswhere

:vswhereLocal {out:vswbin}

set vswfile=!dp0!vswhere
call :batOrExe vswfile xfile

if defined xfile set "%1=!vswfile!" & exit /B 0

:: Only with +15.2.26418.1 VS-build
:: https://github.com/3F/hMSBuild/issues/1

set rlocalp=Microsoft Visual Studio\Installer
if exist "%ProgramFiles(x86)%\!rlocalp!" set "%1=%ProgramFiles(x86)%\!rlocalp!\vswhere" & exit /B 0
if exist "%ProgramFiles%\!rlocalp!" set "%1=%ProgramFiles%\!rlocalp!\vswhere" & exit /B 0

call :dbgprint "local vswhere is not found."
set "%1="
exit /B %ERROR_PATH_NOT_FOUND%
:: :vswhereLocal

:vswhereRemote {out:vswbin} {out:vswdir}
:: 1{vswbin} - relative path from {vswdir} to executable file; 
:: 2{vswdir} - path to used directory with vswhere;

if defined nocachevswhere (
    set tvswhere=!vswhereCache!\_mta\%random%%random%vswhere
) else (
    set tvswhere=!vswhereCache!
    
    if defined vswVersion (
        set tvswhere=!tvswhere!\!vswVersion!
    )
)

call :dbgprint "tvswhere: " tvswhere

if "!vswVersion!"=="latest" (
    set vswpkg=vswhere
) else (
    set vswpkg=vswhere/!vswVersion!
)

set _gntC=/p:ngpackages="!vswpkg!:vswhere" /p:ngpath="!tvswhere!"
call :dbgprint "GetNuTool call: " _gntC

setlocal
set __p_call=1

    if defined hMSBuildDebug (
        call :gntpoint !_gntC!
    ) else (
        call :gntpoint !_gntC! >nul
    )

endlocal

set "%1=!tvswhere!\vswhere\tools\vswhere"
set "%2=!tvswhere!"
exit /B 0
:: :vswhereRemote

:vswhereBin {in:vswbin} {out:toolset} {optin:vswcache}
:: 1{vswbin}    - Full path to vswhere tool; 
:: 2{toolset}   - Returns found toolset;
:: 3{vswcache}  - (Optional) To manage the cache if used;

set "vswbin=!%1!"
set "vswcache=!%3!"

call :batOrExe vswbin vswbin
if not defined vswbin (
    call :dbgprint "vswhere tool does not exist"
    set "%2=" & exit /B %ERROR_FAILED%
)
call :dbgprint "vswbin: " vswbin

set "vswPreRel="
set "msbf="

rem :: https://github.com/3F/hMSBuild/issues/8
set vswfilter=!vswPriority!

:_vswAttempt
call :dbgprint "attempts with filter: " vswfilter vswPreRel

set "vspath=" & set "vsver="
for /F "usebackq tokens=1* delims=: " %%a in (`"!vswbin!" -nologo !vswPreRel! -requires !vswfilter! Microsoft.Component.MSBuild`) do (
    if /I "%%~a"=="installationPath" set vspath=%%~b
    if /I "%%~a"=="installationVersion" set vsver=%%~b

    if defined vspath if defined vsver (
        call :vswmsb vspath vsver msbf
        if defined msbf goto _vswbinReturn

        set "vspath=" & set "vsver="
    )
)

if not defined kStable if not defined vswPreRel (
    set vswPreRel=-prerelease
    goto _vswAttempt
)

if defined vswfilter (
    set _msgPrio=Tools was not found for: !vswfilter!

    if defined kForce (
        call :dbgprint "Ignored via -force. !_msgPrio!"
        set "msbf=" & goto _vswbinReturn
    )
    
    call :warn "!_msgPrio!"
    set "vswfilter=" & set "vswPreRel="
    goto _vswAttempt
)


:_vswbinReturn

if defined vswcache if defined nocachevswhere (
    call :dbgprint "reset vswhere " vswcache
    rmdir /S/Q "!vswcache!"
)

set %2=!msbf!
exit /B 0
:: :vswhereBin

:vswmsb {in:vspath} {in:vsver} {out:msbfile}
:: 1{vspath}   - installationPath
:: 2{in:vsver} - installationVersion
:: 3{msbfile}  - Returns full path to msbuild file.

set vspath=!%1!
set vsver=!%2!

call :dbgprint "vspath: " vspath
call :dbgprint "vsver: " vsver

if not defined vsver (
    call :dbgprint "nothing to see via vswhere"
    set "%3=" & exit /B %ERROR_PATH_NOT_FOUND%
)

for /F "tokens=1,2 delims=." %%a in ("!vsver!") do (
    rem https://github.com/3F/hMSBuild/issues/3
    set vsver=%%~a.0
)
REM VS2019 changed path
if !vsver! geq 16 set vsver=Current

if not exist "!vspath!\MSBuild\!vsver!\Bin" set "%3=" & exit /B %ERROR_PATH_NOT_FOUND%

set _msbp=!vspath!\MSBuild\!vsver!\Bin

call :dbgprint "found path via vswhere: " _msbp

if exist "!_msbp!\amd64" (
    call :dbgprint "found /amd64"
    set _msbp=!_msbp!\amd64
)
call :msbfound _msbp _msbp

set %3=!_msbp!
exit /B 0
:: :vswmsb

:: - - -
:: Tools from Visual Studio - 2015, 2013, ...
:msbvsold  {out:toolset}
call :dbgprint "Searching from Visual Studio - 2015, 2013, ..."

for %%v in (14.0, 12.0) do (
    call :rtools %%v Y & if defined Y ( 
        set %1=!Y!
        exit /B 0 
    )
)
call :dbgprint "-vs: not found"
set "%1="
exit /B 0
:: :msbvsold

:: - - -
:: Tools from .NET Framework - .net 4.0, ...
:msbnetf {out:toolset}
call :dbgprint "Searching from .NET Framework - .NET 4.0, ..."

for %%v in (4.0, 3.5, 2.0) do (
    call :rtools %%v Y & if defined Y ( 
        set %1=!Y!
        exit /B 0 
    )
)

call :dbgprint "-netfx: not found"
set "%1="
exit /B 0
:: :msbnetf

:rtools {in:version} {out:found}
call :dbgprint "check %1"
    
for /F "usebackq tokens=2* skip=2" %%a in (
    `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\%1" /v MSBuildToolsPath 2^> nul`
) do if exist %%b (
    
    set _msbp=%%~b
    call :dbgprint ":msbfound " _msbp

    call :msbfound _msbp _msbf

    set %2=!_msbf!
    exit /B 0
)

set "%2="
exit /B 0
:: :rtools

:msbfound {in:path} {out:fullpath}

set _msbp=!%~1!\MSBuild.exe

set %2=!_msbp!

if not defined notamd64 (
    rem :: it may be x32 or x64, but this does not matter
    exit /B 0
)

:: -notamd64 checks

:: 7z & amd64\msbuild - https://github.com/3F/vsSolutionBuildEvent/issues/38
set _noamd=!_msbp:Framework64=Framework!
set _noamd=!_noamd:\amd64=!

if exist "!_noamd!" (
    call :dbgprint "Return 32bit version because of -notamd64 key."
    set %2=!_noamd!
    exit /B 0
)

if defined kForce (
    call :dbgprint "Ignored via -force. Only 64bit version was found for -notamd64"
    set "%2=" & exit /B 0
)

call :warn "Return 64bit version. Found only this."
exit /B 0
:: :msbfound

:batOrExe {in:fname} {out:fullname}
:: 1 - Variable with path to file without extension; 
:: 2 - Returns found file (.bat/.exe) or empty.

call :dbgprint "bat/exe: " %1

if exist "!%1!.bat" set %2="!%1!.bat" & exit /B 0
if exist "!%1!.exe" set %2="!%1!.exe" & exit /B 0

set "%2="
exit /B 0
:: :batOrExe

:obsolete {in:old} {in:new} [{in:new2}]
call :warn "'%~1' is obsolete. Use alternative: %~2 %~3"
exit /B 0
:: :obsolete

:warn {in:msg}
echo   [*] WARN: %~1
exit /B 0

:dbgprint {in:str} [{in:uneval1}, [{in:uneval2}]]
if defined hMSBuildDebug (
    set msgfmt=%1
    set msgfmt=!msgfmt:~0,-1! 
    set msgfmt=!msgfmt:~1!
    echo.[%TIME% ] !msgfmt! !%2! !%3!
)
exit /B 0
:: :dbgprint

:initargs {in:vname} {in:arguments} {out:index}
:: Usage: 1- the name for variable; 2- input arguments; 3- max index

set _ieqargs=!%2!

:: unfortunately, we also need to protect the equal sign '='
:_eqp
for /F "tokens=1* delims==" %%a in ("!_ieqargs!") do (
    if "%%~b"=="" (
        call :nqa %1 !_ieqargs! %3
        exit /B 0
    )
    set _ieqargs=%%a #__b_EQ## %%b
)
goto _eqp
:nqa

set "vname=%~1"
set /a idx=-1

:_initargs
:: - 
set /a idx+=1
set %vname%[!idx!]=%~2
set %vname%{!idx!}=%2

:: - 
shift & if not "%~3"=="" goto _initargs
set /a idx-=1

set %1=!idx!
exit /B 0
:: :initargs

:eval {in:unevaluated} {out:evaluated}
:: Usage: 1- input; 2- evaluated output

:: delayed evaluation
set _vl=!%1!

:: data from %..% below should not contain double quotes, thus we need to protect this:
set "_vl=%_vl: #__b_CRT## =^%"
set "_vl=%_vl: #__b_ECL## =^!%"
set _vl=!_vl: #__b_EQ## ==!

set %2=!_vl!

exit /B 0
:: :eval

:gntpoint
setlocal disableDelayedExpansion 

:: ========================= GetNuTool =========================

