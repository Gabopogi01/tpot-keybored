package;

import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;
import openfl.events.UncaughtErrorEvent;
import openfl.errors.Error;
import haxe.CallStack;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState, 1, 60, true, false));
		FlxG.autoPause = false; 
		FlxG.fixedTimestep = false;
		FlxG.sound.soundTrayEnabled = false;
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
	}
}
