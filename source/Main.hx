package;

import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;
import backend.framerate.Framerate;
import openfl.events.Event;

class Main extends Sprite
{
	var framrat:Framerate;

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

		framrat = new Framerate();
		addChild(framrat);

		updateLayout();

		openfl.Lib.current.stage.addEventListener(Event.RESIZE, onWindowResize);
	}

	private function onWindowResize(e:Event):Void {
		updateLayout();
	}

	private function updateLayout():Void {
		if (framrat != null && framrat.fps != null) {
			var currentStageHeight = openfl.Lib.current.stage.stageHeight;
			
			framrat.x = 10; 

			var totalHeight = framrat.fps.height;
			if (framrat.committxt != null) {
				totalHeight = framrat.committxt.y + framrat.committxt.height;
			}
			
			framrat.y = currentStageHeight - totalHeight - 10;
		}
	}
}
