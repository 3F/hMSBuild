@echo off
:: Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion

:: path to the directory where the release is located
set "rdir=%~1"

:: path to core
set "core=%~2"

:: path to other compiled version
set "appB=%~3"

:: path to GetNuTool tests
set "tgnt=%~4"

call a isNotEmptyOrWhitespaceOrFail core || exit /B1
call a isNotEmptyOrWhitespaceOrFail rdir || exit /B1
call a isNotEmptyOrWhitespaceOrFail appB || exit /B1
call a isNotEmptyOrWhitespaceOrFail tgnt || exit /B1

call a initAppVersion Hms

echo.
call a cprint 0E  ----------------------
call a cprint F0  "hMSBuild .bat testing"
call a cprint 0E  ----------------------
echo.

if "!gcount!" LSS "1" set /a gcount=0
if "!failedTotal!" LSS "1" set /a failedTotal=0

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests


    echo. & call a print "Tests - 'VswasTests'"
    call .\VswasTests gcount failedTotal "%core%" "%rdir%"

    echo. & call a print "Tests - 'VswStreamTests'"
    call .\VswStreamTests gcount failedTotal "%core%" "%rdir%"

    echo. & call a print "Tests - 'DiffVTests'"
    call .\DiffVTests gcount failedTotal "%rdir%%core%" "%rdir%" dbg2.3.0+204d1a0b
    call .\DiffVTests gcount failedTotal "%rdir%%core%" "%rdir%" "%rdir%%appB%"

    echo. & call a print "Tests - 'DiffVswStreamTests'"
    call .\DiffVswStreamTests gcount failedTotal "%rdir%%core%" "%rdir%" "%rdir%%appB%"

    echo. & call a print "Tests - 'keysAndLogicTests'"
    call .\keysAndLogicTests gcount failedTotal "%core%" "%rdir%"

    call a disableAppVersion Gnt
    echo. & call a print "Tests - '-GetNuTool keysAndLogicTests'"
    call %tgnt%keysAndLogicTests gcount failedTotal "%rdir%%core% -GetNuTool " ""


::::::::::::::::::
::
echo.
call a cprint 0E ----------------
echo  [Failed] = !failedTotal!
set /a "gcount-=failedTotal"
echo  [Passed] = !gcount!
call a cprint 0E ----------------
echo.

if !failedTotal! GTR 0 goto failed
echo.
call a cprint 0A "All Passed."
exit /B 0

:failed
    echo.
    call a cprint 0C "Tests failed." >&2
exit /B 1
