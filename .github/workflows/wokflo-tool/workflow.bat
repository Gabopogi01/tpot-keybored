set "THING=flixel haxeui-flixel haxeui-core hxWindowColorMode haxeui-theme-kenney hxcpp"

echo !!SIGNAL DOWNLOAD LIB
echo !!THIS IS FOR WORKFLOW ONLY!!
for %%i in (%THING%) do (
    haxelib --quiet install %%i
)
echo.
echo done, use %~nx0 --build or --buildtest on ./buildwindow.bat!
exit /b