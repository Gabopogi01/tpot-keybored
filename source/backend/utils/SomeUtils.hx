package backend.utils;

class SomeUtils {
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
}