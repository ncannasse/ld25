import Common;

class Game implements haxe.Public {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	var tiles : h2d.Tile;
	var uiTile : h2d.Tile;
	var cursor : h2d.Tile;
	var sprites : Array<Array<h2d.Tile>>;
	var cars : Array<Array<h2d.Tile>>;
	var scroll : { x : Float, y : Float };

	var scrollBitmap : h2d.CachedBitmap;
	var scrollContent : h2d.Layers;
	var font : h2d.Font;
	
	var hero : Hero;
	var entities : Array<Entity>;
	var collide : Array<Array<Bool>>;
	var road : Array<Array<Bool>>;
	var roadOrPass : Array<Array<Bool>>;
	
	var mapWidth : Int;
	var mapHeight : Int;
	var showBounds : Bool;
	
	var menu : SelectMenu;
	var panel : h2d.Sprite;
	
	var money : Int;
	var moneyUI : h2d.Text;
	
	var attack : Int = 1;
	var life : Float = 100;
	
	var mission : Int;
	var missionText : h2d.Text;
	var missionCheck : Void -> Void;
	var missionScan : Npc -> Bool;
	
	var miniMap : h2d.Bitmap;
	var inShop : Bool = false;
	
	var isHurt : Bool;
	var healCount : Int;

	var curAction : Int;
	var actions : Array<{ id : Int, t : String, f : Void -> Void, mc : h2d.Bitmap }>;
			
	function new(e) {
		this.engine = e;
	}
	
	public function init() {
		entities = [];
		scene = new h2d.Scene();
		scene.setFixedSize(380, 250);
		var t = new Tiles(0, 0, true);
		var s = new Sprites(0, 0, true);
		var c = new CarsBMP(0, 0, true);
		clearTile(t);
		clearTile(s);
		clearTile(c);
		
		actions = [];
		
		font = new h2d.Font("PixelFont", 16);
		uiTile = h2d.Tile.fromBitmap(new UIBMP(0, 0, true));
		tiles = h2d.Tile.fromBitmap(t);
		cursor = tiles.sub(32, 144, 16, 16);
		sprites = h2d.Tile.autoCut(s, 16).tiles;
		
		
		cars = h2d.Tile.autoCut(c, 16 * 3, 16 * 2).tiles;
		for( sx in sprites )
			for( i in 0...sx.length ) {
				var s = sx[i];
				s = s.sub(0, 0, s.width, s.height, -s.width, 5-(s.height * 2) );
				s.scaleToSize(s.width * 2, s.height * 2);
				sx[i] = s;
			}
			
		for( sx in cars )
			for( i in 0...sx.length ) {
				var s = sx[i];
				s = s.sub(0, 0, s.width, s.height, -s.width, 5-(s.height * 2) );
				s.scaleToSize(s.width * 2, s.height * 2);
				sx[i] = s;
			}
			
		
		scrollBitmap = new h2d.CachedBitmap(scene, scene.width, scene.height);
		scrollContent = new h2d.Layers(scrollBitmap);
		scrollBitmap.color = new h3d.Vector(0.8, 0.8, 1.2);
		
		var mpanel = newPanel();
		mpanel.width = scene.width + 6;
		mpanel.x = -3;
		mpanel.height = 30;
		mpanel.y = scene.height - mpanel.height + 3;
		mpanel.alpha = 0.95;
		
		missionText = new h2d.Text(font, mpanel);
		missionText.x = 10;
		missionText.maxWidth = (scene.width - 20) * 2;
		missionText.scaleX = missionText.scaleY = 0.5;
		mission = -1;
		nextMission();
		
		initMap();
		scroll = { x : 15, y : 27 };
		
		var bmp = new flash.display.BitmapData(mapWidth, mapHeight, true, 0xFF808090);
		for( x in 0...mapWidth )
			for( y in 0...mapHeight ) {
				if( road[x][y] ) bmp.setPixel32(x, y, 0xFF404048);
				if( collide[x][y] ) bmp.setPixel32(x, y, 0xFFA0A0B0);
			}
		miniMap = new h2d.Bitmap(h2d.Tile.fromBitmap(bmp), scene);
		miniMap.x = scene.width - mapWidth - 5;
		miniMap.y = 5;
		miniMap.blendMode = Add;
		miniMap.alpha = 0.5;
		initEnt();
		
		addAction(0,"Punch",doPunch);
		
		moneyUI = new h2d.Text(font, scene);
		moneyUI.x = 5;
		moneyUI.y = 5;
		moneyUI.textColor = 0xFFEFE161;
		moneyUI.dropShadow = { dx : 1, dy : 2, color : 0, alpha : 0.5 };
		moneyUI.text = "$" + money;
	}
	
