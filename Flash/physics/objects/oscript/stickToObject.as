﻿package physics.objects.oscript{	public class stickToObject extends UniverseScript{		public var stuckTo		public var whichStuck				override public function advance():void{			var newOutline = stuckTo.thisOutline.intersectWith(whichStuck.thisOutline.outline,1)			stuckTo.thisOutline.outline = newOutline			newOutline.genFill(0x000000)			stuckTo.setGraphic(newOutline.fill)			whichStuck.destroyDefault()			scriptDone = true			trace(sticking)		}				public function setWhichStuckTo(s:PhysObject):void{			stuckTo = s		}		public function setWhichIsStuck(s:PhysObject):void{			whichStuck = s		}					}}