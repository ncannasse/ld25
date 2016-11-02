class Title  {

	var game : Game;
	var tf : h2d.Text;
	var time = 0.;

	public function new() {
		game = Game.inst;
		var bmp = new h2d.Bitmap(hxd.Res.title.toTile(), game.s2d);
		tf = new h2d.Text(game.font, bmp);
		tf.text = "Click to start";
		tf.x = 250;
		tf.y = game.s2d.height - 15;
		tf.dropShadow = { dx : 1, dy  : 1, color : 0, alpha : 0.8 };
		var i = new h2d.Interactive(game.s2d.width, game.s2d.height, bmp);
		i.cursor = Default;
		i.onRelease = function(_) {
			bmp.remove();
			Game.title = null;
			game.initGame();
		};
	}

	public function update(dt:Float) {
		time += dt * 0.1;
		tf.visible = time % 2 < 1;
	}

}