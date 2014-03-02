class Car extends Entity {

	public var id : Int;
	var lock : Int;
	var wait : Float = 0;
	
	public function new(id, x,y) {
		super(x, y);
		this.id = id;
		boundsW = 40 / 16;
		boundsH = 8 / 16;
		play(id);
		power = 10;
		life = maxLife = 100 * (id + 1);
		dirX = Std.random(2) * 2 - 1;
	}
	
	override function hitBy(e) {
		super.hitBy(e);
		hxd.Res.sfx.carHit.play();
	}
	
	override function kill() {
		hxd.Res.sfx.carBreak.play();
		var white = h2d.Tile.fromColor(0xFFFFFFFF).clone();
		white.scaleToSize(16*3, 16);
		for( i in 0...5 )
			Part.explode(white, Std.int(x * 16 - 8), Std.int(y * 16 - 16), i * Math.PI * 2/5, 100);
		remove();
	}
	
	override function collide(x, y) {
		if( super.collide(x, y) )
			return true;
		if( !game.roadOrPass[Std.int(x)][Std.int(y)] ) {
			lock = 10;
			return true;
		}
		return false;
	}
	
	override function onCollide( e : Entity ) {
		e.hitBy(this);
		return true;
	}
	
	override function play(id) {
		this.anim = game.cars[id];
		this.frame = 0;
	}
	
	override function update(dt:Float) {
		if( wait > 0 )
			wait -= dt * 0.1;
		else if( !moveBy(dirX * speed * dt,  0) ) {
			wait = 1.5;
			lock++;
			if( lock >= 5 ) {
				dirX *= -1;
				lock = 0;
			}
		} else
			lock = 0;
		if( dirX == 0  ) dirX = 1;
		mc.scaleX = dirX;
			
		super.update(dt);
	}
	
}