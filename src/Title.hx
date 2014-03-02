class Title  {

	var game : Game;
	var tf : h2d.Text;
	var time = 0.;
	
	public function new() {
		game = Game.inst;
		var bmp = new h2d.Bitmap(hxd.Res.title.toTile(), game.scene);
		tf = new h2d.Text(game.font, bmp);
		tf.text = "Click to start";
		tf.x = 250;
		tf.y = game.scene.height - 15;
		tf.dropShadow = #if h3d { dx : 1, dy  : 1, color : 0, alpha : 0.8 } #else { x : 1, y  : 1, color : 0, alpha : 0.8 } #end;
		var i = new h2d.Interactive(game.scene.width, game.scene.height, bmp);
		i.cursor = Default;
		i.onRelease = function(_) {
			bmp.remove();
			Game.title = null;
			game.init();
		};
	}
	
	public function update(dt:Float) {
		game.engine.render(game.scene);
		time += dt * 0.1;
		tf.visible = time % 2 < 1;
		game.scene.checkEvents();
	}
	
}