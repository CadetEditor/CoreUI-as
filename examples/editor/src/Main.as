/**
 * FloxEditor.as
 *
 * This example provides a simple text input field where you can type Flux XML, 
 * and on the right the view will update instantly to show you the result of
 * deserializing that XML.
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

package
{
	import flash.events.Event;
	
	import flox.ui.components.Application;
	import flox.ui.components.Container;
	import flox.ui.components.TextArea;
	import flox.ui.components.TextInput;
	import flox.ui.components.UIComponent;
	import flox.ui.components.VBox;
	import flox.ui.layouts.HorizontalLayout;
	import flox.ui.util.FloxDeserializer;
	
	[SWF( width="800", height="600", backgroundColor="0x101010", frameRate="60" )]
	public class Main extends Application
	{
		private var textInput	:TextInput;
		private var output		:Container;
		private var errorOutput	:TextArea;
		
		
		public function Main()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			layout = new HorizontalLayout();
			
			var vBox:VBox = new VBox();
			vBox.percentWidth = 100;
			vBox.percentHeight = 100;
			addChild(vBox);
			
			textInput = new TextInput();
			textInput.editable = true;
			textInput.multiline = true;
			textInput.percentWidth = 100;
			textInput.percentHeight = 100;
			textInput.addEventListener(Event.CHANGE, changeTextHandler);
			textInput.fontFamily = "_typewriter";
			textInput.embedFonts = false;
			textInput.fontSize = 11;
			vBox.addChild(textInput);
			
			errorOutput = new TextArea();
			errorOutput.percentWidth = 100;
			errorOutput.height = 100;
			vBox.addChild(errorOutput);
			
			output = new Container();
			output.percentWidth = 100;
			output.percentHeight = 100;
			addChild(output);
			
			var exampleXML:XML =
			<VBox width="100%" height="100%" >
				<Button label="Button A" />
				<Button label="Button B" toggle="true" />
				<Button label="Button C" selected="true" />
			</VBox>
				
			textInput.text = exampleXML.toXMLString();
			textInput.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function changeTextHandler( event:Event ):void
		{
			errorOutput.text = "";
			try
			{
				var xml:XML = XML( textInput.text );
				var component:UIComponent = FloxDeserializer.deserialize(xml);
				while ( output.numChildren > 0 )
				{
					output.removeChildAt(0);
				}
				output.addChild(component);
			}
			catch ( e:Error )
			{
				errorOutput.text = e.message;
				
				if ( textInput.text == "" )
				{
					while ( output.numChildren > 0 )
					{
						output.removeChildAt(0);
					}
				}
			}
		}
	}
}