@echo off

if not exist GetNuTool/gnt.sln (
    git submodule update --init GetNuTool || goto err
)

setlocal
    cd GetNuTool & if [%~1]==[#] build #
    call build PublicRelease || goto err
endlocal

call GetNuTool\packages\vsSolutionBuildEvent\cim.cmd /v:m /m:7 || goto err

:: call tests || goto err

exit /B 0

:err
echo Failed >&2
exit /B 1
