﻿package tanks.explosions{	import tanks.tank.Tank	import flash.events.Event	import flash.display.MovieClip	import tanks.scripts.ExplScript		public class Explosion extends MovieClip {		public var thisTank:Tank		public var initialXY:Array		public var initialAngle:Number		public var initialPower:Number		public var thisScript:ExplScript		public var radius = 100		public var colType = 1				public function Explosion() :void{			createScript()		}				public function setTank(tank:Tank):void{			thisTank = tank			thisTank.thisUniverse.addChild(this)		}				public function setPower(p:Number):void{initialPower = p}		public function setAngle(a:Number):void{initialAngle = a}		public function setInitialXY(xy:Array):void{initialXY = xy; setXY(xy)}		public function setXY(xy:Array):void{			x = xy[0]			y = xy[1]		}				public function eNextFrame(e:Event):void{			if(thisScript.advanceDefault(0)){thisScript.endScriptDefault()}else{			}		}		public function trigger():void{			thisScript.beginScript()			addEventListener(Event.ENTER_FRAME,eNextFrame)		}		public function createScript():void{		}				public function destroyDefault():void{			removeEventListener(Event.ENTER_FRAME,eNextFrame)			thisTank.thisUniverse.removeChild(this)			destroy()		}		public static function initializeExplosion(expl:Explosion,initXY:Array,...args):void{			if(args.length>0){expl.setTank(args[0])} else{expl.setTank(null)}			if(args.length >1){expl.setPower(args[1])} else{expl.setPower(1)}			if(args.length >2){expl.setAngle(args[2])} else{expl.setAngle(0)}			expl.setInitialXY(initXY)			expl.trigger()																		   		}				public function destroy():void{}				}	}