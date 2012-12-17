import Common;

class Game implements haxe.Public {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	var tiles : h2d.Tile;
	var uiTile : h2d.Tile;
	var cursor : h2d.Tile;
	var sprites : Array<Array<h2d.Tile>>;
	var cars : Array<Array<h2d.Tile>>;
	var scroll : { x : Float, y : Float };

	var scrollBitmap : h2d.CachedBitmap;
	var scrollContent : h2d.Layers;
	var font : h2d.Font;
	
	var hero : Hero;
	var entities : Array<Entity>;
	var collide : Array<Array<Bool>>;
	var road : Array<Array<Bool>>;
	var roadOrPass : Array<Array<Bool>>;
	
	var mapWidth : Int;
	var mapHeight : Int;
	var showBounds : Bool;
	
	var menu : SelectMenu;
	var panelMC : h2d.Sprite;
	var panelTime : Float;
	
	var money : Int;
	var moneyUI : h2d.Text;
	
	var mission : Int;
	var missionText : h2d.Text;
	var missionCheck : Void -> Void;
	var missionScan : Npc -> Bool;
	var missionPanel : h2d.ScaleGrid;
	
	var miniMap : h2d.Bitmap;
	var inShop : Bool = true;
	
	var isHurt : Bool;
	var healCount : Int;
	
	var saveObj : flash.net.SharedObject;

	var curAction : Int;
	var actions : Array<{ id : Int, t : String, f : Void -> Void, mc : h2d.Bitmap }>;

	var quests : Array<Int>;
	var questsDone : Array<Int>;
	var items : Array<Item>;
	
	var saveString : String;
	
	var win : Bool;
	var winPanel : Bool;
	var winTime : Float = 0;
			
	function new(e) {
		this.engine = e;
		scene = new h2d.Scene();
		scene.setFixedSize(380, 250);
		font = new h2d.Font("PixelFont", 16);
	}
	
