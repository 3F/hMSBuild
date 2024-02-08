@echo off
:: Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion
call a isStrNotEmptyOrWhitespaceOrFail %~1 || exit /B1

set /a gcount=!%~1! & set /a failedTotal=!%~2!
set "appA=%~3" & set "wdir=%~4" & set "appB=%~5"

set appA="%appA%" & set appB="%appB%"

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    call :execAB "-only-path"
    call :execAB "-only-path -no-vswhere"
    call :execAB "-only-path -no-vs"
    call :execAB "-only-path -no-netfx"
    call :execAB "-only-path -vsw-version local"
    call :execAB "-only-path -vsw-version 2.8.4"
    call :execAB "-only-path -vsw-version latest"
    call :execAB "-only-path -no-cache"
    call :execAB "-only-path -notamd64"
    call :execAB "-only-path -eng"

    call :execAB "-GetNuTool -unpack"

    call :execAB "-only-path -vsw-version local -no-cache"
    call :execAB "-only-path -vsw-version 2.8.4 -no-cache"
    call :execAB "-only-path -vsw-version latest -no-cache"

    call :execAB "-no-vswhere -no-vs -only-path"
    call :execAB "-no-vswhere -no-netfx -only-path"
    call :execAB "-no-vswhere -no-vs -notamd64 -only-path"
    call :execAB "-no-vswhere -no-netfx -notamd64 -only-path"
    call :execAB "-no-netfx -notamd64 -only-path"
    call :execAB "-no-vs -notamd64 -only-path"
    call :execAB "-notamd64 -vsw-version local -only-path"
    call :execAB "-notamd64 -vsw-version 2.8.4 -only-path"
    call :execAB "-notamd64 -vsw-version latest -only-path"
    call :execAB "-no-vswhere -no-vs -no-netfx -only-path"

:::::::::::::
call :cleanup

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::

endlocal & set /a %1=%gcount% & set /a %2=%failedTotal%
if !failedTotal! EQU 0 exit /B 0
exit /B 1

:cleanup
    call a unsetFile gnt.core
exit /B 0

:execAB
    call a startABTest "%~1" %appA% %appB% outA outB

        echo "%outA%"
        echo. ==
        echo "%outB%"

        if not "!outA!"=="!outB!" (
            echo [Failed]: ~

            echo A: %appA%
            echo B: %appB%

            call a failTest
            exit /B 1
        )

    call a completeTest
exit /B 0
