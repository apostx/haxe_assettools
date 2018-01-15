package apostx.sample.asset;
import apostx.asset.IAssetContainer;
import haxe.io.Bytes;

class AssetContainer implements IAssetContainer
{
	public function new() {}
	
	@merge("apostx/sample/asset/test_asset.json", "text/plain")
	public var data:String;
	
	@merge("apostx/sample/asset/test_asset.json", "application/json")
	public var data2:Dynamic;
	
	@merge("apostx/sample/asset/test_asset.json", "application/octet-stream")
	public var data3:String;
}