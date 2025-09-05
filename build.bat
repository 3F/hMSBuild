::! Copyright (c) 2017  Denis Kuzmin <x-3F@outlook.com> github/3F
::! Copyright (c) hMSBuild contributors https://github.com/3F/hMSBuild/graphs/contributors
::! Licensed under the MIT License (MIT).
::! See accompanying License.txt file or visit https://github.com/3F/hMSBuild
@echo off

if not exist GetNuTool/..sln (
    git submodule update --init GetNuTool || goto err
)

set "reltype=%~1" & if not defined reltype set reltype=Release
setlocal
    cd GetNuTool & if [%~1]==[#] build #
    call build Release || goto err
endlocal

call GetNuTool\packages\vsSolutionBuildEvent\cim.cmd ~x ~c %reltype% || goto err

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