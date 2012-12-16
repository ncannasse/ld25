
class Hero extends Entity {

	public function new(x,y) {
		super(x, y);
		power = 1;
		play(11);
		setCursor(0xFFFFFFFF);
		cursor.alpha = 1;
	}
	
	override function onCollide( e : Entity ) {
		if( Std.is(e, Bullet) )
			return false;
		return true;
	}
	
	override function hitBy(e:Entity ) {
		super.hitBy(e);
		Sounds.hit.play();
	}
	
	override function kill() {
		life = -maxLife;
	}
	
	var step : Float = 0.;
	var moved : Bool;
	
	override function moveBy(x:Float, y:Float) {
		anim = game.sprites[y > 0 ? 11 : y < 0 ? 12 : 13];
		if( x < 0 ) mc.scaleX = 1 else if( x > 0 ) mc.scaleX = -1;
		moved = true;
		return super.moveBy(x, y);
	}
	
	override function update(dt:Float) {
		if( life < maxLife && showLifeBar <= 10 ) {
			showLifeBar = 10;
			life += 0.04 * dt;
			if( life > maxLife ) life = maxLife;
		}
		if( life < 0 )
			dt *= 0.7;
		super.update(dt);
		
		if( moved ) {
			step += Timer.tmod * 0.5;
			if( step > 3 ) {
				step = -3;
				Sounds.steps.play();
			}
			moved = false;
		} else {
			step = 0;
			frame = 0;
		}
		
	}

	public function getTargets() : Array<Entity> {
		var hx = ((x - 0.5) * 16 + dirX * 12) / 16;
		var hy = (y * 16 + dirY * 15 - 14) / 16;
		var sizeX = 1.;
		var sizeY = 1.;
		/*
		var b = new h2d.Bitmap(null, game.scrollContent);
		b.scaleX = sizeX  * 16 / 5;
		b.scaleY = sizeY * 16 / 5;
		b.alpha = 0.2;
		b.x = hx * 16;
		b.y = hy * 16;
		*/
		var targets = [];
		
		for( e in game.entities )
			if( e != this && (e.hitBox(hx + sizeX * 0.5, hy + sizeY * 0.5) || e.hitBox(hx, hy) || e.hitBox(hx + sizeX, hy) || e.hitBox(hx, hy + sizeY) || e.hitBox(hx + sizeX, hy + sizeY)) )
				targets.push(e);
		
				
		return cast targets;
	}
		
}