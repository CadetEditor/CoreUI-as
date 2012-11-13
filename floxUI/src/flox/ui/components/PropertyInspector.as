package flox.ui.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import flox.core.data.ArrayCollection;
	import flox.ui.data.DefaultPropertyInspectorDataDescriptor;
	import flox.ui.data.IPropertyInspectorDataDescriptor;
	import flox.ui.data.PropertyInspectorField;
	import flox.core.events.ArrayCollectionEvent;
	import flox.ui.events.ItemEditorEvent;
	import flox.ui.events.PropertyInspectorEvent;
	import flux.skins.PropertyInspectorSkin;

	[Event( type="flox.ui.events.PropertyInspectorEvent", name="commitValue" )]
	public class PropertyInspector extends UIComponent
	{
		// Children
		private var border					:Sprite;
		private var container				:VBox;
		private var scrollBar				:ScrollBar;
		
		// Properties
		private var _dataProvider			:ArrayCollection;
		private var _dataDescriptor			:IPropertyInspectorDataDescriptor;
		private var editorDescriptorTable	:Object;
		private var dataIsInvalid			:Boolean;
		private var itemRendererVisInvalid	:Boolean;
		private var itemRenderers			:Vector.<PropertyInspectorItemRenderer>;
		
		public function PropertyInspector()
		{
			super();
			
			
		}
		
		////////////////////////////////////////////////
		// Public methods
		////////////////////////////////////////////////
		
		/**
		 *
		 * @param	id					The id of the editor. This is how the property inspector matches up inspectable properties with an editor.
		 * 								For example, the metatdata
		 * 								[Inspectable(editor="ColorPicker")]
		 * 								Will cause the PropertyInspector to look for a EditorDescriptor with an id =="ColorPicker"
		 * @param	type				The type of the editor.
		 * @param	valueField			The name of the property on the editor that contains the value being edited (eg NumericStepper's is "value"))
		 * @param	itemsField			(Optional) The name of the property on the editor that should be set with an array of the items being edited.
		 * @param	itemsPropertyField	(Optional) The name of the property on the editor that should be set with the name of the property on the items being edited .
		 */
		public function registerEditor( id:String, type:Class, valueField:String, itemsField:String = null, itemsPropertyField:String = null, autoCommitValue:Boolean = true, changeEventType:String = "change", commitEventType:String = "commitValue" ):void
		{
			var descriptor:EditorDescriptor = new EditorDescriptor( id, type, valueField, itemsField, itemsPropertyField, autoCommitValue, changeEventType, commitEventType );
			editorDescriptorTable[id] = descriptor;
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		public function set dataProvider( value:ArrayCollection ):void
		{
			if ( _dataProvider )
			{
				_dataProvider.removeEventListener( ArrayCollectionEvent.CHANGE, changeDataProviderHandler );
			}
			_dataProvider = value;
			if ( _dataProvider )
			{
				_dataProvider.addEventListener( ArrayCollectionEvent.CHANGE, changeDataProviderHandler );
			}
			dataIsInvalid = true;
			invalidate();
		}
		
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function get dataDescriptor():IPropertyInspectorDataDescriptor
		{
			return _dataDescriptor;
		}
		
		public function set dataDescriptor(value:IPropertyInspectorDataDescriptor):void
		{
			if ( value == null )
			{
				throw( new Error( "Value must not be null" ) );
				return;
			}
			_dataDescriptor = value;
			dataIsInvalid = true;
			invalidate();
		}
		
		////////////////////////////////////////////////
		// Protected methods
		////////////////////////////////////////////////
		
		override protected function init():void
		{
			border = new PropertyInspectorSkin();
			addChild(border);
			
			_dataDescriptor = new DefaultPropertyInspectorDataDescriptor();
			
			container = new VBox();
			container.padding = 6;
			container.resizeToContentHeight = true;
			addChild(container);
			
			scrollBar = new ScrollBar();
			scrollBar.addEventListener(Event.CHANGE, changeScrollBarHandler);
			addChild(scrollBar);
			
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			itemRenderers = new Vector.<PropertyInspectorItemRenderer>();
			
			editorDescriptorTable = { };
			registerEditor( "TextInput", TextInput, "text" );
			registerEditor( "NumberInput", NumberInput, "value" );
			registerEditor( "DropDownMenu", DropDownMenu, "selectedItem" );
			registerEditor( "NumericStepper", NumericStepper, "value" );
			registerEditor( "Slider", HSlider, "value" );
			registerEditor( "ColorPicker", ColorPickerItemEditor, "color" );
			registerEditor( "CheckBox", CheckBox, "selected" );
		}
		
		override protected function validate():void
		{
			border.width = _width;
			border.height = _height;
			
			if ( dataIsInvalid )
			{
				validateData();
				container.validateNow();
				dataIsInvalid = false;
			}
			
			scrollBar.height = _height;
			scrollBar.visible = container.height > _height;
			scrollBar.max = container.height - _height;
			scrollBar.thumbSizeRatio = _height / container.height;
			scrollBar.validateNow();
			
			if ( scrollBar.visible )
			{
				container.width = _width - scrollBar.width;
				scrollBar.x = _width - scrollBar.width;
			}
			else
			{
				container.width = _width;
			}
			
			container.y = -scrollBar.value;
			container.validateNow();
			
			validateItemRendererVisibility();
		}
		
		protected function validateData():void
		{
			// Remove all existing item renderers
			for each ( var itemRenderer:PropertyInspectorItemRenderer in itemRenderers )
			{
				itemRenderer.dispose();
				container.removeChild(itemRenderer);
			}
			itemRenderers = new Vector.<PropertyInspectorItemRenderer>();
			
			if ( _dataProvider == null ) return;
			
			// Generate and sort an array of 'fields'. Each field will become the data provider for a single item renderer.
			var fields:Array = [];
			var fieldPropertiesByType:Dictionary = new Dictionary();
			for ( var i:int = 0; i < _dataProvider.length; i++ )
			{
				var newFields:Array = _dataDescriptor.getFields(_dataProvider[i]);
				for ( var j:int = 0; j < newFields.length; j++ )
				{
					var newField:PropertyInspectorField = newFields[j];
					var newFieldHostType:Class = getType( newField.hosts[0] );
					var existingFieldProperties:Object = fieldPropertiesByType[newFieldHostType];
					if ( existingFieldProperties == null )
					{
						existingFieldProperties = fieldPropertiesByType[newFieldHostType] = {};
					}
					
					var existingField:PropertyInspectorField = existingFieldProperties[newField.property];
					
					if ( existingField )
					{
						existingField.hosts.push(newField.hosts[0]);
					}
					else
					{
						fields.push( newField );
						existingFieldProperties[newField.property] = newField;
						
						if ( newField.category == null )
						{
							newField.category = getClassName(newFieldHostType);
						}
					}
				}
			}
			
			
			
			fields.sortOn(["category", "priority", "property"]);
			
			// Create new item renderers
			var currentCategory:String;
			for ( i = 0; i < fields.length; i++ )
			{
				var field:PropertyInspectorField = fields[i];
				
				if ( field.category != currentCategory )
				{
					currentCategory = field.category;
					
					itemRenderer = new PropertyInspectorItemRenderer();
					container.addChild(itemRenderer);
					var categoryField:PropertyInspectorField = new PropertyInspectorField();
					categoryField.label = currentCategory;
					categoryField.isCategory = true;
					itemRenderer.data = categoryField;
					itemRenderers.push(itemRenderer);
				}
				
				field.editorDescriptor = editorDescriptorTable[field.editorID];
				if ( field.editorDescriptor == null )
				{
					throw( new Error( "No editor descriptor found for editorID : " + field.editorID ) );
					continue;
				}
				
				itemRenderer = new PropertyInspectorItemRenderer();
				container.addChild(itemRenderer);
				itemRenderer.data = field;
				itemRenderers.push(itemRenderer);
				itemRenderer.addEventListener( ItemEditorEvent.CHANGE, onChangeValue );
				itemRenderer.addEventListener( ItemEditorEvent.COMMIT_VALUE, onCommitValue );
				
			}
		}
		
		private function getClassName( object:Object ):String
		{
			var classPath:String = flash.utils.getQualifiedClassName(object).replace("::",".");
			if ( classPath.indexOf(".") == -1 ) return classPath;
			var split:Array = classPath.split( "." );
			return split[split.length-1];
		}
		
		private function getClassPath( object:Object ):String
		{
			return flash.utils.getQualifiedClassName(object).replace("::",".");
		}
		
		private function getType( object:Object ):Class
		{
			var classPath:String = getClassPath( object );
			return Class( flash.utils.getDefinitionByName( classPath ) );
		}
		
		protected function validateItemRendererVisibility():void
		{
			var visibleTop:int = -container.y;
			var visibleBottom:int = visibleTop + _height;
			
			for each ( var itemRenderer:PropertyInspectorItemRenderer in itemRenderers )
			{
				if ( itemRenderer.y + itemRenderer.height >= visibleTop && itemRenderer.y <= visibleBottom )
				{
					itemRenderer.enable();
				}
				else
				{
					itemRenderer.disable();
				}
				
			}
		}
		
		////////////////////////////////////////////////
		// Handlers
		////////////////////////////////////////////////
		
		private function onChangeValue( event:ItemEditorEvent ):void
		{
			
		}
		
		private function onCommitValue( event:ItemEditorEvent ):void
		{
			var itemRenderer:PropertyInspectorItemRenderer = PropertyInspectorItemRenderer(event.target);
			
			dispatchEvent( new PropertyInspectorEvent( PropertyInspectorEvent.COMMIT_VALUE, itemRenderer.data.hosts, event.property, itemRenderer.data.storedValues, event.value ) );
		}
		
		private function changeDataProviderHandler( event:ArrayCollectionEvent ):void
		{
			dataIsInvalid = true;
			invalidate();
		}
		
		private function onMouseWheel( event:MouseEvent ):void
		{
			scrollBar.value += scrollBar.scrollSpeed * (event.delta < 0 ? 1 : -1);
		}
		
		private function changeScrollBarHandler( event:Event ):void
		{
			container.y = -scrollBar.value;
			validateItemRendererVisibility();
		}
		
		////////////////////////////////////////////////
		// Getters/Setters
		////////////////////////////////////////////////
		
		public function set showBorder( value:Boolean ):void
		{
			border.visible = value;
		}
		
		public function get showBorder():Boolean
		{
			return border.visible;
		}
		
		public function set padding( value:int ):void
		{
			container.padding = value;
			invalidate();
		}
		
		public function get padding():int
		{
			return container.padding;
		}
	}
}

internal class EditorDescriptor
{
	public var id					:String
	public var type					:Class
	public var valueField			:String;
	public var itemsField			:String;
	public var itemsPropertyField	:String;
	public var autoCommitValue		:Boolean;
	public var changeEventType		:String;
	public var commitEventType		:String;
	
	public function EditorDescriptor( id:String, type:Class, valueField:String, itemsField:String = null, itemsPropertyField:String = null, autoCommitValue:Boolean = true, changeEventType:String = "change", commitEventType:String = "commitValue" )
	{
		this.id = id;
		this.type =  type;
		this.valueField = valueField;
		this.itemsField = itemsField;
		this.itemsPropertyField = itemsPropertyField;
		this.autoCommitValue = autoCommitValue;
		this.changeEventType = changeEventType;
		this.commitEventType = commitEventType;
	}
}