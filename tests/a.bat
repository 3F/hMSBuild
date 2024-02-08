@echo off
:: Copyright (c) 2015  Denis Kuzmin <x-3F@outlook.com> github/3F
:: Part of https://github.com/3F/GetNuTool

if "%~1"=="" echo Empty function name & exit /B 1
call :%~1 %2 %3 %4 %5 %6 %7 %8 %9 & exit /B !ERRORLEVEL!

:initAppVersion
    for /F "tokens=*" %%i in (..\.version) do set appversion=%%i
exit /B 0

:invoke
    ::  (1) - Command.
    ::  (2) - Input arguments inside "..." via variable.
    :: &[3] - Return code.
    :: !!0+ - Error code from (1)

    set "cmd=%~1 !%2!"

    :: NOTE: Use delayed !cmd! instead of %cmd% inside `for /F` due to
    :: `=` (equal sign, which cannot be escaped as `^=` when runtime evaluation %cmd%)

    set "cmd=!cmd! 2^>^&1 ^&call echo %%^^ERRORLEVEL%%"
    set /a msgIdx=0

    for /F "tokens=*" %%i in ('!cmd!') do 2>nul (
        set /a msgIdx+=1
        set msg[!msgIdx!]=%%i
    )

    if not "%3"=="" set %3=!msg[%msgIdx%]!
exit /B !msg[%msgIdx%]!

:execute
    ::  (1) - Command.
    :: !!0+ - Error code from (1)

    call :invoke "%~1" nul retcode
exit /B !retcode!

:startExTest
    ::  (1) - Logic via :label name
    ::  (2) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  [3] - Expected return code. Default, 0.
    :: !!1  - Error code 1 if app's error code is not equal [2] as expected.

    set "tArgs=%~2"
    if "%~3"=="" ( set /a exCode=0 ) else set /a exCode=%~3

    if "!tArgs!" NEQ "" set tArgs=!tArgs:`="!

    set /a gcount+=1
    echo.
    echo - - - - - - - - - - - -
    echo Test #%gcount% @ %TIME%
    echo - - - - - - - - - - - -
    echo keys: !tArgs!
    echo.

    set callback=%~1 & shift

    goto %callback%
    :_logicExTestEnd

    if "!retcode!" NEQ "%exCode%" call :failTest & exit /B 1
exit /B 0

:startTest
    ::  (1) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  [2] - Expected return code. Default, 0.
    :: !!1  - Error code 1 if app's error code is not equal [2] as expected.

    call :startExTest _logicStartTest %*
    exit /B
    :_logicStartTest
        call :invoke "%wdir%%exec%" tArgs retcode

goto _logicExTestEnd
:: :startTest

:startABTest
    ::   (1) - Input arguments inside "...". Use ` sign to apply " double quotes inside "...".
    ::   (2) - A command
    ::   (3) - B command
    ::  &(4) - Result from (2) A
    ::  &(5) - Result from (3) B

    set "exA=%2" & set "exB=%3"
    set "_4=%4"
    set "_5=%5"

    call :startExTest _logicStartABTest %*
    exit /B
    :_logicStartABTest
        call :invoke !exA! tArgs retcodeA & call :getMsgAt 1 outA
        call :invoke !exB! tArgs retcodeB & call :getMsgAt 1 outB

        set %_4%=!outA! !retcodeA!
        set %_5%=!outB! !retcodeB!
        set /a retcode=0

goto _logicExTestEnd
:: :startABTest

