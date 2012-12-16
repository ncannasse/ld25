
class Bill extends Entity {

	public function new(x,y) {
		super(x, y);
		play(14);
		collideEnt = false;
		mc.scaleX = mc.scaleY = 0.5;
	}
	
	override function hitBy(e) {
	}
	
	override function onCollide(e:Entity) {
		if( Std.is(e, Hero) ) {
			game.getMoney(5);
			Sounds.getMoney.play();
			remove();
		}
		return false;
	}
	
}