
class Entity {

	var game : Game;
	var mc : h2d.Bitmap;
	var shade : h2d.Bitmap;
	var frame : Float;
	public var anim : Array<h2d.Tile>;
	var animSpeed : Float;
	public var speed : Float;
	var time : Float = 0.;
	public var x : Float;
	public var y : Float;
	var boundsW : Float;
	var boundsH : Float;
	var bounds : h2d.Bitmap;
	public var dirX : Int;
	public var dirY : Int;
	
	public var power : Float;
	public var life : Float;
	public var maxLife : Float;
	
	public var pushX = 0.;
	public var pushY = 0.;
	
	var lifeBar : h2d.Bitmap;
	var lifeBarProgress : h2d.Bitmap;
	var showLifeBar : Float = 0.;
	
	var collideEnt = true;
	var cursor : h2d.Bitmap;
	
	public function new(x:Float,y:Float) {
		this.game = Game.inst;
		this.x = x;
		this.y = y;
		frame = 0;
		power = 0;
		boundsW = 6.5 / 16;
		boundsH = 5 / 16;
		mc = new h2d.Bitmap();
		var c = Type.getClass(this);
		
		animSpeed = 0.15;
		speed = 0.12;
		dirX = 0;
		dirY = 1;

		if( c != Car && c != Bill && c != Bullet ) {
			var stile = game.tiles.sub(0, 8 * 16, 16, 16, -16, -22);
			stile.scaleToSize(32, 32);
			shade = new h2d.Bitmap(stile);
			shade.alpha = 0.2;
			game.scrollContent.add(shade, Const.PLAN_SHADES);
		}
		
		game.scrollContent.add(mc, Const.PLAN_ENTITY);

		game.entities.push(this);
	}
	
	static var RED = null;
	
	function frightenBy( e : Entity ) {
		if( e == this ) throw "assert";
		return e.power > power || life < e.power * 2;
	}

	function aggroBy( e : Entity ) {
		if( e == this ) throw "assert";
		if( game.mission == 0 ) return false;
		return e.power * 2 < power;
	}
	
	public function kill() {
		for( i in 0...5 )
			Part.explode(RED, Std.int(x * 16 - 8), Std.int(y * 16 - 16), i * Math.PI * 2/5, 100);
		remove();
	}
	
	public function remove() {
		mc.remove();
		if( shade != null )
			shade.remove();
		if( bounds != null )
			bounds.remove();
		if( cursor != null )
			cursor.remove();
		game.entities.remove(this);
	}
	
	public dynamic function onKill() {
	}
	
	public dynamic function onReallyKill() {
	}
	
	public function hitBy( e : Entity ) {
		var relPower = (e.power + 5) * 0.5 / (power + 5);
		var angle = Math.atan2(e.y - y, e.x - x);
		pushX -= Math.cos(angle) * relPower;
		pushY -= Math.sin(angle) * relPower;
		if( RED == null ) {
			RED = h2d.Tile.fromColor(0xFFC04040).clone();
			RED.scaleToSize(16, 16);
		}
		Part.explode(RED, Std.int(x * 16 - 8), Std.int(y * 16 - 16), angle, Std.int(relPower * 10));
		var isCar = Std.is(this, Npc) && Std.is(e, Car);
		if( life <= 0 ) {
			if( !isCar && e.power >= 5 )
				life -= e.power * 0.5;
			if( life < -maxLife ) {
				kill();
				onReallyKill();
			}
		} else {
			life -= e.power;
			if( life <= 0 ) {
				if( isCar )
					life = 0.01;
				else
					onKill();
				if( life < -maxLife * 0.5 )
					life = -maxLife * 0.5;
			}
		}
		showLife();
	}
	
	public function showLife() {
		showLifeBar = 100;
	}
	
	public function play( id : Int ) {
		this.anim = game.sprites[id];
		this.frame = 0;
	}
	
	function onCollide( e : Entity ) {
		return true;
	}
	
	function collide(x:Float, y:Float) {
		var c = game.collide[Std.int(x)];
		if( c == null || x < 0 || y < 0 || Std.int(y) >= game.mapHeight || c[Std.int(y)] )
			return true;
		if( collideEnt && pushX == 0 && pushY == 0 )
			for( e in game.entities )
				if( e != this && e.hitBox(x, y) && e.onCollide(this) )
					return true;
		return false;
	}
	
