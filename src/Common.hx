
typedef K = flash.ui.Keyboard;

@:bitmap("gfx/tiles.png")
class Tiles extends flash.display.BitmapData {
}

@:bitmap("gfx/sprites.png")
class Sprites extends flash.display.BitmapData {
}

@:bitmap("gfx/radial.png")
class LightBMP extends flash.display.BitmapData {
}

@:bitmap("gfx/halo.png")
class HaloBMP extends flash.display.BitmapData {
}

@:bitmap("gfx/ui.png")
class UIBMP extends flash.display.BitmapData {
}

@:bitmap("gfx/cars.png")
class CarsBMP extends flash.display.BitmapData {
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

typedef NpcData = {
	var id : Int;
	var name : String;
	var age : Int;
	var att : Int;
	var def : Int;
	var money : Int;
	var quest : { ?target : Int, t : String, m : Int, ?kill : Bool };
}

typedef SaveData = {
	act : Int,
	x : Float,
	y : Float,
	attack : Float,
	money : Int,
	life : Float,
	actions : Array<Int>,
	e : Array<{ id : Int, m : Int, life : Float, x : Float, y : Float }>,
	mission : Int,
	quests : Array<Int>,
	items : Array<Item>,
	questsDone : Array<Int>,
}

enum Item {
	Scissors;
	Drug;
	BaseBat;
	Knife;
	Pistol;
	MiniGun;
	Book;
}


