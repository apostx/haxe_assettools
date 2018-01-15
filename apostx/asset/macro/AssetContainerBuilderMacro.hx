package apostx.asset.macro;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.Constant.CString;
import haxe.macro.Expr.ExprDef.EConst;
import sys.io.File;

class AssetContainerBuilderMacro
{
	public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		
		for (field in fields)
		{
			var mergeInfo:FileInfo = null;
			
			for (metaData in field.meta)
			{
				mergeInfo = getMergeMetaInfo(metaData);
				
				if (mergeInfo != null)
				{
					field.meta.remove(metaData);
					break;
				}
			}
			
			if (mergeInfo != null)
			{
				var fieldType:Null<ComplexType> = switch(field.kind)
				{
					case FVar(type, _): type;
					default: null;
				}
				
				var fileData:Dynamic = switch(mergeInfo.type)
				{
					case "text/plain": File.getContent(mergeInfo.path);
					case "application/json": Json.parse(File.getContent(mergeInfo.path));
					default: File.getBytes(mergeInfo.path).toHex();
				};
				
				field.kind = FVar(fieldType, macro $v{fileData});
			}
		}
		
		return fields;
	}
	
	public static function getMergeMetaInfo(metaData:MetadataEntry):FileInfo
	{
		var fileInfo:FileInfo = null;
		
		if (metaData.name == "merge")
		{
			if ( metaData.params == null || metaData.params.length == 0)
			{
				throw "Error: Missing path param!";
			}
			
			fileInfo = {
				path: getMetaDataParam(metaData, 0),
				type: 1 < metaData.params.length ? getMetaDataParam(metaData, 1) : "application/octet-stream"
			};
		}
		
		return fileInfo;
	}
	
	public static function getMetaDataParam(metaData:MetadataEntry, index:Int):String
	{
		return switch(metaData.params[index].expr)
		{
			case EConst(CString(param)): param;
			default: null;
		}
	}
}

typedef ConverterMap = Map<String, Map<Class<Dynamic>, String->Any>>;

typedef FileInfo = {
	var path:String;
	var type:String;
};