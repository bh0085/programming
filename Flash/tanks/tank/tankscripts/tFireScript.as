﻿package tanks.tank.tankscripts {		import flash.display.Shape		public class tFireScript extends TankScript{		public function beginScript():void{						if(howManyOfThisScript < 1){			stage.addEventListener(KeyboardEvent.KEY_UP,tfRelease)				} else {scriptDone = true}					}				function tfRelease(event:KeyboardEvent):void{			if( event.keyCode = Keyboard.SPACE ) 		}				override public function advance():void{						if (frame  > 10) {scriptDone = true}		}	}}