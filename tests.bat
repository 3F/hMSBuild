::! Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) hMSBuild contributors https://github.com/3F/hMSBuild/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/hMSBuild
@echo off

:: run tests by default

setlocal
    if exist "hMSBuild.full.bat" (

        set "rdir=..\"
        set "tgntPath=GetNuTool\"

    ) else if exist "bin\Release\raw\" (

        set "rdir=..\bin\Release\raw\"
        set "tgntPath=..\GetNuTool\tests\"

    ) else goto buildError

    cd tests
    call _run %rdir% hMSBuild.bat hMSBuild.full.bat %tgntPath%
endlocal
exit /B 0

:buildError
    echo. Tests cannot be started: Check your build first. >&2
exit /B 1