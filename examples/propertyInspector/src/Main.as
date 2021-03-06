/**
 * PropertyInspectorExample.as
 *
 * This example shows how to use a Class with [Inspectable] metadata as a
 * dataprovider for the 'PropertyInspector' component.
 * This component will list the inspectable properties of the object, and 
 * allows editing of these properties via itemEditor components.
 *
 * Copyright (c) 2012 Jonathan Pace
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
	import core.data.ArrayCollection;
	import core.ui.components.Application;
	import core.ui.components.PropertyInspector;
	
	import util.InspectableObject;
	
	[SWF( width="400", height="600", backgroundColor="0x101010", frameRate="60" )]
	public class Main extends Application
	{
		private var propertyInspector	:PropertyInspector;
		
		
		public function Main()
		{
			
		}
		
		override protected function init():void
		{
			super.init();
			
			padding = 10;
			
			propertyInspector = new PropertyInspector();
			propertyInspector.percentWidth = propertyInspector.percentHeight = 100;
			addChild(propertyInspector);
			
			var inspectableObject:InspectableObject = new InspectableObject();
			propertyInspector.dataProvider = new ArrayCollection( [ inspectableObject ] );
		}
	}
}