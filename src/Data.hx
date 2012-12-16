import Common;

typedef ShopItem = { i : Item, price : Int, ?text : String, f : Void -> Void }

class Data
{

	static var game(get, null) : Game;
	static function get_game() return Game.inst
	
	public static var WEAPONS : Array<ShopItem> = [
		{ i : BaseBat, price : 10, f : function() game.hero.power = 2 },
		{ i : Knife, price : 50, f : function() game.hero.power = 5 },
		{ i : Pistol, price : 200, f : function() game.hero.power = 10 },
		{ i : MiniGun, price : 1000, f : function() game.hero.power = 20 },
	];
	
	public static var NPC : Array<NpcData> = [
		{ id : 0, name : "JeeZee", age : 30, att : 5, def : 10, money : 5, quest : null },
		{ id : 1, name : "Leela", age : 7, att : 0, def : 5, money : 3, quest : null },
		{ id : 2, name : "Jimjim", age : 9, att : 1, def : 5, money : 3, quest : { target : 7, t : "If you kill my mother I'll give you $100", m : 100 } },
		{ id : 3, name : "Weido", age : 45, att : 2, def : 15, money : 10, quest : null },
		{ id : 4, name : "Tizon", age : 35, att : 50, def : 40, money : 5, quest : { target : 5, t : "You are doing a good job, but Glaze is betraying me : get a knife and kill him !", m : 50, kill : true } },
		{ id : 5, name : "Glaze", age : 30, att : 10, def : 15, money : 20, quest : { target : 4, t : "Our Boss wanna see ya, move your ass and see him quick", m : 0 } },
		{ id : 6, name : "Bob", age : 22, att : 5, def : 20, money : 20, quest : null },
		{ id : 7, name : "Miss Auto", age : 25, att : 5, def : 10, money : 15, quest : null },
		{ id : 8, name : "Mr Punk", age : 30, att : 25, def : 30, money : 5, quest : { target : 5, t : "Ya want money ?!? Bring this drug to Glaze !", m : 20 } },
		{ id : 9, name : "Grandma Kalash", age : 80, att : 8, def : 30, money : 50, quest : null },
		{ id : 10,name : "Snoop", age : 5, att : 15, def : 10, money : 0, quest : null },
	];
	
	
	public static var ACTIONS = ["Punch", "Talk"];
	
	public static var ITEMS : Array<ShopItem> = [
		{ i : Book, price : 30, f : function() game.addAction(1), text : "You can now talk to people !" },
		{ i : Scissors, price : 100, f : function() game.items.push(Scissors), text : "You got scissors ! Whose hair do you want to cut ?" },
	];
	
	public static var ITEM_NAMES = [
		"Haircut Scissors",
		"Drug",
		"Baseball Bat",
		"Knife",
		"Pistol",
		"MiniGun",
		"Social Book",
	];
	
}