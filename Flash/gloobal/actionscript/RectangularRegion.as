﻿package actionscript{	import flash.geom.Rectangle	import flash.geom.Point	public class RectangularRegion extends GlooPlace{		public var cities:Array		public var bounds: Rectangle				public function RectangularRegion(latLonBounds:Rectangle){			bounds  = latLonBounds			type = "Custom"		}		override public function getAirports():Array{			var airports = new Array()			for(var i = 0 ; i < cities.length ; i++){				airports = airports.concat(cities[i].getAirports())			}			return airports		}								public function findCities(){			cities = new Array()			var cTemp = City.cities			for(var i = 0 ; i< cTemp.length ; i++){				var lL = cTemp[i].getLatLon()				if(bounds.containsPoint(new Point(lL[0],lL[1]))){					cities.push(cTemp[i])				}			}		}	}}