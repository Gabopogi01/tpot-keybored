package backend;

import flixel.FlxSprite;
import backend.Paths;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.thread.Thread;

class PassingBy extends FlxSprite{
    public var time = 0;
    
    public function new(?x:Float, ?y:Float, ?sprite:String, ?flip = false, ?speed = 5.7, ?floating = true, ?sinespeed:Float = 1){
        if (sprite == null) sprite = Paths.image("darl/one");

        if (x == null) x = 0;
        if (y == null) y = 0;

        super(x, y);
        loadGraphic(sprite);
        updateHitbox();

        if (flip){
            this.x = -1000;
            FlxTween.tween(this, {x: 1000}, speed, {onComplete: (_)->{
                this.kill();
            }});
        } else {
            this.x = 1200;
            FlxTween.tween(this, {x: -1000}, speed, {onComplete: (_)->{
                this.kill();
            }});
        }

        trace('$x, $y, $sprite');

        Thread.create(function() {
            while (true) {
                if (!floating) return;
                time++;
                this.y = (Math.sin(time / (sinespeed * 10)) * 30) + y;
                this.angle = Math.sin(time / (sinespeed * 10));

                Sys.sleep(0.01);
            }
        });
    }
}