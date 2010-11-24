﻿package mygraphics{	import flash.display.BitmapData		import flash.display.DisplayObject	import flash.display.DisplayObjectContainer		import flash.display.Bitmap	import flash.display.Shape	import flash.display.Sprite	import flash.utils.ByteArray	import flash.geom.Rectangle	import flash.geom.ColorTransform	import flash.display.InterpolationMethod	import flash.geom.Matrix	import flash.display.BlendMode 	import flash.display.MovieClip		import flash.utils.getTimer	import math.VectorMath2D				public class ObjObj {						public static function findIntersect(obj1:DisplayObject, obj2:DisplayObject, container:DisplayObjectContainer):Rectangle{			var intersection:Rectangle			var b0 = findIntersectedBounds(obj1,obj2,container)			if(b0 != null){							var img = new BitmapData(b0.width,b0.height,false,0x000000)								var mat = new Matrix()								mat.tx = Obj.xyIn(obj1,container)[0] - b0.left				mat.ty = Obj.xyIn(obj1,container)[1] - b0.top				img.draw(obj1,mat, new ColorTransform(1,1,1,1,255,-255,-255,255))												mat.tx = Obj.xyIn(obj2,container)[0] - b0.left				mat.ty = Obj.xyIn(obj2,container)[1] - b0.top				img.draw(obj2,mat, new ColorTransform(1,1,1,1,-255,255,-255,255),"add")												intersection = img.getColorBoundsRect(0xFFFFFF,0xFFFF00,true)								intersection.x += b0.left				intersection.y += b0.top						} else {intersection = null}					return intersection					}				public static function findIntersectedBounds(obj1:DisplayObject,obj2:DisplayObject,container:DisplayObjectContainer,...args):Rectangle{			var margin:Number			if(args.length >0){margin = args[0]} else {margin = 2}				var b1 = obj1.getBounds(container)				var b2 = obj2.getBounds(container)								var left =Math.floor( Math.max(b1.left,b2.left)) - margin				var top  =Math.floor( Math.max(b1.top,b2.top)) - margin				var right=Math.floor( Math.min(b1.right,b2.right)) + margin				var bottom=Math.floor( Math.min(b1.bottom,b2.bottom)) + margin				var height = bottom - top				var width  = right -left				if(height <= 0 || width <= 0){return null} else{					var b0 = new Rectangle(left,top,width,height)					return b0				}		}				public static function getWindow(obj1:DisplayObject,obj2:DisplayObject,container:DisplayObjectContainer,margin:Number):Rectangle{						var b1 = obj1.getBounds(container)			var b2 = obj2.getBounds(container)							var left = Math.floor(Math.max(b1.left,b2.left))			var top  = Math.floor( Math.max(b1.top,b2.top))			var right= Math.floor( Math.min(b1.right,b2.right))			var bottom= Math.floor( Math.min(b1.bottom,b2.bottom))			var height = bottom - top			var width  = right -left			var b0 = new Rectangle(left,top,width,height)			if((b0.height) <= 0 ||(b0.width) <=0){return null}							var window = new Rectangle(b0.x - margin,b0.y - margin,b0.width + 2 * margin,b0.height + 2 * margin)												return window						}				public static function getSmartWindow(obj1:DisplayObject, obj2:DisplayObject, container:DisplayObjectContainer,... args):Rectangle{			// do a VERY low Resolution search to find a relevant area to examine for the closet point on BiggerObject to the smaller object...			var returnDiagonal:Number, searchBitmapDiagonal:Number,persistence:Number			if(args.length >0){returnDiagonal = args[0]} else { returnDiagonal = 30 }			if(args.length >1){searchBitmapDiagonal = args[1]} else { searchBitmapDiagonal = 20}			if(args.length >2){persistence = args[2]} else {persistence = 0}						var b1 = obj1.getBounds(container)			var b2 = obj2.getBounds(container)						var objP:DisplayObject			var objL:DisplayObject			var xyP:Array, xyL:Array			var pIsObj = 1			var smallBounds:Rectangle, bigBounds:Rectangle			if (Math.sqrt(Math.pow(b1.width,2) + Math.pow(b1.height,2)) > Math.sqrt(Math.pow(b2.width,2) + Math.pow(b2.height,2))){				objP = obj2;				objL = obj1;				smallBounds = b2				bigBounds = b1				pIsObj=2			} else {				objP = obj1;				objL = obj2;				bigBounds = b2				smallBounds= b1				pIsObj=1			}									//first we try a series of intersections with progressively bigger margins			var search = true			var bInt:Rectangle			var nAttempts:Number = 0			var pDiag = Math.sqrt(Math.pow(smallBounds.width,2) + Math.pow(smallBounds.height,2))			for(var i = 0; i< 10 ; i ++){				if(search){					bInt = findIntersectedBounds(objP,objL,container,pDiag * i / 5)					if (bInt != null) { search = false}					nAttempts++				}			}			if(bInt != null){var searchRectangle = bInt}  else{return null}						var sWidth = searchBitmapDiagonal / Math.sqrt(2)			var sHeight= searchBitmapDiagonal / Math.sqrt(2)			var margin= 5			var sData :BitmapData			 search = true			nAttempts = 0			for( i = 0; i<10; i++){				if(search){					nAttempts ++					sData = new BitmapData(sWidth,sHeight,false,0x000000)					 xyL = Obj.xyIn(objL,container)					var xyLInWindow = [xyL[0] - searchRectangle.x, xyL[1] - searchRectangle.y]					var scaleX = sWidth / searchRectangle.width					var scaleY = sHeight/ searchRectangle.height					var objLMat = new Matrix(scaleX,0,0,scaleY,xyLInWindow[0] * scaleX, xyLInWindow[1] * scaleY)										sData.draw(objL,objLMat,new ColorTransform(1,1,1,1,255,-255,-255,255),BlendMode.NORMAL)					var findRect = sData.getColorBoundsRect(0xFFFFFF,0x000000,true)											if (findRect.height == 0 && findRect.width ==0 ){						searchRectangle = new Rectangle(searchRectangle.x - margin,searchRectangle.y-margin, searchRectangle.width+margin*2,searchRectangle.height+margin*2)					} else { 						if(findRect.height == sData.height && findRect.width == sData.width) {							searchRectangle = new Rectangle(searchRectangle.x - margin,searchRectangle.y-margin, searchRectangle.width+margin*2,searchRectangle.height+margin*2)						} else {search = false}										}				}			}																							/*												if(zoomSprite != null){				container.stage.removeChild(zoomSprite)			}			zoomSprite = new Sprite()						var bmp1 = new Bitmap(sData)			zoomSprite.addChild(bmp1)			var rsp = new Sprite()			rsp.graphics.lineStyle(1,0xFFFFFF)			rsp.graphics.beginFill(0xFFFFFF, .3)			rsp.graphics.drawRect(findRect.x,findRect.y,findRect.width,findRect.height)			zoomSprite.addChild(rsp)			zoomSprite.scaleX = 3			zoomSprite.scaleY = 3			zoomSprite.x = 50			zoomSprite.y = 50			container.stage.addChild(zoomSprite) */			if(search == true){return null} else {return searchRectangle}																										  							}				public static function getLowResData(xyP:Array,objL:DisplayObject,xyL:Array,window:Rectangle,attemptedDiagonal:Number,noZoom:Boolean):Array{						var xyPInWindow = [xyP[0] - window.x, xyP[1] - window.y]			var xyLInWindow = [xyL[0] - window.x, xyL[1] - window.y]						var windowMaxDistance = Math.sqrt(Math.pow(window.height,2) + Math.pow(window.width,2))			var maxDistancePToWindow = windowMaxDistance + Math.sqrt(Math.pow(xyPInWindow[0],2) + Math.pow(xyPInWindow[1],2))						var attemptedRescaleX:Number, attemptedRescaleY:Number			if(!noZoom){				attemptedRescaleX = attemptedDiagonal / windowMaxDistance				attemptedRescaleY = attemptedDiagonal / windowMaxDistance			} else {				attemptedRescaleX = 1				attemptedRescaleY = 1			}									var rescaledWindow = new Rectangle(window.x,window.y,Math.floor(attemptedRescaleX * window.width), Math.floor(attemptedRescaleY * window.height))			var rescaleX = rescaledWindow.width/window.width			var rescaleY = rescaledWindow.height/window.height						var xyPInWindowRescaled = [xyPInWindow[0] * rescaleX, xyPInWindow[1] * rescaleY]			var xyLInWindowRescaled = [xyLInWindow[0] * rescaleX, xyLInWindow[1] * rescaleY]			//for now, the metric created is created with exactly the same size as the original image and then rescaled for bitmapData creation.			//is this slow?						var metric = new Shape()			var gradientSize  = maxDistancePToWindow* 2			var gradientLength= gradientSize/2			var gradientMatrix = new Matrix()			gradientMatrix.createGradientBox(gradientSize,gradientSize,0,xyPInWindow[0] - gradientSize/2 ,xyPInWindow[1] -gradientSize/2 )						metric.graphics.beginGradientFill("radial",[0x000000,0x0000FF],[1,1],[1,255],gradientMatrix,'pad',InterpolationMethod.LINEAR_RGB)			metric.graphics.drawRect(0,0,window.width,window.height)							var objLMat = new Matrix(rescaleX,0,0,rescaleY,xyLInWindowRescaled[0],xyLInWindowRescaled[1])			var metricMat = new Matrix(rescaleX,0,0,rescaleY,0,0)						var d = new BitmapData(rescaledWindow.width,rescaledWindow.height,false,0x000000)			d.draw(objL,objLMat,new ColorTransform(1,1,1,1,255,-255,-255,255),BlendMode.NORMAL)			d.draw(metric,metricMat ,new ColorTransform(1,1,1,1,0,0,0,255),BlendMode.ADD)								return [d,rescaledWindow]					}				public static function getLowResDataWithGreen(objP:DisplayObject,xyP:Array,objL:DisplayObject,xyL:Array,window:Rectangle,attemptedDiagonal:Number,noZoom:Boolean):Array{						var xyPInWindow = [xyP[0] - window.x, xyP[1] - window.y]			var xyLInWindow = [xyL[0] - window.x, xyL[1] - window.y]						var windowMaxDistance = Math.sqrt(Math.pow(window.height,2) + Math.pow(window.width,2))			var maxDistancePToWindow = windowMaxDistance + Math.sqrt(Math.pow(xyPInWindow[0],2) + Math.pow(xyPInWindow[1],2))						var attemptedRescaleX:Number, attemptedRescaleY:Number			if(!noZoom){				attemptedRescaleX = attemptedDiagonal / windowMaxDistance				attemptedRescaleY = attemptedDiagonal / windowMaxDistance			} else {				attemptedRescaleX = 1				attemptedRescaleY = 1			}									var rescaledWindow = new Rectangle(window.x,window.y,Math.floor(attemptedRescaleX * window.width), Math.floor(attemptedRescaleY * window.height))			var rescaleX = rescaledWindow.width/window.width			var rescaleY = rescaledWindow.height/window.height						var xyPInWindowRescaled = [xyPInWindow[0] * rescaleX, xyPInWindow[1] * rescaleY]			var xyLInWindowRescaled = [xyLInWindow[0] * rescaleX, xyLInWindow[1] * rescaleY]			//for now, the metric created is created with exactly the same size as the original image and then rescaled for bitmapData creation.			//is this slow?						var metric = new Shape()			var gradientSize  = maxDistancePToWindow* 2			var gradientLength= gradientSize/2			var gradientMatrix = new Matrix()			gradientMatrix.createGradientBox(gradientSize,gradientSize,0,xyPInWindow[0] - gradientSize/2 ,xyPInWindow[1] -gradientSize/2 )						metric.graphics.beginGradientFill("radial",[0x000000,0x0000FF],[1,1],[1,255],gradientMatrix,'pad',InterpolationMethod.LINEAR_RGB)			metric.graphics.drawRect(0,0,window.width,window.height)							var objLMat = new Matrix(rescaleX,0,0,rescaleY,xyLInWindowRescaled[0],xyLInWindowRescaled[1])			var objPMat = new Matrix(rescaleX,0,0,rescaleY,xyPInWindowRescaled[0],xyPInWindowRescaled[1])			var metricMat = new Matrix(rescaleX,0,0,rescaleY,0,0)						var d = new BitmapData(rescaledWindow.width,rescaledWindow.height,false,0x000000)			d.draw(objL,objLMat,new ColorTransform(1,1,1,1,255,-255,-255,255))			d.draw(objP,objPMat,new ColorTransform(1,1,1,1,-255,255,-255,255),BlendMode.ADD)						d.draw(metric,metricMat ,new ColorTransform(1,1,1,1,0,0,0,255),BlendMode.ADD)								return [d,rescaledWindow,gradientLength]					}				public static function searchRedBlue(bits:ByteArray,highRed:Boolean):Array{			var red = uint, blue = uint			var leastGoodBlue = -1			var leastIDX = -1			var thisDistance:Number			var minOfAllBlue = -1						for(var i:uint =0;i<bits.length;i+=4){				red = bits[i+1]				blue= bits[i+3]				 				if(i==0){					minOfAllBlue = 255					leastGoodBlue = 255				}				if((blue < minOfAllBlue)  ){					minOfAllBlue = blue				}				if(highRed){					if(red >= 125){						if((blue < leastGoodBlue) ){							leastGoodBlue = blue							leastIDX = i						}					}				} else {					if(red <= 125){						if((blue < leastGoodBlue) ){							leastGoodBlue = blue							leastIDX = i						}					}					}			}			return([leastIDX, leastGoodBlue, minOfAllBlue])		}				public static function searchRedBlueGreen(bits:ByteArray,highRed:Boolean):Array{			var red = uint, blue = uint, green = uint			var leastGoodBlue = -1			var leastIDX = -1			var thisDistance:Number			var minOfAllBlue = -1			var minIntersectionBlue = -1,maxIntersectionBlue = -1						for(var i:uint =0;i<bits.length;i+=4){				red = bits[i+1]				green = bits[i+2]				blue= bits[i+3]				 				if(i==0){					minOfAllBlue = 255					leastGoodBlue = 255				}				if((blue < minOfAllBlue)  ){					minOfAllBlue = blue				}								if(red >125 && green >125){					if(blue<minIntersectionBlue || minIntersectionBlue == -1){minIntersectionBlue = blue}					if(blue<maxIntersectionBlue || maxIntersectionBlue == -1){maxIntersectionBlue = blue}				}				if(highRed){					if(red >= 125){						if((blue < leastGoodBlue) ){							leastGoodBlue = blue							leastIDX = i						}					}				} else {					if(red <= 125){						if((blue < leastGoodBlue) ){							leastGoodBlue = blue							leastIDX = i						}					}					}			}				var intersectMaxMin = [minIntersectionBlue,maxIntersectionBlue]			return([leastIDX, leastGoodBlue, minOfAllBlue,intersectMaxMin])		}		/*		public static function vectorsToIntersection(obj1XY:Array,obj1:DisplayObject,obj2XY:Array,obj2:DisplayObject,container:DisplayObjectContainer,... args):Array{					//Section to identify which object to treat as an object and which to treat as a point:			var b1 = obj1.getBounds(container)			var b2 = obj2.getBounds(container)			var objP:DisplayObject			var objL:DisplayObject			var xyP:Array, xyL:Array			var pIsObj = 1			if (Math.sqrt(Math.pow(b1.width,2) + Math.pow(b1.height,2)) > Math.sqrt(Math.pow(b2.width,2) + Math.pow(b2.height,2))){				objP = obj2; xyP = obj2XY				objL = obj1; xyL = obj1XY				pIsObj=2			} else {				objP = obj1; xyP = obj1XY				objL = obj2; xyL = obj2XY				pIsObj=1			}					//uses Input args or a pair of searches to define the window.			var allowExpansionOfSearch:Boolean, windowRect:Rectangle			var window:Rectangle			if(args.length > 0){windowRect = args[0]}else{windowRect = null}			if(args.length > 1){allowExpansionOfSearch:Boolean} else {allowExpansionOfSearch = false}						if(windowRect == null){window = getWindow(obj1,obj2,container,20)} else{				window = windowRect			}			if(window == null){				b2 = objL.getBounds(container)				var left = Math.floor(b2.left)				var top  = Math.floor(b2.top)				var right= Math.floor(b2.right)				var bottom= Math.floor(b2.bottom)				var h = bottom - top				var w = right - left				var margin = 10				window = new Rectangle(left,top,w,h)			} 						var greenToo:Boolean = false						var search = true, nSearches = 0			var isInside = false,noEdge = false, noZoom = false,foundNativeZoom = false			var bestIDXLeastBlue:Array			var depth:Number,leastOfAllBlue:Number,leastGoodBlue:Number,leastIDX:Number						var gradientLengths = new Array()			var maxMinDifferences= new Array()			var windowDiagonal:Number						var hasFoundMinimum = false			while(search){							windowDiagonal = Math.sqrt(Math.pow(window.width,2) +  Math.pow(window.height,2))				if((windowDiagonal < 30 ) || (nSearches >= 2)){					search = false					foundNativeZoom = true					noZoom = true				}								nSearches += 1				var dLandWindow				if(greenToo){					dLandWindow = getLowResDataWithGreen(objP,xyP,objL,xyL,window,30,noZoom)					gradientLengths.push(dLandWindow[2])				} else { 					dLandWindow = getLowResData(xyP,objL,xyL,window,20,noZoom)				}									var dL = dLandWindow[0]				var bits = dL.getPixels(new Rectangle(0,0,dL.width,dL.height))								if(greenToo){					bestIDXLeastBlue = searchRedBlueGreen(bits,!isInside)					maxMinDifferences.push(bestIDXLeastBlue[3])				} else {					bestIDXLeastBlue = searchRedBlue(bits,!isInside)				}								 leastOfAllBlue = bestIDXLeastBlue[2]				 leastGoodBlue = bestIDXLeastBlue[1]				 leastIDX =  bestIDXLeastBlue[0]				if(leastOfAllBlue == leastGoodBlue){					isInside = !isInside					if(greenToo){						bestIDXLeastBlue = searchRedBlueGreen(bits,!isInside)						maxMinDifferences.push(bestIDXLeastBlue[3])					} else {						bestIDXLeastBlue = searchRedBlue(bits,!isInside)					}					leastOfAllBlue = bestIDXLeastBlue[2]					leastGoodBlue = bestIDXLeastBlue[1]					leastIDX = bestIDXLeastBlue[0]				}				if(leastIDX == -1){					hasFoundMinimum = false				} else {					hasFoundMinimum = true				}				var rowBestLow = Math.floor(leastIDX / 4 /   dL.width)				var colBestLow = Math.floor((leastIDX / 4) % dL.width)				var lowScaleX  = dL.width/ window.width				var lowScaleY  = dL.height/window.height					var rowBestFull =Math.floor( rowBestLow / lowScaleY )				var colBestFull =Math.floor( colBestLow / lowScaleX )				var xBest = colBestFull + window.x				var yBest = rowBestFull + window.y						var searchOffsetX =Math.floor( 1 / lowScaleX ) * 3				var searchOffsetY =Math.floor( 1 / lowScaleY ) * 3				if(hasFoundMinimum){					window = new Rectangle(window.x + colBestFull - searchOffsetX, window.y + rowBestFull - searchOffsetX,searchOffsetX*2, searchOffsetY *2)				} else {					if(allowExpansionOfSearch){						window = new Rectangle(window.x - window.width/2, window.y - window.height/2, window.width * 2, window.height * 2)					} else {						return null					}				}										}			var depths = new Array()						for(var i = 0 ; i< maxMinDifferences.length ; i++){				depths.push((maxMinDifferences[i][1] - maxMinDifferences[i][0])/gradientLengths[i])			}			var bestFromPtX = xBest - xyP[0]			var bestFromPtY = yBest - xyP[1]			var bestFromLX  = xBest - xyL[0]			var bestFromLY =  yBest - xyL[1]						var vectorToSurface:Array			if(pIsObj ==1){			 vectorToSurface = [ bestFromPtX, bestFromPtY,bestFromLX,bestFromLY,isInside,pIsObj]			} else {			 vectorToSurface = [ bestFromLX, bestFromLY,bestFromPtX,bestFromPtY,isInside,pIsObj]							}			return vectorToSurface			}*/				public static function closestPoint(obj1XY:Array,obj1:DisplayObject,obj2XY:Array,obj2:DisplayObject,container:DisplayObjectContainer,windowRect:Rectangle, ... args):Array{							var allowExpansionOfSearch:Boolean			if(args.length > 0){allowExpansionOfSearch = args[0]} else {allowExpansionOfSearch = false}		 	var window = windowRect			//Section to identify which object to treat as an object and which to treat as a point:			var b1 = obj1.getBounds(container)			var b2 = obj2.getBounds(container)			var objP:DisplayObject			var objL:DisplayObject			var xyP:Array, xyL:Array			var pIsObj = 1			if (Math.sqrt(Math.pow(b1.width,2) + Math.pow(b1.height,2)) > Math.sqrt(Math.pow(b2.width,2) + Math.pow(b2.height,2))){				objP = obj2; xyP = obj2XY				objL = obj1; xyL = obj1XY				pIsObj=2			} else {				objP = obj1; xyP = obj1XY				objL = obj2; xyL = obj2XY				pIsObj=1			}						var greenToo:Boolean = false			var bestAndIsInside:Array						if( !greenToo ){							bestAndIsInside = PtObj.closestPoint(xyP,xyL,objL,container,window)			} else {								var search = true, nSearches = 0				var isInside = false, noZoom = false,foundNativeZoom = false								var gradientLengths = new Array()				var maxMinDifferences= new Array()				var windowDiagonal:Number								var hasFoundMinimum = false				while(search){									windowDiagonal = Math.sqrt(Math.pow(window.width,2) +  Math.pow(window.height,2))					if((windowDiagonal < 30 ) || (nSearches >= 2)){						search = false						foundNativeZoom = true						noZoom = true					}					nSearches += 1					var dLandWindow = getLowResDataWithGreen(objP,xyP,objL,xyL,window,30,noZoom)					gradientLengths.push(dLandWindow[2])					var dL = dLandWindow[0]					var bits = dL.getPixels(new Rectangle(0,0,dL.width,dL.height))										var bestIDXLeastBlue = searchRedBlueGreen(bits,!isInside)					maxMinDifferences.push(bestIDXLeastBlue[3])					var leastOfAllBlue = bestIDXLeastBlue[2]					var leastGoodBlue = bestIDXLeastBlue[1]					var leastIDX =  bestIDXLeastBlue[0]						if(leastOfAllBlue == leastGoodBlue){						 isInside = !isInside						 bestIDXLeastBlue = searchRedBlueGreen(bits,!isInside)						 maxMinDifferences.push(bestIDXLeastBlue[3])						 leastOfAllBlue = bestIDXLeastBlue[2]						 leastGoodBlue = bestIDXLeastBlue[1]						 leastIDX = bestIDXLeastBlue[0]					}										if(leastIDX == -1){hasFoundMinimum = false} else {hasFoundMinimum = true}						var rowBestLow = Math.floor(leastIDX / 4 /   dL.width)					var colBestLow = Math.floor((leastIDX / 4) % dL.width)					var lowScaleX  = dL.width/ window.width					var lowScaleY  = dL.height/window.height							var rowBestFull =Math.floor( rowBestLow / lowScaleY )					var colBestFull =Math.floor( colBestLow / lowScaleX )					var xBest = colBestFull + window.x					var yBest = rowBestFull + window.y								var searchOffsetX =Math.floor( 1 / lowScaleX ) * 2					var searchOffsetY =Math.floor( 1 / lowScaleY ) * 2					if(hasFoundMinimum){						window = new Rectangle(xBest - searchOffsetX, yBest - searchOffsetX,searchOffsetX*2, searchOffsetY *2)					} else {						if(allowExpansionOfSearch){							window = new Rectangle(window.x - window.width/2, window.y - window.height/2, window.width * 2, window.height * 2)						} else {							return null						}					}				}				if(hasFoundMinimum){ bestAndIsInside = [[xBest,yBest], isInside] }			}			if(bestAndIsInside ==null){return null}			return [bestAndIsInside[0],bestAndIsInside[1],pIsObj]			}						public static function vectorsToIntersectionWithUnits(obj1XY:Array,obj1:DisplayObject,obj2XY:Array,obj2:DisplayObject,container:DisplayObjectContainer,...args):Array{				var ts = new Array()		ts.push(flash.utils.getTimer())			var searchRectangle:Rectangle			var allowExpansionOfSearch:Boolean, giveUpIfNoIntersection:Boolean			if(args.length ==0){searchRectangle = null} else {searchRectangle = args[0]}			if(args.length >1 ){allowExpansionOfSearch = args[1]} else {allowExpansionOfSearch = false}			if(args.length >2 ){giveUpIfNoIntersection = args[2]} else {giveUpIfNoIntersection = true }						if(giveUpIfNoIntersection){				var intersection = findIntersectedBounds(obj1,obj2,container,10)				if(intersection == null){return null}			}						if(searchRectangle == null){				searchRectangle = getSmartWindow(obj1,obj2,container)			}			if(searchRectangle == null){return null}						//Does a search for a vector to the surface... the parameter false tells it not to expand the search window if it does not find a result			var firstVector = closestPoint(obj1XY,obj1,obj2XY,obj2,container,searchRectangle,allowExpansionOfSearch)			if(firstVector == null) { return null }						ts.push(flash.utils.getTimer())						var pIsObject = firstVector[2]			var unitOut:Array			var magVec:Number			var ptOnSurface = firstVector[0]						var vecSmallToSurf:Array			if(pIsObject == 1){vecSmallToSurf =[ ptOnSurface[0] - obj1XY[0],ptOnSurface[1] - obj1XY[1]]}			else {vecSmallToSurf =[ ptOnSurface[0] - obj2XY[0],ptOnSurface[1] - obj2XY[1]]}						magVec = Math.sqrt(Math.pow(vecSmallToSurf[0],2) + Math.pow(vecSmallToSurf[1],2))			if(firstVector[1] == true){unitOut = [vecSmallToSurf[0]/magVec,vecSmallToSurf[1]/magVec]}				else {unitOut = [-vecSmallToSurf[0]/magVec,-vecSmallToSurf[1]/magVec]}			unitAlong = [unitOut[1],-unitOut[0]]						var numInEach = 7, magShift = 20			var pt1s=  new Array(), pt2s = new Array()							var lastPt1:Array,lastPt2:Array,vecAlong1:Array, vecAlong2:Array				var shiftXY1 = [  unitAlong[0] * magShift, unitAlong[1]* magShift]				var shiftXY2 = [ - unitAlong[0] * magShift, - unitAlong[1]* magShift]				var pt1 = ptOnSurface				var pt2 = ptOnSurface				var guess1 = [ptOnSurface[0] + shiftXY1[0],ptOnSurface[1] + shiftXY1[1]]				var guess2 = [ptOnSurface[0] + shiftXY2[0],ptOnSurface[1] + shiftXY2[1]]				var rect1:Rectangle,rect2:Rectangle,margin:Number,lastGuess1:Array,lastGuess2:Array			var startingT:Number, out:Array			var nRedos = 0						pt1s.push(ptOnSurface)						for (var i = 0; i <numInEach ; i++){			startingT = flash.utils.getTimer()					margin = Math.floor(magShift * .5)					rect1 = new Rectangle(guess1[0] - margin,guess1[1] - margin, 2 * margin, 2 * margin)					rect2 = new Rectangle(guess2[0] - margin,guess2[1] - margin, 2 * margin, 2 * margin)							lastPt1 = pt1					lastPt2 = pt2										var k = 3							if(pIsObject ==1){						out = PtObj.closestPoint(guess1,obj2XY,obj2,container,rect1)						if(out != null){pt1 = out[0]}						if(pt1 == lastPt1){							nRedos++							rect1 = new Rectangle(guess1[0] - margin * k, guess1[1] - margin *k, margin *2*k,margin*2*k)							out =PtObj.closestPoint(guess1,obj2XY,obj2,container,rect1)							if(out != null){pt1 = out[0]}						}												out = PtObj.closestPoint(guess2,obj2XY,obj2,container,rect2)						if(out != null){pt2 = out[0]}						if(pt2 == lastPt2){							nRedos++							rect2 = new Rectangle(guess2[0] - margin * k, guess2[1] - margin *k, margin *2*k,margin*2*k)							out =PtObj.closestPoint(guess2,obj2XY,obj2,container,rect2)							if(out != null){pt2 = out[0]}						}					} else {						out = PtObj.closestPoint(guess1,obj1XY,obj1,container,rect1)						if(out != null){pt1 = out[0]} 						if(pt1 == lastPt1){							nRedos++							rect1 = new Rectangle(guess1[0] - margin * k, guess1[1] - margin *k, margin *2*k,margin*2*k)							out =PtObj.closestPoint(guess1,obj2XY,obj2,container,rect1)							if(out != null){pt1 = out[0]}						}						out = PtObj.closestPoint(guess2,obj1XY,obj1,container,rect2)						if(out != null){pt2 = out[0]}						if(pt2 == lastPt2){							nRedos++							rect2 = new Rectangle(guess2[0] - margin * k, guess2[1] - margin *k, margin *2*k,margin*2*k)							out =PtObj.closestPoint(guess2,obj2XY,obj2,container,rect2)							if(out != null){pt2 = out[0]}						}										}														if(pt1 != lastPt1){pt1s.push(pt1)}					if(pt2 != lastPt2){pt2s.push(pt2)}					 vecAlong1 = [pt1[0] - lastPt1[0], pt1[1] - lastPt1[1]]					var magV1 = Math.sqrt(Math.pow(vecAlong1[0],2) +Math.pow(vecAlong1[1],2))					var unitAlong1 = [vecAlong1[0] / magV1, vecAlong1[1]/magV1]															 vecAlong2 = [pt2[0] - lastPt2[0], pt2[1] - lastPt2[1]]					var magV2 = Math.sqrt(Math.pow(vecAlong2[0],2) +Math.pow(vecAlong2[1],2))					var unitAlong2 = [vecAlong2[0] / magV2, vecAlong2[1]/magV2]										guess1 = [pt1[0] + unitAlong1[0]*magShift, pt1[1] + unitAlong1[1]*magShift] 					guess2 = [pt2[0] + unitAlong2[0]*magShift, pt2[1] + unitAlong2[1]*magShift] 								}						var pts = new Array()			for(i = 0; i< pt2s.length; i++){				pts.push(pt2s[pt2s.length - 1 - i])			}			for(i = 0; i<pt1s.length; i++){				pts.push(pt1s[i])			}						ts.push(flash.utils.getTimer())					if(pt1 == null || pt2 == null) { return null }									var difference = [pt1[0] - pt2[0], pt1[1] - pt2[1]]						var dmag = Math.sqrt(Math.pow(difference[0],2) + Math.pow(difference[1],2))			var unitTangent= [difference[0] / dmag, difference[1] / dmag]			var unitPerp   = [-1* unitTangent[1], unitTangent[0]]			if(VectorMath2D.dotMultiply2D(unitPerp,unitOut) < 0){				unitPerp = [-1 * unitPerp[0],-1 * unitPerp[1]]			}			var unitAlong = [unitPerp[1],- unitPerp[0]]			if(isNaN(unitPerp[0]) || isNaN(unitAlong[0])){				return null}						//Returns a four element Array containing :			//1: the Collision Pt in the same Coordinated System as ptXY			//2: Unit vectors pointing perpendicular to and along larger surface			//3: A Boolean telling whether the smaller object is inside of the first object and therefore whether the unit Vector is an outward or Inward normal to the larger surface			//4: A Number, 1 or 2 Saying which of the objects from the input is the smaller and therefore the collider...															return([ ptOnSurface,[unitAlong[0],unitAlong[1],unitPerp[0],unitPerp[1]],firstVector[1],firstVector[2],pts])								}							}	}