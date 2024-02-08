@echo off
:: Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Tests. Part of https://github.com/3F/hMSBuild

setlocal enableDelayedExpansion
call a isStrNotEmptyOrWhitespaceOrFail %~1 || exit /B1

set /a gcount=!%~1! & set /a failedTotal=!%~2!
set "exec=%~3" & set "wdir=%~4"

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path" || goto x
            call a msgOrFailAt 1 "try vswhere..." || goto x
            call a msgOrFailAt 2 "bat/exe:" || goto x
            call a findInStreamOrFail "vswbin:" 3 || goto x

            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-products * -latest" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-as `-latest -products *`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-latest -products *" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-as `-version [15.0,16.0 -products * -latest`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-version [15.0,16.0 -products * -latest" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-as `-products * -latest -requiresAny -version [15.0,16.0 -requires Microsoft.NetCore.Component.SDK`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-products * -latest -requiresAny -version [15.0,16.0 -requires Microsoft.NetCore.Component.SDK" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-as `-products * -latest -requiresAny -version 16.0 -requires Microsoft.Component.MSBuild`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-products * -latest -requiresAny -version 16.0 -requires Microsoft.Component.MSBuild" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-as `-products * -latest -requiresAny -version [15.0,16.0 -requires Microsoft.Component.MSBuild Microsoft.NetCore.Component.SDK`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-products * -latest -requiresAny -version [15.0,16.0 -requires Microsoft.Component.MSBuild Microsoft.NetCore.Component.SDK" || goto x

            call a findInStreamOrFail "attempts with filter: ;" 5 || goto x
        call a completeTest
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a startTest "-debug -only-path -vsw-priority `NoComponent.SDK0`" || goto x
            call a findInStreamOrFail "assign command:" 4,n || goto x
            call a msgOrFailAt !n! "-products * -latest" || goto x

            call a findInStreamOrFail "attempts with filter: NoComponent.SDK0;" 5 || goto x
            call a findInStreamOrFail "attempts with filter: NoComponent.SDK0; `-prerelease`" 6 || goto x
            call a findInStreamOrFail "WARN: Tools was not found for: NoComponent.SDK0" 7 || goto x
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
