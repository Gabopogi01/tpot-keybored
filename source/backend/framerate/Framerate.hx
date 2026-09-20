package backend.framerate;

import backend.framerate.compoments.*;
import openfl.display.Sprite;
import sys.thread.Thread;
import haxe.ui.Toolkit;

class Framerate extends Sprite{
    public var fps:FpsText;
    public var committxt:CommitText;
    public static var fpsY:Float = 0;

    public function new(){
        super();
        fps = new FpsText();
        committxt = new CommitText();

        addChild(fps);
        addChild(committxt);
        if (CommitText.commit == "0"){
            committxt.visible = false;
        }

        Thread.create(function() {
            while (true) {
                fps.y = fpsY;
                committxt.y = fpsY + 23;
                if (Toolkit.theme == "dark"){
                    fps.formatr.color = 0xffffff;
                    committxt.formatr.color = 0xffffff;
                } else {
                    fps.formatr.color = 0x3e3e3e;
                    committxt.formatr.color = 0x3e3e3e;
                }

                committxt.defaultTextFormat = committxt.formatr;
                fps.defaultTextFormat = fps.formatr;

                Sys.sleep(0.01);
            }
        });
    }
    
    public function changeYfps(y:Float):Framerate {
        fpsY = y;

        return this;
    }
}