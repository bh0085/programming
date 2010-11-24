﻿package paths{	import math.VectorMath2D	import flash.display.Shape	import flash.geom.Matrix	import flash.display.BitmapData	import flash.geom.ColorTransform		public class Path2D{						public var isClosed = false 		public var closeDistance = 150		public var minCloseLength = 10		public var mDist = 20		public var fixedEnds = false				public var subPaths = new Array()		public var subPathsOutOfDate = new Array()		public var subPathsInNeed = new Array()		public var pathX = new Array()		public var pathY = new Array()		public var numAvgd = new Array()				public var orientation = 1		public var netOrientation = 0		public var sureOrientation = false		var orientationThreshold = 20		var subPathPtDensity = 20		var happyMass = 10		public var zeroTension = false		public var addKeypoints = true				public function setOrientation(number:Number):void{			orientation = number		}		public function pushOrientation(number:Number):void{			if(!sureOrientation){				netOrientation += number				if(Math.abs(netOrientation) > orientationThreshold){sureOrientation = true}				if(netOrientation >= 0){setOrientation(1)} else{ setOrientation(-1) }			}		}		public function firstGuessOutPosOrientation():Array{			var seg0 = [pathX[0],pathY[0]]			var seg1 = [pathX[1],pathY[1]]			var vec = [seg1[0] - seg0[0],seg1[1] - seg0[1]]			var magVec = Math.sqrt(Math.pow(vec[0],2) + Math.pow(vec[1],2))			var unitVec = [vec[0] / magVec, vec[1] / magVec]			var unitOutPosOrientation = [-unitVec[1] , unitVec[0]]			return unitOutPosOrientation		}				public function pushPt(ptX,ptY,...args){			var mass:Number			if(args.length == 0){mass = 1} else {mass = args[0]}						var lp = pathX.length			if(lp > 1){				if(! isClosed) {					var ptOnRay = [pathX[0] + pathX[0] - pathX[1],pathY[0] + pathY[0] - pathY[1]] 					var dist = VectorMath2D.ptRayDist([ptX,ptY],[pathX[0],pathY[0]], ptOnRay )					var minDist = dist[0]					var bestIDX = 0				} else {					seg0 = [pathX[pathX.length - 1], pathY[pathY.length -1]]					seg1 = [pathX[0],pathY[0]]					dist = VectorMath2D.ptLineDist([ptX,ptY],seg0,seg1,false )					minDist = dist[0]					bestIDX = 0				}									for(var i =0 ; i<lp - 1 ; i++){					var seg0 = [pathX[i],pathY[i]]					var seg1 = [pathX[i +1], pathY[i +1]]					var pt = [ptX,ptY]					dist = VectorMath2D.ptLineDist(pt,seg0,seg1,false)					if(dist[0] < minDist){						minDist = dist[0]						bestIDX = i + 1					}				}								if(! isClosed){					dist = VectorMath2D.ptRayDist([ptX,ptY],[pathX[lp-1],pathY[lp-1]], [pathX[lp-1] + pathX[lp-1] - pathX[lp - 2],pathY[lp-1] + pathY[lp -1] - pathY[lp - 2]]  )					if(dist[0] <minDist){						minDist = dist[0]						bestIDX = pathX.length					}				}				if( !fixedEnds || (bestIDX != 0 && bestIDX != pathX.length) ){					insertPt(bestIDX,ptX,ptY,mass)				}			} else{				insertPt(0,ptX,ptY,mass)			}		}		public function pushPts(ptsX,ptsY,... args):void{			if(args.length > 0){var masses = args[0]} else {masses = new Array()}			if(masses.length ==0){				masses = new Array(ptsX.length)				for(j = 0; j<ptsX.length ; j++){					masses[j] = 1				}			}			for(var j = 0; j< ptsX.length; j++){				pushPt(ptsX[j], ptsY[j], masses[j])			}		}		public function pushSubPts(ptsX,ptsY,masses):void{			for(var i = 0; i < ptsX.length ; i++){				pushSubPt(ptsX[i],ptsY[i],masses[i])			}		}		public function pushSubPt(ptX,ptY,mass):void{					var kptOrig = addKeypoints					addKeypoints = false					pushPt(ptX,ptY,mass)					addKeypoints = kptOrig										}				public function pushKeypoints(ptsX,ptsY,masses):void{			for(var i = 0; i < ptsX.length ; i++){				pushKeypoint(ptsX[i],ptsY[i],masses[i])			}		}		public function pushKeypoint(ptX,ptY,mass):void{					var kptOrig = addKeypoints					addKeypoints = true					pushPt(ptX,ptY,mass)					addKeypoints = kptOrig										}				public function removeKeypoint(index):void{			var idxStart = index -1			var idxFinish = index +1			spliceOut(idxStart,idxFinish)		}		public function spliceOut(idxStart:Number,idxFinish:Number):void{				var numRemove = idxFinish - idxStart - 1				subPaths.splice(idxStart+ 1, numRemove)				subPaths[idxStart] = null				for (var i = idxStart + 1; i < subPaths.length ; i++){					if (subPaths[i] != null){subPaths[i].pIndex -= numRemove}				}				subPathsOutOfDate.splice(idxStart + 1,numRemove)				subPathsOutOfDate[idxStart] = true				subPathsInNeed.splice(idxStart + 1,numRemove)				subPathsInNeed[idxStart] = true				pathX.splice(idxStart + 1,numRemove)				pathY.splice(idxStart + 1,numRemove)				numAvgd.splice(idxStart + 1, numRemove)					}		public function spliceIn(ptX:Number,ptY:Number, mass:Number,idx):void{				addKeypoint(ptX,ptY,mass,idx)		}		public function addKeypoint(ptX:Number,ptY:Number,mass:Number,index:Number):void{				pathX.splice(index,0,ptX)				pathY.splice(index,0,ptY)				numAvgd.splice(index,0,mass)				subPaths.splice(index,0,null)				for (var i = index + 1; i < subPaths.length ; i++){					if(subPaths[i] != null) {subPaths[i].pIndex += 1}				}				subPathsOutOfDate.splice(index,0,true)				if(index != 0){subPathsOutOfDate[index -1] = true}								subPathsInNeed.splice(index,0,true)				if(index != 0){subPathsInNeed[index -1] = true}				if(pathX.length != 1){genSubPath(index)}				if(index != 0){genSubPath(index - 1)}						}		public function moveKeypoint(moveX:Number,moveY:Number,index:Number):void{				pathX[index] += moveX				pathY[index] += moveY				subPathsOutOfDate[index] = true				if(index != 0){ subPathsOutOfDate[index -1 ] = true }				genSubPath(index)				genSubPath(index - 1)		}		public function keypointsInNeed():Array{			var out = new Array(pathX.length)			var foundNone = true			for (var i = 0; i<pathX.length; i++){				if(numAvgd[i] < happyMass){					out[i] = true					foundNone = false					} else {					out[i] = false				}			}			if(foundNone){return null} else{return out}					}		public function getSubpathsInNeed():void{			for(var i = 0 ; i < subPaths.length ; i++){				subPathsInNeed[i] = false				if(subPaths[i] != null){					var mass = subPaths[i].getMinMass()					if (mass < 3){subPathsInNeed[i] = true}					//trace(i,"Mass",mass)									} else {subPathsInNeed[i] = true}			}			if(! isClosed) { subPathsInNeed[subPaths.length - 1] = false } 		}		public function genSubPath(index){			subPaths[index] = new SubPath2D(this,index,4)			subPathsOutOfDate[index] = false		}						public function insertPt(index:Number, ptX:Number, ptY:Number,mass:Number):void{				tensionInsert(index,ptX,ptY,mass)				}		public function insertPtAtEnd( ptX:Number, ptY:Number,mass:Number):void{				var index = pathX.length				addKeypoint(ptX,ptY,mass,index)				}				public function insertPtAtBeginning( ptX:Number, ptY:Number,mass:Number):void{				addKeypoint(ptX,ptY,mass,0)				}		public function tensionInsert(index:Number,ptX:Number, ptY:Number,mass:Number){			var pl = pathX.length			var insert = true			if((index == 0 || index >= pl)){				if(!isClosed) {					if(addKeypoints){						addKeypoint(ptX,ptY,mass,index)						insert = false					}				} 			}			if(insert){				var i0 = index-1				var i1 = index				if(i0 < 0){i0 = pathX.length + i0}				if(i0 >= pathX.length){i0 = i0 - pathX.length}				if(i1 >= pathX.length){i1 = i1 - pathX.length}								var seg0 = [pathX[i0],pathY[i0]]				var seg1 = [pathX[i1],pathY[i1]]				var pt = [ptX,ptY]				var intersect = VectorMath2D.ptLineClosest(pt,seg0,seg1,false)				var delta = [ptX - intersect[0],ptY - intersect[1]]				var distanceToPrev = Math.sqrt(Math.pow(intersect[0] - seg0[0],2) + Math.pow(intersect[1] - seg0[1],2))				var distanceToNext = Math.sqrt(Math.pow(intersect[0] - seg1[0],2) + Math.pow(intersect[1] - seg1[1],2))				if(addKeypoints){					var attachTo = -1					if(distanceToPrev < mergeDist()){						attachTo = 0					} 					if (distanceToNext < mergeDist() && distanceToNext < distanceToPrev) {						attachTo = 1					}					if(attachTo == -1){												addKeypoint(intersect[0],intersect[1],mass,i1)						movement = delta						zeroTensionMove(i1,movement[0],movement[1])															}					if(attachTo == 0){						var newX =( pathX[i0] *numAvgd[i0] + mass* ptX)/(numAvgd[i0]+mass )						var newY =( pathY[i0] *numAvgd[i0] + mass* ptY)/(numAvgd[i0]+mass )						var movement = [newX - pathX[i0],newY - pathY[i0]]						if(!zeroTension){							tensionMove(i0,movement[0],movement[1],mass)						} else{							zeroTensionMove(i0,movement[0],movement[1])						}						numAvgd[i0] += mass					}					if(attachTo == 1){						 newX =( pathX[i1] *numAvgd[i1] + mass* ptX)/(numAvgd[i1]+mass )						 newY =( pathY[i1] *numAvgd[i1] + mass* ptY)/(numAvgd[i1]+mass )						 movement = [newX - pathX[i1],newY - pathY[i1]]						if(!zeroTension){							tensionMove(i1,movement[0],movement[1],mass)						} else{							zeroTensionMove(i1,movement[0],movement[1])						}												numAvgd[i1] += mass					}				} else {					attachTo = -1					if(distanceToPrev == 0){						attachTo = 0					} 					if (distanceToNext == 0) {						attachTo = 1					}					if(attachTo == -1){												if(subPaths[i0] != null){							subPaths[i0].pushPt(ptX,ptY,1)						}					}				}			}		}										public function addToKeypoint(ptX:Number,ptY:Number,mass:Number,i0:Number):void{						var newX =( pathX[i0] *numAvgd[i0] + mass* ptX)/(numAvgd[i0]+mass )						var newY =( pathY[i0] *numAvgd[i0] + mass* ptY)/(numAvgd[i0]+mass )						var movement = [newX - pathX[i0],newY - pathY[i0]]						zeroTensionMove(i0,movement[0],movement[1])						numAvgd[i0] += mass					}		public function calcTensionCof(dist:Number,maxDist:Number,thisDist:Number):Number{			return (.5* (1 - dist/maxDist) + .5) * ((1 - .5*thisDist / maxDist)) 		}		public function zeroTensionMove(index,moveX,moveY){			pathX[index] += moveX			pathY[index] += moveY		}		public function tensionMove(index:Number,moveX:Number, moveY:Number,mass:Number){			var pl = pathX.length			var doMove = true			if((index == 0 || index >= pl)){				if(!isClosed){					doMove = false				} 			}			if(doMove){				var neighbors = 10				var maxDist = mergeDist() * neighbors												var origX = pathX[index]				var origY = pathY[index]								var delta = [moveX,moveY]				pathX[index] += moveX				pathY[index] += moveY								var dist:Number,massFrac:Number				var searchLow = true, searchHigh = true				var lowLast = delta, highLast = delta				var origLowLast = [origX,origY]				var origHighLast = [origX,origY]				var lowMassLast = numAvgd[index], highMassLast = numAvgd[index]				for(var i = 0 ; i< neighbors; i++){					if(searchLow){						var idx = index - 1 - i						if(idx < 0){ if(isClosed) {idx = pathX.length + idx } else {searchLow = false} }						if(searchLow){							dist = Math.sqrt(Math.pow(pathX[idx] - origX,2) + Math.pow(pathY[idx] - origY,2))							if(dist < maxDist){								massFrac = Math.min(lowMassLast/numAvgd[idx],1)								lowMassLast = numAvgd[idx]																var dOldToLast = [pathX[idx] - origLowLast[0],pathY[idx] - origLowLast[1]]								var distToLast = Math.sqrt(Math.pow(dOldToLast[0],2) + Math.pow(dOldToLast[1],2))								 origLowLast = [pathX[idx],pathY[idx]]								var cof = calcTensionCof(dist,maxDist,distToLast)																lowLast = [massFrac* lowLast[0]*cof,massFrac*lowLast[1]*cof]								moveKeypoint(lowLast[0],lowLast[1],idx)								numAvgd[idx] += mass * dist / maxDist							} else {searchLow = false}						}					}					if(searchHigh){						 idx = index + 1 + i						if(idx > pathX.length - 1){ if(isClosed) {idx =idx - pathX.length } else {searchHigh = false} }						if(searchHigh){							dist = Math.sqrt(Math.pow(pathX[idx] - origX,2) + Math.pow(pathY[idx] - origY,2))							if(dist < maxDist){								massFrac = Math.min(highMassLast/numAvgd[idx],1)								highMassLast = numAvgd[idx]																 dOldToLast = [pathX[idx] - origHighLast[0],pathY[idx] - origHighLast[1]]								 distToLast = Math.sqrt(Math.pow(dOldToLast[0],2) + Math.pow(dOldToLast[1],2))								  origHighLast = [pathX[idx],pathY[idx]]								 cof = calcTensionCof(dist,maxDist,distToLast)																highLast = [highLast[0]*massFrac*cof,massFrac*highLast[1]*cof]								moveKeypoint(highLast[0],highLast[1],idx)								numAvgd[idx] += mass * dist / maxDist							} else {searchHigh = false}						}					}				}			}		}				public function setMergeDistance(num:Number){			mDist = num		}		public function mergeDist():Number{return mDist}				public function setCloseDistance(num:Number){closeDistance = num}		public function openClose():void{			var pt0 = [pathX[0] , pathY[0]]			var pt1 = [pathX[pathX.length -1], pathY[pathX.length -1]]			var dist = Math.sqrt(Math.pow(pt0[0]- pt1[0],2) + Math.pow(pt0[1] - pt1[1],2))			if(dist<closeDistance){isClosed = true} else { isClosed = false }			if(pathX.length < minCloseLength){isClosed = false}		}				public static function mergePaths(path1:Path2D,path2:Path2D):Path2D{			var newPath = path1.copyPath()			newPath.pushOrientation(path1.netOrientation)			newPath.pushKeypoints(path2.pathX,path2.pathY,path2.numAvgd)			return newPath		}		public function copyPath():Path2D{			var out = new Path2D()			var kptOrig = addKeypoints			addKeypoints = true			for (var i = 0 ; i < pathX.length ; i++){				out.insertPtAtEnd(pathX[i],pathY[i],numAvgd[i])			}			addKeypoints = kptOrig			return out		}		public function pushPath(path:Path2D){			pushKeypoints(path.pathX,path.pathY,path.numAvgd)		}		public function prune(minDistance:Number):void{			var lastGoodXY:Array,thisXY:Array			var spliceStart:Number, spliceFinish:Number			var splicedPath:Path2D			var isBad = false, hitBad = false, hitGood = false									lastGoodXY = [pathX[0] , pathY[0]]			for (var i = 1; i < pathX.length ; i++){				thisXY = [pathX[i],pathY[i]]				var magDiff = Math.sqrt(Math.pow(thisXY[0] - lastGoodXY[0],2) + Math.pow(thisXY[1] - lastGoodXY[1],2))								if(isBad){					if(magDiff < minDistance*2 && i != pathX.length - 1){						splicedPath.insertPtAtEnd(pathX[i],pathY[i],numAvgd[i])					} else {						 hitGood = true					}				}								if(!isBad){					if(magDiff < minDistance){						 hitBad = true					} else {						lastGoodXY = thisXY					}				} 								if(hitBad){					hitBad = false					isBad = true					spliceStart = i - 1					splicedPath = new Path2D()					splicedPath.insertPtAtEnd(pathX[i],pathY[i],numAvgd[i])									}				if(hitGood){												spliceFinish = i					isBad = false					hitGood = false					lastGoodXY = thisXY					var com = splicedPath.centerOfMass()					var comPt = [com[0],com[1]]					var massPt = com[2]					spliceOut(spliceStart,spliceFinish)					spliceIn(comPt[0],comPt[1],massPt,spliceStart + 1)					var numRemoved = spliceFinish - spliceStart - 1					i = i - numRemoved + 1									}			}		}				public function centerOfMass():Array{			var mass = 0			var xNet = 0			var yNet = 0			for( var i = 0 ; i < pathX.length ; i ++){				mass += numAvgd[i]				xNet += pathX[i] * numAvgd[i]				yNet += pathY[i] * numAvgd[i]			}			return ([xNet / mass, yNet/ mass, mass])		}		public function averageMass(segIdx,numEitherSide){			var mass = 0			var num = 0			for(var i = 0; i < numEitherSide; i++){				var idxPlus = segIdx + 1 + i				var idxMinus = segIdx - i				if(isClosed){					if(idxPlus >= pathX.length){idxPlus = idxPlus - pathX.length}					if(idxMinus < 0){idxMinus = pathX.length + idxMinus}				}				if(idxPlus < pathX.length){					mass += numAvgd[idxPlus]					num += 1				}				if (idxMinus >= 0){					mass += numAvgd[idxMinus]					num += 1				}			}			if(num ==0) {return 0}			return mass / num							}		public function minMass(segIdx,numEitherSide){			var minMass = -1			var num = 0			for(var i = 0; i < numEitherSide; i++){				var idxPlus = segIdx + 1 + i				var idxMinus = segIdx - i				if(isClosed){					if(idxPlus >= pathX.length){idxPlus = idxPlus - pathX.length}					if(idxMinus < 0){idxMinus = pathX.length + idxMinus}				}				if(idxPlus < pathX.length){					num += 1					var thisMass = numAvgd[idxPlus]					if(thisMass < minMass || minMass == -1){						minMass = thisMass					}				} else {					trace("idxPlus > length")					return 0				}								if (idxMinus >= 0){					num += 1					 thisMass = numAvgd[idxMinus]					if(thisMass < minMass || minMass == -1){						minMass = thisMass					}				} else {					trace("idxMinus < 0")					return 0				}			}		if(minMass == -1) {return 0}		return minMass		}		public function getClosestUnits(pt:Array){			var seg = closestSegmentToPoint(pt,true)			var segIdx = seg[1]			var units = getClosestUnitsSegIncluded(segIdx,pt)			return units					}		public function getClosestUnitsSegIncluded(segIdx:Number,pt:Array,...args){			if(args.length ==0){var ignoreSub = false} else {ignoreSub = args[0]}			if(subPaths[segIdx] == null || ignoreSub){				var i0=segIdx 				var i1=segIdx + 1				if(i1 >= pathX.length){i1 = i1 - pathX.length} 				if(i0 >= pathX.length){i0 = i0 - pathX.length} 				if(i1< 0){i1 = i1 + pathX.length} 				if(i0< 0){i1 = i0 + pathX.length} 				var seg0 = [pathX[i0],pathY[i0]]				var seg1 = [pathX[i1],pathY[i1]]				var vec = [seg1[0] - seg0[0],seg1[1] - seg0[1]]				var magVec = Math.sqrt(Math.pow(vec[0],2) + Math.pow(vec[1],2))				var unitVec = [orientation * vec[0] / magVec,orientation * vec[1] / magVec]				var unitOut = [-unitVec[1] , unitVec[0]]						return([unitVec[0],unitVec[1],unitOut[0],unitOut[1]])						} else {				var i = subPaths[segIdx].closestSegment(pt[0],pt[1])				var units = subPaths[segIdx].getUnits(i)				return units			}					}		public function getClosestPointOnSegment(pt:Array,index:Number):Array{			if(subPaths[index] == null){				var i0 = index				var i1 = index + 1				if(i1 >= pathX.length){i1 = i1 - pathX.length} 				var seg0 = [pathX[i0],pathY[i0]]				var seg1 = [pathX[i1],pathY[i1]] 				var intersect = VectorMath2D.ptLineClosest(pt,seg0,seg1,false)								} else {				var i = subPaths[index].closestSegment(pt[0],pt[1])				var bigS0 =[ pathX[index],pathY[index]] 				 i1 = index + 1				if(i1 >= pathX.length){ i1 = i1 - pathX.length }				var bigS1 =[ pathX[i1],pathY[i1]] 								if(i == -1){										 seg0 = bigS0					 seg1 = [subPaths[index].pathX[i +1], subPaths[index].pathY[i +1]]										} else {										if( i== subPaths[index].num -1){						 seg0 = [subPaths[index].pathX[i],subPaths[index].pathY[i]]						 seg1 = bigS1										} else {						 seg0 = [subPaths[index].pathX[i],subPaths[index].pathY[i]]						 seg1 = [subPaths[index].pathX[i +1], subPaths[index].pathY[i +1]]					}				}								intersect = VectorMath2D.ptLineClosest(pt,seg0,seg1,false)			}			return intersect			}		public function closestSegmentToPoint(pt:Array,fast:Boolean):Array{			  			if(!fast){				var bestDist = -1				var bestSegIDX = -1				for(var k =0 ; k< pathX.length ; k ++){					var xy1 = [pathX[k],pathY[k]]					var i1 = k + 1					if(i1 >= pathX.length ){i1 = i1 - pathX.length}					var xy2 = [pathX[i1],pathY[i1]]					var xy3 = [pt[0],pt[1]]					var dist = VectorMath2D.ptLineDist(pt,xy1,xy2,false)[0]					if( (bestDist== -1) || dist < bestDist){						bestDist = dist						bestSegIDX = k					}						}				//trace(bestSegIDX)				return([bestDist,bestSegIDX])			}else{				 bestDist = -1				 bestSegIDX = -1				for( k =0 ; k< pathX.length ; k ++){					 xy1 = [pathX[k],pathY[k]]					 i1 = k + 1					if(i1 >= pathX.length ){i1 = i1 - pathX.length}					 xy2 = [pathX[i1],pathY[i1]]					 xy3 = [pt[0],pt[1]]					var dist1 = Math.sqrt(Math.pow(xy1[0] - xy3[0], 2) + Math.pow(xy1[1] - xy3[1],2))					var dist2 = Math.sqrt(Math.pow(xy2[0] - xy3[0], 2) + Math.pow(xy2[1] - xy3[1],2))					dist = dist1 + dist2					if( (bestDist== -1) || dist < bestDist){						bestDist = dist						bestSegIDX = k					}						}				//trace(bestSegIDX)				return([bestDist,bestSegIDX])			}					}						public function toShape():Shape{			var shape = new Shape()			shape.graphics.moveTo(pathX[0],pathY[0])			for(var i = 0; i< pathX.length ; i++){				shape.graphics.lineStyle(0)				shape.graphics.lineTo(pathX[i],pathY[i])															}						shape.graphics.lineStyle(0,0x000000)			for(  i = 0 ; i<pathX.length ; i ++){				shape.graphics.drawCircle(pathX[i],pathY[i],5)				if(subPathsOutOfDate[i] == false && subPaths[i] != null){					for(var j = 0 ; j<subPaths[i].pathX.length ; j++){						shape.graphics.drawCircle(subPaths[i].pathX[j],subPaths[i].pathY[j],2)					}				}			}			if(isClosed){				shape.graphics.lineStyle(0,0xFFFF00)				shape.graphics.drawCircle(pathX[0],pathY[0],20)				shape.graphics.drawCircle(pathX[pathX.length -1],pathY[pathX.length -1],8)			}			return shape 		}				public static function findConnectedIntersection(path1:Path2D,path2:Path2D):Path2D{			if(path1.isClosed == false || path2.isClosed == false){trace("Cannot Intersect Unclosed Paths") ; return null}			var pts1Inside = new Array(path1.pathX.length)			var pts2Inside = new Array(path2.pathX.length)			var nIn1 = 0, nIn2 = 0			path1.genShape()			path2.genShape()			for(var i = 0; i<pts1Inside.length ; i++){				pts1Inside[i] = path2.ptIsInside([path1.pathX[i],path1.pathY[i]],false)				if(pts1Inside[i]){nIn1 ++}			}						for( i = 0; i<pts2Inside.length ; i++){				pts2Inside[i] = path1.ptIsInside([path2.pathX[i],path2.pathY[i]],false)				if(pts2Inside[i]){nIn2 ++}			}			if(nIn1 == 0 && nIn2 == 0){return null}						var newPath = new Path2D()			var ptX, ptY			for(i = 0 ; i<pts1Inside.length ; i++){				if(pts1Inside[i]){					ptX = path1.pathX[i]					ptY = path1.pathY[i]					newPath.insertPtAtEnd(ptX,ptY,0)				}			}						var atEnd :Boolean			var hasFoundEnd = false			for(i = 0 ; i<pts2Inside.length ; i++){				if(pts2Inside[i]){										ptX = path2.pathX[i]					ptY = path2.pathY[i]					if(hasFoundEnd == false){						if(nIn1 == 0){hasFoundEnd = true ; atEnd = true}					}					if(hasFoundEnd == false){						var ptEnd = [newPath.pathX[newPath.pathX.length - 1], newPath.pathY[newPath.pathX.length - 1]]						var ptStart = [newPath.pathX[0], newPath.pathY[0]]						var diff0 = Math.sqrt(Math.pow(ptX - ptStart[0],2) + Math.pow(ptY - ptStart[1],2))						var diff1 = Math.sqrt(Math.pow(ptX - ptEnd[0],2) + Math.pow(ptY - ptEnd[1],2))						if(diff1 < diff0){atEnd = true} else {atEnd = false}						hasFoundEnd = true					}					if(atEnd){newPath.insertPtAtEnd(ptX,ptY,0)} else{ newPath.insertPtAtBeginning(ptX,ptY,0)}				}			}			return newPath								}				public var myFill:Shape		public function genShape(...args):void{			if(args.length ==0){var color = 0xFFFFFF} else{ color = args[0]}			myFill = new Shape()			myFill.graphics.beginFill(color)			myFill.graphics.lineStyle(0)			myFill.graphics.moveTo(pathX[0],pathY[0])			var detailed = true			for(var i = 0; i < pathX.length ; i++){				myFill.graphics.lineTo(pathX[i],pathY[i])				if(detailed){					if(subPaths[i] != null){						for(var j = 0 ; j < subPaths[i].pathX.length ; j++){							myFill.graphics.lineTo(subPaths[i].pathX[j],subPaths[i].pathY[j])						}					}				}			}		}		public function ptIsInside(pt:Array,gen:Boolean):Boolean{			if(gen){genShape()}			if(myFill == null){genShape()}			var d = new BitmapData(2,1,false,0x000000)			var mat = new Matrix(1,0,0,1,-pt[0],-pt[1])			d.draw(myFill,mat,new ColorTransform(1,1,1,1,255,-255,-255,255))			var rect = d.getColorBoundsRect(0xFFFFFF,0xFF0000,true)			if(rect.width == 0){return false} else {return true}		}		public function closestEnd(pt):Number{						var ptEnd = [pathX[pathX.length - 1],pathY[pathX.length - 1]]						var ptStart = [pathX[0],pathY[0]]						var diff0 = Math.sqrt(Math.pow(pt[0] - ptStart[0],2) + Math.pow(pt[1] - ptStart[1],2))						var diff1 = Math.sqrt(Math.pow(pt[0] - ptEnd[0],2) + Math.pow(pt[1] - ptEnd[1],2))						if(diff1 < diff0){return 1} else{return 0}		}				public function forcePoints(mag:Number, center:Array, radius:Number){			for(var i = 0 ; i<pathX.length ; i++){				var dist = Math.sqrt(Math.pow(center[0] - pathX[i],2) + Math.pow(center[1] - pathY[i],2))				trace(dist/radius)				if(dist< radius){										var unit0 = getClosestUnitsSegIncluded(i,null,true)					var unit1 = getClosestUnitsSegIncluded(i - 1,null,true)					var uAvg = [.5 * ( unit0[2] + unit1[2]) , .5 * (unit1[3] + unit0[3])]					var unit = [-(pathX[i] - center[0])/dist,-(pathY[i] - center[1])/dist]					 uAvg = [.5 * (uAvg[0] +unit[0]) , .5 * (uAvg[1] + unit[1])]										var motion = [mag *uAvg[0] * (1 - dist / radius), mag * uAvg[1] * (1 - dist/radius)]					zeroTensionMove(i,motion[0],motion[1])					var i0 = i - 1					if(i0 <0){i0 = pathX.length + i0}					var i1 = i					genSubPath(i0)					genSubPath(i1)				}			}		}						}}