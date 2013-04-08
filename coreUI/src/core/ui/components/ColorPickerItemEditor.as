/**
 * ColorPickerItemEditor.as
 *
 * Copyright (c) 2011 Jonathan Pace
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package core.ui.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import core.events.PropertyChangeEvent;
	import core.ui.CoreUI;
	import core.ui.events.ItemEditorEvent;
	import core.ui.managers.PopUpManager;
	import core.ui.util.Scale9GridUtil;
	
	import flux.skins.ColorPickerItemEditorSkin;

	public class ColorPickerItemEditor extends UIComponent 
	{
		// Properties
		private var _color			:uint = 0;
		
		// Child elements
		private var background		:Sprite;
		private var labelField		:TextField;
		private var swatch			:Sprite;
		private var panel			:Container;
		private var colorPicker		:ColorPicker;
		
		public function ColorPickerItemEditor() 
		{
			
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			height = 26;
			
			background = new ColorPickerItemEditorSkin();
			
			if (!background.scale9Grid) {
				Scale9GridUtil.setScale9Grid(background, CoreUI.defaultColorPickerItemEditorSkinScale9Grid);
			}
			addChild(background);
			
			labelField = TextStyles.createTextField();
			labelField.autoSize = TextFieldAutoSize.LEFT;
			addChild(labelField);
			
			swatch = new Sprite();
			addChild(swatch);
			
			swatch.addEventListener(MouseEvent.CLICK, clickSwatchHandler);
		}
		
		override protected function validate():void
		{
			var swatchWidth:int = _height * 1.61;
			var swatchHeight:int = _height;
			
			background.width = swatchWidth;
			background.height = swatchHeight;
			
			swatch.graphics.clear();
			swatch.graphics.beginFill(_color);
			swatch.graphics.drawRect(0, 0, swatchWidth-4, swatchHeight-4);
			swatch.x = 2;
			swatch.y = 2;
			
			var str:String = _color.toString(16).toUpperCase();
			while ( str.length < 6 )
			{
				str = "0" + str;
			}
			str = "#" + str;
			labelField.text = str;
			labelField.height = labelField.textHeight + 4;
			labelField.y = (_height - labelField.height) >> 1;
			labelField.x = swatchWidth + 4;
		}
		
		////////////////////////////////////////////////
		// Event Handlers
		////////////////////////////////////////////////
		
		private function clickSwatchHandler( event:MouseEvent ):void
		{
			openPanel();
		}
		
		private function onColorPickerChange( event:Event ):void
		{
			color = colorPicker.color;
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		private function onMouseDownStage( event:MouseEvent ):void
		{
			if ( panel.hitTestPoint(stage.mouseX,stage.mouseY) )
			{
				return;
			}
			event.stopImmediatePropagation();
			closePanel();
			
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, _color, "color" ) );
		}
		
		private function onClickStage( event:MouseEvent ):void
		{
			event.stopImmediatePropagation();
			stage.removeEventListener(MouseEvent.CLICK, onClickStage, true);
			stage.removeEventListener(MouseEvent.CLICK, onClickStage);
		}
		
		////////////////////////////////////////////////
		// Private methods
		////////////////////////////////////////////////
		
		private function openPanel():void
		{
			if (panel && panel.stage) return;
			
			if ( !panel )
			{
				panel = new Canvas();
				panel.padding = 4;
				panel.width = 200;
				panel.height = 200;
				
				colorPicker = new ColorPicker();
				colorPicker.percentWidth = colorPicker.percentHeight = 100;
				colorPicker.color = _color;
				colorPicker.padding = 0;
				colorPicker.showBorder = false;
				colorPicker.addEventListener(Event.CHANGE, onColorPickerChange);
				panel.addChild(colorPicker);
			}
			
			var pt:Point = new Point( 0, 0 );
			pt = background.localToGlobal(pt);
			panel.x = pt.x;
			panel.y = pt.y;
			PopUpManager.addPopUp(panel, false, false);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
			stage.addEventListener(MouseEvent.CLICK, onClickStage, true);
			stage.addEventListener(MouseEvent.CLICK, onClickStage);
		}
		
		private function closePanel():void
		{
			if ( panel.stage == null ) return;
			PopUpManager.removePopUp(panel);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set color( v:uint ):void
		{
			if ( v == _color ) return;
			_color = v;
			dispatchEvent( new PropertyChangeEvent( "propertyChange_value", null, _color ) );
			invalidate();
		}
		
		public function get color():uint
		{
			return _color;
		}
	}
}