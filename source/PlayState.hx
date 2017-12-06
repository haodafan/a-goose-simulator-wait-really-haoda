package;

import flixel.FlxState;
import flixel.FlxG; 

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

import flixel.input.keyboard.FlxKey;

import flixel.system.FlxSound;

import flixel.util.FlxColor;

import Math;

class PlayState extends FlxState
{	

	// --- Object Declarations --- 
	//Sprites
	var playerGoose:FlxSprite;
	var picHonk: Array<FlxSprite> = [];

	//Text
	var text:FlxText;
	var howTo:FlxText;
	var soundHonk:FlxSound; 

	//Some additional values to keep track of things
	var leftAnimation:Bool; 
	var rightAnimation:Bool;
	var upAnimation:Bool;
	var downAnimation:Bool;

	var canLeft:Bool;
	var canRight:Bool;
	var canUp:Bool;
	var canDown:Bool;
		
	override public function create():Void
	{
		super.create();

		//Background Settings
		FlxG.camera.bgColor = 0xFFBADA55;


		//Text title object
		text = new FlxText(0, 32, FlxG.width, "", 32);
		text.text = "FUCKING GEESE!";
		text.setFormat(null, 32, FlxColor.RED, FlxTextAlign.CENTER);
		add(text);

		howTo = new FlxText(0, FlxG.height - 32, FlxG.width, "  Space = HONK , + / - = MUSIC VOLUME", 18);
		add(howTo);

		//New Player Object
		playerGoose = new FlxSprite();
		playerGoose.loadGraphic(AssetPaths.GooseMed2Sprite__png, true, 32, 32);
		playerGoose.x = FlxG.width / 2 - playerGoose.width / 2;
		playerGoose.y = FlxG.height / 2 - playerGoose.height / 2;

		//Adding animation 
		playerGoose.animation.add("walkLeft", [0,1,2,3,4,5,6,7], 24, true);
		playerGoose.animation.add("walkRight", [0,1,2,3,4,5,6,7], 24, true, true); //This flips it horizontally
		playerGoose.animation.add("walkDown", [8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23], 24, true);
		playerGoose.animation.add("walkUp", [24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39], 24, true);

		rightAnimation = false;
		leftAnimation = true;
		upAnimation = false;
		downAnimation = false;

		add(playerGoose);

		playerGoose.animation.play("walkLeft");
		playerGoose.animation.stop(); 

		//New Honking object
		for (i in 0...3) {
			picHonk[i] = new FlxSprite(); 
			if (i == 0) {
				picHonk[0].loadGraphic(AssetPaths.honk__png);
			}
			else if (i == 1) {
				picHonk[1].loadGraphic(AssetPaths.honk2__png);
			}
			else {
				picHonk[2].loadGraphic(AssetPaths.honk3__png);
			}
			picHonk[i].x = FlxG.width / 2 - picHonk[i].width / 2;
			picHonk[i].y = FlxG.height / 2 - picHonk[i].height / 2;
			picHonk[i].alpha = 0; //This picture is unseen
			picHonk[i].scale.set(2,2);
			add(picHonk[i]);
		}
		//The honking picture will become visible when you press the honk button (space) 


		//MUSIC 
		#if flash
			FlxG.sound.playMusic(AssetPaths.uwaterlooOP__mp3);
			soundHonk = FlxG.sound.load(AssetPaths.Goose_SoundBible__mp3);
		#else
			FlxG.sound.playMusic(AssetPaths.uwaterlooOP__ogg);
			soundHonk = FlxG.sound.load(AssetPaths.Goose_SoundBible__wav);
		#end

		FlxG.sound.music.onComplete = function() {
			trace("Song Ended");

		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//  ----- KEYBOARD EVENT CONTROL LOOP -----
		if(FlxG.keys.pressed.UP) { 
			playerGoose.y --; 
			rightAnimation = false;
			leftAnimation = false; 
			upAnimation = true;
			downAnimation = false;
		}
		if(FlxG.keys.pressed.DOWN) {
			playerGoose.y ++; 
			rightAnimation = false;
			leftAnimation = false; 
			upAnimation = false;
			downAnimation = true;
		}
		if(FlxG.keys.pressed.RIGHT) {
			playerGoose.x ++;
			rightAnimation = true;
			leftAnimation = false; 
			upAnimation = false;
			downAnimation = false;
		}		
		if(FlxG.keys.pressed.LEFT) {
			playerGoose.x --;
			leftAnimation = true;
			rightAnimation = false; 
			upAnimation = false;
			downAnimation = false;
		}

		//This is for animation
		if (FlxG.keys.anyPressed([UP, DOWN, LEFT, RIGHT])) {
			if (leftAnimation) {
				playerGoose.animation.play("walkLeft");
			}
			else if (rightAnimation) {
				playerGoose.animation.play("walkRight");
			}
			else if (upAnimation) {
				playerGoose.animation.play("walkUp");
			}
			else if (downAnimation) {
				playerGoose.animation.play("walkDown");
			}
		}
		else {
			playerGoose.animation.curAnim.curFrame = 0;
			playerGoose.animation.stop();
		}

		//This is for the honking
		if (FlxG.keys.justPressed.SPACE) { 
			soundHonk.play(true);

			//Now, let's choose one at random! 
			var randomInt = Math.random(); 
			var index:Int; 
			if (randomInt < 0.333) {
				index = 0;
			}
			else if (randomInt < 0.667) {
				index = 1;
			}
			else {
				index = 2;
			}
			FlxTween.tween(picHonk[index], {alpha : 100}, 0.2, {type: FlxTween.ONESHOT, onComplete : endHonkTween});
			
			//First let's make sure no honking pictures are already on screen
			// for (i in 0...3) {
			// 	picHonk[i].alpha = 0;
			// }
		}

		//This is for music controls
		if (FlxG.keys.justPressed.PLUS) FlxG.sound.changeVolume(0.1);
		if (FlxG.keys.justPressed.MINUS) FlxG.sound.changeVolume(-0.1);

	}

	private function endHonkTween(tween:FlxTween):Void {
		for (i in 0...3) {
			FlxTween.tween(picHonk[i], {alpha : 0}, 0.2, {type: FlxTween.ONESHOT});
		}
	}

	//This function takes in 
	private function borderSecurity() {

	}

}
