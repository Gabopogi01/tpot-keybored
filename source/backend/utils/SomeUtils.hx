package backend.utils;

import flixel.FlxG;
import backend.Paths;

@:cppFileCode('
#include <windows.h>
#include <shellapi.h>

#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "user32.lib")
')

class SomeUtils {
    private static var keyStates:Array<Bool> = [];

    public static function centerWindow(){
        #if desktop
        var window = openfl.Lib.application.window;
        var display = lime.system.System.getDisplay(0); 
        if (display != null) {
            var screenBounds = display.bounds;
            var centerX = Std.int((screenBounds.width - window.width) / 2);
            var centerY = Std.int((screenBounds.height - window.height) / 2);
            window.move(centerX, centerY);
        }
        #end
    }

    public static function init(){
        for (i in 0...512) { keyStates.push(false); }
    }

    public static function checkAndPlayKey(vk:Int, fileSuffix:String, ?vol:Float):Void
    {
        if (vol == null) vol = 1.0;

        var isDownNow:Bool = false;
        #if windows
        var state:Int = untyped __cpp__("GetAsyncKeyState({0})", vk);
        isDownNow = (state & 0x8000) != 0;
        #end
        
        var wasDownBefore:Bool = keyStates[vk];
        if (isDownNow && !wasDownBefore) { 
            var keysSound = FlxG.sound.play(Paths.sound(fileSuffix)); 
            keysSound.volume = vol;
        }
        keyStates[vk] = isDownNow;
    }
}