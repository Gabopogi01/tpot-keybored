@echo off
set "ARG=%~1"
set "SILENT=false"

set "FLAGS=%*"
if defined FLAGS set "FLAGS=%FLAGS:* =%"
if "%FLAGS%"=="%~1" set "FLAGS="

set "THING=flixel haxeui-flixel haxeui-core hxWindowColorMode haxeui-theme-kenney hxcpp"

if "%ARG%" == ""          goto :help
if "%ARG%" == "--build"     goto :build
if "%ARG%" == "--buildtest" goto :buildtest
if "%ARG%" == "--dllib"     goto :dllib

:help
echo ARG is null!
echo %~nx0 [ARG] [FLAG, OPTIONAL, MULTIPLE]
echo.
echo arg list:
echo --build
echo --buildtest
echo --dllib
echo    -q --quiet dont use persent, useful for workflow
exit /b

:build
echo !!SIGNAL BUILD
if "%FLAGS%" == "" (
    echo lime test windows%FLAGS%
    call haxelib run lime build windows
) else (
    echo lime test windows %FLAGS%
    call haxelib run lime build windows %FLAGS%
)
exit /b

:buildtest
echo !!SIGNAL BUILD TEST
if "%FLAGS%" == "" (
    call lime test windows
) else (
    echo lime test windows %FLAGS%
    call lime test windows %FLAGS%
)
exit /b

:dllib

if "%FLAGS%"=="-q" set "SILENT=true"
if "%FLAGS%"=="--quiet" set "SILENT=true"

echo !!SIGNAL DOWNLOAD LIB
if "%SILENT%"=="false" (
    for %%i in (%THING%) do (
        haxelib install %%i
    )
) else (
    for %%i in (%THING%) do (
        haxelib --quiet install %%i
    )
)
echo.
echo done, use %~nx0 --build or --buildtest!
exit /b
