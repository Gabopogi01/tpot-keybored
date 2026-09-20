package backend;

import sys.FileSystem;

class Paths {
    public static var WAV:String = "wav";
    public static var OGG:String = "ogg";

    public static function image(file:String){
        var addedFileName = "assets/images/" + file + ".png";

        if (!FileSystem.exists(addedFileName)) {trace(addedFileName + " Does Not Exist!"); return null;}

        return addedFileName;
    }

    public static function sound(file:String, ?exec:String){
        if (exec == null) exec = "wav";
        var addedFileName = "assets/sounds/" + file + "." + exec;

        if (!FileSystem.exists(addedFileName)) {trace(addedFileName + " Does Not Exist!"); return null;}

        return addedFileName;
    }

    public static function font(file:String){
        var addedFileName = "assets/fonts/" + file + ".ttf";

        if (!FileSystem.exists(addedFileName)) {trace(addedFileName + " Does Not Exist!"); return null;}

        return addedFileName;
    }
}