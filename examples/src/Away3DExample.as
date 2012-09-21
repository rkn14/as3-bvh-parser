package
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import org.rkn14.bvh.examples.away3d.Away3DBvhObject;
	
	
	[SWF(frameRate="60", width="800", height="600")]
	public class Away3DExample extends Sprite
	{
		
		[Embed(source="../assets/14_01.bvh", mimeType="application/octet-stream")]
		private const BVH_FILE : Class;
		
		
		private var _scene : Scene3D;
		private var _view : View3D;
		private var _lightPicker : StaticLightPicker;
		
		
		private var _bvh3D : Away3DBvhObject;
		
		
		
		
		
		public function Away3DExample()
		{
			super();
			
			_build();
			_loadBvh();
			
			addEventListener(Event.ENTER_FRAME, _handler_EnterFrame);
		}
		
		
		
		
		
		
		private function _loadBvh():void
		{			
			Away3DBvhObject.NODE_RADIUS = 15;					
			Away3DBvhObject.NODE_HEAD_RADIUS = 15;				
			Away3DBvhObject.JOINT_THICKNESS = 3;						
			Away3DBvhObject.DEFAULT_BVH_SCALE = 20;					
			
			Away3DBvhObject.setMaterials(
				new ColorMaterial(0x999900),
				new ColorMaterial(0xEE3300),
				new ColorMaterial(0xDDAA87),
				_lightPicker				
			);
			
			var bytes : ByteArray = new BVH_FILE() as ByteArray;
			var bvhString : String = bytes.readUTFBytes(bytes.length);
			
			_bvh3D = new Away3DBvhObject(bvhString);
			_scene.addChild(_bvh3D);	
		}		
		
		
		
		
		
		private function _render():void
		{
			var coeff : int = 2;
			
			var nextFrame : uint = _bvh3D.currentFrame + coeff;
			if(nextFrame >= _bvh3D.nbFrames)
				nextFrame = 0;
			_bvh3D.gotoFrame(nextFrame);
			
			_view.render();
		}		
		
		
		
		
		
		private function _build() : void
		{
			
			_scene = new Scene3D();
			_view = new View3D(_scene);
			_view.width = 800;
			_view.height = 600;			
			_view.antiAlias = 2;
			addChild(_view);
						
			
			_view.camera.lens.far = 1000000;			
			_view.camera.y = 300;
			_view.camera.z = -1000;
			_view.camera.lookAt(new Vector3D(0,250,0)); 

			_createLights();
			_createGround();
			
			
		}
		
	
		
		
		
		
		
		
		
		
		
		
		
		
		protected function _handler_EnterFrame(event:Event):void
		{
			_render();
		}		
		
		
		
		private function _createLights():void
		{
			var lights : Array = [];
			
			// devant
			var light1 : PointLight = new PointLight();
			light1.y = 2000;
			light1.z = -2000;
			_scene.addChild(light1);
			lights.push(light1);
			
			// derriere
			var light2 : PointLight = new PointLight();
			light2.y = 2000;
			light2.z = 2000;
			_scene.addChild(light2);
			lights.push(light2);
			
			// dessus
			var light3 : PointLight = new PointLight();
			light3.y = 3000;				
			_scene.addChild(light3);
			lights.push(light3);
			
			_lightPicker = new StaticLightPicker(lights);
			
		}
		
		
		private function _createGround() : void
		{
			var groundMaterial : ColorMaterial = new ColorMaterial(0x666666);
			groundMaterial.ambient = 0.5;
			groundMaterial.bothSides = true;			
			
			var ground : PlaneGeometry = new PlaneGeometry(10000, 10000);
			var mesh : Mesh = new Mesh(ground, groundMaterial);
			mesh.rotationY = 45;
			mesh.castsShadows = true;
			_scene.addChild(mesh);
		}
		
		
	
		
		

		
	}
}