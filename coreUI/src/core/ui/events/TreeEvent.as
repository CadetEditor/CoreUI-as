/**
 * TreeEvent.as
 * 
 * Container component with a title bar and control bar.
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

package core.ui.events 
{
	import flash.events.Event;
	
	public class TreeEvent extends Event 
	{
		public static const ITEM_OPEN		:String = "itemOpen";
		public static const ITEM_CLOSE		:String = "itemClose";
		
		private var _item		:Object;
		
		public function TreeEvent( type:String, item:Object, bubbles:Boolean = false, cancelable:Boolean = false ) 
		{
			super(type, bubbles, cancelable);
			_item = item;
		}
		
		override public function clone():Event
		{
			return new TreeEvent( type, _item, bubbles, cancelable );
		}
		
		public function get item():Object
		{
			return _item;
		}
	}
}