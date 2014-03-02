
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
	var quest : { ?targets : Array<Int>, t : String, m : Int, ?kill : Bool };
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
	cars : Array<{ id : Int, life : Float, x : Float, y : Float, dir : Int }>,
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
	Pills;
	Pizza;
	Angel;
}


