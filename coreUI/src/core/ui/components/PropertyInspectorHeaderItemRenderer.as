package core.ui.components
{
	import core.ui.events.ItemEditorEvent;

	public class PropertyInspectorHeaderItemRenderer extends UIComponent
	{
		private var _data	:Object;
		
		private var labelField	:Label;
		
		public function PropertyInspectorHeaderItemRenderer()
		{
			super();
		}
		
		override protected function init():void
		{
			percentWidth = 100;
			height = 26;
			
			labelField = new Label();
			addChild(labelField);
		}
		
		override protected function validate():void
		{
			if ( _data )
			{
				labelField.text = _data.label;
			}
			labelField.width = _width;
			labelField.y = (height - labelField.height) * 0.5;
			labelField.validateNow();
		}
		
		public function set data( value:Object ):void
		{
			_data = value;
			invalidate();
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}