:startVFTest
    ::  (1) - Input core application.
    ::  (2) - Input arguments to core inside "...". Use ` sign to apply " double quotes inside "...".
    ::  (3) - Full path to actual data in the file system.
    :: &(4) - Return actual data.

    set _exapp="%~1"
    set _lwrap="%~3"
    set "_4=%4"

    call :startExTest _logicStartVFTest %2
    exit /B
    :_logicStartVFTest
        call :invoke %_exapp% tArgs retcode
        for /f "usebackq tokens=*" %%i in (`type %_lwrap%`) do set "%_4%=%%i"

goto _logicExTestEnd
:: :startVFTest

:completeTest
    echo [Passed]
exit /B 0

:failTest
    set /a "failedTotal+=1"
    call :printStream failed
exit /B 0

:printStream
    for /L %%i in (0,1,!msgIdx!) do echo (%%i) *%~1: !msg[%%i]!
exit /B 0

:contains
    ::  (1) - input string via variable
    ::  (2) - substring to check
    :: &(3) - result, 1 if found.

    set "input=!%~1!"

    if "%~2"=="" if "!input!"=="" set /a %3=1 & exit /B 0
    if "!input!"=="" if not "%~2"=="" set /a %3=0 & exit /B 0

    set "cmp=!input:%~2=!"

    if .!cmp! NEQ .!input! ( set /a %3=1 ) else set /a %3=0
exit /B 0

:getMsgAt
    ::  (1) - index at msg
    :: &(2) - result string
    :: !!1  - Error code 1 if &(1) is empty or not valid.

    if "%~1"=="" exit /B 1
    if %msgIdx% LSS %~1 exit /B 1
    if %~1 LSS 0 exit /B 1

    set %2=!msg[%~1]!
exit /B 0

:msgAt
    ::  (1) - index at msg
    ::  (2) - substring to check
    :: &(3) - result, 1 if found.

    set /a %3=0
    call :getMsgAt %~1 _msgstr || exit /B 0

    call :contains _msgstr "%~2" n & set /a %3=!n!
exit /B 0

:msgOrFailAt
    ::  (1) - index at msg
    ::  (2) - substring to check
    :: !!1  - Error code 1 if the message is not found at the specified index.

    call :msgAt %~1 "%~2" n & if .!n! NEQ .1 call :failTest & exit /B 1
exit /B 0

:checkFs
    ::  (1) - Path to directory that must be available.
    ::  (2) - Path to the file that must exist.
    :: !!1  - Error code 1 if the directory or file does not exist.

    if not exist "%~1" call :failTest & exit /B 1
    if not exist "%~1\%~2" call :failTest & exit /B 1
exit /B 0

:checkFsBase
    ::  (1) - Path to directory that must be available.
    ::  (2) - Path to the file that must exist.
    :: !!1  - Error code 1 if the directory or file does not exist.

    call :checkFs "%basePkgDir%%~1" "%~2" || exit /B 1
exit /B 0

:checkFsNo
    ::  (1) - Path to the file or directory that must NOT exist.
    :: !!1  - Error code 1 if the specified path exists.

    if exist "%~1" call :failTest & exit /B 1
exit /B 0

:checkFsBaseNo
    ::  (1) - Path to the file or directory that must NOT exist.
    :: !!1  - Error code 1 if the specified path exists.

    call :checkFsNo "%basePkgDir%%~1" || exit /B 1
exit /B 0

:unsetDir
    :: (1) - Path to directory.
    rmdir /S/Q "%~1" 2>nul
exit /B 0

:unsetPackage
    :: (1) - Package directory.
    call :unsetDir "%basePkgDir%%~1"
exit /B 0

:unsetFile
    :: (1) - File name.
    del /Q "%~1" 2>nul
exit /B 0

:unsetNupkg
    :: (1) - Nupkg file name.
    call :unsetFile "%~1"
exit /B 0

:checkFsNupkg
    ::  (1) - Nupkg file name.
    :: !!1  - Error code 1 if the input (1) does not exist.

    if not exist "%~1" call :failTest & exit /B 1
exit /B 0

:findInStream
    ::  (1) - substring to check
    :: &(2) - result, 1 if found.

    for /L %%i in (0,1,!msgIdx!) do (
        call :msgAt %%i "%~1" n & if .!n! EQU .1 (
            set /a %2=1
            exit /B 0
        )
    )
    set /a %2=0
exit /B 0

:failIfInStream
    ::  (1) - substring to check
    :: !!1  - Error code 1 if the input (1) was not found.

    call :findInStream "%~1" n & if .!n! EQU .1 call :failTest & exit /B 1
exit /B 0

:print
    :: (1) - Input string.

    echo.[ %TIME% ] %~1
exit /B 0

:isNotEmptyOrWhitespace
    :: &(1) - Input variable.
    :: !!1  - Error code 1 if &(1) is empty or contains only whitespace characters.

    set "_v=!%~1!"
    if not defined _v exit /B 1

    set _v=%_v: =%
    if not defined _v exit /B 1

    :: e.g. set a="" not set "a="
exit /B 0

:sha1At0
    ::  (1) - Stream index.
    :: &(2) - sha1 result.
    set %2=!msg[%~1]:~4,40!
exit /B 0

:sha1At
    ::  (1) - Stream index.
    :: &(2) - sha1 result.
    set %2=!msg[%~1]:~45,40!
exit /B 0

:errargs
    echo.
    echo. Incorrect arguments to start tests. >&2
exit /B 1

:isNotEmptyOrWhitespaceOrFail
    :: &(1) - Input variable.
    :: !!1  - Error code 1 if &(1) is empty or contains only whitespace characters.
    call :isNotEmptyOrWhitespace %* || (call :errargs & exit /B 1)
exit /B 0