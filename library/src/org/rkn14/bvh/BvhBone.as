package org.rkn14.bvh
{
	
	
	/**
	 * org.rkn14.bvh.BvhBone
	 * 21/09/2012
	 * 
	 * @author Grégory Lardon -- rkn14.com
	 * @version 1.0
	 * 
	 * 
	 * This class represents a bone of o Bvh structure.
	 * 
	 * It has 1 parent and many children
	 * 
	 * Call structureToString to trace the bone and his children structure
	 * 
	 */ 
	public class BvhBone
	{
		
		
		private var _name : String;
		
		private var _offsetX : Number = 0;
		private var _offsetY : Number = 0;
		private var _offsetZ : Number = 0;
		
		private var _nbChannels : int;
		private var _channels : Vector.<String>;
		
		private var _endSite : Boolean = false;
		private var _endOffsetX : Number = 0;
		private var _endOffsetY : Number = 0;
		private var _endOffsetZ : Number = 0;
		
		
		private var _parent : BvhBone;
		private var _children : Vector.<BvhBone>;
		
		
		private var _Xposition : Number = 0;
		private var _Yposition : Number = 0;
		private var _Zposition : Number = 0;
		private var _Xrotation : Number = 0;
		private var _Yrotation : Number = 0;
		private var _Zrotation : Number = 0;
		
		
		
		public function BvhBone(__parent : BvhBone = null) 
		{
			_parent = __parent;
			_channels = new Vector.<String>();
			_children = new Vector.<BvhBone>();
		}
		
		
		
		

		public function toString() : String
		{
			return "[BvhBone] " + _name;
		}
		public function structureToString(__indent : uint = 0) : String
		{
			var res : String = "";
			for (var i : int = 0; i < __indent; i++)
				res += "=";
			
			res = res + "> " + _name + "  " + _offsetX + " " + _offsetY+ " " + _offsetZ + "\n";
			for each (var child : BvhBone in _children)
			res += child.structureToString(__indent+1);
			
			return res;
		}
		
		
		
		
		
		
		
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get isRoot():Boolean
		{
			return (_parent == null);
		}
		
		
		
		
		public function get children():Vector.<BvhBone>
		{
			return _children;
		}
		public function set children(value:Vector.<BvhBone>):void
		{
			_children = value;
		}
		
		public function get parent():BvhBone
		{
			return _parent;
		}
		public function set parent(value:BvhBone):void
		{
			_parent = value;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		public function get Zrotation():Number
		{
			return _Zrotation;
		}
		public function set Zrotation(value:Number):void
		{
			_Zrotation = value;
		}

		public function get Yrotation():Number
		{
			return _Yrotation;
		}
		public function set Yrotation(value:Number):void
		{
			_Yrotation = value;
		}

		public function get Xrotation():Number
		{
			return _Xrotation;
		}
		public function set Xrotation(value:Number):void
		{
			_Xrotation = value;
		}
		
		

		public function get Zposition():Number
		{
			return _Zposition;
		}
		public function set Zposition(value:Number):void
		{
			_Zposition = value;
		}

		public function get Yposition():Number
		{
			return _Yposition;
		}
		public function set Yposition(value:Number):void
		{
			_Yposition = value;
		}

		public function get Xposition():Number
		{
			return _Xposition;
		}
		public function set Xposition(value:Number):void
		{
			_Xposition = value;
		}

		

		
		
		
		
		public function get endSite():Boolean
		{
			return _endSite;
		}
		public function set endSite(value:Boolean):void
		{
			_endSite = value;
		}
		
		

		public function get endOffsetZ():Number
		{
			return _endOffsetZ;
		}
		public function set endOffsetZ(value:Number):void
		{
			_endOffsetZ = value;
		}

		public function get endOffsetY():Number
		{
			return _endOffsetY;
		}
		public function set endOffsetY(value:Number):void
		{
			_endOffsetY = value;
		}

		public function get endOffsetX():Number
		{
			return _endOffsetX;
		}
		public function set endOffsetX(value:Number):void
		{
			_endOffsetX = value;
		}
		
		
		
		

		public function get channels():Vector.<String>
		{
			return _channels;
		}
		public function set channels(value:Vector.<String>):void
		{
			_channels = value;
		}

		public function get nbChannels():int
		{
			return _nbChannels;
		}
		public function set nbChannels(value:int):void
		{
			_nbChannels = value;
		}
		
		
		
		

		public function get offsetZ():Number
		{
			return _offsetZ;
		}
		public function set offsetZ(value:Number):void
		{
			_offsetZ = value;
		}

		public function get offsetY():Number
		{
			return _offsetY;
		}
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}

		public function get offsetX():Number
		{
			return _offsetX;
		}
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}



	

	}
}