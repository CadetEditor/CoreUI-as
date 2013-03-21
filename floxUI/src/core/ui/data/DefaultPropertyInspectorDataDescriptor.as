package core.ui.data
{
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import core.data.ArrayCollection;
	
	public class DefaultPropertyInspectorDataDescriptor implements IPropertyInspectorDataDescriptor
	{
		public function DefaultPropertyInspectorDataDescriptor()
		{
		}
		
		public function getFields(object:Object):Array
		{
			var description:XML = describeType( object );
			var fields:Array = [];
			
			for each( var node:XML in description.children() )
			{
				if ( node.name() != "accessor" && node.name() != "variable" ) continue;
				var metadata:XML = node.metadata.( @name=="Inspectable" )[0];
				if ( !metadata ) continue;
				
				
				var field:PropertyInspectorField = new PropertyInspectorField();
				field.category = getClassName(object);
				field.property = String( node.@name );
				field.hosts = [object];
				
				// If the property is an inspectable list, then populate the fields with the children of that list too.
				if ( object[field.property] is Proxy )
				{
					var children:Object = Proxy(object[field.property]);
					for ( i = 0; i < children.length; i++ )
					{
						var child:Object = children[i];
						var childFields:Array = getFields(child);
						childFields = childFields.sortOn("property");
						fields = fields.concat( childFields );
					}
				}
				else
				{
					// Parse each metadata argument into the field
					for ( var i:int = 0; i < metadata.arg.length(); i++ )
					{
						var argNode:XML = metadata.arg[i];
						
						var key:String = String(argNode.@key);
						var value:String = String(argNode.@value);
						
						// 'editorType' is special, and is id for mapping a property to an editor
						if ( key == "editor" )
						{
							field.editorID = value;
						}
						else if ( key == "label" )
						{
							field.label = value;
						}
						else if ( key == "category" )
						{
							field.category = value;
						}
						else if ( key == "priority" )
						{
							field.priority = int(value);
						}
						// Everything else gets parsed into the editorParameters object. These
						// values then get passed to the editor when created.
						else
						{
							if ( value == "true" )
							{
								field.editorParameters[key] = true;
							}
							else if ( value == "false" )
							{
								field.editorParameters[key] = false;
							}
							else if ( isNaN(Number(value)) == false )
							{
								field.editorParameters[key] = Number(value);
							}
							else if ( value.charAt(0) == "[" && value.charAt(value.length-1) == "]" )
							{
								value = value.substr(1, value.length-2);
								field.editorParameters[key] = new ArrayCollection(value.split(","));
							}
							else
							{
								field.editorParameters[key] = value;
							}
						}
					}
					
					if ( field.editorID == null || field.editorID == "")
					{
						var value2:* = object[field.property];
						if ( value2 is Number )
						{
							field.editorID = "NumberInput";
						}
						else if ( value2 is Boolean )
						{
							field.editorID = "CheckBox";
						}
						else
						{
							field.editorID = "TextInput";
						}
					}
						
					fields.push(field);
				}
			}
			
			return fields;
		}
		
		static private function getClassName( object:Object ):String
		{
			var classPath:String = flash.utils.getQualifiedClassName(object).replace("::",".");
			if ( classPath.indexOf(".") == -1 ) return classPath;
			var split:Array = classPath.split( "." );
			return split[split.length-1];
		}
	}
}