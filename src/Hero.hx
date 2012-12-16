
class Hero extends Entity {

	public function new(x,y) {
		super(x, y);
		play(11);
		setCursor(0xFFFFFFFF);
		cursor.alpha = 1;
	}
	
	override function kill() {
		life = -maxLife;
	}
	
	override function moveBy(x:Float, y:Float) {
		anim = game.sprites[y > 0 ? 11 : y < 0 ? 12 : 13];
		if( x < 0 ) mc.scaleX = 1 else if( x > 0 ) mc.scaleX = -1;
		return super.moveBy(x, y);
	}
	
	override function update(dt:Float) {
		if( life < maxLife && showLifeBar <= 10 ) {
			showLifeBar = 10;
			life += 0.04 * dt;
			if( life > maxLife ) life = maxLife;
		}
		super.update(dt);
	}
	
	public function attack() {
		
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
		
		for( e in game.entities )
			if( e != this && (e.hitBox(hx+sizeX*0.5,hy+sizeY*0.5) || e.hitBox(hx, hy) || e.hitBox(hx + sizeX, hy) || e.hitBox(hx, hy + sizeY) || e.hitBox(hx + sizeX, hy + sizeY)) ) {
				e.hitBy(this);
			}
	}
	
}