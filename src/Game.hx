import Common;

class Game implements haxe.Public {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	var tiles : h2d.Tile;
	var sprites : Array<Array<h2d.Tile>>;
	var scroll : { x : Float, y : Float };

	var lightsBitmap : h2d.CachedBitmap;
	var lights : h2d.Sprite;
	var scrollBitmap : h2d.CachedBitmap;
	var scrollContent : h2d.Layers;
	
	var hero : Hero;
	var entities : Array<Entity>;
	var collide : Array<Array<Bool>>;
	var road : Array<Array<Bool>>;
	
	var mapWidth : Int;
	var mapHeight : Int;
	var light : h2d.Tile;
	var lightBulb : h2d.Tile;
	var showBounds : Bool;
	
	function new(e) {
		this.engine = e;
	}
	
	public function init() {
		entities = [];
		light = h2d.Tile.fromBitmap(new LightBMP(0, 0, true));
		scene = new h2d.Scene();
		scene.setFixedSize(380, 250);
		var t = new Tiles(0, 0, true);
		var s = new Sprites(0, 0, true);
		clearTile(t);
		clearTile(s);
		tiles = h2d.Tile.fromBitmap(t);
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
		
		lightsBitmap = new h2d.CachedBitmap(scene, scene.width, scene.height);
		
		var halo = new h2d.Bitmap(h2d.Tile.fromBitmap(new HaloBMP(0, 0, true)));
		lightsBitmap.addChild(halo);
		lights = new h2d.Sprite(lightsBitmap);
		lightsBitmap.blendMode = Hide;
		
		lightBulb = tiles.sub(48, 96, 16, 16, 0, -16);

		scrollBitmap.colorMatrix = h3d.Matrix.S(0.4, 0.4, 0.5);
		scrollBitmap.multiplyMap = lightsBitmap.getTile();
		scrollBitmap.multiplyFactor = 3.0;
		
		initMap();
		scroll = { x : 15, y : 27 };
		hero = new Hero(scroll.x, scroll.y);
		
		for( i in 0...11 ) {
			var x, y;
			do {
				x = Std.random(mapWidth);
				y = Std.random(mapHeight);
			} while( collide[x][y] || road[x][y] );
			new Npc(i, x + 0.5, y + 0.5);
		}
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
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 )
							new Light(x+0.5,y+0.5);
					}
				continue;
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
	
	function update(dt:Float) {
		engine.render(scene);
		
		scroll.x = hero.x;
		scroll.y = hero.y;
		
		var ix = Std.int(scroll.x * 16) - (scene.width >> 1);
		var iy = Std.int(scroll.y * 16) - (scene.height >> 1);
		scrollContent.x = lights.x = -ix;
		scrollContent.y = lights.y = -iy;
		
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
			
		if( Key.isToggled("B".code) )
			showBounds = !showBounds;
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