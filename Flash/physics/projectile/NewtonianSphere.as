﻿package physics.projectile{	import flash.display.Shape;	import paths.PhysOutline;	public class NewtonianSphere extends Projectile {		public function NewtonianSphere():void {			setMass(1);			setCustomCharge(0,getCharge());			setCustomCharge(1,getMass());			thisOutline = PhysOutline.sphereOutline(10,10);			thisOutline.setObject(this);			setGraphic(thisOutline.outline.drawFill());		}		override public function createScript():void {			thisScript = new NewtSScript();			thisScript.setProjectile(this);			thisScript.setTank(thisTank);			thisScript.beginScript();		}		override public function collided():void {			//trace(getX(),getY());			thisScript.scriptDone = true;		}	}}