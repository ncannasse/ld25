
typedef K = flash.ui.Keyboard;

@:bitmap("gfx/tiles.png")
class Tiles extends flash.display.BitmapData {
}

@:bitmap("gfx/sprites.png")
class Sprites extends flash.display.BitmapData {
}

typedef Layer = {
	data : Array<Int>,
	name : String,
}

typedef Tiled = {
	width : Int,
	height : Int,
	layers : Array<Layer>,
}