	public function init() {
		entities = [];
		quests = [];
		questsDone = [];
		items = [];
		
		var t = new Tiles(0, 0, true);
		var s = new Sprites(0, 0, true);
		var c = new CarsBMP(0, 0, true);
		clearTile(t);
		clearTile(s);
		clearTile(c);
		
		actions = [];
		
		
		var ui = new UIBMP(0, 0, true);
		clearTile(ui, 0xFFFF00FF);
		uiTile = h2d.Tile.fromBitmap(ui);
		tiles = h2d.Tile.fromBitmap(t);
		cursor = tiles.sub(32, 144, 16, 16);
		sprites = h2d.Tile.autoCut(s, 16).tiles;
		
		cars = h2d.Tile.autoCut(c, 16 * 3, 16 * 2).tiles;
		for( sx in sprites )
			for( i in 0...sx.length ) {
				var s = sx[i];
				s = s.sub(0, 0, s.width, s.height, -s.width, 5-(s.height * 2) );
				s.scaleToSize(s.width * 2, s.height * 2);
				sx[i] = s;
			}
			
		for( sx in cars )
			for( i in 0...sx.length ) {
				var s = sx[i];
				s = s.sub(0, 0, s.width, s.height, -s.width, 5-(s.height * 2) );
				s.scaleToSize(s.width * 2, s.height * 2);
				sx[i] = s;
			}
			
		
		scrollBitmap = new h2d.CachedBitmap(scene, scene.width, scene.height);
		scrollContent = new h2d.Layers(scrollBitmap);
		scrollBitmap.color = new h3d.Vector(0.8, 0.8, 1.2);
		
		var mpanel = newPanel();
		mpanel.width = scene.width + 6;
		mpanel.x = -3;
		mpanel.height = 30;
		mpanel.y = scene.height - mpanel.height + 3;
		mpanel.alpha = 0.95;
		missionPanel = mpanel;
		
		missionText = new h2d.Text(font, mpanel);
		missionText.x = 10;
		missionText.maxWidth = (scene.width - 20) * 2;
		missionText.scaleX = missionText.scaleY = 0.5;
	
		initMap();
		scroll = { x : 15, y : 27 };
		
		var bmp = new flash.display.BitmapData(mapWidth, mapHeight, true, 0xFF808090);
		for( x in 0...mapWidth )
			for( y in 0...mapHeight ) {
				if( road[x][y] ) bmp.setPixel32(x, y, 0xFF404048);
				if( collide[x][y] ) bmp.setPixel32(x, y, 0xFFA0A0B0);
			}
		miniMap = new h2d.Bitmap(h2d.Tile.fromBitmap(bmp), scene);
		miniMap.x = scene.width - mapWidth - 5;
		miniMap.y = 5;
		miniMap.blendMode = Add;
		miniMap.alpha = 0.5;
		initEnt();
		
		moneyUI = new h2d.Text(font, scene);
		moneyUI.x = 5;
		moneyUI.y = 5;
		moneyUI.textColor = 0xFFEFE161;
		moneyUI.dropShadow = { dx : 1, dy : 2, color : 0, alpha : 0.5 };
		
		saveObj = flash.net.SharedObject.getLocal("save3");
		var save = saveObj.data.save;
		if( save != null ) {
			var save : SaveData = haxe.Unserializer.run(save);
			money = save.money;
			quests = save.quests;
			items = save.items;
			questsDone = save.questsDone;
			hero.power = save.attack;
			hero.x = save.x;
			hero.y = save.y;
			hero.life = save.life;
			mission = save.mission;
			for( a in save.actions )
				addAction(a);
			var npcs = new IntHash(), cars = new IntHash();
			for( e in entities ) {
				var n = flash.Lib.as(e, Npc);
				if( n == null ) {
					var n = flash.Lib.as(e, Car);
					if( n != null ) cars.set(n.id, n);
					continue;
				}
				npcs.set(n.id, n);
			}
			for( e in save.e ) {
				var n = npcs.get(e.id);
				if( n == null )
					n = addNpc(e.id);
				n.life = e.life;
				n.x = e.x;
				n.y = e.y;
				n.money = e.m;
				npcs.remove(e.id);
				if( n.id == 7 && Lambda.has(questsDone, 0) )
					n.play(15);
			}
			for( e in save.cars ) {
				var c = cars.get(e.id);
				c.life = e.life;
				c.x = e.x;
				c.y = e.y;
				c.dirX = e.dir;
				cars.remove(e.id);
			}
			for( n in npcs )
				n.remove();
			for( c in cars )
				c.remove();
			nextMission(true);
			announce("Game Loaded");
			setAction(save.act);
		} else {
			mission = -1;
			addAction(0);
			nextMission();
		}
				
		moneyUI.text = "$" + money;
	}
	
	static var disableColor = new h3d.Vector(0.5, 0.5, 0.5, 1);
	
	function setPanel(panel) {
		if( panelMC != null ) panelMC.remove();
		panelMC = panel;
		panelTime = 0.;
	}
	
	function addAction(id) {
		var mc = new h2d.Bitmap(tiles.sub(id * 16, 208, 16, 16), scene);
		mc.x = 5 + actions.length * 20;
		mc.y = scene.height - 40;
		if( actions.length > 0 ) mc.color = disableColor;
		var f = [
			doPunch,
			doTalk,
			doShot,
		][id];
		actions.push( { id:id, t:Data.ACTIONS[id], f:f, mc :mc } );
	}
	
	function initEnt() {
		hero = new Hero(scroll.x, scroll.y);
		hero.life = hero.maxLife = 100;
		
		for( i in 0...11 )
			addNpc(i);
		
		var cpos = [[10, 26], [33, 31], [12, 55], [32, 14]];
		for( i in 0...cpos.length ) {
			var c = new Car(i, cpos[i][0], cpos[i][1]);
			c.onKill = function() {
				c.kill();
				if( c.id == 1 && Lambda.has(quests, 10) )
					addItem(Pizza);
			}
		}
	}
	
