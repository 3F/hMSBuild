@echo off
:: Tests. Part of https://github.com/3F/hMSBuild
setlocal enableDelayedExpansion

:: path to core
set core=%1

:: path to directory where release
set rdir=%2

:: path to compiled full version
set cfull=%~3

call :isEmptyOrWhitespace core _is & if [!_is!]==[1] goto errargs
call :isEmptyOrWhitespace rdir _is & if [!_is!]==[1] goto errargs
call :isEmptyOrWhitespace cfull _is & if [!_is!]==[1] goto errargs

echo.
echo ------------
echo Testing
echo -------
echo.

call :print "Tests - 'vswas'"
call .\vswas %core% %rdir% || goto err

call :print "Tests - 'diffversions'"
call .\diffversions %core% %rdir% %cfull% || goto err


echo.
call :print "All Passed."
exit /B 0


:err
echo.
echo. Tests failed. 1>&2
exit /B 1

:errargs
echo.
echo. Incorrect arguments to start tests. 1>&2
exit /B 1

:print
setlocal enableDelayedExpansion
set msgfmt=%1
set msgfmt=!msgfmt:~0,-1! 
set msgfmt=!msgfmt:~1!
echo.[%TIME% ] !msgfmt!
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