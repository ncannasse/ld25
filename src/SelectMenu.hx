package ;

class SelectMenu extends h2d.ScaleGrid {

	var cursor : h2d.Bitmap;
	
	public var options : Array < { t:String, c:Void->Void }>;
	public var index : Int;
	
	public function new(options) {
		var game = Game.inst;
		super(game.uiTile, 4, 4, game.scene);
		this.x = 10;
		this.y = 10;
		this.options = options;
		width = 80;
		height = 15 + options.length * 12;
		cursor = new h2d.Bitmap(game.cursor, this);
		var pos = 0;
		for( o in options ) {
			var t = new h2d.Text(game.font, this);
			t.scaleX = t.scaleY = 0.5;
			t.x = 10;
			t.y = 10 + pos * 12;
			t.text = o.t;
			pos++;
		}
		cursor.scaleX = cursor.scaleY = 0.5;
		index = 0;
		update(0);
	}
	
	public function update(dt:Float) {
		cursor.x = 0;
		cursor.y = 10 + index * 12;
	}
	
}