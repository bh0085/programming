﻿package physics {	import Math	import flash.display.Shape		public class PhysFieldLines extends Shape {						public var field:PhysField				public static var perq:Number = 30		public static var steplength:Number = 3		public static var firststep:Number = 35		public static var numsteps:Number = 10				public function PhysFieldLines(system:PhysField){//Create a physFieldLines object associated with a particular field			field = system		}		public function linesAtObject(object:PhysObject){			//Draws lines around the object specified for this field										var numlines:Number = Math.floor(perq * (object.charge))				for( var j:Number = 0; j < numlines ; j++) {										var angle:Number = 360 * j / numlines					var xstep:Number = Math.cos(angle * 2 * Math.PI / 360) * firststep 					var ystep:Number = Math.sin(angle * 2 * Math.PI / 360) * firststep										graphics.lineStyle(1)										var currx:Number = object.getPhysicalCenterX() + xstep					var curry:Number = object.getPhysicalCenterY() + ystep					graphics.moveTo(currx,curry)					for ( var k: Number = 0; k<  numsteps ; k ++) {						var thisE:Array = field.fieldAt(currx,curry)						var magE:Number = Math.sqrt(Math.pow(thisE[0],2) + Math.pow(thisE[1],2))						currx += (thisE[0] / magE) * steplength						curry += (thisE[1] / magE) * steplength 						graphics.lineTo(currx,curry)					}				}		}		public function linesAtAllObjects(){			//Draws lines around each of the objects in the field to which these lines are registered								var numobj:Number = field.objects.length						for ( var i:Number = 0 ; i < numobj ; i++) {				var numlines:Number = Math.floor(perq * (field.objects[i].charge))				for( var j:Number = 0; j < numlines ; j++) {										var angle:Number = 360 * j / numlines					var xstep:Number = Math.cos(angle * 2 * Math.PI / 360) * firststep 					var ystep:Number = Math.sin(angle * 2 * Math.PI / 360) * firststep										graphics.lineStyle(1)										var currx:Number = field.objects[i].xcenter + xstep					var curry:Number = field.objects[i].ycenter + ystep					graphics.moveTo(currx,curry)					for ( var k: Number = 0; k<  numsteps ; k ++) {						var thisE:Array = field.fieldAt(currx,curry)						var magE:Number = Math.sqrt(Math.pow(thisE[0],2) + Math.pow(thisE[1],2))						currx += (thisE[0] / magE) * steplength						curry += (thisE[1] / magE) * steplength 						graphics.lineTo(currx,curry)					}				}			}					}				public function clearLines(){			//Clears all lines...			graphics.clear()		}					}}