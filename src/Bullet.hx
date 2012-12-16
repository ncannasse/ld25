package ;

class Bullet extends Entity {

	public var angle : Float;
	var startX : Float;
	var startY : Float;
	var trail : h2d.Bitmap;
	
	public function new(x, y, a) {
		this.angle = a;
		super(x, y);
		trail = new h2d.Bitmap(game.tiles.sub(32, 192, 16, 1));
		game.scrollContent.add(trail, Const.PLAN_PART);
		trail.x = x * 16 + Math.cos(a) * 8;
		trail.y = y * 16 + Math.sin(a) * 8;
		trail.rotation  = angle * 180 / Math.PI;
		trail.filter = true;
		trail.alpha = 0.2;
		trail.blendMode = Add;
		
		startX = x;
		startY = y;
		speed *= 3;
		boundsW = 3 / 16;
		boundsH = 3 / 16;
		power = 5;
		mc.tile = game.tiles.sub(16, 192, 16, 16, -8, -8);
		game.scrollContent.add(mc, Const.PLAN_PART);
	}
	
	override function remove() {
		super.remove();
		trail.remove();
	}
	
	override function hitBy(e:Entity) {
		if( mc.parent != null )
			onCollide(e);
	}
	
	override function onCollide(e:Entity) {
		if( Std.is(e, Hero) || Std.is(e,Bullet) )
			return false;
		remove();
		e.hitBy(this);
		return false;
	}

	override function update(dt:Float) {
		dt *= 0.1;
		for( i in 0...10 ) {
			x += Math.cos(angle) * dt * speed;
			y += Math.sin(angle) * dt * speed;
			super.update(dt);
			if( collide(x, y) )
				remove();
			if( mc.parent == null ) break;
		}
		mc.rotation = angle * 180 / Math.PI;
		var dx = x - startX;
		var dy = y - startY;
		trail.scaleX = Math.sqrt(dx * dx + dy * dy) - 0.5;
		trail.alpha = 1 / (3 + trail.scaleX);
	}
	
}