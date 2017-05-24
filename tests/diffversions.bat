@echo off
:: Tests. Part of https://github.com/3F/hMSBuild
setlocal enableDelayedExpansion

set core=%1
set dir=%2

set core=%core:"=%
set dir=%dir:"=%

set core="%core%"
set light="%dir%hMSBuild_light.bat"
set minified="%dir%hMSBuild_minified.bat"

set /a gcount=0
set /a failedTotal=0

:: =========== Tests ====================

call :execAll "-only-path"
call :execAll "-only-path -novswhere"
call :execAll "-only-path -novs"
call :execAll "-only-path -nonet"
call :execAll "-only-path -vswhere-version local"
call :execAll "-only-path -vswhere-version 1.0.50"
call :execAll "-only-path -vswhere-version latest"
call :execAll "-only-path -nocachevswhere"
call :execAll "-only-path -notamd64"
call :execAll "-only-path -eng"

call :execAll "-GetNuTool -unpack"

call :execAll "-only-path -vswhere-version local -nocachevswhere"
call :execAll "-only-path -vswhere-version 1.0.50 -nocachevswhere"
call :execAll "-only-path -vswhere-version latest -nocachevswhere"

call :execAll "-novswhere -novs -only-path"
call :execAll "-novswhere -nonet -only-path"
call :execAll "-novswhere -novs -notamd64 -only-path"
call :execAll "-novswhere -nonet -notamd64 -only-path"
call :execAll "-nonet -notamd64 -only-path"
call :execAll "-novs -notamd64 -only-path"
call :execAll "-notamd64 -vswhere-version local -only-path"
call :execAll "-notamd64 -vswhere-version 1.0.50 -only-path"
call :execAll "-notamd64 -vswhere-version latest -only-path"
call :execAll "-novswhere -novs -nonet -only-path"

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
set cmd=%1
set cmd=%cmd:~1,-1%
set /a "gcount+=1"
echo.
echo -----
echo Test%gcount%: %cmd%
echo -----
call :execAB core light cmd & if not "!ERRORLEVEL!"=="0" goto eqFailed
call :execAB core minified cmd & if not "!ERRORLEVEL!"=="0" goto eqFailed
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