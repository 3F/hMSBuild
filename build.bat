@echo off

set cimdll=GetNuTool\packages\vsSBE.CI.MSBuild\bin\CI.MSBuild.dll
set netmsb=GetNuTool\netmsb

call submodules "GetNuTool/gnt.sln" || goto err

setlocal
    cd GetNuTool
    call build || goto err
endlocal

call %netmsb% "hMSBuild.sln" /l:"%cimdll%" /v:m /m:4 || goto err

exit /B 0

:err

echo. Build failed. 1>&2
exit /B 1

