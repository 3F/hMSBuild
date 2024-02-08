@echo off
:: Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion

call a isNotEmptyOrWhitespaceOrFail %~1 || exit /B1

set /a gcount=!%~1! & set /a failedTotal=!%~2!
set "exec=%~3" & set "wdir=%~4"

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    :: NOTE: :startTest will use ` as "
    :: It helps to use double quotes inside double quotes " ... `args` ... "

:::::::::::::::::
    call :cleanup

    ::_______ ------ ______________________________________

        call a startTest "-help" || goto x
            call a msgOrFailAt 0 "" || goto x

            if not defined appversionHms call a failTest "Empty *appversionHms" & goto x
            if not "%appversionHms%"=="off" (
                call a msgOrFailAt 1 "hMSBuild %appversionHms%" || goto x
            )
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-version" || goto x
            if not defined appversionHms call a failTest "Empty *appversionHms" & goto x
            if not "%appversionHms%"=="off" (
                call a msgOrFailAt 1 "%appversionHms%" || goto x
            )
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-?" || goto x
            call a msgOrFailAt 1 "hMSBuild %appversionHms%" || goto x
            call a msgOrFailAt 2 "github/3F" || goto x
        call a completeTest
    ::_____________________________________________________

:::::::::::::
call :cleanup

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
::
:x
endlocal & set /a %1=%gcount% & set /a %2=%failedTotal%
if !failedTotal! EQU 0 exit /B 0
exit /B 1

:cleanup

exit /B 0