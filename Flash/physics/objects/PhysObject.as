﻿package physics.objects{		import math.MathArray	import math.VectorMath3D	import math.VectorMath2D		import tanks.tank.Tank	import physics.twobody.TwoBodyCollision		import physics.PhysOverlay	import physics.PhysSuper	import physics.PhysUniverse	import physics.pscript.PhysScript	import physics.objects.oscript.ObjectScript	import physics.objects.oscript.attachToObj	import physics.objects.oscript.bounceOffObj	import physics.objects.oscript.nearObject	import physics.objects.oscript.attachedToObject	import physics.pscript.stickToObject	import physics.projectile.NewtonianSphere	import physics.misc.Dipole	import physics.misc.Multipole		import flash.utils.getQualifiedClassName	import flash.display.MovieClip	import flash.display.Sprite	import flash.display.DisplayObject	import flash.text.TextField	import Math	import flash.geom.Rectangle	import flash.events.MouseEvent	import flash.events.Event	import flash.utils.getTimer	import flash.display.Graphics	import paths.Node	import paths.PhysOutline		import mygraphics.PtObj	import mygraphics.Obj			public class PhysObject extends MovieClip {				//Physical Constants			public static var eps = 8.845 * Math.pow(10, -12)	//Free Space Permittivity in MKS					public static var kc = 9*Math.pow(10,9)				//Coulomb law K in MKS					public static var G = 6.67 * Math.pow(10, -11)	//Gravitational Constant		//Dragging Scripts (needed?)			public var dragging:Boolean = false;				//Handles dragging			public var lastclicktimer:Number = 0 				//Double Click Timer					public var dragTicker:Number = 0					//Drag Stuff			public var pastx:MathArray = new MathArray()								public var pasty:MathArray = new MathArray()			public var pastvx:MathArray = new MathArray()			public var pastvy:MathArray	 = new MathArray()						public var isDraggable:Boolean = true				//Physical Characteristics		public var isDestroyed = false	 	var momentOfInertia:Number = 0		var COM = [0,0]		var mass = 0		var customCharges:Array = new Array()		var charge = 0		var omega:Number = 0		public var angle:Number = 0		var xvel = 0;								var yvel = 0;						var ftorqueThisTimeStep = [0,0,0]		var multipole:Multipole		public var physX = 0, physY = 0		//Graphics		public var graphic:Sprite;		public var gfxMask:DisplayObject;		public var extraGFX:Sprite		//Constraint/Collision		public var constraint = null				public var minimumMassToAttachTo:Number = 20000		public var objectCanAttach = false		public var objectCanBeAttachedTo = false		public var objectCanStick = false		public var objectIsSticky = false		public var skinDepth = 10						var detachPronto = false		public var collisionsForbidden = new Array()		public var unitSpread = 0 //The unit spread is used when calling the getUnits function for any				//Management of universe membership (needed??)		public var thisUniverseIndex:Number;	 		public var thisUniverse:PhysUniverse;						//Dynamic attributes		public var isstatic:Boolean = false;				//Disables motion		public var isSleeping:Boolean = false				//Does not compute Forces		public var staticInFields: Array = new Array()		//Tells it to skip certain field in the computation of forces		//Misc Properties		public var scripts = new Array()		public var minimumMeaningfulLengthScale = 100		public var color = 0xFFFFFF		public var thisOutline:PhysOutline		public var eraseable = false		public function PhysObject(){			graphic = new Sprite()			addChild(graphic)		}//TIMESTEP		public function executeScripts(priority:Number):void	{			if  (scripts.length != 0){				for (var i = 0 ; i< (scripts.length) ;i ++){							if (scripts[i].advanceDefault(priority)){							scripts[i].endScriptDefault()							scripts.splice(i,1)							i--}}}		}		public function defaultFT():void						{			forceOn()		}		public function resetFT():void							{			ftorqueThisTimeStep = [0,0,0]		}		public function applyForces():void{				accelerateBy([ftorqueThisTimeStep[0]/ mass,ftorqueThisTimeStep[1]/mass])				if (momentOfInertia != 0) {angularAccelerateBy(ftorqueThisTimeStep[2]/ momentOfInertia)}						resetFT()					}		public function defaultKinematics():void				{				applyForces()				kineticFriction()							rotateStep()				moveStep() 		}		public function executeTimeStep():Boolean 				{			if (! isstatic && ! dragging ) {return true} else {return false}		}					public function timeStep1():void						{			if(!isSleeping){defaultFT()}		}		public function timeStep2():void						{						if (executeTimeStep()){				defaultKinematics()			}		}				//COLLISION SCRIPTING				public function mustDetach():Boolean												{			if(detachPronto){				detachPronto = false; 				return true}			else return false		}		public function collided():void														{}		public static function collision(obj1:PhysObject,obj2:PhysObject):void				{			if(obj1.getCollisionsAllowed(obj2) && obj2.getCollisionsAllowed(obj1)){				var b1 = obj1.getBounds(obj1.getUniverse())				var b2 = obj2.getBounds(obj2.getUniverse())				var b0 = b1.intersection(b2)				if(b0.width != 0){					var v1 = obj1.getVel()					var v2 = obj2.getVel()					var magV = Math.sqrt(Math.pow(v1[0] - v2[0],2) + Math.pow(v1[1] - v2[1],2))					var intersect = PhysOutline.intersectionRectangle(obj1.thisOutline,obj2.thisOutline,magV *PhysUniverse.timestep)					if(intersect.width != 0){						var i2 = PhysOutline.intersectionRectangle(obj1.thisOutline,obj2.thisOutline,0)						if(i2.width !=  0){ var hasHit = true} else{hasHit = false}						obj1.collidedWith(obj2,hasHit)						obj2.collidedWith(obj1,hasHit)					}				}			}					}		public function collidedWith(obj:PhysObject,hasHit:Boolean):void					{						if(getCollisionsAllowed(obj)){				if(hasHit){collided()}												if(doesAttachTo(obj)){					if(numAttachScripts() == 0){						var nodesCollided = getNodesCollided(obj.thisOutline)						createNearObjectScript(obj,nodesCollided[0])					} else {						trace("conflicting attachment ignored")					}				} 				if(hasHit){					if(doesStickTo(obj)){						trace("sticking")						createStickToScript(obj)					}									}			}		}		public function getNodesCollided(po:PhysOutline)									{			var outs =[new Array(), new Array()]			var search = true			var nodes = thisOutline.outline.nodesInOrder()						for(var i = 0 ; i <nodes.length ; i++){					var node = nodes[i]					var nodeExternalXY = node.thisCtdOutline.nodeExternalCoords(node)					var collision = po.getCollision(nodeExternalXY)					outs[0].push(collision[0])					outs[1].push(collision[1])			}			var altitudes = outs[0]			var bestAlt:Number			var bestIDX:Number = -1			var secondBestIDX = -1			var secondBestAlt:Number			for(i = 0 ; i <altitudes.length ; i ++){				if(bestIDX == -1 || altitudes[i] < bestAlt){					secondBestIDX = bestIDX					secondBestAlt = bestAlt					bestIDX = i					bestAlt = altitudes[i]				} else {					if ( secondBestIDX == -1 || altitudes[i] < secondBestAlt){							secondBestAlt = altitudes[i]							secondBestIDX = i					}				}			}			var bits = outs[1]			var closeBits = [bits[bestIDX],bits[secondBestIDX]]			var closeNodes= [nodes[bestIDX],nodes[secondBestIDX]]			return([closeNodes,closeBits,[bestAlt,secondBestAlt]])		}		public function doesAttachTo(object:PhysObject):Boolean								{			if(objectCanAttach){				if (minimumMassToAttachTo > 0){					if(object.getMass() > minimumMassToAttachTo){return true} else {return false}				} else {return false}			} else {return false}		}		public function doesStickTo(object:PhysObject):Boolean								{			if(objectCanStick && object.objectIsSticky){return true} else{return false}					}		public function setAttachMass(arg:Number)											{			minimumMassToAttachTo = arg		}		public function createNearObjectScript(object:PhysObject,nodesAttached:Array):void	{			var nearScript = new nearObject()			addObjectScript(nearScript)			nearScript.setNear(object)			nearScript.setNearestNodes(nodesAttached)		}		public function createAttachScript(object:PhysObject):void		{			var attachScript = new attachToObj()			addObjectScript(attachScript)			attachScript.setAttachedTo(object)			attachScript.setWhichAttached([thisOutline.outline.first,thisOutline.outline.first.next])					}		public function numAttachScripts():Number{			var dummy = new attachedToObject()			var num = ObjectScript.howManyInObject(dummy,this)			return num		}		public function createStickToScript(object:PhysObject):void							{			var script = new stickToObject()			script.setWhichIsStuck(this)			script.setWhichStuckTo(object)			object.addObjectScript(script)					}		public function createBounceOffScript(object:PhysObject,nodesAttached:Array):void	{			var bounceScript = new bounceOffObj()			addObjectScript(bounceScript)			bounceScript.setAttachedTo(object)			bounceScript.setWhichAttached(nodesAttached)					}				public function setCollisionsAllowed(object:PhysObject, allowed:Boolean):void		{			var currIDX = collisionsForbidden.lastIndexOf(object)			if(allowed == false){				if(currIDX == -1){					collisionsForbidden.push(object)				}			} else {				if(currIDX != -1){					collisionsForbidden.splice(currIDX,1)				}			}		}		public function getCollisionsAllowed(object:PhysObject):Boolean						{			var currIDX = collisionsForbidden.lastIndexOf(object)			if(currIDX == -1){ return true } else { return false }		}		public function setDetachPronto(pronto:Boolean):void								{			detachPronto = pronto			constraint = null		}		public function getDetachPronto():Boolean											{			return detachPronto		}				//OUTLINE AND MOMENT OF INERTIA/COM		public function setOutline(po:PhysOutline):void		{						thisOutline= po			setDefaults()					}		public function getOutline():PhysOutline			{			return thisOutline		}		public function setDefaults():void					{			setCOMDefault()			setMomentDefault()		}		public function setMomentDefault():void				{			momentOfInertia = 0			var nodes = thisOutline.outline.nodesInOrder()			var nodeMass = mass / nodes.length			momentOfInertia = 0			for(var i = 0 ; i < nodes.length ; i++){				var r = Math.sqrt(Math.pow(nodes[i].x - COM[0],2 ) + Math.pow(nodes[i].y - COM[1],2) )				momentOfInertia += nodeMass * Math.pow(r,2)			}					}		public function setCOMDefault()						{			COM = thisOutline.outline.getCOM()		}		public function eraseWith(po:PhysOutline)			{			if(thisOutline != null){				var g = getGfxMask()				if(g != null){					var b0 = g.getBounds(this)					var a0 =Math.sqrt( Math.pow(b0.width,2) + Math.pow(b0.height,2))				}				var path = thisOutline.intersect2(po.outline, 0)				if(path!= null){					thisOutline.outline = path					thisOutline.setObject(this)					thisOutline.cleanOutline()					thisOutline.outline.genSegments()										thisOutline.outline.genFill()					//thisOutline.outline.deleteKinks(Math.PI/10)					thisOutline.outline.genOrientation()					setDefaults()									}								setGfxMask(thisOutline.drawShape())					g = getGfxMask()				var b1 = g.getBounds(this)				var af = Math.sqrt(Math.pow(b1.width,2) + Math.pow(b1.height,2))				var aRatio = af / a0				setMass(getMass() * aRatio)			}		}				public function unionWith(po:PhysOutline)			{			if(thisOutline != null){				var path = thisOutline.intersect2(po.outline, 2)				if(path!= null){					thisOutline.outline = path					thisOutline.setObject(this)					thisOutline.cleanOutline()					thisOutline.outline.genSegments()										thisOutline.outline.genFill()					//thisOutline.outline.deleteKinks(Math.PI/10)					thisOutline.outline.genOrientation()					setDefaults()									}				var gAdd = po.drawShapeExt()				gAdd.x = - getX()				gAdd.y = - getY()				gAdd.rotation = - rotation				addGraphic(gAdd)				//var gMask = thisOutline.drawShapeExt()				setGfxMask(thisOutline.drawShape())							}		}//MISC FUNCTIONS				public function getSuper():PhysSuper 												{return thisUniverse.thisstage}		public function getOverlay():PhysOverlay 											{return thisUniverse.thisstage.thisOverlay}		public function isStaticIn(index:Number):Boolean									{			if (staticInFields.length <= index) { return false 				} else { 			return staticInFields[index] }		}		public function setStaticIn(index:Number,isStatic:Boolean):void 					{			if (staticInFields.length < (index + 1 )){				while(staticInFields.length < (index + 1)){					staticInFields.push(false)				}			}			staticInFields[index] = isStatic		}		public function setStatic(isStatic:Boolean):void 									{			isstatic = isStatic		}		public function getUniverseIndex():Number											{			return thisUniverseIndex		}		public function setUniverse(physUniverse:PhysUniverse, i : Number):void				{			thisUniverse = physUniverse			thisUniverseIndex = i			setDefaults()			setMass(mass)			setCharge(charge)		}		public function getUniverse():PhysUniverse											{return thisUniverse}		public function setGraphic(newGraphic:DisplayObject)								{						var remove = true			while(remove){				try{					graphic.removeChildAt(0)				} catch (e:Error) {					remove = false				}			}			graphic.addChild(newGraphic)		}		public function addGraphic(newGraphic:DisplayObject):void{			graphic.addChild(newGraphic)		}		public function getGraphic():DisplayObject{			return graphic		}		public function setGfxMask(newGraphic:DisplayObject)								{			if(gfxMask != null){removeChild(gfxMask)}			addChild(newGraphic)			gfxMask = newGraphic			graphic.mask = gfxMask		}		public function getGfxMask():DisplayObject{			return gfxMask		}		public function setExtraGFX(newGraphic:Sprite)										{						if(extraGFX != null){				thisUniverse.removeChild(extraGFX)			}			extraGFX = newGraphic			thisUniverse.addChild(extraGFX)					}		public function objMouseDown(event:MouseEvent)										{						setDetachPronto(true)			var thistime = flash.utils.getTimer()			if (thistime - lastclicktimer < 400) {isstatic = ! isstatic} 			lastclicktimer = thistime			if (isDraggable){			startDrag()			dragTicker = 0			dragging = true			pastx = new MathArray()			pasty = new MathArray()			pastx.push(x)			pasty.push(y)			}		} 							public function objMouseUp(event:MouseEvent)										{				if (isDraggable){			stopDrag()			dragging = false			xvel = pastvx.mean()    / PhysUniverse.timestep			yvel = pastvy.mean()	/ PhysUniverse.timestep		}					}		public function objEnterFrame(event:Event)											{			if (dragging){			dragTicker++			if (dragTicker % 2 ==0){														pastx.push(x);				pasty.push(y); 				if (pastx.length > 3){					pastx.shift()					pasty.shift()				}								pastvx = new MathArray()				pastvy = new MathArray()				for ( var i:Number = 0 ; i <( pastx.length -1 ); i ++) {					pastvx.push(( pastx[i + 1] - pastx[i]	)/2)				pastvy.push(( pasty[i + 1] - pasty[i]   )/2)				}			xvel = pastvx.mean()    / PhysUniverse.timestep			yvel = pastvy.mean()	/ PhysUniverse.timestep			}			}			}					public function destroyDefault():void												{			thisUniverse.thisstage.removeDrawnObject(this)			destroy()		}		public function destroy():void														{			isDestroyed = true		}		public function sleep():void														{			isSleeping = true		}		public function wake():void															{			isSleeping = false		}		public function addObjectScript(script:ObjectScript):void							{			var advanceOnInit = true			script.setObject(this)			addScript(script )		}		public function addScript(script:PhysScript):void	  								{			scripts.push(script); 			script.beginScriptDefault()		}//GET / SET PHYSICAL ATTRIBUTES				public function setMass(newMass:Number):void						{			mass = newMass			if(thisUniverse != null){			if(thisUniverse.fieldIsGravity != -1){				setCustomCharge(thisUniverse.fieldIsGravity,mass)			}}		}		public function getMass():Number									{return mass}				public function getEMassAtAlong(pt:Array,unitAlong:Array){				var comRad = getCOMRadius(pt)				var unitPerp = [-unitAlong[1],unitAlong[0]]				var radiusParallel = VectorMath2D.dotMultiply2D(unitPerp,comRad)				return 1 / (Math.pow(radiusParallel , 2) / getMomentOfInertia() + 1 / getMass())					}		public function setMomentOfInertia(newMoment:Number):void			{			momentOfInertia = newMoment		}		public function getMomentOfInertia():Number							{return momentOfInertia}		public function setCharge(newCharge:Number):void					{			charge = newCharge 			if(thisUniverse != null){			if(thisUniverse.fieldIsElectric != -1){				setCustomCharge(thisUniverse.fieldIsElectric,charge)			}}		}		public function getCharge():Number									{return charge}				public function setCustomCharge(index:Number, charge:Number):void	{			if (customCharges.length < (index + 1 )){				while(customCharges.length < (index + 1)){					customCharges.push(0)				}			}			customCharges[index] = charge		}				public function getCustomCharge(index:Number):Number				{			if (customCharges.length > index) {return customCharges[index]} else return 0		}		public function getCustomCharges():Array							{return customCharges}		public function getDipole():Dipole{				var comXY = [getCOMX(), getCOMY()]				var masses = [mass/2,mass/2]				var charges = [charge/2,charge/2]				var ccEach = new Array(customCharges.length)				for(var i = 0 ; i < ccEach.length; i++){					ccEach[i] = customCharges[i] / 2				}				var dipoleCustomCharges = [ccEach,ccEach]				var radius =Math.sqrt( momentOfInertia / mass )				var units = getUnits()				var ptsXY = [[comXY[0] + units[0] * radius,comXY[1] + units[1] * radius],[comXY[0] -units[0] * radius, comXY[1] - units[1] * radius]]				var dipole = new Dipole(masses, charges, dipoleCustomCharges, ptsXY)				return dipole					}		public function setMultipole():void{			var multipole = getDipole()		}		public function getMultipole():Multipole{			return multipole		}		public function getUnits():Array		{			return [Math.cos(angle),Math.sin(angle),-1*Math.sin(angle),Math.cos(angle)]			}		public function unitUp():Array			{			var units = getUnits()			return([ -1 * units[2], -1 * units[3] ] )		}		public function getVel(...args):Array		{			if(args.length == 0){var pt = null} else {pt = args[0]}			var v = [xvel ,yvel]			if(pt != null){				var local = comCoords(pt)				var vRotLocal = [-local[1] * omega, local[0] * omega]				var vRot = rotateToExternal(vRotLocal)				v = [v[0] + vRot[0], v[1] + vRot[1]]			}			return v		}		public function getUnitVel(...args):Array	{			if(args.length != 0){var pt = args[0]} else {pt = null}			var vel = getVel(pt)			var magV = Math.sqrt(Math.pow(vel[0],2) + Math.pow(vel[1],2))			var uVel = [vel[0] / magV, vel[1] / magV]			return uVel		}		public function getNextVel(...args):Array  {			if(args.length != 0){var pt = args[0]} else {pt = null}			var v = getVel(pt)						var a = [ftorqueThisTimeStep[0]/ mass,ftorqueThisTimeStep[1]/mass]			v[0] += a[0]* PhysUniverse.timestep  			v[1] += a[1] *PhysUniverse.timestep			if(pt != null){				var local = comCoords(pt)				var alpha = ftorqueThisTimeStep[2]/ momentOfInertia				var delta = alpha * PhysUniverse.timestep				var vRotLocal = [-local[1] * delta, local[0] * delta]				var vRot = rotateToExternal(vRotLocal)				v = [v[0] + vRot[0], v[1] + vRot[1]]							}			return v		}		public function getNextOmega():Number {			return omega + ftorqueThisTimeStep[2]/momentOfInertia*PhysUniverse.timestep		}		public function getOmega():Number  {return omega}		public function getKE():Number			{			var v = getVel()			return (.5 * mass * ( Math.pow( v[0],2) + Math.pow(v[1],2)) + .5 * momentOfInertia * Math.pow(omega, 2))		}		public function getX():Number{ return physX}		public function getY():Number{ return physY}		public function getCOMX():Number{			return getCOM()[0]		}		public function getCOMY():Number{			return getCOM()[1]		}		public function getCOM():Array{			var COMExt = thisOutline.outline.externalCoords(COM)			return COMExt		}		public function getCOMRadius(pt:Array):Array{				return [pt[0] - getCOMX(),pt[1] - getCOMY()]		}		public function isAttached():Boolean{			if(constraint == null){return false} else{return true}		}		public function externalCoords(localXY:Array){			var externalX = localXY[0] * Math.cos(angle) +  - localXY[1] * Math.sin(angle) + getX()			var externalY = localXY[0] * Math.sin(angle) +    localXY[1] * Math.cos(angle) + getY()			var out = [externalX,externalY]			return out					}		public function comCoords(objXY:Array):Array{			var COMY = getCOMY()			var COMX = getCOMX()			var localX = ( objXY[0] - COMX) * Math.cos(angle) +   ( objXY[1] - COMY) * Math.sin(angle) 			var localY =-( objXY[0] - COMX) * Math.sin(angle) +   ( objXY[1] - COMY) * Math.cos(angle)			var out = [localX,localY]			return out		}		public function externalCOMCoords(localXY:Array){			var COMY = getCOMY()			var COMX = getCOMX()			var externalX = localXY[0] * Math.cos(angle) +  - localXY[1] * Math.sin(angle) + COMX			var externalY = localXY[0] * Math.sin(angle) +    localXY[1] * Math.cos(angle) + COMY			var out = [externalX,externalY]			return out					}		public function localCoords(objXY:Array):Array{			var localX = ( objXY[0] - getX()) * Math.cos(angle) +   ( objXY[1] - getY()) * Math.sin(angle) 			var localY =-( objXY[0] - getX()) * Math.sin(angle) +   ( objXY[1] - getY()) * Math.cos(angle)			var out = [localX,localY]			return out		}		public function rotateToExternal(v:Array):Array{			return VectorMath2D.rotate(v,angle)		}		public function rotateToLocal(v:Array):Array{			return VectorMath2D.rotate(v,-angle)		}//FIELD GENERATION		public function eOfAt(xy:Array):Array							{			var rx = xy[0] - getX()			var ry = xy[1] - getY()			var r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)			var E= [kc * rx * charge / Math.pow(r,3), kc * ry * charge / Math.pow(r,3)]			return E		}		public function gOfAt(xy:Array):Array							{						var rx = xy[0] - getX()			var ry = xy[1] - getY()				var r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)			var g = [-G * rx * mass / Math.pow(r,3), -G * ry * mass / Math.pow(r,3)]			return g		}		public function inverseSquareOfAt(xy:Array):Array				{			var rx = xy[0] - getCOMX()			var ry = xy[1] - getCOMY()			var r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)			var f= [ rx  / Math.pow(r,3),  ry  / Math.pow(r,3)]			return f		}		public function inverseCubeOfAt(xy:Array):Array					{			var rx = xy[0] - getCOMX()			var ry = xy[1] - getCOMY()			var r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)			var f= [ rx  / Math.pow(r,3),  ry  / Math.pow(r,4)]			return f		}		public function inverseFirstOfAt(xy:Array):Array				{			var rx = xy[0] - getCOMX()			var ry = xy[1] - getCOMY()			var r = Math.max(Math.sqrt(Math.pow(rx,2) + Math.pow(ry,2)),minimumMeaningfulLengthScale)			var f= [ rx  / Math.pow(r,3),  ry  / Math.pow(r,2)]			return f		}		//DYNAMICStwop		public function moveStep():void							{			var vel = getVel()			var displacement = [vel[0] *PhysUniverse.timestep, vel[1] * PhysUniverse.timestep]			moveBy(displacement)		}		//Outdated...but a good method.		/*public function constrainedMoveStep():void				{			var vel = getVel()			var displacement = [vel[0] *PhysUniverse.timestep, vel[1] * PhysUniverse.timestep]			var xyInit = constraint[1].thisCtdOutline.nodeExternalCoords(constraint[1])			var magV = Math.sqrt(Math.pow(vel[0],2) + Math.pow(vel[1],2))			var out = moveFromBy(xyInit,displacement,Math.sqrt(magV)*15,magV)				if(out[3]){				var newXY = out[0]				var unitAlong = out[1]				var dot = out[2]				moveBy([newXY[0] - xyInit[0],newXY[1] - xyInit[1]])				 magV = Math.sqrt(Math.pow(vel[0],2) + Math.pow(vel[1],2))				var vNew = [magV * unitAlong[0] * dot, magV * unitAlong[1] * dot]								xvel = vNew[0]				yvel = vNew[1]			} else {				 newXY = out[0]				 unitAlong = out[1]				 dot = out[2]				moveBy([newXY[0] - xyInit[0],newXY[1] - xyInit[1]])				moveBy([out[4] * unitAlong[0], out[4] * unitAlong[1]])				setDetachPronto(true)				 magV = Math.sqrt(Math.pow(vel[0],2) + Math.pow(vel[1],2))				 vNew = [magV * unitAlong[0] * dot, magV * unitAlong[1] * dot]								xvel = vNew[0]				yvel = vNew[1]							}					}*/		/*public function moveFromBy(externalXY:Array, displacement:Array,bForcePerMass:Number,magV:Number):Array{			var outline = constraint[0]			var localCoord = outline.localCoords(externalXY)			var node = outline.closest(externalXY)			var units = outline.getUnitsExt(node)			var dot = math.VectorMath2D.dotMultiply2D(displacement,[units[0]*outline.ort,units[1]*outline.ort])			if(dot > 0){var forward = true} else {forward = false}			var dot0 = dot									units = outline.getUnitsExt(node,false)			if(forward){dot = math.VectorMath2D.dotMultiply2D(displacement,[units[0]*outline.ort,units[1]*outline.ort])} else{				dot = math.VectorMath2D.dotMultiply2D(displacement,[-units[0]*outline.ort,-units[1]*outline.ort])							}			var distanceInit =  Math.sqrt(Math.pow(displacement[0],2) + Math.pow(displacement[1],2))			if(distanceInit != 0){var dd = 	Math.abs(dot)/distanceInit}else {dd = 0 }			if(distanceInit != 0){ dot0 = 	Math.abs(dot0)/distanceInit}else {dd = 0 }			var totalDist =Math.abs(distanceInit *Math.max(dd,.2))						var distSoFar = 0			//thisUniverse.plotter.setYRange([0,1])			//thisUniverse.plotter.pushY(1 - dd,'ctd')									var lastPt = node.ptBitClosest(localCoord,false)			if(forward){var nextNode = node.next} else {nextNode = node}			if(forward){units = outline.getUnitsExt(node,false)} else{ units = outline.getUnitsExt(nextNode,false)}			if(forward){var uA0 = [outline.ort* units[0],outline.ort * units[1]]} else { uA0 = [-outline.ort * units[0],-outline.ort * units[1]] }			unitAlong = uA0						var startingVel = getVel()			var newVel = [uA0[0]*magV*dd,uA0[1]*magV*dd]			var dv = [newVel[0]  - startingVel[0],newVel[1] - startingVel[1]]			var dvIn = - math.VectorMath2D.dotMultiply2D([units[2],units[3]],dv)						dist = Math.sqrt(Math.pow(nextNode.x - lastPt[0],2) + Math.pow(nextNode.y - lastPt[1],2))			if(distSoFar + dist >= totalDist ){var search = false} else {search = true ; distSoFar += dist}			var loops = 0			var p0 = lastPt			var d0 = dist			while(search){				loops ++				node = nextNode				lastPt = [node.x,node.y]				if(forward){nextNode = node.next} else {nextNode = node.prev}									var uUpLast =[units[2],units[3]]					if(forward){units = outline.getUnitsExt(node,false)} else{ units = outline.getUnitsExt(nextNode,false)}					var uALast = unitAlong					if(forward){ unitAlong = [outline.ort* units[0],outline.ort* units[1]]} else { unitAlong = [-outline.ort *units[0],-outline.ort *units[1]] }					var du = [unitAlong[0] - uA0[0] , unitAlong[1] - uA0[1]]					var dt = PhysUniverse.timestep					var impulsePerMass = [du[0]/dt*magV,du[1]/dt * magV]					var magImpulsePerMass = Math.sqrt(Math.pow(impulsePerMass[0] , 2) + Math.pow(impulsePerMass[1],2))					 newVel = [unitAlong[0]*magV*dd,unitAlong[1]*magV*dd]					 dv = [newVel[0]  - startingVel[0],newVel[1] - startingVel[1]]					 var vecUp = [uUpLast[0] + units[2], uUpLast[1] + units[3]]					 var magUp = Math.sqrt(Math.pow(vecUp[0],2) + Math.pow(vecUp[1],2))					 var uUp = [vecUp[0]/magUp,vecUp[1]/magUp]					 dvIn = - math.VectorMath2D.dotMultiply2D(uUp,dv)					if(dvIn > bForcePerMass){						return [outline.externalCoords(lastPt),uALast,dd,false,totalDist - distSoFar]					}														var dist = Math.sqrt(Math.pow(nextNode.x - lastPt[0],2) + Math.pow(nextNode.y - lastPt[1],2))				if(distSoFar + dist >= totalDist ){search = false} else {					distSoFar += dist									}				if(loops > outline.numNodes){					search = false ; 					trace("BADSEARCH!!!",distSoFar,dist,p0,loops)					}																					}			//trace(loops)			var vecAlong = [nextNode.x - lastPt[0],nextNode.y - lastPt[1]]			var magAlong = Math.sqrt(Math.pow(vecAlong[0],2) + Math.pow(vecAlong[1],2))			var unitAlong= [vecAlong[0]/magAlong,vecAlong[1]/magAlong]			var finalMove = [unitAlong[0] * (totalDist - distSoFar), unitAlong[1]*(totalDist - distSoFar)]			var finalXY = [lastPt[0] + unitAlong[0] * (totalDist - distSoFar), lastPt[1] + unitAlong[1] * (totalDist - distSoFar)]			var out = outline.externalCoords(finalXY)										if(distanceInit != 0){ dd = 	Math.abs(dot)/distanceInit}else {dd = 0 }			return [out,unitAlong,dd,true]					}*/				public function haltPt(ptXY:Array):void{			trace(getNextVel(ptXY))			trace(getVel(ptXY))			//var torqueMultiplier = 						var rP = getCOMRadius(ptXY)			var rMag = Math.sqrt(Math.pow(rP[0],2) + Math.pow(rP[1],2))			var rUnit = [rP[0]/rUnit,rP[1]/rUnit]			var fTMult = VectorMath2D.dotMultiply2D(rUnit,F						rP x w + vCom = 0			w = rP x F * t + w0			vCom = F * t + v0						var vec = getNextVel(ptXY)			var mag = Math.sqrt(Math.pow(vec[0],2) + Math.pow(vec[1],2))			var unitAlong = [vec[0] / mag, vec[1] / mag]			var eMass = getEMassAtAlong(ptXY, unitAlong)			var impulse = eMass * mag			exertImpulseAt([impulse * -unitAlong[0] , impulse * -unitAlong[1]],ptXY)			trace(getNextVel(ptXY))			var vf = getNextVel(ptXY)			trace(VectorMath2D.dotMultiply2D(vf,vec))		}		public function updateGraphics():void{			x = physX			y = physY			rotation = Math.floor(angle * 180 / Math.PI) % 360			try{				var t = this as Tank				if(t.wT!= null){				// trace(t.wT.parent.transform.concatenatedMatrix.b, t.wT.parent)				// trace(t.wT.transform.concatenatedMatrix.b)				}			} catch(e:Error){}					}		public function timeTravel(seconds:Number):void{			rotateBy(seconds * omega)			var vel = getVel()			var displacement = [vel[0] *seconds, vel[1] * seconds]			moveBy(displacement)		}		public function movePtTowardsAboutFixedPt(ptXY:Array,fixedXY:Array,xyFinal:Array):void{									var vecFixedToFinal = [xyFinal[0] - fixedXY[0], xyFinal[1]  - fixedXY[1]]				var vecFixedToPt = [ptXY[0] - fixedXY[0], ptXY[1] - fixedXY[1]]				var magFTF = Math.sqrt(Math.pow(vecFixedToFinal[0] ,2) + Math.pow(vecFixedToFinal[1],2))				var magFTP = Math.sqrt(Math.pow(vecFixedToPt[0] ,2) + Math.pow(vecFixedToPt[1],2))				if(magFTF != 0 && magFTP !=0){					var unitFTF = [vecFixedToFinal[0] / magFTF, vecFixedToFinal[1]/magFTF]					var unitFTP = [vecFixedToPt[0]/magFTP,vecFixedToPt[1]/magFTP]										var angFTF = Math.asin(unitFTF[1])					if(unitFTF[0] < 0){ angFTF = Math.PI - angFTF }					var angFTP = Math.asin(unitFTP[1])					if(unitFTP[0] < 0){ angFTP = Math.PI - angFTP }										var angleDelta = angFTF - angFTP					if(isNaN(angleDelta)){return}					rotateAroundBy(fixedXY,angleDelta)				}					}		public function moveBy(xyMove:Array):void				{				physX += xyMove[0]				physY += xyMove[1]		}		public function moveTo(xyFinal:Array):void				{				physX = xyFinal[0]				physY = xyFinal[1]		}		public function setXY(xyFinal:Array):void			{				moveTo(xyFinal)				updateGraphics()		}		public function rotateStep()						{			rotateBy(omega * PhysUniverse.timestep)		}		public function rotateBy(radians:Number):void		{								rotateAroundBy(getCOM(),radians)		}		public function rotateTo(angleRadians:Number):void	{				rotateAroundTo(getCOM(),angleRadians)		}				public function rotateAroundBy(xyRotAround:Array,angleRadians:Number):void{				var toAxis = [xyRotAround[0] - getX(),xyRotAround[1] - getY()]				angle += angleRadians				var axisNewPositionX = [Math.cos(angleRadians) * toAxis[0] - Math.sin(angleRadians) * toAxis[1]]				var axisNewPositionY = [Math.cos(angleRadians) * toAxis[1] + Math.sin(angleRadians) * toAxis[0]]				var axisDisplacement = [axisNewPositionX - toAxis[0], axisNewPositionY - toAxis[1]]				moveBy([-1 * axisDisplacement[0], -1 * axisDisplacement[1]])																			}		public function rotateAroundTo(xyRotAround:Array,angleRadians:Number):void{				var deltaAngle = angleRadians - angle				rotateAroundBy(xyRotAround,deltaAngle)		}		public function accelerateBy(a:Array):void				{						xvel += a[0]* PhysUniverse.timestep  						yvel += a[1] *PhysUniverse.timestep		}		public function angularAccelerateBy(alpha:Number):void	{				omega += PhysUniverse.timestep * alpha		}		public function exertImpulseOn(impulse:Array):void				{ 			ftorqueThisTimeStep[0] += impulse[0] / PhysUniverse.timestep			ftorqueThisTimeStep[1] += impulse[1] / PhysUniverse.timestep		}		public function exertImpulseAt(impulse:Array,xyAt:Array)		{			exertImpulseOn(impulse)			var xyRadius = [xyAt[0] - getCOMX(), xyAt[1] - getCOMY(), 0]			var torqueImpulse = VectorMath3D.crossMultiply3D(xyRadius, impulse)   			exertTorqueImpulseOn(torqueImpulse)								}		public function exertTorqueImpulseOn(impulse:Array):void		{					ftorqueThisTimeStep[2]+=impulse[2] /PhysUniverse.timestep		}		public function getForceApplied():Array					{			return [ftorqueThisTimeStep[0],ftorqueThisTimeStep[1]]		}		public function getTorqueApplied():Number				{			return ftorqueThisTimeStep[2]		}		public function cancelAppliedForces():void			{			ftorqueThisTimeStep = [0,0,ftorqueThisTimeStep[2]]		}		public function cancelAppliedTorques():void			{			ftorqueThisTimeStep = [ftorqueThisTimeStep[0],ftorqueThisTimeStep[1],0]		}		public function kineticFriction():void				{						var v = getVel()			var magV = Math.sqrt(Math.pow(v[0],2) + Math.pow(v[1],2))			var highSpeed = 175			var speedLimit = 400			var defaultDamp = .8			if(magV <= highSpeed ){				var dampCof = defaultDamp			} else{  				if(magV <= speedLimit){					dampCof =   ( highSpeed/magV  +( (magV - highSpeed) / magV) * (1 - ( magV - highSpeed ) / (speedLimit - highSpeed) )) * defaultDamp				} else {					dampCof = defaultDamp * speedLimit/magV				}			}			dampen([dampCof,dampCof,defaultDamp])		}		public function dampen(args,...extra):void			{			var dampenForce:Boolean			if(extra.length ==0){dampenForce = false} else {dampenForce = args[0]}						var wdamp:Number			var xdamp:Number			var ydamp:Number			if (args.length ==0){xdamp = 1; ydamp = 1 ; wdamp = 1} else {				if (args.length ==1) {xdamp = args[0] ; ydamp = args[0] ; wdamp = args[0]} else {					if (args.length ==2) {xdamp = args[0] ; ydamp = args[1] ; wdamp =1} else {						if (args.length ==3 ) {xdamp = args[0];ydamp = args[1] ; wdamp = args[2]}					}				}			}						xvel *= xdamp			yvel *= ydamp			omega *= wdamp						if(dampenForce){				ftorqueThisTimeStep[0] *= xdamp				ftorqueThisTimeStep[1] *= ydamp				ftorqueThisTimeStep[2] *= wdamp			}					}				public function dampenAlong(unit, k, ...args):void	{			var dampenForce:Boolean			if(args.length ==0){dampenForce = false} else {dampenForce = args[0]}			var unitPerp = [ -1 * unit[1], unit[0] ]			var vAlong = VectorMath2D.dotMultiply2D(unit,[xvel,yvel])			var vPerp = VectorMath2D.dotMultiply2D(unitPerp, [xvel,yvel])			vAlong = vAlong * k						xvel = unitPerp[0] * vPerp + unit[0] * vAlong			yvel = unitPerp[1] * vPerp + unit[1] * vAlong			if(dampenForce){				var fAlong = VectorMath2D.dotMultiply2D(unit,[ftorqueThisTimeStep[0],ftorqueThisTimeStep[1]])				var fPerp = VectorMath2D.dotMultiply2D(unitPerp,[ftorqueThisTimeStep[0],ftorqueThisTimeStep[1]])				fAlong = fAlong * k											ftorqueThisTimeStep[0] = unitPerp[0] * fPerp + unit[0] * fAlong				ftorqueThisTimeStep[1] = unitPerp[1] * fPerp + unit[1] * fAlong			}		}		public function forceOn():void						{			for (var j = 0; j < customCharges.length ; j++){  				if((customCharges[j] != 0) && (!isStaticIn(j)) ){					thisUniverse.customChargeFields[j].forceOn(this)				}			}		}	}}