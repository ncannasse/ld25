
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
	
	public function new(x:Float,y:Float) {
		this.game = Game.inst;
		this.x = x;
		this.y = y;
		boundsW = 7 / 16;
		boundsH = 5 / 16;
		mc = new h2d.Bitmap();
		mc.scaleX = mc.scaleY = 2;
		var c = Type.getClass(this);
		
		animSpeed = 0.15;
		speed = 0.12;

		if( c != Light ) {
			shade = new h2d.Bitmap(game.tiles.sub(0, 8 * 16, 16, 16));
			shade.scaleX = shade.scaleY = 2;
			shade.alpha = 0.2;
			game.scene.add(shade, Const.PLAN_SHADES);
		}
		
		game.scrollContent.add(mc, Const.PLAN_ENTITY);

		game.entities.push(this);
	}
	
	public function play( id : Int ) {
		this.anim = game.sprites[id];
		this.frame = 0;
	}
	
	function collide(x:Float, y:Float) {
		var c = game.collide[Std.int(x)];
		var iy = Std.int(y);
		return c == null || iy < 0 || iy >= game.mapHeight ? true : c[iy];
	}
	
	function collideBox(x:Float, y:Float) {
		return collide(x - boundsW, y - boundsH) || collide(x + boundsW, y - boundsH) || collide(x - boundsW, y + boundsH) || collide(x + boundsW, y + boundsH);
	}
	
	public function move(dx:Float, dy:Float) {
		var mx = dx * speed * Timer.tmod;
		var my = dy * speed * Timer.tmod;
		if( !collideBox(x+mx,y) ) x += mx;
		if( !collideBox(x,y+my) ) y += my;
	}
	
	public function update(dt:Float) {
		if( anim != null ) {
			frame += dt * animSpeed;
			mc.tile = anim[Std.int(frame) % anim.length];
		}
		time += dt;
		mc.x = Std.int(x * 16) - 15;
		mc.y = Std.int(y * 16) - 27;
		if( shade != null ) {
			shade.x = mc.x - 1;
			shade.y = mc.y + 1;
		}
	}
	
}