	function addNpc(id:Int) {
		var x, y;
		do {
			x = Std.random(mapWidth);
			y = Std.random(mapHeight);
		} while( collide[x][y] || road[x][y] );
		
		var inf = Data.NPC[id];
		var n = new Npc(id, x + 0.5, y + 0.5, inf.money);
		n.life = n.maxLife = inf.def;
		n.power = inf.att;
		n.onKill = function() {
			if( n.money > 0 ) {
				var k = ((n.money + 1) >> 1) + Std.random(n.money>>1);
				for( i in 0...k ) {
					var e = new Bill(n.x, n.y);
					var a = Math.atan2(n.y - hero.y, n.x - hero.x) + (Math.random() * 2 - 1) * Math.PI / 4;
					var p = (2 + Math.random() * 4) * 0.1;
					e.pushX = Math.cos(a) * p;
					e.pushY = Math.sin(a) * p;
				}
				n.money -= k;
			}
			if( n.id == 7 && Lambda.has(quests, 0) && Lambda.has(items, Scissors) ) {
				n.play(15);
				questDone(0);
			}
		}
		n.onReallyKill = function() {
			switch( n.id ) {
			case 1, 2, 7, 9, 10:
				Sounds.childKill.play();
			default:
				Sounds.manKill.play();
			}
			for( q in quests ) {
				var qinf = Data.NPC[q].quest;
				if( Lambda.has(qinf.targets,n.id) ) {
					if( qinf.kill ) {
						var has = false;
						for( t in qinf.targets )
							for( e in entities ) {
								var n = flash.Lib.as(e, Npc);
								if( n != null && n.id == t )
									has = true;
							}
						if( !has )
							questDone(q);
					} else {
						quests.remove(q);
						showPanel("You have failed to complete " + Data.NPC[q].name + "'s quest", true);
					}
				}
			}
		}
		return n;
	}
	
	function getMoney(m) {
		money += m;
		moneyUI.text = "$" + money;
		if( m > 0 ) announce("You got $" + m);
	}
	
	var announceText : h2d.Text;
	function announce(text) {
		if( announceText != null )
			announceText.remove();
		announceText = new h2d.Text(font,scene);
		announceText.x = 5;
		announceText.y = 25;
		announceText.scaleX = announceText.scaleY = 0.5;
		announceText.text = text;
	}
	