	public function hitBox( px : Float, py : Float ) {
		return px > x - boundsW && py > y - boundsH && px < x + boundsW && py < y + boundsH;
	}
	
	function collideBox(x:Float, y:Float) {
		return collide(x - boundsW, y - boundsH) || collide(x + boundsW, y - boundsH) || collide(x - boundsW, y + boundsH) || collide(x + boundsW, y + boundsH);
	}
	
	public function moveBy(mx:Float, my:Float) {
		var ok = false;
		dirX = mx > 0 ? 1 : mx < 0 ? -1 : 0;
		dirY = my > 0 ? 1 : my < 0 ? -1 : 0;
		if( mx != 0 && !collideBox(x + mx, y) ) { x += mx; ok = true; }
		if( my != 0 && !collideBox(x, y + my) ) { y += my; ok = true; }
		return ok;
	}
	
	static var WHITE;
	
	function setCursor( color : Int ) {
		if( cursor == null ) {
			if( WHITE == null ) WHITE = h2d.Tile.fromColor(0xFFFFFFFF);
			cursor = new h2d.Bitmap(WHITE, game.miniMap);
			cursor.alpha = 0.5;
		}
		cursor.color = h3d.Color.ofInt(color, (color >>> 24) / 255).toVector();
	}
	
	public function update(dt:Float) {
		if( anim != null ) {
			frame += dt * animSpeed;
			mc.tile = anim[Std.int(frame) % anim.length];
		}
		if( game.showBounds ) {
			if( bounds == null ) {
				bounds = new h2d.Bitmap();
				game.scrollContent.add(bounds, Const.PLAN_SHADES);
				bounds.scaleX = boundsW * 16 * 2 / 5;
				bounds.scaleY = boundsH * 16 * 2 / 5;
			}
			bounds.x = Std.int((x - boundsW) * 16);
			bounds.y = Std.int((y - boundsH) * 16);
		} else if( bounds != null ) {
			bounds.remove();
			bounds = null;
		}
		time += dt;
		mc.x = Std.int(x * 16);
		mc.y = Std.int(y * 16);
		if( shade != null ) {
			shade.x = mc.x;
			shade.y = mc.y;
		}
		if( cursor != null ) {
			cursor.x = Std.int(x);
			cursor.y = Std.int(y);
		}
		if( pushX != 0 || pushY != 0 ) {
			var maxPush = 2;
			moveBy(Math.min(pushX,maxPush)*dt, Math.min(pushY,maxPush)*dt);
			pushX *= Math.pow(0.8,dt);
			pushY *= Math.pow(0.8,dt);
			if( Math.abs(pushX) < 0.02 ) pushX = 0;
			if( Math.abs(pushY) < 0.02 ) pushY = 0;
		}
		
		if( showLifeBar > 0 ) {
			showLifeBar -= dt;
			if( lifeBar == null ) {
				var bg = h2d.Tile.fromColor(0xFF000000).clone();
				bg.scaleToSize(Std.int(16 + 2), 3);
				lifeBar = new h2d.Bitmap(bg, mc);
				lifeBar.x = -8;
				lifeBar.y = -(mc.tile.height + 2);
				lifeBarProgress = new h2d.Bitmap(null, lifeBar);
				lifeBarProgress.x = lifeBarProgress.y = 1;
			}
			var color, size;
			if( life <= 0 ) {
				color = 0xFFFFFFFF;
				size = (life + maxLife) / maxLife;
			} else {
				color = life < 10 && life < maxLife * 0.5 ? 0xFFC00000 : 0xFF00A000;
				size = life / maxLife;
			}
			var t = h2d.Tile.fromColor(color).clone();
			
			t.scaleToSize(Math.ceil(size * 16), 1);
			lifeBarProgress.tile = t;
			mc.addChild(lifeBar);
			
			var a = showLifeBar > 10 ? 1 : showLifeBar / 10;
			lifeBar.alpha = 0.7 * a;
			lifeBar.scaleX = mc.scaleX;
			lifeBar.x = -8 * mc.scaleX;
			lifeBarProgress.alpha = 0.9 * a;
		} else {
			if( lifeBar != null ) lifeBar.remove();
		}
	}
	
}