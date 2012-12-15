import Common;

class Game implements haxe.Public {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	var tiles : h2d.Tile;
	var sprites : Array<Array<h2d.Tile>>;
	var scroll : { x : Float, y : Float };
	var hero : Hero;
	var entities : Array<Entity>;
	var collide : Array<Array<Bool>>;
	var mapWidth : Int;
	var mapHeight : Int;
	
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
		tiles = h2d.Tile.fromBitmap(t);
		sprites = h2d.Tile.autoCut(s, 16).tiles;
		initMap();
		scroll = { x : 56.5, y : 41.5 };
		hero = new Hero(scroll.x, scroll.y);
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
		var tmap = [];
		for( y in 0...tiles.height >> 4 )
			for( x in 0...tiles.width >> 4 )
				tmap.push(tiles.sub(x * 16, y * 16, 16, 16));
		collide	= [];
		for( x in 0...map.width )
			collide[x] = [];
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
			case "underShades":
				t.alpha = 0.3;
			case "shades":
				t.alpha = 0.5;
			case "windows":
				t.alpha = 0.5;
			case "sprites":
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 ) {
							var s = new h2d.Bitmap(tmap[c - 1]);
							s.x = x * 16;
							s.y = y * 16;
							scene.add(s, Const.PLAN_ENTITY);
						}
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
			scene.add(t, plan);
		}
	}
	
	function update(dt:Float) {
		engine.render(scene);
		var ix = Std.int(scroll.x * 16) - (scene.width >> 1);
		var iy = Std.int(scroll.y * 16) - (scene.height >> 1);
		scene.x = -ix;
		scene.y = -iy;
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) )
			hero.move( -1, 0);
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) )
			hero.move( 1, 0);
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) )
			hero.move( 0, 1);
		if( Key.isDown(K.UP) || Key.isDown("Z".code) || Key.isDown("W".code) )
			hero.move( 0, -1);
		scene.ysort(Const.PLAN_ENTITY);
		for( e in entities.copy() )
			e.update(dt);
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