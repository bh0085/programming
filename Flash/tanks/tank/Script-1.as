﻿package physics{	public class PhysWallObject extends PhysObject {				public static var lastbmp:Bitmap			public function closestAlongRadius(pt:Array):Array{		var rad = [pt[0] - x, pt[1] - y]		var radMag = Math.sqrt(Math.pow(rad[0], 2) + Math.pow(rad[1],2))		var radUnit= [rad[0] / radMag, rad[1] / radMag]		var radPerp= [-1 * radUnit[1], radUnit[0]]		var rot = new Matrix()		rot.a = radPerp[0]		rot.b = radPar[0] * -1		rot.c = radPerp[1] * -1		rot.d = radPar[1]		var bounds = new Object					var w = 5			var h = radMag			var img:BitmapData = new BitmapData(w,h, false)			img.draw(obj1,rot, new ColorTransform(1,1,1,1,255,-255,-255,0));						if (lastbmp != null) {root.removeChild(lastbmp)}			lastbmp = new Bitmap(img)			lastbmp.x = 250			lastbmp.y = 100			root.addChild(lastbmp)				}		public function getUnits(pt1:Array,pt2:Array):Array{		return [0,0,0,0]	}	}	}