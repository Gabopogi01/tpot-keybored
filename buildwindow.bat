@echo off
set "ARG=%~1"

shift
set "FLAGS="
:loop
if "%~1" == "" goto :continue
set "FLAGS=%FLAGS% %1"
shift
goto :loop
:continue

set "THING=flixel haxeui-flixel haxeui-core hxWindowColorMode haxeui-theme-kenney"

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
exit /b

:build
echo !!SIGNAL BUILD
if "%FLAGS%" == "" (
    call lime build windows
) else (
    call lime build windows%FLAGS%
)
exit /b

:buildtest
echo !!SIGNAL BUILD TEST
if "%FLAGS%" == "" (
    call lime test windows
) else (
    call lime test windows%FLAGS%
)
exit /b

:dllib
echo !!SIGNAL DOWNLOAD LIB
for %%i in (%THING%) do (
    haxelib install %%i
)
echo.
echo done, use %~nx0 --build or --buildtest!
exit /b
