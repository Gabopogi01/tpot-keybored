package;

import lime.app.Application;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;
import backend.framerate.Framerate;
import openfl.events.Event;
import flixel.FlxState;
import backend.PassingBy;

class Main extends Sprite
{
	var framrat:Framerate;

	public function new()
	{
		super();
		
		//playstate
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

		#if debug
		FlxG.debugger.visible = false;
		#end
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

class TestState extends FlxState {
	var char:PassingBy;

	override public function create(){
		super.create();
		Application.current.window.visible = true;
		char = new PassingBy(0, 0, null, false, 7, true, 7);
		char.scale.set(0.3, 0.3);
		add(char);
		trace("test state loaded");
	}
}