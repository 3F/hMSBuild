@echo off

:: run tests by default

setlocal
    if exist "hMSBuild.full.bat" (

        set "rdir=..\"

    ) else if exist "bin\Release\raw\" (

        set "rdir=..\bin\Release\raw\"

    ) else goto buildError

    cd tests
    call _run %rdir% "hMSBuild.bat" "hMSBuild.full.bat"
endlocal
exit /B 0

:buildError
    echo. Tests cannot be started: Check your build first. >&2
exit /B 1