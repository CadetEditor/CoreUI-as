package core.ui.components
{
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import core.layout.TextAlign;
	import core.ui.data.PropertyInspectorField;
	import core.ui.events.ItemEditorEvent;

	[Event( type="core.ui.events.ItemEditorEvent", name="commitValue" )]
	public class PropertyInspectorItemRenderer extends UIComponent
	{
		private var _data	:PropertyInspectorField;
		
		private var labelField	:Label;
		private var editor		:UIComponent;
		private var isEnabled	:Boolean;
		private var isEditing	:Boolean;
		private var interval	:int;
		private var hRuleTop	:HRule;
		private var hRuleBottom	:HRule;
		
		public function PropertyInspectorItemRenderer()
		{
			super();
		}
		
		override protected function init():void
		{
			percentWidth = 100;
			
			labelField = new Label();
			labelField.resizeToContentWidth = false;
			
			addChild(labelField);
		}
		
		override protected function validate():void
		{
			if ( _data && _data.isCategory )
			{
				
				height = 36;
				labelField.bold = true;
				labelField.x = 6;
				labelField.width = _width - 12;
				labelField.textAlign = TextAlign.LEFT;
				
				if ( hRuleTop == null )
				{
					hRuleTop = new HRule();
					addChildAt(hRuleTop,0);
					hRuleBottom = new HRule();
					addChildAt(hRuleBottom,0);
				}
				
				hRuleTop.visible = true;
				hRuleBottom.visible = true;
				hRuleTop.width = hRuleBottom.width = _width;
				hRuleTop.y = _height-hRuleTop.height;
				hRuleTop.validateNow();
				hRuleBottom.validateNow();
			}
			else
			{
				height = 28;
				labelField.bold = false;
				labelField.x = 6;
				labelField.width = 120;
				labelField.textAlign = TextAlign.RIGHT;
				
				if ( hRuleTop )
				{
					hRuleTop.visible = false;
					hRuleBottom.visible = false;
				}
			}
			
			labelField.validateNow();
			labelField.y = (height - labelField.height) * 0.5;
			
			
			if ( editor )
			{
				editor.x = labelField.x + labelField.width + 6;
				editor.y = (_height - editor.height) * 0.5;
				editor.width = _width - editor.x - 4;
				editor.validateNow();
			}
		}
		
		public function set data( value:PropertyInspectorField ):void
		{
			var wasEnabled:Boolean = isEnabled;
			
			if ( _data )
			{
				disable();
				if ( editor )
				{
					removeChild(editor);
					editor = null;
				}
			}
			
			_data = value;
			
			if ( _data )
			{
				labelField.text = _data.label || _data.property;
				
				if ( _data.editorDescriptor )
				{
					createEditor();
				}
			}
			
			if ( wasEnabled )
			{
				enable();
			}
			
			invalidate();
		}
		
		public function get data():PropertyInspectorField
		{
			return _data;
		}
		
		protected function createEditor():void
		{
			var editorType:Class = _data.editorDescriptor.type;
			editor = UIComponent(new editorType());
			
			for ( var editorProperty:String in _data.editorParameters )
			{
				if ( editor.hasOwnProperty( editorProperty ) == false )
				{
					throw( new Error( "Cannot find property '" + editorProperty + "' on editor of type '" + _data.editorID ) );
					continue;
				}
				editor[editorProperty] = _data.editorParameters[editorProperty];
			}
			
			if ( _data.editorDescriptor.itemsField )
			{
				editor[_data.editorDescriptor.itemsField] = _data.hosts;
			}
			if ( _data.editorDescriptor.itemsPropertyField )
			{
				editor[_data.editorDescriptor.itemsPropertyField] = _data.property;
			}
			
			addChild(editor);
			
			updateEditorValueFromHosts();
			
			
		}
		
		public function dispose():void
		{
			disable();
		}
		
		public function enable():void
		{
			if ( isEnabled ) return;
			
			isEnabled = true;
			
			if ( !editor ) return;
			
			if ( _data.editorDescriptor.autoCommitValue )
			{
				editor.addEventListener( _data.editorDescriptor.changeEventType, onEditorChange );
				editor.addEventListener( _data.editorDescriptor.commitEventType, onEditorCommit );
				interval = flash.utils.setInterval( updateEditorValueFromHosts, 30 );
			}
		}
		
		public function disable():void
		{
			if ( !isEnabled ) return;
			
			isEditing = false;
			isEnabled = false;
			
			if ( !editor ) return;
			
			if ( _data.editorDescriptor.autoCommitValue )
			{
				editor.removeEventListener( _data.editorDescriptor.changeEventType, onEditorChange );
				editor.removeEventListener( _data.editorDescriptor.commitEventType, onEditorCommit );
				flash.utils.clearInterval(interval);
			}
		}
		
		private function updateEditorValueFromHosts():void
		{
			//if ( _data.editorDescriptor.autoCommitValue == false ) return;
			
			var allMatch:Boolean = true;
			for ( var i:int = 1; i < _data.hosts.length; i++ )
			{
				var prevHost:Object = _data.hosts[i-1];
				var host:Object = _data.hosts[i];
				if ( prevHost[_data.property] != host[_data.property] )
				{
					allMatch = false;
					break;
				}
			}
			
			if ( allMatch )
			{
				editor[_data.editorDescriptor.valueField] = _data.hosts[0][_data.property];
			}
			else
			{
				editor[_data.editorDescriptor.valueField] = null;
			}
		}
		
		private function storeValuesIfNeeded():void
		{
			if ( isEditing ) return;
			isEditing = true;
			
			_data.storedValues = [];
			for ( var i:int = 0; i < _data.hosts.length; i++ )
			{
				_data.storedValues[i] = _data.hosts[i][_data.property];
			}
		}
		
		private function onEditorChange( event:Event ):void
		{
			storeValuesIfNeeded();
			
			var value:* = editor[_data.editorDescriptor.valueField];
			
			if ( _data.editorDescriptor.autoCommitValue )
			{
				for each ( var host:Object in _data.hosts )
				{
					host[_data.property] = value;
				}
			}
					
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.CHANGE, value, _data.property ) );
		}
		
		private function onEditorCommit( event:Event ):void
		{
			storeValuesIfNeeded();
			isEditing = false;
			
			var value:* = editor[_data.editorDescriptor.valueField];
			
			if ( _data.editorDescriptor.autoCommitValue )
			{
				for each ( var host:Object in _data.hosts )
				{
					host[_data.property] = value;
				}
			}
			
			dispatchEvent( new ItemEditorEvent( ItemEditorEvent.COMMIT_VALUE, value, _data.property ) );
		}
	}
}