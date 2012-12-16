class Car extends Entity {

	public var id : Int;
	var lock : Int;
	var wait : Float = 0;
	
	public function new(id, x,y) {
		super(x, y);
		boundsW = 40 / 16;
		boundsH = 8 / 16;
		play(id);
		dirX = Std.random(2) * 2 - 1;
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
	
	override function play(id) {
		this.anim = game.cars[id];
		this.frame = 0;
	}
	
	override function update(dt:Float) {
		if( wait > 0 )
			wait -= dt * 0.1;
		else if( !move(dirX, 0) ) {
			wait = 1.5;
			lock++;
			if( lock >= 5 ) {
				dirX *= -1;
				lock = 0;
			}
		} else
			lock = 0;
		mc.scaleX = dirX;
			
		super.update(dt);
	}
	
}