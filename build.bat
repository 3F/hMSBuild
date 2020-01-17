@echo off

if not exist GetNuTool/gnt.sln (
    git submodule update --init --recursive GetNuTool || goto err
)

setlocal
    cd GetNuTool
    call build PublicRelease || goto err
endlocal

call GetNuTool\packages\vsSolutionBuildEvent\cim.cmd "hMSBuild.sln" /v:m /m:4 || goto err

:: call tests || goto err

exit /B 0

:err

echo. Build failed. 1>&2
exit /B 1

