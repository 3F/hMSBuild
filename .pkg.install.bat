::! Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) hMSBuild contributors https://github.com/3F/hMSBuild/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/hMSBuild
@echo off

:: Arguments: https://github.com/3F/GetNuTool?tab=readme-ov-file#touch--install--run
:: 1 tmode "path to the working directory" "path to the package"
if "%~1" LSS "1" echo Version "%~1" is not supported. 2>&1 & exit /B1

if not exist "%~dp0\hMSBuild.bat" exit /B1
set /p _version=<"%~dp0\.version"

if not defined use (
    call :copyAndRun "hMSBuild.bat" %~2

) else if "%use%"=="full" (
    call :copyAndRun "hMSBuild.full.bat" %~2

) else if "%use%"=="doc" (
    call :doc %~2

) else if "%use%"=="documentation" (
    call :doc %~2

) else if "%use%"=="-" (
    exit /B 0

) else (
    echo "%use%" is not supported 2>&1 & exit /B1
)

exit /B 0

:copyAndRun
    :: (1) app
    :: (2) tMode
    call :copy "%~dp0\%~1"
    if "%~2"=="install" (
        call :xcopy "%~dp0\doc\hMSBuild.%_version%.html"

    ) else if "%~2"=="run" (
        "%~dp0\doc\hMSBuild.%_version%.html"
    )
exit /B 0

:doc
    :: (1) tMode
    if "%~1"=="install" (
        call :xcopy "%~dp0\doc\hMSBuild.%_version%.html"

    ) else if "%~1"=="run" (
        "%~dp0\doc\hMSBuild.%_version%.html"

    ) else if "%~1"=="touch" (
        call :xcopy "%~dp0\doc\hMSBuild.%_version%.html"
        "%cd%\hMSBuild.%_version%.html"
    )
exit /B 0

:xcopy
    :: xcopy: including the readonly (/R) attr
    :: (1) input file
    :: [2] optional new name
    xcopy %1 "%cd%\%~2" /Y/R/V/I/Q 2>nul>nul || call :copy %1
exit /B 0

:copy
    :: copy: fail on the readonly attr
    :: (1) input file
    :: [2] optional new name
    copy /Y/V %1 "%cd%\%~2" 2>nul>nul || goto :error
exit /B 0

:error
exit /B 1