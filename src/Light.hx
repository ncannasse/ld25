class Light extends Entity {
	/*
	var wait : Float = 0;
	var light : h2d.Bitmap;
	
	public function new(x,y) {
		super(x, y);
		mc.tile = game.lightBulb;
		mc.scaleX = mc.scaleY = 1;
		mc.color = new h3d.Vector();
		light = new h2d.Bitmap(game.light, game.lights);
		light.blendMode = Add;
		time = Math.random() * 100;
	}
	
	override function onCollide(e:Entity) {
		return false;
	}
	
	override function update(dt) {
		super.update(dt);
		mc.x = Std.int(x * 16) - 8;
		mc.y = Std.int(y * 16) + 8;
		light.x = mc.x - 128;
		light.y = mc.y - 128;
		if( wait > 0 ) {
			wait -= dt * 0.1;
			light.alpha *= 0.25;
		} else {
			var ta = (0.8 + Math.abs(Math.sin(time * 0.05) * 0.2)) * 0.9;
			light.alpha = mc.alpha * 0.5 + ta * 0.5;
			if( Std.random(Math.ceil(1000/dt)) == 0 )
				wait = Math.random() + 0.5;
		}
		var v = 0.5 + light.alpha * 0.6;
		mc.color.set(v, v, v);
	}
		*/
}