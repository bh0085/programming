﻿package actionscript{	import flash.display.Sprite	public class City extends GlooPlace{		var population		var cGFX: Sprite = new Sprite()		public static var cities = new Array()		public function City(nNew:String):void{			name = nNew			addChild(cGFX)			cities.push(this)			type = "City"		}		public function setPopulation(pop:Number):void{			population = pop		}		public function drawCity():void{			var s = new Sprite()			//s.graphics.beginFill(0xFFFFFF,.8)			//s.graphics.drawCircle(0,0,40)			s.graphics.lineStyle(25,0xFFFFFF,.6)			s.graphics.drawCircle(0,0,Math.sqrt(population / 100000)* 5)			s.graphics.lineStyle()			s.graphics.beginFill(0xFF4444,1)			s.graphics.drawCircle(0,0,Math.sqrt(population / 100000)* 5)			try{				cGFX.removeChildAt(0)			} catch (e:Error) {}			cGFX.addChild(s)			addChild(cGFX)			cGFX.x = getXY()[0]			cGFX.y = getXY()[1]									}		override public function draw():Sprite{			var s = new Sprite()			s.graphics.lineStyle(25,0xFFFFFF,.6)			s.graphics.drawCircle(0,0,Math.sqrt(population / 100000)* 5)			s.graphics.lineStyle()			s.graphics.beginFill(0xFF4444,1)			s.graphics.drawCircle(0,0,Math.sqrt(population / 100000)* 5)			var drawBig = false			if(GloobalMain.main.selected.getType() == "Custom" ||GloobalMain.main.selected.getType() == "Country" ){				var cs = GloobalMain.main.selected.cities				if(cs.indexOf(this) != -1){ drawBig = true }			}			if(drawBig){				s.graphics.lineStyle(5,0x000000)				s.graphics.beginFill(0x000000,0)				s.graphics.drawCircle(0,0,2 * Math.sqrt(population / 100000)* 5)							}									try{				cGFX.removeChildAt(0)			} catch (e:Error) {}			cGFX.addChild(s)			addChild(cGFX)			cGFX.x = getXY()[0]			cGFX.y = getXY()[1]			return cGFX		}		public function hasAirport():Boolean{			return true		}						public static function resetFairs():void{			for( var i = 0 ; i < cities.length ; i++){				cities[i].resetFair()			}		}		override public function getAirports():Array{			if(hasAirport()){return [this]} else {return new Array()}		}	}}