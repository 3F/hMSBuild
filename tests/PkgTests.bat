::! Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) hMSBuild contributors https://github.com/3F/hMSBuild/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/hMSBuild
@echo off

setlocal enableDelayedExpansion

call a isNotEmptyOrWhitespaceOrFail %~1 || exit /B1

set /a gcount=!%~1! & set /a failedTotal=!%~2!
set "exec=%~3" & set "wdir=%~4"

:::::::::::::::::: :::::::::::::: :::::::::::::::::::::::::
:: Tests

    if exist "%hmsLocalServer%" ( set hmsServer=/p:ngserver="%hmsLocalServer%" ) else set "hmsServer="

    set "hMSBuildCurrent=hMSBuild.%appversionHms%"

    :: check if the package is not published yet /F-156
        set "packageHMSBuildIsNotReady="
        call a execute "%wdir%%exec% -GetNuTool ~hMSBuild/%appversionHms%" 2>nul>nul || set "packageHMSBuildIsNotReady=true"
        if defined packageHMSBuildIsNotReady echo Warning: Remote package is not ready. Some tests will be disabled.

    :: NOTE: :startTest will use ` as "
    :: It helps to use double quotes inside double quotes " ... `args` ... "

:::::::::::::::::
    call :cleanup


    ::_______ ------ ______________________________________

        if not defined packageHMSBuildIsNotReady (

            call a unsetPackage %hMSBuildCurrent%
            call a checkFsNo %hMSBuildCurrent%.html || goto x
            call a checkFsNo hMSBuild.bat || goto x
            call a checkFsNo "packages\%hMSBuildCurrent%\hMSBuild.bat" || goto x

            call a startTest "-GetNuTool ~hMSBuild/%appversionHms%" || goto x
                call a findInStreamOrFail "hMSBuild/%appversionHms% ... "
                call a checkFsNo %hMSBuildCurrent%.html || goto x
                call a checkFs hMSBuild.bat || goto x
                call a checkFsNo "packages\%hMSBuildCurrent%\hMSBuild.bat" || goto x
            call a completeTest
        )
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        if not defined packageHMSBuildIsNotReady (
            call a unsetFile hMSBuild.bat

            call a startTest "-GetNuTool +hMSBuild/%appversionHms%" || goto x
                call a findInStreamOrFail "hMSBuild/%appversionHms% ... "
                call a checkFs %hMSBuildCurrent%.html || goto x
                call a checkFs hMSBuild.bat || goto x
                call a checkFs "packages\%hMSBuildCurrent%\hMSBuild.bat" || goto x
                call a checkFs "packages\%hMSBuildCurrent%\hMSBuild.full.bat" || goto x
            call a completeTest
        )
    ::_____________________________________________________


    ::_______ ------ ______________________________________

        call a unsetFile hMSBuild.bat

        call a startTest "-GetNuTool ~hMSBuild/%appversionHms% %hmsServer%" || goto x
            call a checkFs hMSBuild.bat || goto x
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
    call a unsetFile %hMSBuildCurrent%.html
    call a unsetFile hMSBuild.bat
    call a unsetPackage %hMSBuildCurrent%
    call a unsetDir packages
exit /B 0