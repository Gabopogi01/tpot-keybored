package backend.framerate.compoments;

import haxe.Timer;
import openfl.text.TextFormat;
import sys.thread.Thread;
import openfl.text.TextField;

class FpsText extends TextField {
    private var fps = "FPS";
    private var frame:Int = 0;
    public var formatr = new TextFormat();

    public function new() {
        super();
        autoSize = LEFT;
		multiline = wordWrap = false;
        text = 'FPS: ' + fps;

        formatr.color = 0xFFffff;
        formatr.size = 20;
        formatr.font = Paths.font("SEGUISB");

        defaultTextFormat = formatr;

        var tim = new Timer(640); 

        tim.run = function() {
            fps = Std.string(frame);
            text = 'FPS: ' + fps;
            frame = 0;
        };

        Thread.create(function() {
            while (true) {
                frame++;

                Sys.sleep(0.01);
            }
        });
    }
}