@echo off

set core=%1
set output=%2
set fMinified=hMSBuild_minified.bat
set fLight=hMSBuild_light.bat

set netmsb=GetNuTool\netmsb

call :isDef core isCore
if [%isCore%]==[0] set /P core=core=

call :isDef output isOutput
if [%isOutput%]==[0] set /P output=output path=

call :print "Compression is started ..."

call :print "core = '%core%'"
call :print "output = '%output%'"

call :print "Generate minified version ..."
call %netmsb% minified/.compressor /p:core="%core%" /p:output="%output%\%fMinified%" /nologo /v:m /m:4 || goto err

call :print "Generate light version ..."
call %netmsb% light/.compressor /p:core="%core%" /p:output="%output%\%fLight%" /nologo /v:m /m:4 || goto err

call :print "Done."
exit /B 0

:err

echo. Compression failed. 1>&2
exit /B 1

:isDef
setlocal enableDelayedExpansion
set "_v=!%1!"

if not defined _v endlocal & set /a %2=0 & exit /B 0
 
set _v=%_v: =%
set "_v= %_v%"
if [^%_v:~1,1%]==[] endlocal & set /a %2=0 & exit /B 0
 
endlocal & set /a %2=1
exit /B 0

:print
setlocal enableDelayedExpansion
set msgfmt=%1
set msgfmt=!msgfmt:~0,-1! 
set msgfmt=!msgfmt:~1!
echo.[%TIME% ] !msgfmt!
exit /B 0