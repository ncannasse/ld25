using Common;

class Part {

	var mc : h2d.SpriteBatch.BatchElement;
	var x : Float;
	var y : Float;
	var z : Float;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var startTime : Float;
	public var time : Float;
	public var speed : Float;
	public var gravity : Float;
	
	public function new(x, y, z, mc, startTime = 50.) {
		this.mc = mc;
		this.x = x;
		this.y = y;
		this.z = z;
		this.speed = 0.8;
		gravity = 1.0;
		mc.x = x;
		mc.y = y - z;
		vx = (Math.random() - 0.5) * 3;
		vy = (Math.random() - 0.5) * 3;
		vz = (Math.random() + 2) * 1.5;
		this.startTime = startTime;
		time = startTime;
		all.push(this);
	}
	
	public function update(dt:Float) {
		x += vx * speed;
		y += vy * speed;
		z += vz * speed;
		vz -= Math.pow(0.9, dt) * speed * gravity;
		if( z < 0 ) {
			z = -z;
			vz *= -0.5;
		}
		mc.x = x;
		mc.y = y - z;
		time -= dt;
		mc.alpha = time / (startTime * 0.5);
		return time > 0;
	}
	
	public function remove() {
		mc.remove();
	}
	
	public static function explode( t : h2d.Tile, px : Int, py : Int, angle : Float, proba = 100 ) {
		if( t == null )
			return;
		var b = new h2d.SpriteBatch(t);
		for( x in 0...t.width )
			for( y in 0...t.height ) {
				if( Std.random(100) >= proba ) continue;
				var p = new Part(px + x + t.dx, py + y + t.dy, 0, b.alloc(t.sub(x, y, 1, 1)));
				p.vx -= Math.cos(angle) * 3;
				p.vy -= Math.sin(angle) * 3;
			}
		Game.inst.scrollContent.add(b, Const.PLAN_PART);
		batches.push(b);
	}

	public static function emit( t : h2d.Tile, px : Int, py : Int, proba = 10 ) {
		var b = new h2d.SpriteBatch(t);
		if( t != null ) {
			var size = t.width * t.height * 10;
			for( x in 0...t.width )
				for( y in 0...t.height ) {
					if( Std.random(size) >= proba ) continue;
					var p = new Part(px + x + t.dx, py + y + t.dy, 0, b.alloc(t.sub(x, y, 1, 1)));
					var a = Math.atan2(y - (t.height >> 1), x - (t.width >> 1));
					p.vx = Math.cos(a);
					p.vy = Math.sin(a);
					p.vz = 0;
					p.time = 50;
					p.speed *= 0.7;
					p.startTime = 80;
					p.gravity = 0;
				}
			Game.inst.scrollContent.add(b, Const.PLAN_PART);
			batches.push(b);
		}
		return b;
	}
	
	static var all = new Array<Part>();
	static var batches = new Array<h2d.SpriteBatch>();

	public static function updateAll( dt ) {
		for( p in all.copy() )
			if( !p.update(dt) ) {
				p.remove();
				all.remove(p);
				if( p.mc.batch.isEmpty() ) {
					p.mc.batch.remove();
					batches.remove(p.mc.batch);
				}
			}
	}
	
}