﻿package phystest{	import flash.display.MovieClip	import flash.events.MouseEvent	import flash.events.Event		public class ZoomControl extends MovieClip {						var thisClip: MovieClip;	var universe:MovieClip;	var dragging:Boolean = false;	var clickRadius:Number;	var clickScl:Number = 1;	var clickSclUniverse:Number = 1;			public function ZoomControl(mc:MovieClip,universeclip:MovieClip) {			thisClip = mc			universe = universeclip			mc.addEventListener(MouseEvent.MOUSE_DOWN,zcMouseDown)			mc.addEventListener(MouseEvent.MOUSE_UP,zcMouseUp)			mc.addEventListener(Event.ENTER_FRAME,zcEnterFrame)		}		 function zcMouseDown(event:MouseEvent):void{			dragging = true			clickRadius =Math.sqrt(Math.pow( mouseX,2) +Math.pow(mouseY,2))			clickScl = thisClip.scaleX			clickSclUniverse = universe.scaleX		}				 function zcMouseUp(event:MouseEvent):void{			dragging = false		}		 function zcEnterFrame(event:Event):void{			if (dragging) {				var currRadius =Math.sqrt(Math.pow( mouseX,2) +Math.pow(mouseY,2))				var scl = currRadius / clickRadius   * clickSclUniverse				var sclThis = currRadius/clickRadius *clickScl				thisClip.scaleX =  sclThis				thisClip.scaleY =  sclThis				universe.scaleX = scl				universe.scaleY = scl			}		}			}}