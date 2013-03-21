/**
 * Icon.as
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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	import core.ui.events.ResizeEvent;
	
	public class Image extends UIComponent
	{
		// Scale modes
		public static const SCALE_MODE_ORIGINAL	:String = "original";
		public static const SCALE_MODE_FIT		:String = "fit";
		public static const SCALE_MODE_FILL		:String = "fill";
		public static const SCALE_MODE_STRETCH	:String = "stretch";
		
		// Properties
		private var _source		:Object;
		private var _scaleMode	:String = SCALE_MODE_ORIGINAL;
		private var _maxScale	:Number = 1;
		private var _minScale	:Number = 0;
		
		// Child elements
		private var child		:DisplayObject;
		
		public function Image()
		{
			
		}
		
		override protected function validate():void
		{
			if ( child )
			{
				removeChild(child);
				child = null;
			}
			
			if ( _source == null )
			{
				_width = 0;
				_height = 0;
				return;
			}
			
			
			if ( _source is DisplayObject )
			{
				child = DisplayObject(_source);
			}
			else if ( _source is BitmapData )
			{
				child = new Bitmap( BitmapData(_source), "auto", true );
			}
			else
			{
				try
				{
					var instance:Object = new _source();
					
					if ( instance is DisplayObject )
					{
						child = DisplayObject(instance);
					}
					else if ( instance is BitmapData )
					{
						child = new Bitmap( BitmapData(instance) );
					}
				}
				catch( e:Error )
				{
					//return;
				}
				
				// if the source has been passed in via the MXML flavoured XML.
				if (!child && _source is String ) {
					var imgClass:Class;
					if ( _source.indexOf("::") ) {
						var arr:Array = _source.split("::");
						var icons:Class = getDefinitionByName(arr[0]) as Class;
						imgClass = icons[arr[1]];
					} else {
						imgClass = getDefinitionByName(String(_source)) as Class;
					}
					if (imgClass) {
						child = new imgClass();
					}
				}
				
				if (!child) return;
			}
			
			addChild(child);
			
			child.scaleX = child.scaleY = 1;
			child.scrollRect = null;
			switch ( _scaleMode )
			{
				case SCALE_MODE_ORIGINAL :
					_width = child.width;
					_height = child.height;
					break;
				case SCALE_MODE_STRETCH :
					child.width = _width;
					child.height = _height;
					break;
				case SCALE_MODE_FIT :
					var minRatio:Number = Math.min( _width / child.width, _height / child.height );
					minRatio = minRatio < _minScale ? _minScale : minRatio > _maxScale ? _maxScale : minRatio;
					child.width *= minRatio;
					child.height *= minRatio;
					child.x = (_width - child.width) * 0.5;
					child.y = (_height - child.height) * 0.5;
					break;
				case SCALE_MODE_FILL :
					var maxRatio:Number = Math.max( _width / child.width, _height / child.height );
					maxRatio = maxRatio < _minScale ? _minScale : maxRatio > _maxScale ? _maxScale : maxRatio;
					child.width *= maxRatio;
					child.height *= maxRatio;
					//child.x = (_width - child.width) * 0.5;
					//child.y = (_height - child.height) * 0.5;
					
					//minRatio = Math.min( _width / child.width, _height / child.height );
					
					child.scrollRect = new Rectangle( (_width - child.width)*0.5, (_height-child.height)*0.5, _width * (1/maxRatio), _height * (1/maxRatio) );
					
					break;
			}
			
			dispatchEvent( new ResizeEvent( ResizeEvent.RESIZE ) );
		}
		
		public function set source( value:Object ):void
		{
			if ( value == _source ) return;
			_source = value
			invalidate();
		}
		
		public function get source():Object
		{
			return _source;
		}

		public function get scaleMode():String
		{
			return _scaleMode;
		}

		public function set scaleMode(value:String):void
		{
			if ( value == _scaleMode ) return;
			invalidate();
			_scaleMode = value;
		}

		public function get maxScale():Number
		{
			return _maxScale;
		}

		public function set maxScale(value:Number):void
		{
			if ( _maxScale == value ) return;
			invalidate();
			_maxScale = value;
		}

		public function get minScale():Number
		{
			return _minScale;
		}

		public function set minScale(value:Number):void
		{
			if ( _minScale == value ) return;
			invalidate();
			_minScale = value;
		}


	}
}