﻿package physics.objects.oscript{	import physics.PhysUniverse	import physics.objects.PhysObject	import mygraphics.PtObj	import mygraphics.ObjObj		import flash.geom.Rectangle	import flash.display.Sprite	import flash.display.BitmapData	import flash.display.Bitmap	import flash.geom.Matrix	import flash.display.Shape		import flash.utils.getQualifiedClassName	import paths.Path2D	import math.VectorMath2D			public class attachToObj extends ObjectScript{				public var objAttachedTo		public var objsAttached				public var surfaceSegment:Array		public var surfaceUnits:Array		public var surfacePoint:Array		public static var s:Shape				override public function beginScript():void{			//trace("ATTACHING")			var testAttached = new attachedToObject()			var num = 0						if(howManyInObject(new attachedToObject(), thisObject) + howManyInObject(new detachFromObj,thisObject) > 0){ 				scriptDone = true 			} else {				var n = ObjectScript.howManyInObject(new bounceOffObj(),thisObject)			}		}				public function spawnAttached():void{			var newScript = new attachedToObject()			newScript.setAttachedTo(objAttachedTo)			newScript.setWhichAttached(objsAttached)			thisObject.addObjectScript(newScript)				}				override public function advance(...args):void{			//thisObject.sleep()			thisObject.setCollisionsAllowed(objAttachedTo, false)				spawnAttached()				scriptDone =true								}		public function setAttachedTo(obj:PhysObject):void{			objAttachedTo = obj			setPriority(2)		}		public function setWhichAttached(objects:Array):void{			objsAttached = objects		}	}}