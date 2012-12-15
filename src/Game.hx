class Game {
	
	var engine : h3d.Engine;
	var scene : h2d.Scene;
	
	function new(e) {
		this.engine = e;
		scene = new h2d.Scene();
		scene.setFixedSize(380, 250);
	}
	
	function update(dt:Float) {
		engine.render(scene);
	}

	public static var inst : Game;
	
	static function updateLoop() {
		Timer.update();
		if( inst != null ) inst.update(Timer.tmod);
	}

	
	static function main() {
		var engine = new h3d.Engine();
		engine.onReady = function() {
			inst = new Game(engine);
		};
		engine.init();
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, function(_) updateLoop());
	}
	
}