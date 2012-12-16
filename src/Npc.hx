class Npc extends Entity {

	public var id : Int;
	var wait : Float = 0.;
	var path : Array<{ x : Int, y : Int }>;
	var target : { x : Int, y : Int };
	var walkOnStreet : Bool;
	var lock : Int;
	var flee : Null<Float>;
	var aggro : { target : Entity, time : Float, attack : Float };
	var moneyWin : Float = 15.;
	public var money : Int;
	
	public function new(id,x,y,money) {
		super(x, y);
		this.money = money;
		this.id = id;
		speed = 0.05;
		animSpeed = 0.15;
		switch(id) {
		case 1, 2:
			speed *= 0.5;
			animSpeed *= 1.5;
		case 3:
			speed *= 0.5;
			animSpeed *= 2.5;
		case 4:
			speed *= 0.6;
		case 5:
			animSpeed *= 3;
		case 6:
			speed *= 2.5;
		case 7:
			speed *= 0.7;
		case 9:
			speed *= 0.2;
		}
		anim = game.sprites[id];
	}

	static inline function K(x,y) return x | (y << 7)
	
	
	override function onCollide(e:Entity) {
		if( Std.is(e, Npc) && wait > 0 )
			return false;
		return true;
	}
	
	function selectPath( cx : Float, cy : Float, r : Float ) {
		var px, py, tx, ty;
		if( cx > game.mapWidth + r*0.5  )
			cx = game.mapWidth + r * 0.5;
		if( cx < -r*0.5  )
			cx = -r* 0.5;
		if( cy > game.mapHeight + r*0.5  )
			cy = game.mapHeight + r * 0.5;
		if( cy < -r*0.5  )
			cy = -r * 0.5;
		var ntry = 1000;
		var walk = walkOnStreet || game.road[Std.int(x)][Std.int(y)];
		do {
			px = Math.random() * r * 2 - r;
			py = Math.random() * r * 2 - r;
			tx = Std.int(cx + px);
			ty = Std.int(cy + py);
			if( ntry-- == 0 )
				return;
		} while( tx < 0 || tx >= game.mapWidth || ty < 0 || ty >= game.mapHeight || game.collide[tx][ty] || (!walk && game.road[tx][ty]) || (px * px + py * py) > r*r );
		var t0 = haxe.Timer.stamp();
		var path = new flash.Vector<Int>((game.mapHeight + 1) << 7);
		var k = [ { x:tx, y:ty } ], dist = 1;
		while( k.length > 0 ) {
			var tmp = k;
			k = [];
			for( v in tmp ) {
				var x = v.x, y = v.y;
				var pid = K(x,y);
				if( path[pid] != 0 ) continue;
				path[pid] = dist;
				if( game.collide[x][y] || (game.road[x][y] && !walk) )
					continue;
				if( x > 0 ) k.push( { x:x - 1, y:y } );
				if( x < game.mapWidth-1 ) k.push( { x:x + 1, y:y } );
				if( y > 0 ) k.push( { x:x, y:y-1 } );
				if( y < game.mapHeight-1 ) k.push( { x:x, y:y+1 } );
			}
			dist++;
		}
		var cx = Std.int(x);
		var cy = Std.int(y);
		var d = path[K(cx,cy)];
		if( d == 0 )
			return;
		var p = [];
		var dirs = [];
		for( i in 0...4 )
			dirs.insert(Std.random(dirs.length),i);
		while( d > 0 ) {
			p.push( { x : cx, y : cy } );
			d--;
			var o = cx + cy;
			for( di in dirs )
				switch( di ) {
				case 0:
					if( cy > 0 && path[K(cx, cy - 1)] == d ) {
						dirs.remove(di);
						dirs.unshift(di);
						cy--;
						break;
					}
				case 1:
					if( path[K(cx,cy+1)] == d ) {
						dirs.remove(di);
						dirs.unshift(di);
						cy++;
						break;
					}
				case 2:
					if( cx > 0 && path[K(cx-1,cy)] == d ) {
						dirs.remove(di);
						dirs.unshift(di);
						cx--;
						break;
					}
				default:
					if( path[K(cx+1,cy)] == d ) {
						dirs.remove(di);
						dirs.unshift(di);
						cx++;
						break;
					}
				}
		}
		p.shift();
		this.path = p;
	}
	
	override function hitBy(e) {
		super.hitBy(e);
		
		target = null;
		path = null;

		if( !Std.is(e, Hero) )
			return;
		
		if( frightenBy(e) )
			fleeFrom(e, 10);
		else
			aggroTo(e);
			
		for( e2 in game.entities ) {
			var n = flash.Lib.as(e2, Npc);
			if( n == null || e2 == this ) continue;
			var dx = e.x - x;
			var dy = e.y - y;
			var d = Math.sqrt(dx * dx + dy * dy);
			if( d < 7 && n.frightenBy(e) )
				n.fleeFrom(e, 3);
			// get some help !
			if( d < 8 && Lambda.has(game.quests,n.id) && Data.NPC[n.id].quest.target == id && Data.NPC[n.id].quest.kill )
				n.aggroTo(this);
			else if( d < 5 && n.aggroBy(e) )
				n.aggroTo(e);
		}
	}
	
	function aggroTo( e : Entity ) {
		if( aggro != null ) {
			aggro.time += Math.random() * 2;
			return;
		}
		cancelFlee();
		path = null;
		target = null;
		collideEnt = true;
		aggro = {
			target : e,
			time : (Math.random() + 1) * 4,
			attack : -1,
		};
		mc.colorAdd = new h3d.Vector(0.1,0,0,0);
		speed *= 3;
		animSpeed *= 3;
	}
	
	function cancelAggro() {
		if( aggro == null ) return;
		collideEnt = true;
		speed /= 3;
		animSpeed /= 3;
		mc.colorAdd = null;
		aggro = null;
	}
	
	function cancelFlee() {
		if( flee == null ) return;
		flee = null;
		collideEnt = true;
		speed /= 5;
		animSpeed /= 3;
	}
	
	function fleeFrom( e:  Entity, time : Float ) {
		cancelAggro();
		if( flee != null )
			return;
		flee = (Math.random() + 0.5) * time;
		collideEnt = false;
		walkOnStreet = true;
		var a = Math.atan2(e.y - y, e.x - x);
		selectPath( x - Math.cos(a) * 10, y - Math.sin(a) * 10, 5 );
		walkOnStreet = false;
		speed *= 5;
		animSpeed *= 3;
	}
	
	override function moveBy(dx:Float, dy:Float) {
		if( id == 10 || id == 6 ) {
			if( dx < 0 )
				mc.scaleX = -1;
			else if( dx > 0 )
				mc.scaleX = 1;
		}
		
		if( !super.moveBy(dx, dy) ) {
			target = null;
			path = null;
			lock++;
			if( lock > 20 )
				walkOnStreet = true;
			wait = (Std.random(10) + 5) * 0.01;
			return false;
		}
		return true;
	}
	
	override function update(dt:Float) {
		
		if( game.missionScan == null || !game.missionScan(this) ) {
			setCursor(0x80FFFFFF);
			for( q in game.quests )
				if( Data.NPC[q].quest.target == id )
					setCursor(0xFF00FF00);
		} else
			setCursor(0xFFFF0000);
			
		if( life <= 0 ) {
			cancelAggro();
			cancelFlee();
			wait = 10;
			life += 0.02 * dt;
		} else if( life < maxLife && flee == null && aggro == null ) {
			life += 0.03 * dt;
		}
		
		if( flee != null ) {
			flee -= Timer.deltaT;
			wait = 0;
			if( flee < 0 )
				cancelFlee();
		}
		
		if( aggro != null ) {
			aggro.time -= Timer.deltaT;
			wait = 0;
			var t = aggro.target;
			var dx = t.x - x;
			var dy = t.y - y;
			var d = Math.sqrt(dx * dx + dy * dy);
			if( d > 10 || aggro.time < 0 || t.life <= 0 ) {
				cancelAggro();
			}
			else {
				moveBy(dx * speed * dt / d, dy * speed * dt / d);
				if( aggro.attack > 0 )
					aggro.attack -= dt * 0.05;
				else if( d < 1 ) {
					aggro.attack += Math.random() + 0.2;
					t.hitBy(this);
				}
			}
		} else if( wait > 0 )
			wait -= Timer.deltaT * 2;
		else if( target != null ) {
			var ds = speed * dt;
			var tx = target.x + 0.5, ty = target.y + 0.5;
			if( tx > x  )
				moveBy(Math.min(tx - x, ds), 0);
			else if( tx < x )
				moveBy(Math.max(tx - x, -ds), 0);

			if( ty > y  )
				moveBy(0,Math.min(ty - y, ds));
			else if( ty < y )
				moveBy(0,Math.max(ty - y, -ds));
							
			if( tx == x && ty == y )
				target = null;
		} else {
			if( path == null ) {
				selectPath(x,y,20);
				if( path == null )
					lock++;
				if( lock > 20 )
					walkOnStreet = true;
			}
			if( path != null ) {
				target = path.shift();
				if( target == null ) {
					path = null;
					lock = 0;
					wait = (Std.random(10) + 5) * 0.5;
				}
				if( walkOnStreet && Std.random(10) == 0 )
					walkOnStreet = false;
			}
		}
		super.update(dt);
		
		moneyWin -= dt / 60;
		if( moneyWin < 0. ) {
			moneyWin += 5 + Math.random() * 15;
			if( money < Data.NPC[id].money )
				money++;
		}
	}
	
}