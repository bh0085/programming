﻿package physics.collisions{	import math.VectorMath2D	import math.VectorMath3D	import physics.PhysObject	import physics.PhysUniverse	import physics.PhysCollisions	import paths.PhysOutline	import mygraphics.ObjObj	import flash.display.Sprite		public class Collision{				public static function collisionYesNo(obj1:PhysObject, obj2:PhysObject):Boolean{			//trace(obj1,obj2)			if(obj1.thisOutline == null || obj2.thisOutline ==null){return false}			var v1 = obj1.getVel()			var v2 = obj2.getVel()			var magV = Math.sqrt(Math.pow(v1[0] - v2[0],2) + Math.pow(v1[1] - v2[1],2))						var intersect = PhysOutline.intersectionRectangle(obj1.thisOutline,obj2.thisOutline,magV)			if(intersect.width == 0){return false} else {				return true}					}/*		public static function paddedCollision(obj1:PhysObject, obj2:PhysObject,padding):Boolean{			var intersect = PhysOutline.intersectionRectangle(obj1.thisOutline,obj2.thisOutline,padding)								}*/				/*		public static function collision(obj1:PhysObject, obj2:PhysObject):Boolean{			if(!( (obj1.getAttachedTo() == obj2)  || (obj2.getAttachedTo() == obj1))){				var nc1:Number,nc2:Number,no1:Number,no2:Number				if(obj1.children == null){					nc1 = 0					no1 = 1				} else {nc1 = obj1.children.length; no1 = nc1}				if(obj2.children == null){					nc2 = 0					no2 = 1				} else {nc2 = obj2.children.length; no2 = nc2}								var objs1 = new Array(no1)								var objs2 = new Array(no2)				if(nc1 ==0){objs1[0] = obj1} else{					for(var i:Number = 0; i < nc1 ; i++){						objs1[i] = obj1.children[i]					}				}				if(nc2 ==0){objs2[0] = obj2} else{					for(i = 0; i < nc2 ; i++){						objs2[i] = obj2.children[i]					}				}								//Now I have two arrays populated with the children of each object and I can run a hitTest for each.								var j:Number = 0, skinDepth:Number				var collisionDepths = new Array(no1)				var collisionSkinDepths = new Array(no1)				var collisionUnits  = new Array(no1)				var theseUnits:Array				var out:Array				var isInside:Array = new Array(no1)				var xy1:Array				var xy2:Array								if(obj1.isPtLike){var ptLike = 1} else { if(obj2.isPtLike){ptLike =2} else {ptLike = 0}}								for(i = 0 ; i < no1 ; i++){					collisionDepths[i] = new Array(no2)					collisionUnits[i] = new Array(no2)					collisionSkinDepths[i] = new Array(no2)					for( j = 0 ; j<no2 ; j++){												xy1 = [objs1[i].getX(),objs1[i].getY()]						xy2 = [objs2[j].getX(),objs2[j].getY()]						var b1 = objs1[i].getBounds(obj1.thisUniverse)						var b2 = objs2[j].getBounds(obj1.thisUniverse)												if(ptLike == 1){								var bigObj = objs2[i]								var smallObj = objs1[j]						}else { if(ptLike == 2) {									bigObj = objs1[j]									smallObj = objs2[i]							}													}						if(bigObj != null){							if(bigObj.thisOutline != null){								var outline = bigObj.thisOutline								var localXY = outline.outline.localCoords([smallObj.getX(), smallObj.getY() ])								var surfaceBit = outline.outline.closest(localXY)								var surfacePoint = surfaceBit.ptBitClosest(localXY, true)								var surfaceUnits = outline.outline.getUnits(surfaceBit)											collisionUnits[i][j] = surfaceUnits																var altitude = [smallObj.getX() - surfacePoint[0], smallObj.getY() - surfacePoint[1]]								var depth = -1 * math.VectorMath2D.dotMultiply2D(altitude,[surfaceUnits[2],surfaceUnits[3]])								collisionDepths[i][j] = depth								skinDepth = objs1[i].skinDepth + objs2[j].skinDepth								collisionSkinDepths[i][j] = collisionDepths[i][j]/skinDepth								//trace(altitude)															} else {								collisionDepths[i][j] = 0							}						} else {							var distance = Math.sqrt(Math.pow(xy1[0] - xy2[0],2) + Math.pow(xy1[1] - xy2[1],2))							var r12 =[( xy2[0] - xy1[0] )/ distance,( xy2[1] - xy1[1]) / distance]							collisionUnits[i][j] = [r12[0],r12[1],-r12[1],r12[1]]							var depth = objs1[i].collisionRadius + objs2[j].collisionRadius - distance							skinDepth = objs1[i].skinDepth + objs2[j].skinDepth							collisionDepths[i][j] = depth							collisionSkinDepths[i][j] = collisionDepths[i][j]/skinDepth						}											}				}								var nColl = 0				var whichColl = new Array()								for(i = 0; i<no1 ; i++){					for(j= 0; j<no2 ; j ++){						if(collisionDepths[i][j] >0){							nColl++							whichColl.push([i,j])						}					}				}																var k:Number				if(nColl >0){					for(k = 0; k<nColl ; k++){						i = whichColl[k][0]						j = whichColl[k][1]						dampenObjects(objs1[i],objs2[j],nColl,collisionSkinDepths[i][j])					}									for(k = 0; k<nColl ; k++){						i = whichColl[k][0]						j = whichColl[k][1]						exertImpulses(objs1[i],objs2[j],collisionUnits[i][j])					}									for(k = 0; k<nColl ; k++){						i = whichColl[k][0]						j = whichColl[k][1]						secondDampenObjects(objs1[i],objs2[j],nColl,collisionSkinDepths[i][j])					}								}				if (nColl>0) {return true} else {return false}			} else {return false}		}						public static function exertImpulses(obj1:PhysObject,obj2:PhysObject,units:Array):void{															var unitPar = [units[0],units[1]];			var unitPerp= [units[2],units[3]];											var object:PhysObject			var eMasses = new Array(2)			var vPerps  = new Array(2)			var rChild:Array								var vParent:Array, vChild:Array, vPerp:Number			var distanceParalellToWall:Number						if(obj1.getNumCollisions(obj2.getUniverseIndex()) == 0){						for( var i:Number = 0; i < 2 ; i++ ){							if(i ==0) {object = obj1} else { object = obj2}					rChild = object.comRadius();						if (rChild != null){						distanceParalellToWall = VectorMath2D.dotMultiply2D(unitPar,rChild);						eMasses[i] = 1 / (Math.pow(distanceParalellToWall , 2) / object.childOf.momentOfInertia + 1 / object.childOf.mass);								vParent = object.childOf.velocity();						vChild  = VectorMath3D.crossMultiply3D([0,0,object.childOf.omega], [unitPar[0] *distanceParalellToWall,unitPar[1]*distanceParalellToWall,0]);						vPerp   = VectorMath2D.dotMultiply2D([vParent[0] + vChild[0],vParent[1] + vChild[1]],unitPerp)						vPerps[i] = vPerp												} else {						eMasses[i] = object.mass						vChild = object.velocity()						vPerp   = VectorMath2D.dotMultiply2D(vChild,unitPerp)						vPerps[i]=vPerp					}				}												var vCom = (vPerps[0]*eMasses[0] + vPerps[1]*eMasses[1])/(eMasses[0] + eMasses[1])				var vIns = [vPerps[0] - vCom, vPerps[1] - vCom]				var energyIn = .5 * eMasses[0]*Math.pow(vIns[0],2)+ .5 * eMasses[1]*Math.pow(vIns[1],2)				var magVOuts = new Array(2)				magVOuts[0] = Math.sqrt(energyIn * 2 * eMasses[1]/eMasses[0] * 1/(eMasses[0] + eMasses[1]))				magVOuts[1] = Math.sqrt(energyIn * 2 * eMasses[0]/eMasses[1] * 1/(eMasses[0] + eMasses[1]))				var vOuts = new Array(2)				if(vIns[0] < 0){					vOuts[0] = magVOuts[0]					vOuts[1] = magVOuts[1] * -1				} else {					vOuts[0] = magVOuts[0] * -1					vOuts[1] = magVOuts[1] 				}				var impulse1 = (vOuts[0] - vIns[0]) * eMasses[0]				var impulse2 = (vOuts[1] - vIns[1]) * eMasses[1]				obj1.exertImpulseOn([impulse1 * unitPerp[0],impulse1 * unitPerp[1]])				obj2.exertImpulseOn([impulse2 * unitPerp[0],impulse2 * unitPerp[1]])			}			}		public static function dampenObjects(obj1:PhysObject,obj2:PhysObject, nColl:Number, skinDepths:Number):void{			var object:PhysObject			for(var i:Number = 0; i < 2; i++){				if(i ==0){object = obj1} else { object = obj2 }									if (object.childOf != null ){object.childOf.dampen(getDamping(skinDepths,nColl,obj1.getNumCollisions(obj2.getUniverseIndex()),true))} else {								object.dampen(getDamping(skinDepths,nColl,obj1.getNumCollisions(obj2.getUniverseIndex()),true))}			}		}		public static function secondDampenObjects(obj1:PhysObject,obj2:PhysObject, nColl:Number, skinDepths:Number):void{				var object:PhysObject			for(var i:Number = 0; i < 2; i++){				if(i ==0){object = obj1} else { object = obj2 }									if (object.childOf != null ){object.childOf.dampen(getDamping(skinDepths,nColl,obj1.getNumCollisions(obj2.getUniverseIndex()),false))} else {								object.dampen(getDamping(skinDepths,nColl,obj1.getNumCollisions(obj2.getUniverseIndex()),false))}			}		}				public static function getDamping( skinDepth:Number, numChildrenCollided:Number, numCollisionsChild:Number, incoming:Boolean):Array {			var vdamp:Number			var wdamp:Number			if (numCollisionsChild == 0 ){vdamp = .9} else {vdamp = .9}			if (numChildrenCollided >= 0){wdamp = .9 } else {wdamp =.9 }						var xdamp = vdamp			var ydamp = vdamp			return([xdamp, ydamp, wdamp])								}				public static function getCollisionDepth(obj1:PhysObject, obj2:PhysObject,units:Array){			var collisiondepth = 0;			var angle12 = Math.sin(units[1])			if (units[0] < 0){angle12 = Math.PI - angle12}			var rotateRadians = -1 * angle12;			var intersection = PhysCollisions.physHitTestIrregular(obj1.getGraphic(), obj2.getGraphic() ,obj1.thisUniverse,rotateRadians);			if ((intersection != null)) {				collisiondepth = intersection.height;			}			return collisiondepth;					}				*/	}}