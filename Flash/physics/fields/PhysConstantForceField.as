﻿package physics{	public class PhysConstantForceField extends PhysField{				public static var fx		public static var fy		public function PhysConstantForceField(newfx:Number, newfy:Number) {			super()						fx = newfx			fy = newfy		}		override public function fieldAt(thisx:Number,thisy:Number):Array{				var cfield = [fx,fy]			return cfield											}		override public function fieldOn(object:PhysObject, fieldidxinobj:Number):Array{			var cfield = [fx,fy]			return cfield													}		override public function forceOn(object:PhysObject,fieldidxinobj:Number):Array{			var force = [fx , fy ]			return force						}		}}