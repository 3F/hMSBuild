@echo off
:: dbg2.3.0+204d1a0b.bat


set arg=%*

:: 2.4+ -vsw-version renamed as -vwshere
set "arg=%arg: -vswhere= -vsw-version%"

.\dbg2.3.0+204d1a0b.bat %arg%