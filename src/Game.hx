import Common;

class Game implements haxe.Public {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	var tiles : h2d.Tile;
	var uiTile : h2d.Tile;
	var cursor : h2d.Tile;
	var sprites : Array<Array<h2d.Tile>>;
	var scroll : { x : Float, y : Float };

	var scrollBitmap : h2d.CachedBitmap;
	var scrollContent : h2d.Layers;
	var font : h2d.Font;
	
	var hero : Hero;
	var entities : Array<Entity>;
	var collide : Array<Array<Bool>>;
	var road : Array<Array<Bool>>;
	
	var mapWidth : Int;
	var mapHeight : Int;
	var showBounds : Bool;
	
	var menu : SelectMenu;
	var panel : h2d.Sprite;
	
	var money : Int;
	var attack : Int = 1;
	var defense : Int = 1;
	var life : Float = 100;
	
	var mission : Int;
	var missionText : h2d.Text;
	var missionCheck : Void -> Void;
	var missionScan : Npc -> Bool;
	
	var miniMap : h2d.Bitmap;
	
	function new(e) {
		this.engine = e;
	}
	
	public function init() {
		entities = [];
		scene = new h2d.Scene();
		scene.setFixedSize(380, 250);
		var t = new Tiles(0, 0, true);
		var s = new Sprites(0, 0, true);
		clearTile(t);
		clearTile(s);
		
		font = new h2d.Font("PixelFont", 16);
		uiTile = h2d.Tile.fromBitmap(new UIBMP(0, 0, true));
		tiles = h2d.Tile.fromBitmap(t);
		cursor = tiles.sub(32, 144, 16, 16);
		sprites = h2d.Tile.autoCut(s, 16).tiles;
		for( sx in sprites )
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
		missionText.y = 8;
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
		

		hero = new Hero(scroll.x, scroll.y);
		
		for( i in 0...11 ) {
			var x, y;
			do {
				x = Std.random(mapWidth);
				y = Std.random(mapHeight);
			} while( collide[x][y] || road[x][y] );
			var n = new Npc(i, x + 0.5, y + 0.5);
			//if( i == 0 ) doLook(n);
		}
	}
	
	function nextMission() {
		mission++;
		var text, miss, scan : Npc -> Bool = null;
		switch( mission ) {
		case 0:
			text = "Stole $20 from people which can't defend themselves.";
			miss = function() {
				if( money >= 20 ) nextMission();
			};
			scan = function(n) return NPC[n.id].att <= attack;
		default:
			text = "TODO";
			miss = function() {
			};
		}
		missionText.text = "Mission " + (mission + 1) + " : " + text;
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
		for( x in 0...map.width ) {
			collide[x] = [];
			road[x] = [];
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
						case 7, 36: // walk way
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
	
	static var NPC = [
		{ name : "JeeZee", age : 30, att : 5, def : 10 },
		{ name : "Leela", age : 7, att : 0, def : 0 },
		{ name : "Jimjim", age : 9, att : 1, def : 0 },
		{ name : "Weido", age : 45, att : 20, def : 5 },
		{ name : "Tizon", age : 35, att : 50, def : 40 },
		{ name : "Glaze", age : 30, att : 10, def : 15 },
		{ name : "Bob", age : 22, att : 5, def : 20 },
		{ name : "Miss Auto", age : 25, att : 5, def : 10 },
		{ name : "Mr Punk", age : 30, att : 25, def : 30 },
		{ name : "Grandma Kalash", age : 80, att : 2, def : 1 },
		{ name : "Snoop", age : 5, att : 15, def : 10 },
	];
	
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
		var inf = NPC[n.id];
		t.text = 'Name : ${inf.name}\nAge : ${inf.age}\nAttack : ${inf.att}\nDefense : ${inf.def}';
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
		var inf = NPC[n.id];
		if( inf.att > attack ) {
			showPanel("You should not attack someone stronger than you !");
			return;
		}
		
	}
	
	function updateGamePlay(dt) {
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) )
			hero.move( -1, 0);
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) )
			hero.move( 1, 0);
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) )
			hero.move( 0, 1);
		if( Key.isDown(K.UP) || Key.isDown("Z".code) || Key.isDown("W".code) )
			hero.move( 0, -1);
		scrollContent.ysort(Const.PLAN_ENTITY);
		for( e in entities.copy() )
			e.update(dt);
			
		if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) ) {
			var px = hero.x + hero.dirX * 0.5;
			var py = hero.y + hero.dirY * 0.5;
			for( e in entities ) {
				var n = flash.Lib.as(e, Npc);
				if( n != null && n.hitBox(px, py) ) {
					menu = new SelectMenu([
						{ t : "Look", c : callback(doLook, n) },
						{ t : "Steal", c : callback(doSteal, n) },
						{ t : "Cancel", c : function() {} },
					]);
					break;
				}
			}
		}
	}
	
	function update(dt:Float) {
		
		
		scroll.x = hero.x;
		scroll.y = hero.y;
		
		var ix = Std.int(scroll.x * 16) - (scene.width >> 1);
		var iy = Std.int(scroll.y * 16) - (scene.height >> 1);
		if( ix < 0 ) ix = 0;
		if( iy < 0 ) iy = 0;
		if( ix + scene.width > mapWidth * 16 ) ix = mapWidth * 16 - scene.width;
		if( iy + scene.height > mapHeight * 16 ) iy = mapHeight * 16 - scene.height;
		scrollContent.x = -ix;
		scrollContent.y = -iy;
		
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
				old.options[old.index].c();
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
			
		missionCheck();
			
		engine.render(scene);
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