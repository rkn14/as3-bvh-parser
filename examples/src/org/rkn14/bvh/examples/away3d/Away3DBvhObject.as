package org.rkn14.bvh.examples.away3d	
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.math.Quaternion;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.SoftShadowMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SphereGeometry;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Cubic;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.flash_proxy;
	
	import org.rkn14.bvh.BvhBone;
	import org.rkn14.bvh.BvhParser;
	
	
	
	public class Away3DBvhObject extends ObjectContainer3D
	{
		
		
		
		
		// STATIC VARS
		public static const DEFAULT_NODE_COLOR : Number = 0xFF0000;		
		public static const DEFAULT_NODE_HEAD_COLOR : Number = 0x00FF00;		
		public static const DEFAULT_JOINT_COLOR : Number = 0xFFFF00;
		
		
		public static var NODE_RADIUS : Number = 4;		
		public static var NODE_HEAD_RADIUS : Number = 50;		
		public static var JOINT_THICKNESS : Number = 6;		
		public static var DEFAULT_BVH_SCALE : Number = 5;
		
		
		public static var NODE_MATERIAL : MaterialBase = new ColorMaterial(DEFAULT_NODE_COLOR);
		public static var NODE_HEAD_MATERIAL : MaterialBase = new ColorMaterial(DEFAULT_NODE_HEAD_COLOR);
		public static var JOINT_MATERIAL : MaterialBase = new ColorMaterial(DEFAULT_JOINT_COLOR);
		
		

		public function get headNode3D():BvhNode3D
		{
			return _headNode3D;
		}

		public static function setMaterials(__nodeMaterial : MaterialBase, __nodeHeadMaterial : MaterialBase, __jointMaterial : MaterialBase, __lightPicker : StaticLightPicker) : void
		{
			_lightPicker = __lightPicker;
			
			NODE_MATERIAL = __nodeMaterial;		
			NODE_HEAD_MATERIAL = __nodeHeadMaterial;
			JOINT_MATERIAL = __jointMaterial;
			
			__nodeMaterial.lightPicker = _lightPicker;
			__nodeHeadMaterial.lightPicker = _lightPicker;
			__jointMaterial.lightPicker = _lightPicker;

		}
		
		
		
		
		
		
		
		// PRIVATE VARS
		
		private var _bvhStr : String;
		
		private var _bvh : BvhParser;
		
		private var _bones : Vector.<BvhNode3D>;
		
		private var _bvhScale : Number = DEFAULT_BVH_SCALE;		
		
		private var _currentFrame:uint;
		
		private var _headNode3D : BvhNode3D;
		private static var _lightPicker:StaticLightPicker;

		
		
		
		
		
		
		
		public function Away3DBvhObject(__bvhStr : String)
		{
			super();
			_bvhStr = __bvhStr;
			_build();
		}
		
		
		
		public function kill():void
		{
			_bvh = null;
			while(numChildren > 0)
				removeChild(getChildAt(0));
			_bones = null;
		}
		
		
		
		
		
		public function get frameTime() : Number
		{
			return _bvh.frameTime;
		}
		
		public function get framerate() : Number
		{
			return _bvh.framerate;
		}
		
		
		
		public function get bvhScale():Number
		{
			return _bvhScale;
		}
		public function set bvhScale(value:Number):void
		{
			_bvhScale = value;
		}

		
		
		
		public function gotoFrame(__frame : uint) : void
		{
			_currentFrame = __frame;
			_bvh.gotoFrame(__frame);
			_updateFrame();
		}
		
		public function easeToFrame(__frame : uint, __duration : Number, __ease : Function, __onComplete : Function) : void
		{
			_bvh.gotoFrame(__frame);
			_easeToFrame(__frame, __duration, __ease, __onComplete);
		}
		
		
		
		
		
		public function get nbFrames():uint
		{
			return _bvh.nbFrames;
		}
		
		public function get currentFrame() : uint
		{
			return _currentFrame;
		}
		
		
		public function get bones() : Vector.<BvhNode3D>
		{
			return _bones;
		}
		
		

		
		
		
		
		
		
		
		
		
		
		
		private function _build():void
		{
			_bvh = new BvhParser();
			_bvh.parse(_bvhStr);
			 
			_bvh.motionLoop = false;
			
			var bone3D : BvhNode3D;
			var bone : BvhBone;
			
			_bones = new Vector.<BvhNode3D>();
			for each (bone in _bvh.bones)
			{
				bone3D = new BvhNode3D(bone.name == "Head");
				bone3D.name = bone.name;
				_bones.push(bone3D);
			}
			
			// addchilds
			for each (bone in _bvh.bones)
			{
				bone3D = getBoneByName(bone.name);
				if(bone.isRoot)
				{
					addChild(bone3D);
				}else{
					var parent : BvhNode3D = getBoneByName(bone.parent.name);
					parent.addBoneChild(bone3D);
					if(bone.endSite)
						bone3D.addEndSite();
				}
			}
			
		}
		
		

		
		
		
		public function getBoneByName(__name:String):BvhNode3D
		{
			for each (var bone3D : BvhNode3D in _bones)
			{
				if (bone3D.name == __name)
					return bone3D;
			}
			return null;
		}
		
		
		private function _updateFrame() : void
		{
			
			for (var i : uint = 0; i < _bvh.bones.length; i++)
			{
				var bone : BvhBone = _bvh.bones[i];
				var bone3D : BvhNode3D = _bones[i];
				
				if(bone3D.parent != this)
				{
					bone3D.x = (bone.offsetX + bone.Xposition) * bvhScale;
					bone3D.y = (bone.offsetY + bone.Yposition) * bvhScale;
					bone3D.z = (bone.offsetZ + bone.Zposition) * bvhScale;
				}else{
					bone3D.x = (bone.Xposition) * bvhScale;
					bone3D.y = (bone.Yposition) * bvhScale;
					bone3D.z = (bone.Zposition) * bvhScale;
				}
				

				
				// apply rotations :  Y / X / Z
				bone3D.rotationX = 0;
				bone3D.rotationY = 0;
				bone3D.rotationZ = 0;
				
				for each (var channel : String in bone.channels)
				{
					switch (channel)
					{
						case BvhParser.PROP_X_ROTATION:
							bone3D.pitch(bone.Xrotation);	
							break;
						case BvhParser.PROP_Y_ROTATION:
							bone3D.yaw(bone.Yrotation);
							break;
						case BvhParser.PROP_Z_ROTATION:
							bone3D.roll(bone.Zrotation);	
							break;
					}
				}
				
				
					
				
				
				if(bone.endSite)
				{
					bone3D.endOffsetX = bone.endOffsetX;
					bone3D.endOffsetY = bone.endOffsetY;
					bone3D.endOffsetZ = bone.endOffsetZ;
				}

			}
			
			// update joints
			for each (bone3D in _bones)
			{
				bone3D.drawJoints();
				bone3D.drawEndSite();
			}
			
		}
		
		
		private function _easeToFrame(__frame : uint, __duration : Number, __ease : Function, __onComplete : Function) : void
		{
			for (var i : uint = 0; i < _bvh.bones.length; i++)
			{
				var bone : BvhBone = _bvh.bones[i];
				var bone3D : BvhNode3D = _bones[i];
				var props : Object = {};
				
				if(bone3D.parent != this)
				{
					props.x = (bone.offsetX + bone.Xposition) * bvhScale;
					props.y = (bone.offsetY + bone.Yposition) * bvhScale;
					props.z = (bone.offsetZ + bone.Zposition) * bvhScale;
				}else{
					props.x = (bone.Xposition) * bvhScale;
					props.y = (bone.Yposition) * bvhScale;
					props.z = (bone.Zposition) * bvhScale;
				}
				
				props.rotationX = bone.Xrotation;
				props.rotationY = bone.Yrotation;
				props.rotationZ = bone.Zrotation;
				
				props.ease = __ease;
				props.onComplete = __onComplete;
				
				TweenMax.to(bone3D, __duration, props);
				
			}			
		}
		
		
		
	}
}





