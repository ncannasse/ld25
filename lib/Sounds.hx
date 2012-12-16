#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
@:build(Sounds.build())
#end
class Sounds {

	#if macro
	public static function build() {
		var fields = [];
		var pos = Context.currentPos();
		for( f in sys.FileSystem.readDirectory("sfx") ) {
			switch( f.substr(f.length - 3, 3) ) {
			case "wav":
				var name = f.substr(0, -4);
				/*
				var mp3 = name + ".mp3";
				var changed = try sys.FileSystem.stat(mp3).mtime.getTime() < sys.FileSystem.stat(f).mtime.getTime() catch( e : Dynamic ) true;
				if( changed )
					Sys.command("lame", ["--silent", "-h", "sfx/" + f, "sfx/" + mp3]);
				*/
				var data = sys.io.File.getContent("sfx/" + f);
				var fpos = Context.makePosition( { min:0, max:0, file : "sfx/" + f } ) ;
				var c  = {
					pos : fpos,
					fields : [],
					params : [],
					pack : ["_res"],
					name : "R" + name,
					meta : [ { name : ":sound", params : [ { expr :EConst(CString("data:" + data)), pos :fpos } ], pos : fpos } ],
					isExtern : false,
					kind : TDClass( { pack : ["flash", "media"], name : "Sound", params :[] } ),
				};
				Context.defineType(c);
				fields.push( {
					name : name,
					access : [APublic, AStatic],
					doc : null,
					kind : FVar(null, { expr : ENew( { pack : ["_res"], name : "R" + name, params : [] }, []), pos : pos } ),
					meta : [],
					pos : pos,
				});
			default:
			}
		}
		return fields;
	}
	#end
	
	
}