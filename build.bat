@echo off

setlocal
    cd GetNuTool
    call build || goto err
endlocal

copy /Y/B frontend.bat+"GetNuTool\bin\Release\raw\versions\01. executable\gnt.bat" bin\hMSBuild.bat || goto err

exit /B 0

:err

echo. Build failed. 1>&2
exit /B 1