	function nextMission( load = false ) {
		if( !load ) mission++;
		var text, miss, scan : Npc -> Bool = null;
		var prefix = "Mission " + (mission + 1) + " : ";
		switch( mission ) {
		case 0:
			text = "Stole $10 from people which can't defend themselves.\nTip : Look at the Minimap to find your target.";
			miss = function() {
				if( money >= 10 ) nextMission();
			};
			scan = function(n) return n.power <= hero.power && n.money > 0;
		case 1:
			if( !load ) showPanel("You have completed the first mission ! Look at the panel below to check next objective");
			text = "Go buy a weapon at your favorite shop in the city center.";
			miss = function() {
				if( hero.power > 1 ) nextMission();
			};
		case 2:
			text = "Try to get $30 from people. But be careful to hide yourself from other peasants.";
			miss = function() {
				if( money >= 30 ) nextMission();
			};
			scan = function(n) return n.power <= hero.power && n.money > 0;
		case 3:
			text = "Go buy the Book at the items shop !";
			miss = function() {
				if( actions.length > 1 ) nextMission();
			};
		case 4:
			text = "Select the Talk Action : use the '2' Action Key";
			miss = function() {
				if( curAction == 1 ) nextMission();
			}
		case 5:
			var id = 8;
			text = "Go talk to " + Data.NPC[id].name + ", he might have a job for you.";
			miss = function() {
				if( curAction != 1 )  {
					mission--;
					nextMission(true);
				} else if( Lambda.has(quests,8) ) nextMission();
			};
			scan = function(n) return n.id == id;
		case 6:
			text = "Complete the job you got.\nCheck the green point on the Minimap for Job target";
			miss = function() {
				if( Lambda.has(questsDone,8) ) nextMission();
			};
		case 7:
			text = "Talk again to Glaze";
			miss = function()  {
				if( Lambda.has(quests, 5) ) nextMission();
			};
			scan = function(n) return n.id == 5;
		case 8:
			text = "Talk to the boss";
			miss = function()  {
				if( Lambda.has(questsDone, 5) ) nextMission();
			};
		case 9:
			text = "Buy a Knife at the weapon shop";
			miss = function()  {
				if( Lambda.has(items, Knife) ) nextMission();
			};
		case 10:
			text = "Activate Attack Mode : use the '1' Action Key";
			miss = function()  {
				if( curAction == 0 ) nextMission();
			};
		case 11:
			text = "Hit Glaze until he die";
			miss = function()  {
				if( curAction != 0 )  {
					mission--;
					nextMission(true);
				} else if( Lambda.has(questsDone, 4) ) nextMission();
			};
		case 12:
			text = "Go and save your game at the save point";
			miss = function() {
			};
		default:
			prefix = "";
			var count = questsDone.length;
			text = "You are now in sandbox mode : play as you wish !\n"+count+"/"+Data.NPC.length+" quests completed, talk to people for more quests";
			miss = function() {
				if( questsDone.length != count ) nextMission(true);
			};
		}
		missionText.text = prefix + text;
		missionText.y = (30 - (missionText.textHeight >> 1)) >> 1;
		missionPanel.colorAdd = new h3d.Vector(0.5, 0.5, 0.5, 0);
		missionCheck = miss;
		missionScan = scan;
	}
	
	function clearTile(t:flash.display.BitmapData, bg:UInt= 0) {
		if( bg == 0 ) bg = t.getPixel32(t.width - 1, t.height - 1);
		t.lock();
		for( x in 0...t.width )
			for( y in 0...t.height )
				if( t.getPixel32(x, y) == bg )
					t.setPixel32(x, y, 0);
	}
	
