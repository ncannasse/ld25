
class Entity {

	var game : Game;
	public var mc : h2d.Bitmap;
	var frame : Float;
	var anim : Array<h2d.Tile>;
	var animSpeed : Float;
	var speed : Float;
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
		animSpeed = 0.15;
		speed = 0.12;
		game.scene.add(mc, Const.PLAN_ENTITY);
		game.entities.push(this);
		update(0);
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
		frame += dt * animSpeed;
		mc.tile = anim == null ? null : anim[Std.int(frame) % anim.length];
		mc.x = Std.int(x * 16) - 15;
		mc.y = Std.int(y * 16) - 27;
	}
	
}