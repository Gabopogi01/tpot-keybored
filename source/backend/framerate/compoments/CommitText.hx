package backend.framerate.compoments;

import openfl.text.TextField;
import haxe.macro.Compiler;
import openfl.text.TextFormat;

class CommitText extends TextField {
    public static var commit = Compiler.getDefine("commit").split("=").pop();
    public var formatr = new TextFormat();

    public function new() {
        super();
        autoSize = LEFT;
		multiline = wordWrap = false;
        text = 'Commit ' + commit;

        formatr.color = 0xFFffff;
        formatr.size = 16;
        formatr.font = Paths.font("SEGUISB");

        defaultTextFormat = formatr;
    }
}   