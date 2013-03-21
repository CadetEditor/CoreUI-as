package core.ui.events
{
	import flash.events.Event;
	
	public class ResizeEvent extends Event
	{
		public static const RESIZE:String = "core_resize";
	
		public var oldHeight:Number;
		public var oldWidth:Number;		
		
		public function ResizeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldWidth:Number = NaN, oldHeight:Number = NaN)
		{
			this.oldWidth = oldWidth;
			this.oldHeight = oldHeight;
		
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ResizeEvent(type, bubbles, cancelable, oldWidth, oldHeight);
		}
	}
}