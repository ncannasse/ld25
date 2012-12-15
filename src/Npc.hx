class Npc extends Entity {

	public var id : Int;
	var wait : Float = 0.;
	var path : Array<{ x : Int, y : Int }>;
	var target : { x : Int, y : Int };
	
	public function new(id,x,y) {
		super(x, y);
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
	
	function selectPath() {
		var tx, ty;
		do {
			tx = Std.random(game.mapWidth);
			ty = Std.random(game.mapHeight);
		} while( game.collide[tx][ty] || game.road[tx][ty] );
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
				if( game.collide[x][y] || game.road[x][y] )
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
			return null;
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
		p.pop();
		return p;
	}
	
	override function move(dx, dy) {
		if( !super.move(dx, dy) ) {
			target = null;
			path = null;
			wait = (Std.random(10) + 5) * 0.01;
			return false;
		}
		return true;
	}
	
	override function update(dt:Float) {
		
		if( game.missionScan == null || !game.missionScan(this) )
			setCursor(0x80FFFFFF);
		else
			setCursor(0xFFFF0000);
		
		
		if( wait > 0 )
			wait -= Timer.deltaT;
		else if( target != null ) {
			var ds = speed * dt;
			var tx = target.x + 0.5, ty = target.y + 0.5;
			if( id == 10 || id == 6 ) {
				if( tx < x )
					mc.scaleX = -1;
				else if( tx > x )
					mc.scaleX = 1;
			}
			if( tx > x && move(1,0) ) {
				if( x > tx ) x = tx;
			} else if( ty > y && move(0,1) ) {
				if( y > ty ) y = ty;
			} else if( tx < x && move(-1,0) ) {
				if( x < tx ) x = tx;
			} else if( ty < y && move(0,-1) ) {
				if( y < ty ) y = ty;
			}
			if( tx == x && ty == y )
				target = null;
		} else {
			if( path == null )
				path = selectPath();
			if( path != null ) {
				target = path.shift();
				if( target == null ) {
					path = null;
					wait = (Std.random(10) + 5) * 0.5;
				}
			}
		}
		
		super.update(dt);
	}
	
}