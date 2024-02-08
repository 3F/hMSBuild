@echo off
:: Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion

:: path to core
set core=%1

:: path to the directory where the release is located
set rdir=%2

:: path to other compiled version
set appB=%~3

call a isNotEmptyOrWhitespaceOrFail core || exit /B1
call a isNotEmptyOrWhitespaceOrFail rdir || exit /B1
call a isNotEmptyOrWhitespaceOrFail appB || exit /B1

echo.
echo ------------
echo Testing
echo -------
echo.

set /a gcount=0 & set /a failedTotal=0

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    echo. & call a print "Tests - 'VswasTests'"
    call .\VswasTests gcount failedTotal %core% %rdir%

    echo. & call a print "Tests - 'DiffVTests'"
    call .\DiffVTests gcount failedTotal %core% %rdir% dbg2.3.0+204d1a0b
    call .\DiffVTests gcount failedTotal %core% %rdir% %appB%

::::::::::::::::::
::
echo.
echo ################
echo  [Failed] = !failedTotal!
set /a "gcount-=failedTotal"
echo  [Passed] = !gcount!
echo ################
echo.

if !failedTotal! GTR 0 goto failed
echo.
call a print "All Passed."
exit /B 0

:failed
    echo.
    echo. Tests failed. >&2
exit /B 1
