﻿package physics.objects.oscript{	import physics.PhysUniverse	import physics.objects.PhysObject	import flash.geom.Rectangle	import flash.display.Sprite	import flash.display.Shape	import flash.display.BitmapData	import flash.display.Bitmap	import flash.geom.Matrix		import math.VectorMath2D	import flash.utils.getTimer			public class nearObject extends ObjectScript{						public var objNear		public var nearestNodes		public var surfaceNodes:Array		public var avgUp:Array		public var surfaceUnits:Array		public var surfacePoints:Array			public var surfaceHeights:Array			public var sfcPtAvg:Array		public var sfcUnitsAvg:Array		public var escapeSpeed:Array						function friction():void{			thisObject.dampenAlong(avgUp,1.2,true)			thisObject.dampen([.9,.9,.4])		}		 function alignWithSurface():void{			var objUp = thisObject.unitUp()			var sfcUp = [sfcUnitsAvg[2],sfcUnitsAvg[3]]					var angObj = Math.asin(objUp[1])					if(objUp[0] < 0){ angObj = Math.PI - angObj }					var angSfc = Math.asin(sfcUp[1])					if(sfcUp[0] < 0){ angSfc = Math.PI - angSfc }			var angleDelta = angSfc - angObj			var search = true			 while( search ){				if(angleDelta < -1 * Math.PI) { angleDelta += Math.PI * 2 }				if(angleDelta > Math.PI) {angleDelta -= Math.PI*2 }				if(Math.abs(angleDelta) <= Math.PI) {search = false}			}			thisObject.rotateBy(angleDelta/3)		}		public function testDetach():Boolean{			var s = new Sprite()			s.graphics.lineStyle(1)			s.graphics.moveTo(thisObject.getX(),thisObject.getY())			s.graphics.lineTo(thisObject.getX() +sfcUnitsAvg[2]* 50 ,thisObject.getY() + sfcUnitsAvg[3]* 50)			//thisObject.setExtraGFX(s)			var v= thisObject.getVel()			var vUp = math.VectorMath2D.dotMultiply2D([sfcUnitsAvg[2],sfcUnitsAvg[3]],v)			if(vUp > escapeSpeed){return true} else{ return false }		}		public function findNearestNodes():void{						var nodes = thisObject.getNodesCollided(objNear.thisOutline)			setNearestNodes(nodes[0])		}		public function setInfo():void{				findNearestNodes()				surfacePoints = new Array()				surfaceUnits = new Array()				surfaceNodes = new Array()				surfaceHeights = new Array()				sfcPtAvg = [0,0]				sfcUnitsAvg = [0,0,0,0]				for(var i = 0; i < nearestNodes.length ; i ++){					thisObject.setCollisionsAllowed(objNear,false)					var outline = objNear.thisOutline.outline					var pt = nearestNodes[i].thisCtdOutline.nodeExternalCoords(nearestNodes[i])												var surfaceBit = outline.closest(pt)					surfaceNodes.push(surfaceBit)					var localXY = outline.localCoords(pt)					var sfcXY = surfaceBit.ptBitClosest(localXY,true) 					surfacePoints.push(sfcXY)					sfcPtAvg[0] += sfcXY[0]/nearestNodes.length					sfcPtAvg[1] += sfcXY[1]/nearestNodes.length					var sfcUnits = outline.getUnitsExt(surfaceBit)						surfaceUnits.push(sfcUnits)					var altitude = [pt[0] - sfcXY[0],pt[1] - sfcXY[1]]					var height = math.VectorMath2D.dotMultiply2D([sfcUnits[2],sfcUnits[3]],altitude)					surfaceHeights.push(height)					sfcUnitsAvg = [sfcUnitsAvg[0] + sfcUnits[0],sfcUnitsAvg[1] +sfcUnits[1], sfcUnitsAvg[2] + sfcUnits[2],sfcUnitsAvg[3] + sfcUnits[3]]				}				var sfcMag1 = Math.sqrt(Math.pow(sfcUnitsAvg[0], 2) + Math.pow(sfcUnitsAvg[1],2))				sfcUnitsAvg = [sfcUnitsAvg[0] / sfcMag1, sfcUnitsAvg[1]/sfcMag1,-sfcUnitsAvg[1]/sfcMag1,sfcUnitsAvg[0]/sfcMag1]				avgUp = [sfcUnitsAvg[2],sfcUnitsAvg[3]]					}		override public function advance(...args):void{			var step = args[0]			if(step == 1 || step == 2){				setInfo()				if(testDetach()){					thisObject.setCollisionsAllowed(objNear,true)					scriptDone = true				}						}			if(step == 1){					if(!scriptDone){					friction()					alignWithSurface()									} 			}			if(step == 1 || step ==2){				if(thisObject.numAttachScripts() != 0){					scriptDone = true					return				}				if(surfaceHeights[0] < 0 || surfaceHeights[1] < 0){					thisObject.createAttachScript(objNear)					scriptDone = true				}			}								}		public function setNear(obj:PhysObject):void{			objNear = obj			multiPriorities = true		}		public function setNearestNodes(nodes:Array):void{			nearestNodes = nodes		}			}}