	static var disableColor = new h3d.Vector(0.5, 0.5, 0.5, 1);
	
	function addAction(id, text, f) {
		var mc = new h2d.Bitmap(tiles.sub(id * 16, 208, 16, 16), scene);
		mc.x = 5 + actions.length * 20;
		mc.y = scene.height - 40;
		if( actions.length > 0 ) mc.color = disableColor;
		actions.push( { id:id, t:text, f:f, mc :mc } );
	}
	
	function initEnt() {
		hero = new Hero(scroll.x, scroll.y);
		hero.power = 2;
		hero.life = hero.maxLife = 100;
		
		for( i in 0...11 ) {
			var x, y;
			do {
				x = Std.random(mapWidth);
				y = Std.random(mapHeight);
			} while( collide[x][y] || road[x][y] );
			var id = i % 11;
			var n = new Npc(id, x + 0.5, y + 0.5);
			var inf = Data.NPC[n.id];
			n.life = n.maxLife = inf.def;
			n.power = inf.att;
			n.onKill = function() {
				if( inf.money > 0 ) {
					var k = ((inf.money + 1) >> 1) + Std.random(inf.money>>1);
					for( i in 0...k ) {
						var e = new Bill(n.x, n.y);
						var a = Math.atan2(n.y - hero.y, n.x - hero.x) + (Math.random() * 2 - 1) * Math.PI / 4;
						var p = (2 + Math.random() * 4) * 0.1;
						e.pushX = Math.cos(a) * p;
						e.pushY = Math.sin(a) * p;
					}
					inf.money -= k;
				}
			}
		}
		
		new Car(0, 10, 26);
		new Car(1, 33, 31);
		new Car(2, 12, 55);
		new Car(3, 32, 14);
	}
	
	function getMoney(m) {
		money += m;
		moneyUI.text = "$" + money;
		if( m > 0 ) announce("You got $" + m);
	}
	
	var announceText : h2d.Text;
	function announce(text) {
		if( announceText != null )
			announceText.remove();
		announceText = new h2d.Text(font,scene);
		announceText.x = 5;
		announceText.y = 25;
		announceText.scaleX = announceText.scaleY = 0.5;
		announceText.text = text;
	}
	
	function nextMission() {
		mission++;
		var text, miss, scan : Npc -> Bool = null;
		switch( mission ) {
		case 0:
			text = "Stole $10 from people which can't defend themselves.\nTip : Look at the Minimap to find your target.";
			miss = function() {
				if( money >= 10 ) nextMission();
			};
			scan = function(n) return Data.NPC[n.id].att <= attack;
		case 1:
			showPanel("You have completed the first mission ! Look at the panel below to check next objective");
			text = "Go buy a weapon at your favorite shop in the city center.";
			miss = function() {
				if( attack > 1 ) nextMission();
			};
		case 2:
			text = "Try to get $30 from people. But be careful to hide yourself from other peasants.";
			miss = function() {
				if( money >= 30 ) nextMission();
			};
			scan = function(n) return Data.NPC[n.id].att <= attack;
		case 3:
			text = "Go buy an item at the items shop !";
			miss = function() {
				
			};
		default:
			text = "TODO";
			miss = function() {
			};
		}
		missionText.text = "Mission " + (mission + 1) + " : " + text;
		missionText.y = (30 - (missionText.textHeight>>1)) >> 1;
		missionCheck = miss;
		missionScan = scan;
	}
	
	function clearTile(t:flash.display.BitmapData) {
		var bg = t.getPixel32(t.width - 1, t.height - 1);
		t.lock();
		for( x in 0...t.width )
			for( y in 0...t.height )
				if( t.getPixel32(x, y) == bg )
					t.setPixel32(x, y, 0);
	}
	
