package flox.ui.util
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class Scale9GridUtil
	{
		public static function setScale9Grid(skin:Sprite, grid:Rectangle):void
		{
			while (!skin.scale9Grid) {
				try {
					skin.scale9Grid = grid;
				} catch ( e:Error ) {
					trace("setScale9Grid "+e.errorID+" "+e.message);
				}
			}
		}
	}
}