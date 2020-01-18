@echo off
:: Tests. Part of https://github.com/3F/hMSBuild
setlocal enableDelayedExpansion

set core=%~1 & set wdir=%~2 & set cfull=%~3

set core="%core%"
set cfull="%cfull%"
:: set light="%wdir%hMSBuild_light.bat"
:: set minified="%wdir%hMSBuild.bat"

set /a gcount=0
set /a failedTotal=0

:: =========== Tests ====================

call :execAll "-only-path"
call :execAll "-only-path -no-vswhere"
call :execAll "-only-path -no-vs"
call :execAll "-only-path -no-netfx"
call :execAll "-only-path -vsw-version local"
call :execAll "-only-path -vsw-version 2.8.4"
call :execAll "-only-path -vsw-version latest"
call :execAll "-only-path -no-cache"
call :execAll "-only-path -notamd64"
call :execAll "-only-path -eng"

call :execAll "-GetNuTool -unpack"

call :execAll "-only-path -vsw-version local -no-cache"
call :execAll "-only-path -vsw-version 2.8.4 -no-cache"
call :execAll "-only-path -vsw-version latest -no-cache"

call :execAll "-no-vswhere -no-vs -only-path"
call :execAll "-no-vswhere -no-netfx -only-path"
call :execAll "-no-vswhere -no-vs -notamd64 -only-path"
call :execAll "-no-vswhere -no-netfx -notamd64 -only-path"
call :execAll "-no-netfx -notamd64 -only-path"
call :execAll "-no-vs -notamd64 -only-path"
call :execAll "-notamd64 -vsw-version local -only-path"
call :execAll "-notamd64 -vsw-version 2.8.4 -only-path"
call :execAll "-notamd64 -vsw-version latest -only-path"
call :execAll "-no-vswhere -no-vs -no-netfx -only-path"

echo.
echo =================
echo [Failed] = !failedTotal!
set /a "gcount-=failedTotal"
echo [Passed] = !gcount!
echo =================
echo.
if "!failedTotal!"=="0" exit /B 0
exit /B 1
:: ======================================

:execAll
set cmd=%~1
set /a "gcount+=1"
echo.
echo -----
echo Test%gcount%: %cmd%
echo -----
if defined cfull call :execAB core cfull cmd & if not "!ERRORLEVEL!"=="0" goto eqFailed
if defined light call :execAB core light cmd & if not "!ERRORLEVEL!"=="0" goto eqFailed
if defined minified call :execAB core minified cmd & if not "!ERRORLEVEL!"=="0" goto eqFailed
echo [Passed]
exit /B 0

:eqFailed
::echo [Failed]
set /a "failedTotal+=1"
exit /B 1

:execAB
set exA=!%1!
set exB=!%2!
set cmd=!%3!
call :exec exA cmd out1
call :exec exB cmd out2
echo "%out1%" == "%out2%"
call :isEqFailed out1 out2
if not "!ERRORLEVEL!"=="0" (
    echo exA: !exA!
    echo exB: !exB!
    exit /B 1
)
exit /B 0

:exec
set app=!%1!
set _cmd=!%2!
for /f "usebackq tokens=*" %%a in (`%app% %_cmd%`) do set res=%%a
set res=%res:"=%
set %3=%res%
exit /B 0

:isEqFailed
set left=!%1!
set right=!%2!
if not "%left%"=="%right%" (
    echo [Failed]: ~ 
    echo "%left%" 
    echo "%right%"
    echo.
    exit /B 1
)
exit /B 0

:print
set msgfmt=%1
set msgfmt=!msgfmt:~0,-1! 
set msgfmt=!msgfmt:~1!
echo.[%TIME% ] !msgfmt!
exit /B 0