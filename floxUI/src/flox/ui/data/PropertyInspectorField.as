/**
 * PropertyInspectorField.as
 * 
 * Used internally by the PropertyInspector control. Should not be created outside this scope.
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

package flox.ui.data 
{
	public class PropertyInspectorField
	{
		public var hosts			:Array;		// The owner of the property
		public var property			:String;	// The name of the property on the host
		public var label			:String;	// Optional. The label to display (if null, will display property).
		public var category			:String;	// Optional.
		public var editorDescriptor	:Object
		public var editorParameters	:Object;
		public var editorID			:String;
		public var storedValues		:Array;
		public var priority			:int = int.MAX_VALUE;
		public var isCategory		:Boolean;
		
		public function PropertyInspectorField()
		{
			editorParameters = {};
		}
	}

}