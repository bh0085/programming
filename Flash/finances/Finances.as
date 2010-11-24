﻿package finances {	import flash.text.TextField	import flash.text.TextFieldType	import flash.display.MovieClip	import flash.display.Sprite	import flash.events.MouseEvent	import flash.events.KeyboardEvent		public class Finances extends MovieClip{		public var categorySprites = new Array()		public var expendCategories = new Array()		public var expenditures = new Array()				var fapType, fapText, fapCost, fapMonth, fapDay, fapYear						public function Finances():void{						var financesBackground = new Sprite()			financesBackground.graphics.lineStyle(1)			financesBackground.graphics.drawRect(20,20,550 - 20*2, 400  - 20 * 2)			addChild(financesBackground)						var financesAddPane = new Sprite()			financesAddPane.x=0			financesAddPane.y = 0			financesAddPane.graphics.beginFill(0xCCCCCC,.5)			financesAddPane.graphics.drawRect(0,10,550,30)						financesAddPane.graphics.beginFill(0xEEEEEE)			financesAddPane.graphics.drawRect(0,15,550,20)				var m = 100			 fapType = new TextField()			fapType.text = "type"			fapType.y = 20			fapType.x = m+ 10			fapType.type = TextFieldType.INPUT			financesAddPane.addChild(fapType)			 fapText = new TextField()			fapText.text = "text"			fapText.y = 20			fapText.x =  m+40			fapText.type = TextFieldType.INPUT			financesAddPane.addChild(fapText)			 fapCost = new TextField()			fapCost.text = "cost"			fapCost.y = 20			fapCost.x =  m+70			fapCost.type = TextFieldType.INPUT			financesAddPane.addChild(fapCost)			 fapMonth = new TextField()			fapMonth.text = "month"			fapMonth.y = 20			fapMonth.x =  m+100			fapMonth.type = TextFieldType.INPUT			financesAddPane.addChild(fapMonth)			 fapDay = new TextField()			fapDay.text = "day"			fapDay.y = 20			fapDay.x =  m+140			fapDay.type = TextFieldType.INPUT			financesAddPane.addChild(fapDay)						 fapYear = new TextField()			fapYear.text = "year"			fapYear.y = 20			fapYear.x =  m+170			fapYear.type = TextFieldType.INPUT			financesAddPane.addChild(fapYear)						var fapButton = new Sprite()			fapButton.graphics.beginFill(0xFFFFFF)			fapButton.graphics.lineStyle(0x000000)			fapButton.graphics.drawCircle(0,0,25)			fapButton.x =  m+250			fapButton.y = 25			financesAddPane.addChild(fapButton)			fapButton.addEventListener(MouseEvent.MOUSE_DOWN,fapButtonMouseDown)			addChild(financesAddPane)						stage.addEventListener(MouseEvent.MOUSE_DOWN,finMouseDown)			stage.addEventListener(KeyboardEvent.KEY_DOWN,finKBD)		}				public function finMouseDown(e:MouseEvent){					}				public function fapButtonMouseDown(e:MouseEvent){			addExpenditure(fapType.text,fapCost.text,fapText.text,fapMonth.text,fapDay.text,fapYear.text)		}		public function finKBD(e:KeyboardEvent){					}				public function addExpenditureCategory(name:String):void{			var cat = new ExpenditureCategory(name)			expendCategories.push(cat)			addChild(cat.expGraphic)		}				public function idxWithName(name:String):Number{			var idx = -1			for(var i = 0 ; i < expendCategories.length ; i++){				if(expendCategories[i].name == name){idx = i}			}			return idx		}				public function addExpenditure(type:String,cost:Number,text:String,month:Number,day:Number,year:Number){						var e = new Expenditure(type,cost,text,month,day,year)			var idx = idxWithName(type)			if(idx != -1){				expendCategories[idx].pushExpenditure(e)			} else {				trace("bad category")				addExpenditureCategory(type)				expendCategories[expendCategories.length - 1].pushExpenditure(e)			}					}					}}