@echo off

:: tests by default
setlocal
    cd tests
    call _run "..\\bin\\Release\\raw\\hMSBuild.bat" "..\\bin\\Release\\raw\\"
endlocal