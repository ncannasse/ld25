import Common;

typedef ShopItem = { i : Item, price : Int, ?text : String, f : Void -> Void }

class Data
{

	static var game(get, null) : Game;
	static function get_game() return Game.inst
	
	public static var WEAPONS : Array<ShopItem> = [
		{ i : BaseBat, price : 10, f : function() game.hero.power = 2 },
		{ i : Knife, price : 50, f : function() game.hero.power = 5 },
		{ i : Pistol, price : 500, f : function() game.hero.power = 10 },
		{ i : MiniGun, price : 5000, f : function() game.addAction(2) },
	];
	
	public static var NPC : Array<NpcData> = [
		{ id : 0, name : "JeeZee", age : 30, att : 5, def : 10, money : 5, quest : { targets : [7], t : "I'm in Love with Miss Auto, but she rejected me. Attack her and cut her beautiful hair for me !", m : 10 } },
		{ id : 1, name : "Leela", age : 7, att : 0, def : 5, money : 3, quest : { targets : [2], t : "My brother is annoying, he won't stop complaining.\nIf you kill him I'll give you a reward.", m : 50, kill : true } },
		{ id : 2, name : "Jimjim", age : 9, att : 1, def : 5, money : 3, quest : { targets : [7], t : "My mother is annoying, she won't stop yelling at me.\nIf you kill her I'll give you $100", m : 100, kill : true } },
		{ id : 3, name : "Weido", age : 45, att : 2, def : 15, money : 10, quest : { targets : [8,4], t : "The two Mafia members Tizon and Glaze are threatening be.\nIf you could get rid of them I'll give you a huge reward", m : 4700, kill : true } },
		{ id : 4, name : "Tizon", age : 35, att : 50, def : 40, money : 5, quest : { targets : [5], t : "You are doing a good job, but Glaze is betraying me : get a knife and kill him !", m : 50, kill : true } },
		{ id : 5, name : "Glaze", age : 30, att : 10, def : 15, money : 20, quest : { targets : [4], t : "Our Boss wanna see ya, move your ass and see him quick", m : 0 } },
		{ id : 6, name : "Bob", age : 22, att : 5, def : 20, money : 20, quest : { targets : [6], t : "I hate these truks, they won't let me skate freely.\nDestroying them would require a MiniGun...", m : 50 } },
		{ id : 7, name : "Miss Auto", age : 25, att : 5, def : 10, money : 15, quest : { targets : [9], t : "Would you buy some strong sleeping pills for Grandma ?\nI'm tired of seeing her ugly face", m : 100 } },
		{ id : 8, name : "Mr Punk", age : 30, att : 25, def : 30, money : 5, quest : { targets : [5], t : "Ya want money ?!? Bring this drug to Glaze !", m : 20 } },
		{ id : 9, name : "Grandma Kalash", age : 80, att : 8, def : 30, money : 50, quest : { targets : [10], t : "Would you agree to kill this wandering dog ?\nI HATE dogs", m : 500, kill : true } },
		{ id : 10, name : "Snoop", age : 5, att : 15, def : 10, money : 0, quest : { targets : [10], t : "Woof ! Woof ! Pizzzaaa woof !", m : 0 } },
		{ id : 11, name : "Angel", age : 666, att : 0, def : 100, money : 0, quest : { targets : [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], t : "I am your guardian angel. Punish all the sinners and get redemption !", kill : true, m : 0 } },
	];
	
	
	public static var ACTIONS = ["Punch", "Talk"];
	
	public static var ITEMS : Array<ShopItem> = [
		{ i : Book, price : 30, f : function() game.addAction(1), text : "You can now talk to people !" },
		{ i : Pills, price : 100, f : function() game.items.push(Pills), text : "This could kill an elephant." },
		{ i : Scissors, price : 150, f : function() game.items.push(Scissors), text : "Whose hair do you want to cut ?" },
	];
	
	public static var ITEM_NAMES = [
		"Haircut Scissors",
		"Drug",
		"Baseball Bat",
		"Knife",
		"Pistol",
		"MiniGun",
		"Social Book",
		"Sleeping Pills",
		"Pizza",
	];
	
}