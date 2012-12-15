
class Entity {

	var game : Game;
	var mc : h2d.Bitmap;
	var shade : h2d.Bitmap;
	var frame : Float;
	var anim : Array<h2d.Tile>;
	var animSpeed : Float;
	var speed : Float;
	var time : Float = 0.;
	public var x : Float;
	public var y : Float;
	var boundsW : Float;
	var boundsH : Float;
	var bounds : h2d.Bitmap;
	
	public function new(x:Float,y:Float) {
		this.game = Game.inst;
		this.x = x;
		this.y = y;
		frame = 0;
		boundsW = 7 / 16;
		boundsH = 5 / 16;
		mc = new h2d.Bitmap();
		var c = Type.getClass(this);
		
		animSpeed = 0.15;
		speed = 0.12;

		if( c != Light ) {
			var stile = game.tiles.sub(0, 8 * 16, 16, 16);
			stile.scaleToSize(32, 32);
			shade = new h2d.Bitmap(stile);
			shade.alpha = 0.2;
			//game.scrollContent.add(shade, Const.PLAN_SHADES);
		}
		
		game.scrollContent.add(mc, Const.PLAN_ENTITY);

		game.entities.push(this);
	}
	
	public function play( id : Int ) {
		this.anim = game.sprites[id];
		this.frame = 0;
	}
	
	function onCollide( e : Entity ) {
		return true;
	}
	
	function collide(x:Float, y:Float) {
		var c = game.collide[Std.int(x)];
		if( c == null || x < 0 || y < 0 || Std.int(y) >= game.mapHeight || c[Std.int(y)] )
			return true;
		for( e in game.entities )
			if( e != this && e.hitBox(x, y) && e.onCollide(this) )
				return true;
		return false;
	}
	
	function hitBox( px : Float, py : Float ) {
		return px > x - boundsW && py > y - boundsH && px < x + boundsW && py < y + boundsH;
	}
	
	function collideBox(x:Float, y:Float) {
		return collide(x - boundsW, y - boundsH) || collide(x + boundsW, y - boundsH) || collide(x - boundsW, y + boundsH) || collide(x + boundsW, y + boundsH);
	}
	
	public function move(dx:Float, dy:Float) {
		var mx = dx * speed * Timer.tmod;
		var my = dy * speed * Timer.tmod;
		var ok = false;
		if( mx != 0 && !collideBox(x + mx, y) ) { x += mx; ok = true; }
		if( my != 0 && !collideBox(x, y + my) ) { y += my; ok = true; }
		return ok;
	}
	
	public function update(dt:Float) {
		if( anim != null ) {
			frame += dt * animSpeed;
			mc.tile = anim[Std.int(frame) % anim.length];
		}
		if( game.showBounds ) {
			if( bounds == null ) {
				bounds = new h2d.Bitmap();
				game.scrollContent.add(bounds, Const.PLAN_SHADES);
				bounds.scaleX = boundsW * 16 * 2 / 5;
				bounds.scaleY = boundsH * 16 * 2 / 5;
			}
			bounds.x = Std.int((x - boundsW) * 16);
			bounds.y = Std.int((y - boundsH) * 16);
		} else if( bounds != null ) {
			bounds.remove();
			bounds = null;
		}
		time += dt;
		mc.x = Std.int(x * 16);
		mc.y = Std.int(y * 16);
		if( shade != null ) {
			shade.x = mc.x - 1;
			shade.y = mc.y + 1;
		}
	}
	
}