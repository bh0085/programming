﻿package physics.objects {	import physics.objects.PhysObject		public class UniformDensityObject extends PhysObject{					var density:Number		var volume:Number					public function setDefaultVolume(){				volume = Math.pow((graphic.width + graphic.height)/2,3)			}			public function getVolume():Number{				if(volume != 0){return volume} else {return Math.pow((graphic.width + graphic.height)/2,3)}			}			public function setVolume(newVolume:Number):void{				volume = newVolume			}			public function setDefaultDensity(){				density = getMass() / getVolume()			}			public function setDensity(newDensity:Number){				density = newDensity				setDefaultMass()			}			public function setDefaultMass(){				setMass(density * getVolume())			}					}}