	function initMap() {
		var map : Tiled = haxe.Json.parse(haxe.Resource.getString("map"));
		var layers = [];
		var tmap = [], smap = [];
		for( y in 0...tiles.height >> 4 )
			for( x in 0...tiles.width >> 4 ) {
				tmap.push(tiles.sub(x * 16, y * 16, 16, 16));
				smap.push(tiles.sub(x * 16, y * 16, 16, 16, 0, -16));
			}
		collide	= [];
		road = [];
		roadOrPass = [];
		for( x in 0...map.width ) {
			collide[x] = [];
			road[x] = [];
			roadOrPass[x] = [];
		}
		mapWidth = map.width;
		mapHeight = map.height;
		for( l in map.layers ) {
			var over = false;
			var pos = 0;
			var t = new h2d.TileGroup(tiles);
			var plan = Const.PLAN_MAP;
			switch( l.name ) {
			case "collide":
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 ) collide[x][y] = true;
					}
				continue;
			case "soil":
				t.blendMode = None;
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						switch( c-1 ) {
						case 0, 1, 2, 33, 34:
							road[x][y] = true;
							roadOrPass[x][y] = true;
						case 7, 36: // walk way
							roadOrPass[x][y] = true;
						default:
						}
					}
				pos = 0;
			case "underShades":
				t.alpha = 0.3;
			case "shades":
				t.alpha = 0.3;
			case "windows":
				t.alpha = 0.5;
			case "sprites":
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 ) {
							var s = new h2d.Bitmap(smap[c - 1]);
							s.x = x * 16;
							s.y = (y + 1) * 16;
							scrollContent.add(s, Const.PLAN_ENTITY);
						}
					}
				continue;
			case "lights":
				var l = h2d.Tile.fromBitmap(new LightBMP(0, 0, true)).sub(0, 0, 256, 256, -4, -5);
				plan = Const.PLAN_LIGHT;
				l.scaleToSize(32, 32);
				t.tile = l;
				t.alpha = 0.5;
				t.blendMode = Add;
				tmap[101] = l;
			case "over":
				plan = Const.PLAN_OVER;
			case "overShades":
				plan = Const.PLAN_OVER;
				t.alpha = 0.3;
			default:
			}
			for( y in 0...mapHeight ) {
				for( x in 0...mapWidth ) {
					var c = l.data[pos++];
					if( c == 0 ) continue;
					t.add(x * 16, y * 16, tmap[c - 1]);
				}
			}
			scrollContent.add(t, plan);
		}
	}
	
	function doLook(n:Npc) {
		var p = newPanel();
		p.width = 150;
		p.height = 50;
		var b = new h2d.Bitmap(n.anim[0], p);
		b.x = 20;
		b.y = 35;
		var t = new h2d.Text(font, p);
		t.x = 40;
		t.y = 10;
		var inf = Data.NPC[n.id];
		t.text = 'Name : ${inf.name}\nAge : ${inf.age}\nPower : ${inf.att}\nLife : ${Math.ceil(n.life)}/${inf.def}';
		t.scaleX = t.scaleY = 0.5;
		panel = p;
	}
	
	function newPanel() {
		var p = new h2d.ScaleGrid(uiTile, 4, 4, scene);
		p.x = 10;
		p.y = 10;
		return p;
	}
	
	function showPanel( text : String ) {
		if( panel != null )
			panel.remove();
		var p = newPanel();
		p.width = scene.width - 20;
		p.height = 25;
		var t = new h2d.Text(font, p);
		t.text = text;
		t.maxWidth = (scene.width - 40) * 2;
		t.scaleX = t.scaleY = 0.5;
		t.y = (25 - (t.textHeight >> 1)) >> 1;
		t.x = (p.width - (t.textWidth >> 1)) >> 1;
		panel = p;
	}
	
	function doSteal(n:Npc) {
		var inf = Data.NPC[n.id];
		if( inf.att > attack ) {
			showPanel("You should not attack someone stronger than you !");
			return;
		}
		
	}
	
	function updateGamePlay(dt:Float ) {
		var ds = hero.speed * dt;
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) )
			hero.moveBy( -ds, 0);
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) )
			hero.moveBy( ds, 0);
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) )
			hero.moveBy( 0, ds);
		if( Key.isDown(K.UP) || Key.isDown("Z".code) || Key.isDown("W".code) )
			hero.moveBy( 0, -ds);
		scrollContent.ysort(Const.PLAN_ENTITY);
		for( e in entities.copy() )
			e.update(dt);
			
		if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) )
			actions[curAction].f();
	}
	
	
	function update(dt:Float) {
		
		if( announceText != null ) {
			announceText.alpha -= dt * 0.05;
			announceText.y -= dt * 0.5;
			if( announceText.alpha <= 0 ) {
				announceText.remove();
				announceText = null;
			}
		}
		
		Part.updateAll(dt);
		
		scroll.x = hero.x;
		scroll.y = hero.y;
		
		var ix = Std.int(scroll.x * 16) - (scene.width >> 1);
		var iy = Std.int(scroll.y * 16) - (scene.height >> 1);
		if( ix < 0 ) ix = 0;
		if( iy < 0 ) iy = 0;
		if( ix + scene.width > mapWidth * 16 ) ix = mapWidth * 16 - scene.width;
		if( iy + scene.height > mapHeight * 16 + 20 ) iy = mapHeight * 16 - scene.height + 20;
		scrollContent.x = -ix;
		scrollContent.y = -iy;
		
		for( i in 0...9 )
			if( (Key.isToggled(K.NUMBER_1 + i) || Key.isToggled(K.NUMPAD_1 + i)) && actions[i] != null && i != curAction ) {
				curAction = i;
				for( i in 0...actions.length )
					actions[i].mc.color = i == curAction ? null : disableColor;
					
				announce("Action : " + actions[i].t);
				break;
			}
				
		
		if( menu != null ) {

			if( Key.isToggled(K.DOWN) || Key.isToggled("S".code) ) {
				menu.index++;
				menu.index %= menu.options.length;
			}
			
			if( Key.isToggled(K.UP) || Key.isToggled("Z".code) || Key.isToggled("W".code) ) {
				menu.index--;
				if( menu.index < 0 ) menu.index += menu.options.length;
			}
			
			if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) ) {
				var old = menu;
				menu.remove();
				menu = null;
				var o = old.options[old.index];
				if( o.price != null ) {
					if( money < o.price )
						showPanel("You don't have enough money");
					else {
						money -= o.price;
						o.c();
					}
				} else
					o.c();
				return;
			}
			
			menu.update(dt);
				
		} else if( panel != null ) {
			if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) ) {
				panel.remove();
				panel = null;
			}
		} else
			updateGamePlay(dt);
			
		if( Key.isToggled("B".code) )
			showBounds = !showBounds;
	
		if( Key.isToggled("M".code) )
			getMoney(money == 0 ? 10 : money);
			
		var ix = Std.int(hero.x), iy = Std.int(hero.y);
		if( ix == 20 && iy == 22 )
			initShop(Data.WEAPONS);
		else if( ix == 35 && iy == 27 ) {
			if( !inShop ) {
				if( mission < 3 ) {
					inShop = true;
					showPanel("The item shop is currently closed, please come by again later.");
				} else
					initShop(Data.ITEMS);
			}
		} else if( ix == 6 && iy == 40 ) {
			if( !inShop ) {
				inShop = true;
				var price = 20 + healCount * 10;
				menu = new SelectMenu([
					{
						t : "Heal",
						price : price,
						c : function() {
							hero.life = hero.maxLife;
							hero.showLife();
							announce("Life healed !");
						}
					},
					{
						t : "Exit",
						c : function() {},
					}
				]);
			}
		} else
			inShop = false;
	
		if( !isHurt && hero.life < 0 ) {
			isHurt = true;
			showPanel("You've been badly hurt, you should go to the hospital to heal yourself");
		}
			
		missionCheck();
		
		engine.render(scene);
	}

	function initShop( items : Array<Data.ShopItem> ) {
		if( inShop )
			return;
		inShop = true;
		var options : SelectMenu.Options = [];
		for( i in items )
			options.push( {
				t : i.name,
				price : i.price,
				c : function() {
					items.remove(i);
					i.f();
					var text = "Congratulations ! You bought " + i.name + " for $" + i.price + "\n";
					if( i.text != null )
						text += i.text;
					else if( items == Data.WEAPONS )
						text += "Your attack power is now " + attack;
										showPanel(text);
				},
			});
		options.push( { t : "Exit", price : null, c : function() { } });
		menu = new SelectMenu(options);
	}
	
	//----------------- ACTIONS
	
	function doPunch() {
		if( hero.life <= 0 )
			showPanel("You can't attack while you're badly hurt, wait to recover or go to the hospital");
		else
			hero.attack();
	}
	
	function doTalk() {
		trace("TODO");
	}
	
	
	public static var inst : Game;
	
	static function updateLoop() {
		Timer.update();
		if( inst != null ) inst.update(Timer.tmod);
	}

	
	static function main() {
		var engine = new h3d.Engine();
		engine.onReady = function() {
			inst = new Game(engine);
			inst.init();
		};
		engine.init();
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, function(_) updateLoop());
		Key.init();
	}
	
}