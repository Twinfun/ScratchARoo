package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.ui.MultitouchInputMode;
	
	//import flash.display.StageAlign;
	//import flash.display.StageScaleMode;
	
	public class ScratchARoo extends Sprite
	{		
		[SWF(width="1024", height="600", backgroundColor="#cccccc", frameRate="30")]
		
		[Embed(source = 'img/Arctic.png')]
		private var Arctic:Class;
		[Embed(source = 'img/Brick.png')]
		private var BrickImg:Class;
		[Embed(source = 'img/CatAndBike.png')]
		private var CatAndBike:Class;
		[Embed(source = 'img/CourtLibrary.png')]
		private var CourtLibrary:Class;
		[Embed(source = 'img/Desert.png')]
		private var Desert:Class;
		[Embed(source = 'img/DogFish1.png')]
		private var DogFish1:Class;
		[Embed(source = 'img/Farm.png')]
		private var Farm:Class;
		[Embed(source = 'img/FlamingoBeach.png')]
		private var FlamingoBeach:Class;
		[Embed(source = 'img/GrassBoat.png')]
		private var GrassBoat:Class;
		[Embed(source = 'img/HopTheMorning.png')]
		private var HopTheMorning:Class;
		[Embed(source = 'img/Ice.png')]
		private var IceImg:Class;
		[Embed(source = 'img/Icon.png')]
		private var Icon:Class;
		[Embed(source = 'img/LivingRoom1.png')]
		private var LivingRoom1:Class;
		[Embed(source = 'img/Menu.png')]
		private var Menu:Class;
		[Embed(source = 'img/Penguin.png')]
		private var Penguin:Class;
		[Embed(source = 'img/PenPencil1.png')]
		private var PenPencil:Class;
		[Embed(source = 'img/PotOfGold.png')]
		private var PotOfGold:Class;
		[Embed(source = 'img/Rainbow1.png')]
		private var Rainbow1:Class;
		[Embed(source = 'img/SeaOcto.png')]
		private var SeaOcto:Class;
		[Embed(source = 'img/SleepTight.png')]
		private var SleepTight:Class;
		[Embed(source = 'img/SplashScreen.png')]
		private var SplashScreen:Class;
		[Embed(source = 'img/TenthDay.png')]
		private var TenthDay:Class;
		[Embed(source = 'img/TripToWonderland.png')]
		private var TripToWonderland:Class;
		
		private var ice:Bitmap = new IceImg();
		
		private var brick:Bitmap = new BrickImg();
		
		private var lineSize:Number = 40;
		private var doDraw:Boolean = false;
		private var resumeDrawing:Boolean = false;		
		/*
		Create a bitmap to act as our image mask
		Add it to stage & cache as bitmap
		*/
		private var erasableBitmapData:BitmapData = new BitmapData(340, 340, true, 0xFFFFFFFF);
		private var erasableBitmap:Bitmap = new Bitmap(erasableBitmapData);
		
		//erasableBitmap.cacheAsBitmap = true; //.cacheAsBitmap = true;		
		
		private var eraserClip:Sprite = new Sprite();		
		private var drawnBitmapData:BitmapData = new BitmapData(340, 340, true, 0x00000000);
		private var drawnBitmap:Bitmap = new Bitmap(drawnBitmapData);
		
		private var pixelCount:int = stage.width * stage.height;
		private var frameCount:int = 0;
		
		//stage.align = StageAlign.TOP_LEFT;
		//stage.scaleMode = StageScaleMode.NO_SCALE;
		
		public function ScratchARoo():void
		{
			flash.ui.Multitouch.inputMode = flash.ui.MultitouchInputMode.TOUCH_POINT;
			
			erasableBitmap.cacheAsBitmap = true;
			brick.cacheAsBitmap = true;
			brick.mask = erasableBitmap;
			
			addChild(ice);
			addChild(brick);
			addChild(erasableBitmap);
			//addChild(ice);
			
			/*
			Set the erasable bitmap as a mask of our image & cache image as bitmap
			*/
			
			//ice.cacheAsBitmap = true;
			//ice.mask = erasableBitmap;
			
			/*************************
			 ERASER
			 **************************/
			
			/*
			Create a sprite for drawing the eraser lines onto
			Set its lineStyle, and move the line to the current mouse x,y
			*/
			initEraser();
			
			/*************************
			 MOUSE EVENTS
			 **************************/
			
			/*
			Add event listeners for mouse movements
			*/
			stage.addEventListener(TouchEvent.TOUCH_MOVE, maskMove);
			stage.addEventListener(TouchEvent.TOUCH_OUT, maskOut);
			stage.addEventListener(TouchEvent.TOUCH_OVER, maskOver);
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			//stage.addEventListener(MouseEvent.MOUSE_UP, stopDrawing);
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, startDrawing);
			stage.addEventListener(TouchEvent.TOUCH_END, stopDrawing);
			
			stage.addEventListener(Event.ENTER_FRAME, updateAll);
			
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, reset);
			
			//stage.nativeWindow.visible = true;
		}
		
		/**
		 * ERASABLE IMAGE EFFECT
		 * Jonathan Nicol
		 * f6design.com/journal
		 * v1.0
		 * Date: 24 May 2009
		 *
		 * Demonstrates how to 'erase' an image by drawing with the mouse.
		 * The effect is similar to way you would use the eraser tool in Photoshop.
		 *
		 * I have combined two other approaches to achieve this effect:
		 *
		 * http://www.ultrashock.com/forums/actionscript/eraser-tool-in-as3-123871.html
		 * Explains how to erase portions of a bitmap mask using BlendMode.ERASE
		 *
		 * http://www.flashandmath.com/basic/mousedraw2/index.html
		 * Describes how to draw with the mouse
		 *
		 * The gorgeous photographs used in this demo are by wabberjocky and ex.libris and
		 * are available from flickr under a Creative Commons license.
		 *
		 */
		
		private function updateAll(e:Event):void
		{
			if (frameCount >= 30) {
				var amountErased:int = 0;
				for (var w:int = 0; w < stage.width; w++) {
					for (var h:int = 0; h < stage.height; h++) {
						if (erasableBitmap.bitmapData.getPixel(w, h) == 0) {
							amountErased++;
						}
					}
				}
				trace(amountErased.toString());
				frameCount = 0;
			} else { frameCount++; }
		}
		
		/*************************
		 MASKING
		 **************************/
		
		
		private function initEraser():void
		{
			eraserClip.graphics.lineStyle(lineSize, 0xff0000);
			eraserClip.graphics.moveTo(stage.mouseX, stage.mouseY);
		}
		
		/*
		Create a bitmap to copy the erased lines to.
		This is required to ensure a smooth erase effect (applying eraserClip
		directly to erasableBitmapData leaves jaggy edges  around alpha areas.
		If anyone knows why, I'd love to know!)
		*/
		
		/*
		Mouse down handler
		Begin drawing
		*/
		private function startDrawing(e:TouchEvent):void
		{
			eraserClip.graphics.moveTo(e.stageX, e.stageY);
			doDraw = true;
		}
		
		/*
		Mouse up handler
		Stop drawing
		*/
		private function stopDrawing(e:TouchEvent):void
		{
			doDraw = false;
			resumeDrawing = false;
		}
		
		/*
		Mouse out handler
		If user was drawing when they moved mouse off stage, we will need
		to resume drawing when they move back onto stage.
		*/
		private function maskOut(e:Event):void
		{
			if (doDraw)
			{
				resumeDrawing = true;
			}
		}
		
		/*
		Mouse over handler
		If user's mouse if still down, continue drawing from the point where
		the mouse re-entered the stage.
		*/
		private function maskOver(e:TouchEvent):void
		{
			if (resumeDrawing)
			{
				resumeDrawing = false;
				eraserClip.graphics.moveTo(e.stageX, e.stageY);
			}
		}
		
		/*
		Mouse move handler
		*/
		private function maskMove(e:TouchEvent):void
		{
			if (doDraw && !resumeDrawing)
			{
				// Draw a line to current mouse position
				eraserClip.graphics.lineTo(e.stageX, e.stageY);
				// Clear the drawn bitmap by filling it with a transparent color
				drawnBitmapData.fillRect(drawnBitmapData.rect, 0x00000000);
				// Copy our eraser drawing into the erasable bitmap
				// (This is required to ensure the smooth alpha edges on our eraser are retained)
				drawnBitmapData.draw(eraserClip, new Matrix(), null, BlendMode.NORMAL);
				// Fill the erasable bitmap with a solid color
				erasableBitmapData.fillRect(erasableBitmapData.rect, 0xFFFFFFFF);
				// Copy the scribble bitmap to our main bitmap, with blendmode set to ERASE
				// This erases the portion of the mask that has been drawn.
				erasableBitmapData.draw(drawnBitmap, new Matrix(), null, BlendMode.ERASE);
			}
			// Update after event to ensure no lag
			e.updateAfterEvent();
		}
		
		private function reset(e:Event):void
		{
			eraserClip.graphics.clear();
			initEraser();
			erasableBitmapData.fillRect(erasableBitmapData.rect, 0xFFFFFFFF);
		}
		
		private function closeWindow(e:Event):void{
			stage.nativeWindow.close();
		}
	}
}