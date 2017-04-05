@echo off

echo Checking submodules ...

set _dep=%1

if "%_dep%"=="" (
    echo Incorrect command.
    exit /B 0
)


if not exist "%_dep%" goto restore
exit /B 0

:restore

echo.
echo. Whoops, you need to update git submodules.
echo. But we'll update this automatically.
echo.
echo. Please wait...
echo.

git submodule update --init --recursive 2>nul || goto gitNotFound

exit /B 0

:gitNotFound

echo.  1>&2
echo. `git` was not found or something went wrong. Check your connection and env. variable `PATH`. Or get submodules manually: 1>&2
echo.     1. Use command `git submodule update --init --recursive` 1>&2
echo.     2. Or clone initially with recursive option: `git clone --recursive ...` 1>&2
echo.  1>&2

exit /B 2