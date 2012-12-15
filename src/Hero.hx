
class Hero extends Entity {

	public function new(x,y) {
		super(x, y);
		play(11);
	}
	
	override function move(x:Float, y:Float) {
		anim = game.sprites[y > 0 ? 11 : y < 0 ? 12 : 13];
		if( x < 0 ) mc.scaleX = 1 else if( x > 0 ) mc.scaleX = -1;
		return super.move(x, y);
	}
	
}