	function initMap() {
		var map : Tiled = haxe.Json.parse(haxe.Resource.getString("map"));
		var layers = [];
		var tmap = [], smap = [];
		for( y in 0...tiles.height >> 4 )
			for( x in 0...tiles.width >> 4 ) {
				tmap.push(tiles.sub(x * 16, y * 16, 16, 16));
				smap.push(tiles.sub(x * 16, y * 16, 16, 16, 0, -16));
			}
		collide	= [];
		road = [];
		roadOrPass = [];
		for( x in 0...map.width ) {
			collide[x] = [];
			road[x] = [];
			roadOrPass[x] = [];
		}
		mapWidth = map.width;
		mapHeight = map.height;
		for( l in map.layers ) {
			var over = false;
			var pos = 0;
			var t = new h2d.TileGroup(tiles);
			var plan = Const.PLAN_MAP;
			switch( l.name ) {
			case "collide":
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 ) collide[x][y] = true;
					}
				continue;
			case "soil":
				t.blendMode = None;
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						switch( c-1 ) {
						case 0, 1, 2, 33, 34:
							road[x][y] = true;
							roadOrPass[x][y] = true;
						case 7, 36: // walk way
							roadOrPass[x][y] = true;
						default:
						}
					}
				pos = 0;
			case "underShades":
				t.alpha = 0.3;
			case "shades":
				t.alpha = 0.3;
			case "windows":
				t.alpha = 0.5;
			case "sprites":
				for( y in 0...mapHeight )
					for( x in 0...mapWidth ) {
						var c = l.data[pos++];
						if( c != 0 ) {
							var s = new h2d.Bitmap(smap[c - 1]);
							s.x = x * 16;
							s.y = (y + 1) * 16;
							scrollContent.add(s, Const.PLAN_ENTITY);
						}
					}
				continue;
			case "lights":
				var l = h2d.Tile.fromBitmap(new LightBMP(0, 0, true)).sub(0, 0, 256, 256, -4, -5);
				plan = Const.PLAN_LIGHT;
				l.scaleToSize(32, 32);
				t.tile = l;
				t.alpha = 0.5;
				t.blendMode = Add;
				tmap[101] = l;
			case "over":
				plan = Const.PLAN_OVER;
			case "overShades":
				plan = Const.PLAN_OVER;
				t.alpha = 0.3;
			default:
			}
			for( y in 0...mapHeight ) {
				for( x in 0...mapWidth ) {
					var c = l.data[pos++];
					if( c == 0 ) continue;
					t.add(x * 16, y * 16, tmap[c - 1]);
				}
			}
			scrollContent.add(t, plan);
		}
	}
	
	
	function newPanel( ?parent : h2d.Sprite ) {
		if( parent == null ) parent = scene;
		var p = new h2d.ScaleGrid(uiTile, 4, 4, parent);
		p.x = 10;
		p.y = 10;
		return p;
	}
	
	function showPanel( text : String, ?delay ) {
		var p = newPanel();
		p.width = scene.width - 20;
		var t = new h2d.Text(font, p);
		t.text = text;
		t.maxWidth = (scene.width - 40) * 2;
		t.scaleX = t.scaleY = 0.5;
		t.x = (p.width - (t.textWidth >> 1)) >> 1;
		t.y = 5;
		p.height = 10 + (t.textHeight>>1);
		setPanel(p);
		if( delay ) panelTime = 1.;
	}
	
	
	function updateGamePlay(dt:Float ) {
		var ds = hero.speed * dt;
		if( Key.isDown(K.LEFT) || Key.isDown("A".code) || Key.isDown("Q".code) )
			hero.moveBy( -ds, 0);
		if( Key.isDown(K.RIGHT) || Key.isDown("D".code) )
			hero.moveBy( ds, 0);
		if( Key.isDown(K.DOWN) || Key.isDown("S".code) )
			hero.moveBy( 0, ds);
		if( Key.isDown(K.UP) || Key.isDown("Z".code) || Key.isDown("W".code) )
			hero.moveBy( 0, -ds);
		scrollContent.ysort(Const.PLAN_ENTITY);
		for( e in entities.copy() )
			e.update(dt);
			
		if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) )
			actions[curAction].f();
	}
	
	
	function setAction(i) {
		curAction = i;
		for( i in 0...actions.length )
			actions[i].mc.color = i == curAction ? null : disableColor;
	}
	
	function update(dt:Float) {
		
		if( announceText != null ) {
			announceText.alpha -= dt * 0.05;
			announceText.y -= dt * 0.5;
			if( announceText.alpha <= 0 ) {
				announceText.remove();
				announceText = null;
			}
		}
		
		if( missionPanel.colorAdd != null ) {
			missionPanel.colorAdd.x -= dt * 0.1;
			missionPanel.colorAdd.y -= dt * 0.1;
			missionPanel.colorAdd.z -= dt * 0.1;
			if( missionPanel.colorAdd.x < 0 )
				missionPanel.colorAdd = null;
		}
		
		Part.updateAll(dt);
		
		scroll.x = hero.x;
		scroll.y = hero.y;
		
		var ix = Std.int(scroll.x * 16) - (scene.width >> 1);
		var iy = Std.int(scroll.y * 16) - (scene.height >> 1);
		if( ix < 0 ) ix = 0;
		if( iy < 0 ) iy = 0;
		if( ix + scene.width > mapWidth * 16 ) ix = mapWidth * 16 - scene.width;
		if( iy + scene.height > mapHeight * 16 + 20 ) iy = mapHeight * 16 - scene.height + 20;
		scrollContent.x = -ix;
		scrollContent.y = -iy;
		
		for( i in 0...9 )
			if( (Key.isToggled(K.NUMBER_1 + i) || Key.isToggled(K.NUMPAD_1 + i)) && actions[i] != null && i != curAction ) {
				setAction(i);
				announce("Action : " + actions[i].t);
				break;
			}
				
		
		if( menu != null ) {

			if( Key.isToggled(K.DOWN) || Key.isToggled("S".code) ) {
				menu.index++;
				Sounds.menu.play();
				menu.index %= menu.options.length;
			}
			
			if( Key.isToggled(K.UP) || Key.isToggled("Z".code) || Key.isToggled("W".code) ) {
				menu.index--;
				Sounds.menu.play();
				if( menu.index < 0 ) menu.index += menu.options.length;
			}
			
			if( Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER) ) {
				var old = menu;
				Sounds.menu.play();
				menu.remove();
				menu = null;
				var o = old.options[old.index];
				if( o.price != null ) {
					if( money < o.price )
						showPanel("You don't have enough money");
					else {
						getMoney(-o.price);
						o.c();
					}
				} else
					o.c();
				return;
			}
			
			menu.update(dt);
				
		} else if( panelMC != null ) {
			panelTime -= dt / 60;
			if( (Key.isToggled(K.SPACE) || Key.isToggled(K.ENTER)) && panelTime < 0 ) {
				Sounds.menu.play();
				panelMC.remove();
				panelMC = null;
			}
		} else
			updateGamePlay(dt);
			
		if( win ) {
			if( winPanel ) {
				if( panelMC == null ) {
					scene.dispose();
					startGame(engine);
					return;
				}
			} else {
				winTime += dt / 60;
				var a = 0.8 - winTime * 0.2;
				var b = winTime * 0.2;
				var c = 1.2  - winTime * 0.2;
				var r = winTime * 0.5;
				scrollBitmap.color = null;
				scrollBitmap.colorMatrix = h3d.Matrix.L([
					a + r, b, b, 0,
					b + r, a, b, 0,
					b + r, b, c, 0,
					0, 0, 0, 1,
				]);
				if( winTime > 3.5 ) {
					winPanel = true;
					showPanel("Small Theft Auto\nMade in 48 hours for the Ludum Dare #25 contest\n\nCongratulations for finishing the game!\nPlease tweet me if you like it @ncannasse\nYou can also follow @shirogames : we are making independant games!\n\nPress action key to return to title.");
				}
			}
		}
			
		if( Key.isDown(K.ESCAPE) && Key.isDown(K.CONTROL) ) {
			saveObj.data.save = null;
			saveObj.flush();
			announce("Save Clear");
		}
			
		if( Key.isToggled("S".code) && Key.isDown(K.CONTROL) )
			save();
			
		if( Key.isToggled("B".code) )
			showBounds = !showBounds;
	
		if( Key.isToggled("M".code) )
			getMoney(money == 0 ? 10 : money);
			
		var ix = Std.int(hero.x), iy = Std.int(hero.y);
		if( ix == 20 && iy == 22 )
			initShop(Data.WEAPONS);
		else if( ix == 35 && iy == 27 ) {
			if( !inShop ) {
				if( mission < 3 ) {
					inShop = true;
					showPanel("The item shop is currently closed, please come by again later.");
				} else
					initShop(Data.ITEMS);
			}
		} else if( ix == 6 && iy == 40 ) {
			if( !inShop ) {
				inShop = true;
				var price = 20 + healCount * 10;
				if( price > money ) price = money;
				if( mission <= 11 ) price = 0;
				menu = new SelectMenu([
					{
						t : "Heal",
						price : price,
						c : function() {
							hero.life = hero.maxLife;
							hero.showLife();
							announce("Life healed !");
						}
					},
					{
						t : "Exit",
						c : function() {},
					}
				]);
			}
		} else if( ix == 21 && iy == 41 ) {
			if( !inShop ) {
				inShop = true;
				menu = new SelectMenu([
					{
						t : "Save",
						c : save,
					},
					{
						t : "Erase Save",
						c : function() {
							saveObj.data.save = null;
							saveObj.flush();
							showPanel("Save Clear.\nReload game to restart from scratch, or save again to cancel.");
						},
					},
					{
						t : "Exit",
						c : function() {},
					}
				]);
			}
		} else
			inShop = false;
	
		if( !isHurt && hero.life < 0 ) {
			isHurt = true;
			showPanel("You've been badly hurt, you should go to the hospital to heal yourself", true);
		}
			
		missionCheck();
				
		
		if( questsDone.length >= 10 && !Lambda.has(items, Angel) ) {
			items.push(Angel);
			addNpc(11);
		}
		
		if( questsDone.length == Data.NPC.length && panelMC == null )
			win = true;
		
		engine.render(scene);
	
	}

	function save() {
		if( mission == 12 )
			nextMission();
		var ent = [], cars = [];
		for( e in entities )
			if( Std.is(e, Npc) ) {
				var e : Npc = cast e;
				ent.push( { id: e.id, x : e.x, m : e.money, y : e.y, life:e.life } );
			} else if( Std.is(e, Car) ) {
				var e : Car = cast e;
				cars.push( { id : e.id, x : e.x, y : e.y, life : e.life, dir : e.dirX } );
			}
		var save : SaveData = {
			act : curAction,
			x : hero.x,
			y : hero.y,
			actions : Lambda.array(Lambda.map(actions, function(a) return a.id)),
			money : money,
			e : ent,
			cars : cars,
			attack : hero.power,
			life : hero.life,
			mission : mission,
			quests : quests,
			items : items,
			questsDone : questsDone,
		};
		var s = haxe.Serializer.run(save);
		saveObj.data.save = s;
		saveObj.flush();
		announce("Saved");
	}
	
	function initShop( shop : Array<Data.ShopItem> ) {
		if( inShop )
			return;
		inShop = true;
		var options : SelectMenu.Options = [];
		for( i in shop ) {
			if( Lambda.has(items, i.i) )
				continue;
			var name = Data.ITEM_NAMES[Type.enumIndex(i.i)];
			options.push( {
				t : name,
				price : i.price,
				c : function() {
					i.f();
					var text = "Congratulations ! You bought " + name + " for $" + i.price + "\n";
					if( i.text != null )
						text += i.text;
					else if( shop == Data.WEAPONS ) {
						if( i.i == MiniGun )
							text += "You can now shot at everybody !";
						else
							text += "Your attack power is now " + hero.power;
					}
					this.items.push(i.i);
					showPanel(text);
				},
			});
		}
		options.push( { t : "Exit", price : null, c : function() { } });
		menu = new SelectMenu(options);
	}
	
	//----------------- ACTIONS
	
	function doPunch() {
		if( hero.life <= 0 ) {
			if( panelMC == null )
				showPanel("You can't attack while you're badly hurt, wait to recover or go to the hospital");
		}
		else {
			for( e in hero.getTargets() )
				e.hitBy(hero);
		}
	}
	
	function doShot() {
		if( hero.life <= 0 ) {
			if( panelMC == null )
				showPanel("You can't attack while you're badly hurt, wait to recover or go to the hospital");
		} else {
			for( i in 0...5 ) {
				var a = Math.atan2(hero.dirY, hero.dirX) + (Math.random() * 2 - 1) * Math.PI / 16;
				var e = new Bullet(hero.x + Math.cos(a) * 0.5, hero.y - 0.5 + Math.sin(a) * 0.5, a);
			}
			Sounds.fire.play();
		}
	}
	
	function addItem(i) {
		items.push(i);
		showPanel("You got item : " + Data.ITEM_NAMES[Type.enumIndex(i)]);
	}
	
	function questDone(q,?ann) {
		quests.remove(q);
		questsDone.push(q);
		var inf = Data.NPC[q];
		var text = "You have completed " + inf.name + "'s quest !";
		if( inf.quest.m > 0 ) {
			text += "\n You get $"+inf.quest.m+" as a reward";
			getMoney(inf.quest.m);
		}
		if( ann ) announce(text) else showPanel(text,true);
	}
	
	function doTalk() {
		var n = flash.Lib.as(hero.getTargets()[0], Npc);
		if( n == null )
			return;
				
		setPanel(new h2d.Sprite(scene));

		var p = newPanel(panelMC);
		p.width = 150;
		p.height = 50;
		var b = new h2d.Bitmap(n.anim[0], p);
		b.x = 20;
		b.y = 35;
		var t = new h2d.Text(font, p);
		t.x = 40;
		t.y = 10;
		var inf = Data.NPC[n.id];
		t.text = 'Name : ${inf.name}\nAge : ${inf.age}\nPower : ${inf.att}\nLife : ${Math.ceil(n.life)}/${inf.def}';
		t.scaleX = t.scaleY = 0.5;
		
		var cancelNext = false;
		
		for( q in quests ) {
			function giveItem(i) {
				if( Lambda.has(items, i) ) {
					var name = Data.ITEM_NAMES[Type.enumIndex(i)];
					menu = new SelectMenu([
						{ t : "Give " + name, c : function() {
							items.remove(i);
							questDone(q);
							panelTime = 0;
						} },
						{ t : "Cancel", c : function() {
							setPanel(null);
						} },
					]);
					menu.x = 120;
					menu.y = 15;
					cancelNext = true;
				}
			}
			if( Lambda.has(Data.NPC[q].quest.targets,n.id) ) {
				switch( q ) {
				case 8:
					giveItem(Drug);
				case 5:
					questDone(q, true);
				case 7:
					giveItem(Pills);
				case 10:
					giveItem(Pizza);
				case 6:
					var isCar = false;
					for( e in entities )
						if( Std.is(e, Car) )
							isCar = true;
					if( !isCar ) {
						questDone(q);
						return;
					}
				default:
				}
			}
		}
		
		if( cancelNext )
			return;
		
		if( !Lambda.has(questsDone,n.id) && inf.quest != null ) {
			var d = newPanel(panelMC);
			d.x = 10;
			d.y = 70;
			d.width = 300;
			var t = new h2d.Text(font, d);
			t.scaleX = t.scaleY = 0.5;
			t.maxWidth = 280 * 2;
			t.x = 10;
			t.y = 10;
			t.text = inf.quest.t;
			d.height = 20 + (t.textHeight >> 1);
			if( !Lambda.has(quests,n.id) ) {
				menu = new SelectMenu([
					{ t : "Accept Mission", c : function() {
						quests.push(n.id);
						setPanel(null);
						switch( n.id ) {
						case 8:
							addItem(Drug);
							
						}
					} },
					{ t : "Cancel", c : function() {
						setPanel(null);
					} },
				]);
				menu.x = 120;
				menu.y = 15;
			}
		}
	}
	
	
	public static var inst : Game;
	public static var title : Title;
	
	static function updateLoop() {
		Timer.update();
		if( title != null ) title.update(Timer.tmod) else if( inst != null ) inst.update(Timer.tmod);
	}

	static function startGame(engine) {
		inst = new Game(engine);
		title = new Title();
	}
	
	static function main() {
		Sounds.music.play(0, 99999).soundTransform = new flash.media.SoundTransform(0.5);
		var engine = new h3d.Engine();
		engine.onReady = function() {
			startGame(engine);
		};
		engine.init();
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, function(_) updateLoop());
		Key.init();
	}
	
}