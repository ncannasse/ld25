class Title  {

	var game : Game;
	var tf : h2d.Text;
	var time = 0.;
	
	public function new() {
		game = Game.inst;
		var bmp = h2d.Bitmap.create(new Common.TitleBMP(0, 0, true));
		game.scene.addChild(bmp);
		tf = new h2d.Text(game.font, bmp);
		tf.text = "Click to start";
		tf.x = 250;
		tf.y = game.scene.height - 15;
		tf.dropShadow = { dx : 1, dy  : 1, color : 0, alpha : 0.8 };
		var i = new h2d.Interactive(game.scene.width, game.scene.height, bmp);
		i.useMouseHand = false;
		i.onRelease = function(_) {
			bmp.remove();
			Game.title = null;
			game.init();
		};
	}
	
	public function update(dt:Float) {
		game.engine.render(game.scene);
		time += dt * 0.1;
		if( time % 2 < 1 )
			tf.blendMode = Normal;
		else
			tf.blendMode = Hide;
		game.scene.checkEvents();
	}
	
}