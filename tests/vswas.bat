@echo off
:: Tests. Part of https://github.com/3F/hMSBuild
setlocal enableDelayedExpansion

set core=%~1 & set wdir=%~2

set core="%core%"
set vswhelper="%wdir%vswhere.bat"
set vswlog="%wdir%vswas.log"

set /a gcount=0
set /a failedTotal=0

echo echo %%*^> %vswlog% > %vswhelper%

:: =========== Tests ====================

set "base=-nologo -prerelease -requires  Microsoft.Component.MSBuild"
call :Vrfy base "-products *" "-only-path"

call :Vrfy base "-products * -latest" "-only-path"

call :Vrfy base "-latest -products *" "-only-path"

call :Vrfy base "-version [15.0,16.0) -products * -latest" "-only-path"

call :Vrfy base "-products * -latest -requiresAny -version [15.0,16.0) -requires Microsoft.NetCore.Component.SDK" "-only-path"

call :Vrfy base "-products * -latest -requiresAny -version 16.0 -requires Microsoft.Component.MSBuild" "-only-path"

call :Vrfy base "-products * -latest -requiresAny -version [15.0,16.0) -requires Microsoft.Component.MSBuild Microsoft.NetCore.Component.SDK" "-only-path"


:: =========== /Tests ====================

del /Q/F %vswhelper%
del /Q/F %vswlog%


echo.
echo =================
echo [Failed] = !failedTotal!
set /a "gcount-=failedTotal"
echo [Passed] = !gcount!
echo =================
echo.
if "!failedTotal!"=="0" exit /B 0
exit /B 1

:: ============

:Vrfy
:: (1) - Expected base line
:: (2) - `vsw-as` keys
:: [3] - left args before vsw-as keys
:: [4] - right args before vsw-as keys
set __base=!%~1! & set vswas=%~2 & set left=%~3 & set right=%~4

set cmd=%left% -vsw-as "%vswas%" %right%

set /a "gcount+=1"
echo.
echo -----
echo Test%gcount%: %cmd%
echo -----

call %core% %cmd%
for /f "usebackq tokens=*" %%a in (`type %vswlog%`) do set "actual=%%a"
set "expected=%__base%%vswas%"

echo "%expected%" == "%actual%"

call :isEqFailed expected actual
if not "!ERRORLEVEL!"=="0" (
    REM echo core: %core%
    goto eqFailed
)

echo [Passed]
exit /B 0

:eqFailed
set /a "failedTotal+=1"
exit /B 1

:exec
set app=!%1!
set _cmd=!%2!

echo `%app% %_cmd%`
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