@echo off

:: run tests by default

setlocal
    cd tests
    
    if not exist "..\\bin\\Release\\raw\\" goto buildError
    
    :: (1) - path to core ;
    :: (2) - path to directory where release ; 
    :: (3) - path to compiled full version ;
    call _run "..\\bin\\Release\\raw\\hMSBuild.bat" "..\\bin\\Release\\raw\\" "..\\bin\\Release\\raw\\hMSBuild.full.bat"
endlocal

exit /B 0

:buildError
echo Tests cannot be started: Check your build first >&2
exit /B 1