import away3d.containers.ObjectContainer3D;
import away3d.core.math.Quaternion;
import away3d.core.math.Vector3DUtils;
import away3d.entities.Mesh;
import away3d.entities.SegmentSet;
import away3d.materials.ColorMaterial;
import away3d.primitives.CubeGeometry;
import away3d.primitives.CylinderGeometry;
import away3d.primitives.LineSegment;
import away3d.primitives.SphereGeometry;

import flash.geom.Vector3D;

import org.rkn14.bvh.examples.away3d.Away3DBvhObject;




internal class BvhNode3D extends ObjectContainer3D
{
	
	
	private const DEFAULT_END_SITE_HEIGHT : Number = 50;
	
	
	private var _node : ObjectContainer3D;
	private var _childrenNodesContainer : ObjectContainer3D;
	private var _cylindersContainer : ObjectContainer3D;
	
	private var _cylinders : Vector.<Mesh>;
	private var _isHead:Boolean;
	
	private var _endSiteCylinder : Mesh;
	private var _endOffsetX:Number;
	private var _endOffsetY:Number;
	private var _endOffsetZ:Number;
	
	private var _endSiteDefaultHeight : Number;
	
	
	 
	public function BvhNode3D(__isHead : Boolean, __endSiteDefaultHeight : Number = DEFAULT_END_SITE_HEIGHT) 
	{
		super();
		
		_isHead = __isHead;
		_endSiteDefaultHeight = __endSiteDefaultHeight;
		
		_cylinders = new Vector.<Mesh>();
		
		_node = _createNode();		
		_childrenNodesContainer = new ObjectContainer3D();
		_cylindersContainer = new ObjectContainer3D();
		
		addChild(_node);
		addChild(_childrenNodesContainer);
		addChild(_cylindersContainer);
		
	}
	
	
	
	
	
