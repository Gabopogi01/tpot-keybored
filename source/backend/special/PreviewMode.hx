package backend.special;

import flixel.FlxG;
import backend.utils.SomeUtils;

class PreviewMode {
    private static var onPreview:Bool = false;

    public static function init(){
        #if preview
            onPreview = true;
            trace("preview is Defined!");
        #else
            onPreview = false;
            trace("preview is not Defined!");
        #end
    }
    
    public static function prev(){
        if (!onPreview) {trace("Not Defined -D preview! or Not Init!"); return;}
        lime.app.Application.current.window.maximized = true;
        FlxG.mouse.visible = false;
        lime.app.Application.current.window.width = 1280;
        lime.app.Application.current.window.height = 720;
        lime.app.Application.current.window.visible = true;
        SomeUtils.centerWindow();
        trace("Press Enter to Change theme");
    }
}