﻿package tanks.scripts{	import physics.pscript.ProjScript	import tanks.explosions.Explosion	import tanks.scripts.ProjScript	public class BombScript extends ProjScript{		override public function advance(...args):void{			if (frame == 1){				var impulsemag = (thisProjectile.initialPower * thisProjectile.getMass() * (6 - frame) * 100)				thisProjectile.exertImpulseOn([Math.cos(thisProjectile.initialAngle)*impulsemag,Math.sin(thisProjectile.initialAngle)*impulsemag])			}			if (frame == 100) {scriptDone = true}		}			}}	