	public function get isHead():Boolean
	{
		return _isHead;
	}

	public function set endOffsetX(value:Number):void
	{
		_endOffsetX = value;
	}
	public function set endOffsetY(value:Number):void
	{
		_endOffsetY = value;
	}
	public function set endOffsetZ(value:Number):void
	{
		_endOffsetZ = value;
	}
	
	
	
	

	public function addBoneChild(__bone3D:BvhNode3D):void
	{
		_addJoint();
		_childrenNodesContainer.addChild(__bone3D);
	}
	
	public function addEndSite() : void
	{
		var cylG : CylinderGeometry = new CylinderGeometry(10, 10, 100);
		cylG.yUp = false;
		_endSiteCylinder = new Mesh(cylG, Away3DBvhObject.JOINT_MATERIAL);
		_endSiteCylinder.castsShadows = true;
		
		addChild(_endSiteCylinder);
	}
		
	
	public function drawJoints() : void
	{
		for (var i : int = 0; i < _childrenNodesContainer.numChildren; i++)
		{
			var child : ObjectContainer3D = _childrenNodesContainer.getChildAt(i);

			// cylinders
			var cylMesh : Mesh = _cylinders[i];
			var geom : CylinderGeometry = cylMesh.geometry as CylinderGeometry;
			
			geom.height = Vector3D.distance(new Vector3D(), child.position);
			
			cylMesh.lookAt(child.position);
			
			cylMesh.position = new Vector3D(0,0,0);
			cylMesh.moveForward(geom.height/2);			
		}	
	}
	
	public function drawEndSite() : void
	{
		if(_endSiteCylinder == null)
			return;
			
		var endSiteVector : Vector3D = new Vector3D(_endOffsetX, _endOffsetY, _endOffsetZ); 
		
		var geom : CylinderGeometry = _endSiteCylinder.geometry as CylinderGeometry;
		geom.height = _endSiteDefaultHeight;
		
		
		
		_endSiteCylinder.position = new Vector3D(0,0,0);
		_endSiteCylinder.lookAt(endSiteVector);
		_endSiteCylinder.moveForward(geom.height/2);			
		
	}
	
	
	
	
	private function _addJoint():void
	{
		// cylinder
		var cylG : CylinderGeometry = new CylinderGeometry(10, 10, 100);
		cylG.yUp = false;
		var mesh : Mesh = new Mesh(cylG, Away3DBvhObject.JOINT_MATERIAL);
		mesh.castsShadows = true;
		
		_cylindersContainer.addChild(mesh);
		_cylinders.push(mesh);
	}
	
	
	
	
	
	
	private function _createNode() : ObjectContainer3D
	{
		var cube : SphereGeometry = new SphereGeometry(_isHead ? Away3DBvhObject.NODE_HEAD_RADIUS : Away3DBvhObject.NODE_RADIUS);
		var mesh : Mesh = new Mesh(cube, _isHead ? Away3DBvhObject.NODE_HEAD_MATERIAL : Away3DBvhObject.NODE_MATERIAL);
		mesh.castsShadows = true;
		return mesh;	
	}
	
	
}







