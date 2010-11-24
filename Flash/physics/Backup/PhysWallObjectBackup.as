﻿package physics{	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.geom.Matrix;	import flash.geom.ColorTransform;	import flash.geom.Point	import flash.events.MouseEvent;	import flash.events.Event;	import flash.display.Shape;	import flash.display.Sprite;	import flash.geom.Rectangle;	import flash.utils.getTimer;	import math.VectorMath2D;	import math.VectorMath3D;	public class PhysWallObject extends PhysWall {		public var tracer:Sprite;		public var unitArrow:Shape;		public var twoRadii:Shape;		public static  var lastbmp:Bitmap;		public var xCenters:Array;		public var yCenters:Array;		public var massFracs:Array;		public var chargeFracs:Array;		public var massWeights:Array;		public var chargeWeights:Array;				public function setCenters(xs:Array,ys:Array):void {			xCenters = xs;			yCenters = ys;			massWeights = new Array();			chargeWeights = new Array();			for (var i = 0; i < xs.length; i++) {				massWeights.push(1);				chargeWeights.push(1);			}			calculateFracs();		}		public function addCenter(xAdd:Number,yAdd:Number):void {			if ( xCenters == null) {				xCenters = new Array ;				yCenters = new Array ;				massWeights = new Array ;				chargeWeights = new Array;			}			xCenters.push(xAdd);			yCenters.push(yAdd);			massWeights.push(1);			chargeWeights.push(1);			calculateFracs();		}		function calculateFracs():void {			var l = xCenters.length;			var cWeightTotal = 0;			var mWeightTotal = 0;			massFracs = new Array(l);			chargeFracs = new Array(l)			;			for (var i = 0; i < l; i++) {				cWeightTotal+= chargeWeights[i];				mWeightTotal+= massWeights[i];			}			if (cWeightTotal == 0) {				cWeightTotal = 1;			}			if (mWeightTotal ==0) {				mWeightTotal = 1;			}			for (i = 0; i< l; i++) {				massFracs[i] = massWeights[i] / mWeightTotal;				chargeFracs[i] = chargeWeights[i] / cWeightTotal;			}		}		public function getXCenters() {			var newXCenters = new Array();			for (var i  = 0; i < xCenters.length; i++) {				newXCenters[i] = xCenters[i] + getX();			}			return newXCenters;		}		public function getYCenters() {			var newYCenters = new Array();			for (var i  = 0; i < yCenters.length; i++) {				newYCenters[i] = yCenters[i] + getY();			}			return newYCenters;		}		public function getNearestCenter(object:PhysObject):Array {			if (xCenters == null) {				return [getX(),getY()];			} else {				var newXCenters = getXCenters();				var newYCenters = getYCenters();				var objX = object.getX();				var objY = object.getY();				var l = newXCenters.length;				var abs = Math.sqrt(Math.pow(objX - newXCenters[0],2) + Math.pow(objY - newYCenters[0],2));				var idxAbs = 0;				var temp:Number;				for (var i = 1; i < l; i ++) {					temp = Math.sqrt(Math.pow(objX - newXCenters[i],2) + Math.pow(objY - newYCenters[i],2));					if (temp < abs) {						abs = temp;						idxAbs = i;					}				}				var output = xCenters;				return [newXCenters[idxAbs],newYCenters[idxAbs]];			}		}		public function getNearestCenterToPt(pt:Array):Array {			if (xCenters == null) {				return [getX(),getY()];			} else {				var newXCenters = getXCenters();				var newYCenters = getYCenters();				var objX = pt[0];				var objY = pt[1];				var l = newXCenters.length;				var abs = Math.sqrt(Math.pow(objX - newXCenters[0],2) + Math.pow(objY - newYCenters[0],2));				var idxAbs = 0;				var temp:Number;				for (var i = 1; i < l; i ++) {					temp = Math.sqrt(Math.pow(objX - newXCenters[i],2) + Math.pow(objY - newYCenters[i],2));					if (temp < abs) {						abs = temp;						idxAbs = i;					}				}				var output = xCenters;				return [newXCenters[idxAbs],newYCenters[idxAbs]];			}		}		override public function getCOMX():Number{			if (xCenters.length == 0){return getX()} else{				var newX = getXCenters()				var COMX = 0				for (var i = 0; i < newX.length ; i++){					COMX += massFracs[i] * newX[i]				}				return COMX			}		}		override public function getCOMY():Number{			if (yCenters.length == 0){return getY()} else{				var newY = getYCenters()				var COMY = 0				for (var i = 0; i < newY.length ; i++){					COMY += massFracs[i] * newY[i]				}				return COMY			}				}						override public function eOfAt(xy:Array):Array {			var newXCenters = getXCenters();			var newYCenters = getYCenters();			var E:Array = [0,0];			var rx:Number;			var ry:Number;			var r:Number;			for (var i = 0; i < xCenters.length; i++) {				rx = xy[0] - newXCenters[i];				ry = xy[1] - newYCenters[i];				r = Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2));				E[0] += kc * rx * chargeFracs[i] *charge / Math.pow(r,3) ;				E[1] += kc * ry * chargeFracs[i] * charge/ Math.pow(r,3);			}			return E;		}		override public function gOfAt(xy:Array):Array {			var newXCenters = getXCenters();			var newYCenters = getYCenters();			var g:Array = [0,0];			var rx:Number;			var ry:Number;			var r:Number;			for (var i = 0; i < xCenters.length; i++) {				rx = xy[0] - newXCenters[i];				ry = xy[1] - newYCenters[i];				//trace(rx)				//trace(ry)				r = Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2));				g[0] += -G * rx * massFracs[i] * mass /  Math.pow(r,3) ;				g[1] += -G * ry * massFracs[i] * mass /  Math.pow(r,3);				//trace(g)			}			return g;		}		override public function inverseSquareOfAt(xy:Array):Array{			var newXCenters = getXCenters();			var newYCenters = getYCenters();			var f:Array = [0,0];			var rx:Number;			var ry:Number;			var r:Number;					var fThis:Array;						for (var i = 0; i < xCenters.length; i++) {						 rx = xy[0] - newXCenters[i];						 ry = xy[1] - newYCenters[i];						 r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)						 fThis = [ rx  / Math.pow(r,3),  ry  / Math.pow(r,3)]						 f[0] += fThis[0]						 f[1] += fThis[1]						}			return f		}		override public function inverseCubeOfAt(xy:Array):Array{			var newXCenters = getXCenters();			var newYCenters = getYCenters();			var f:Array = [0,0];			var rx:Number;			var ry:Number;			var r:Number;					var fThis:Array;						for (var i = 0; i < xCenters.length; i++) {						 rx = xy[0] - newXCenters[i];						 ry = xy[1] - newYCenters[i];						 r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)						 fThis = [ rx  / Math.pow(r,3),  ry  / Math.pow(r,3)]						 f[0] += fThis[0]						 f[1] += fThis[1]						}			return f		}		override public function inverseFirstOfAt(xy:Array):Array{			var newXCenters = getXCenters();			var newYCenters = getYCenters();			var f:Array = [0,0];			var rx:Number;			var ry:Number;			var r:Number;					var fThis:Array;						for (var i = 0; i < xCenters.length; i++) {						 rx = xy[0] - newXCenters[i];						 ry = xy[1] - newYCenters[i];						 r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)						 fThis = [ rx  / Math.pow(r,3),  ry  / Math.pow(r,3)]						 f[0] += fThis[0]						 f[1] += fThis[1]						}			return f		}						public function getUnitsAngle(obj:PhysObject, ... pt):Number {			var units:Array;			if (pt.length ==0) {				units = wallObjGetUnits(obj);			} else {				units = wallObjGetUnits(obj, pt[0]);			}			var yAlong = units[1];			var angle12 = Math.asin(yAlong);			if (units[0] < 0) {				angle12 = Math.PI - angle12;			}			return angle12;		}		public function hitTest(obj:PhysObject):Number {			var indexhit = -1;			var collisiondepth = 0;			var angle12 = getUnitsAngle(obj);			var rotateRadians = -1 * angle12;			var intersection = PhysCollisions.physHitTestIrregular(obj.getGraphic(), getGraphic() ,thisUniverse,rotateRadians);			if ((intersection != null)) {				collisiondepth = intersection.height;			}			return collisiondepth;		}				public function collision(ParentObject:PhysObject):void {			if (ParentObject.children != null) {				complexBodyCollision(ParentObject,ParentObject.children);			} else {				simpleCollision(ParentObject);			}		}				public function simpleCollision(parentObj:PhysObject):void {						var depthCollided:Number			var anyCollisions = false;			depthCollided = hitTest(parentObj);			if (depthCollided > 0) { anyCollisions = true}						if (anyCollisions) {				parentObj.collided()				var nColl  = 1;				var skinDepths = getSkinDepths(depthCollided)				dampenObject(parentObj,nColl,skinDepths)				exertImpulse(parentObj)				exertSecondImpulse(parentObj, skinDepths)				secondDampenObject(parentObj,nColl,skinDepths)							}									}		public function getSkinDepths(collisionDepth:Number):Number{			var skinDepth = 20			return(collisionDepth / skinDepth)		}		public function exertImpulse(object:PhysObject):void{																	var units = wallObjGetUnits(object);					var unitPar = [units[0],units[1]];					var unitPerp= [units[2],units[3]];											var rChild = object.comRadius();					if (rChild != null){						var distanceParalellToWall = VectorMath2D.dotMultiply2D(unitPar,rChild);						var equivalentMass = 1 / (Math.pow(distanceParalellToWall , 2) / object.childOf.momentOfInertia + 1 / object.childOf.mass);							var vParent = object.childOf.velocity();						var vChild  = VectorMath3D.crossMultiply3D([0,0,object.childOf.omega], [unitPar[0] *distanceParalellToWall,unitPar[1]*distanceParalellToWall,0]);						var vPerp   = VectorMath2D.dotMultiply2D([vParent[0] + vChild[0],vParent[1] + vChild[1]],unitPerp)													var theImpulse = -1 * 2 * equivalentMass  * (vPerp) 									if (object.numConsecutiveWallHits ==0 ) {							object.exertImpulseOn([theImpulse * unitPerp[0], theImpulse * unitPerp[1]]);						}					}		}		public function exertSecondImpulse(object:PhysObject, skinDepths:Number){												var units:Array						if( object.childOf != null ){						 units = wallObjGetUnits(object.childOf) } else {						 units = wallObjGetUnits(object)}												var unitPar = [units[0],units[1]];						var unitPerp= [units[2],units[3]]						var f:Array												if( object.childOf != null){ f = object.childOf.forceOn()} else{							 f = object.forceOn()}													var magF = Math.sqrt(Math.pow(f[0],2) + Math.pow(f[1],2))												//Now, the directions of the force are defined...						var fUnitPar =  [ f[0] / magF,  f[1]/ magF];						var fUnitPerp = [ fUnitPar[1], - fUnitPar[0]]												//and Now, the dot product of rChild with the force vector												var massFrac:Number						if (object.childOf !=null){							var rChildPerp = VectorMath2D.dotMultiply2D(fUnitPerp, object.comRadius());							var equivalentMass = 1 / (Math.pow(rChildPerp , 2) / object.childOf.momentOfInertia + 1 / object.childOf.mass);							 massFrac = equivalentMass/object.childOf.mass						} else { massFrac = 1}												var fOnMag   = magF * massFrac												var k = Math.sqrt( Math.min(skinDepths,10) / PhysUniverse.timestep / 10)						var fOnChildAgainst = [ unitPerp[0] * fOnMag * k,  unitPerp[1] * fOnMag * k];						object.exertImpulseOn([fOnChildAgainst[0] * PhysUniverse.timestep,fOnChildAgainst[1] * PhysUniverse.timestep]);						object.cancelForces(skinDepths/2);		}		public function dampenObject(object:PhysObject, nColl:Number, skinDepths:Number):void{												if (object.childOf != null ){object.childOf.dampen(getDamping(skinDepths,nColl,object.numConsecutiveWallHits,true))} else {								object.dampen(getDamping(skinDepths,nColl,object.numConsecutiveWallHits,true))}		}		public function getDamping( skinDepth:Number, numChildrenCollided:Number, numCollisionsChild:Number, incoming:Boolean):Array {			var vdamp:Number			var wdamp:Number			if (numCollisionsChild == 0 ){vdamp = .9} else {vdamp = .9}			if (numChildrenCollided >= 0){wdamp = .9 } else {wdamp =.9 }						var xdamp = vdamp			var ydamp = vdamp			return([xdamp, ydamp, wdamp])								}		public function secondDampenObject(object:PhysObject, nColl:Number, skinDepths:Number):void{						if (object.childOf != null ){object.childOf.dampen(getDamping(skinDepths,nColl,object.numConsecutiveWallHits,false))} else {								object.dampen(getDamping(skinDepths,nColl,object.numConsecutiveWallHits,false))}					}				public function complexBodyCollision(parentObject:PhysObject, children:Array) {			var l = children.length;			var hasCollided = new Array(l);			var depthCollided = new Array(l);			var anyCollisions = false;			var collision:Number;			for (var i = 0; i < l; i++) {								if(i == 0){(closestSurfacePointTo([children[i].getX(),children[i].getY()],children[i].getPointSearchRadius(),true))}				collision = hitTest(children[i]);				if (collision == 0 ) {					hasCollided[i] = false;				} else {					hasCollided[i] = true;					depthCollided[i] = collision;					anyCollisions = true;					children[i].hasCollided = true;				}			}			if (anyCollisions) {				parentObject.collided()				var skinDepths:Array = new Array(l)				var nColl  = 0;								for (i =0; i < l; i++) {					skinDepths[i] = getSkinDepths(depthCollided[i])					if (hasCollided[i]) {						nColl++;					}				}				for (i =0; i < l; i++) {					if (hasCollided[i]) {						dampenObject(children[i],nColl,skinDepths[i])					}				}				for (i =0; i < l; i++) {					if (hasCollided[i]) {						exertImpulse(children[i])					}				}				for (i =0; i < l; i++) {					if (hasCollided[i]) {						exertSecondImpulse(children[i], skinDepths[i])					}				}				for (i =0; i < l; i++) {					if (hasCollided[i]) {						secondDampenObject(children[i],nColl,skinDepths[i])					}				}			}		}		public function wallObjGetUnits(object:PhysObject, ...pt):Array {			var nearestCenter:Array;			if (pt.length ==0 ) {				nearestCenter = getNearestCenter(object);			} else {				nearestCenter = getNearestCenterToPt(pt);			}			var cx = nearestCenter[0];			var cy = nearestCenter[1];			var objectRad:Array;			if (pt.length == 0 ) {				objectRad = [object.getX() , object.getY() ];			} else {				objectRad = pt;			}			var radToObj = [objectRad[0] - cx, objectRad[1] - cy];						var magRad = Math.sqrt(Math.pow(radToObj[0],2) + Math.pow(radToObj[1],2));			var unitToObj=[radToObj[0]/magRad,radToObj[1]/magRad];			var unitTangent=[unitToObj[1], -1*unitToObj[0]];			var pts = [objectRad[0] + unitTangent[0] * 10, objectRad[1] + unitTangent[1] * 10,			objectRad[0] - unitTangent[0]* 10, objectRad[1] - unitTangent[1] * 10];			var radPt1 = closestAlongRadius([pts[0],pts[1]]);			var radPt2 = closestAlongRadius([pts[2],pts[3]]);			var search:Boolean = true			var k = 0			var deltaRad=[radPt2[0] - radPt1[0],radPt2[1] - radPt1[1]];			if(deltaRad[0] ==0) {				while(search){				trace("FINDING")				k++				var rx = Math.random()				var ry = Math.random()				radPt2 = closestAlongRadius(   [pts[2] +10 * rx,   pts[3]+10 * ry]);				//trace([radPt2,rx,ry])				deltaRad=[radPt2[0] - radPt1[0],radPt2[1] - radPt1[1]];				if(deltaRad[0] != 0){search = false}				if(k> 10){search = false}				}			}			var deltaMag= Math.sqrt(Math.pow(deltaRad[0],2) + Math.pow(deltaRad[1],2));			var unitPar=[deltaRad[0]/deltaMag,deltaRad[1]/deltaMag];			var unitPerp=[-1 * unitPar[1],unitPar[0]];			if (VectorMath2D.dotMultiply2D(unitPerp, [radPt1[0] - cx,radPt1[1] - cy]) < 0) {				unitPar = [-1 * unitPar[0], -1 * unitPar[1]];				unitPerp= [-1 * unitPerp[0],-1 * unitPerp[1]];			}			var units = [unitPar[0],unitPar[1],unitPerp[0],unitPerp[1]];			if(!(Math.abs(units[0]) > 0)){				trace("stopping")			}						return units;		}								public function closestSurfacePointTo(pt:Array, searchRadius:Number, ... returnUnits):Array{			var units:Boolean			if ( returnUnits.length == 0 ){ units = false} else { units = returnUnits[0]}			var angleSteps =10			var angleSteps2 = 10			var tempangle:Number			var w = 1						var h = searchRadius			var img:BitmapData			var intersection:Rectangle			var rot:Matrix			var dx:Number			var dy:Number			var foundSlice = false				 dx = (pt[0] - getX())				 dy = (pt[1] - getY())			 rot = new Matrix()			 rot.tx = -dx + h			 rot.ty = -dy + h			 			img = new BitmapData(2*h, 2*h, false);			img.draw(this,rot, new ColorTransform(1,1,1,1,255,-255,-255, 0));			intersection = img.getColorBoundsRect(0xFFFFFF,0xFF0000,true);						var intersectiondistances = new Array(angleSteps)			var leastdistance:Number = h			var bestangle:Number = 0						var bestimg:BitmapData			var xyObj2PT = new Array(2)			var xyClose = new Array(2)			var angleBest:Number						var imgAll:BitmapData = new BitmapData(angleSteps+angleSteps2,h,false)						if(intersection.height == 0) {				//trace("Not near enough to get a point")				return null			} else{		//First find the angular window within which the closest point lies:						for (var i = 0 ; i < angleSteps; i++){				tempangle = i / angleSteps * Math.PI * 2								rot = new Matrix()				rot.a = Math.cos(tempangle)				rot.b = Math.sin(tempangle)				rot.c = -1 * Math.sin(tempangle)				rot.d = Math.cos(tempangle)													rot.tx = -( dx * Math.cos(tempangle) -  dy * Math.sin(tempangle)) + w/2				rot.ty = -( dy * Math.cos(tempangle) +  dx * Math.sin(tempangle))															img = new BitmapData(w,h, false);				img.draw(this,rot, new ColorTransform(1,1,1,1,255,-255,-255, 0));				imgAll.copyPixels(img,new Rectangle( 0,0,w,h) ,new Point(i,0))				intersection = img.getColorBoundsRect(0xFFFFFF,0xFF0000,true);				intersectiondistances[i] = intersection.y				if ((intersection.height !=0) && (intersection.y < leastdistance)) {					leastdistance = intersection.y 					bestangle = tempangle				}			}										var a0:Number			var a1:Number					var dAngle = Math.PI * 2 / angleSteps			a0 = bestangle - dAngle			a1 = bestangle + dAngle			bestangle = 0			leastdistance = h						for (var i = 0 ; i < angleSteps2; i++){				tempangle =  i / angleSteps2 * (a1 - a0) + a0								rot = new Matrix()				rot.a = Math.cos(tempangle)				rot.b = Math.sin(tempangle)				rot.c = -1 * Math.sin(tempangle)				rot.d = Math.cos(tempangle)							rot.tx = -( dx * Math.cos(tempangle) -  dy * Math.sin(tempangle)) + 0 // w/2				rot.ty = -( dy * Math.cos(tempangle) +  dx * Math.sin(tempangle))								img = new BitmapData(w,h, false);				img.draw(this,rot, new ColorTransform(1,1,1,1,255,-255,-255, 0));				imgAll.copyPixels(img,new Rectangle( 0,0,w,h) ,new Point(angleSteps + i,0))					intersection = img.getColorBoundsRect(0xFFFFFF,0xFF0000,true);				intersectiondistances[i] = intersection.y				if ((intersection.height !=0) && (intersection.y < leastdistance)) {					leastdistance = intersection.y 					bestangle = tempangle}			}							if (lastbmp != null) {thisUniverse.thisstage.removeChild(lastbmp)}			lastbmp = new Bitmap(imgAll)			lastbmp.x = 50			lastbmp.y = 100			thisUniverse.thisstage.addChild(lastbmp)			lastbmp.scaleX = 2			lastbmp.scaleY = 2						xyObj2PT = [0, leastdistance]			angleBest =bestangle			xyClose[0] = xyObj2PT[0] *Math.cos(angleBest) + xyObj2PT[1]* Math.sin(angleBest)// + pt[0]			xyClose[1] = xyObj2PT[1] *Math.cos(angleBest) - xyObj2PT[0]* Math.sin(angleBest)// + pt[1]									trace(["Coord, Angle",xyClose,bestangle])			if (!units){return [xyClose]}else{			var mag =Math.sqrt(Math.pow( xyClose[0],2) + Math.pow(xyClose[1],2))				unitPerp = [xyClose[0] * -1 / mag, xyClose[1] * -1 / mag]			unitPar  = [unitPerp[1],-1 * unitPerp[0]]			return([unitPar[0],unitPar[1],unitPerp[0],unitPerp[1]])			}			}		}				public function closestAlongRadius(pt:Array):Array {			var nearestCenter = getNearestCenterToPt(pt);			var cx = nearestCenter[0];			var cy = nearestCenter[1];			var rad = [pt[0] - cx, pt[1] -cy];			var radMag = Math.sqrt(Math.pow(rad[0], 2) + Math.pow(rad[1],2));			var radUnit= [rad[0] / radMag, rad[1] / radMag];			var radPerp= [-1 * radUnit[1], radUnit[0]];			var rot = new Matrix();			var angleRotate = Math.asin(radUnit[1]);			if (Math.cos(radUnit[0]) < 0 ) {				angleRotate = Math.PI - angleRotate;			}			angleRotate = - 1 * angleRotate			;			rot.a = Math.cos(angleRotate);			rot.b = Math.sin(angleRotate);			rot.c =-Math.sin(angleRotate);			rot.d = Math.cos(angleRotate)			;			//trace(thisUniverse.objects[0].y)			rot.tx = -(cx  * Math.cos(angleRotate) -  cy * Math.sin(angleRotate));			rot.ty = -(cy  * Math.cos(angleRotate) +  cx * Math.sin(angleRotate));						///NEED TO MAKE THIS DISPLAY CORRECTLY			var bounds = getBounds(thisUniverse);			var w = 5;			var h = Math.sqrt(Math.pow(bounds.height,2) + Math.pow(bounds.width,2));			var img:BitmapData = new BitmapData(w,h, false);			img.draw(this,rot, new ColorTransform(1,1,1,1,255,-255,-255,0));			/*			if (lastbmp != null) {thisUniverse.thisstage.removeChild(lastbmp)}			lastbmp = new Bitmap(img)			lastbmp.x = 50			lastbmp.y = 100			thisUniverse.thisstage.addChild(lastbmp)			lastbmp.scaleX = .2			lastbmp.scaleY = .2			*/			var intersection:Rectangle = img.getColorBoundsRect(0xFFFFFF,0xFF0000,true);			return [cx + radUnit[0] * intersection.height,cy + radUnit[1] * intersection.height];		}	}}