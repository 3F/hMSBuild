@echo off

if not exist GetNuTool/gnt.sln (
    git submodule update --init GetNuTool || goto err
)

setlocal
    cd GetNuTool & if [%~1]==[#] build #
    call build PublicRelease || goto err
endlocal

call GetNuTool\packages\vsSolutionBuildEvent\cim.cmd ~x || goto err

setlocal enableDelayedExpansion
    cd tests
    call a initAppVersion Hms
    call a execute "..\bin\Release\hMSBuild -h" & call a msgOrFailAt 1 "hMSBuild %appversionHms%" || goto err
    call a printMsgAt 1 3F "Completed as a "
endlocal
exit /B 0

:err
    echo Failed build>&2
exit /B 1