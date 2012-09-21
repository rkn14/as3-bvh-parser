package org.rkn14.bvh
{
	
	
	/**
	 * org.rkn14.bvh.BvhParser
	 * 21/09/2012
	 * 
	 * @author Grégory Lardon -- rkn14.com
	 * @version 1.0
	 * 
	 * 
	 * This class provides a way to parse BVH files.
	 * 
	 * call the parse method with the string content of a bvh file.
	 * 
	 * see gotoFrame, get bones, ...
	 * 
	 * 
	 */ 
	public class BvhParser
	{
		
		
		public static const HIERARCHY : String = "HIERARCHY";
		public static const BONE : String = "BONE";
		public static const BRACE_OPEN : String = "BRACE_OPEN";
		public static const BRACE_CLOSED : String = "BRACE_CLOSED";
		public static const OFFSET : String = "OFFSET";
		public static const CHANNELS : String = "CHANNELS";
		public static const END_SITE : String = "END_SITE";
		
		public static const MOTION : String = "MOTION";
		public static const FRAMES : String = "FRAMES";
		public static const FRAME_TIME : String = "FRAME_TIME";
		public static const FRAME : String = "FRAME";
		
		
		public static const BONE_TYPE_ROOT : String = "ROOT";
		public static const BONE_TYPE_JOINT : String = "JOINT";
		
		public static const PROP_X_POS : String = "Xposition";
		public static const PROP_Y_POS : String = "Yposition";
		public static const PROP_Z_POS : String = "Zposition";
		public static const PROP_X_ROTATION : String = "Xrotation";
		public static const PROP_Y_ROTATION : String = "Yrotation";
		public static const PROP_Z_ROTATION : String = "Zrotation";
		
		
		
		
		
		private var _motionLoop : Boolean;
		
		private var _currentFrame : uint = 0;
		
		private var _src : String;
		private var _lines : Vector.<BvhLine>;
		
		private var _currentLine : uint;
		private var _currentBone : BvhBone;
		
		private var _rootBone : BvhBone;
		private var _frames : Vector.<Vector.<Number>>;
		private var _nbFrames : uint;
		private var _frameTime : Number;
		
		private var _bones : Vector.<BvhBone>;
		
		
		
		
		
		
		public function BvhParser()
		{
		}
		
		
		
		
		
		public function get frameTime():Number
		{
			return _frameTime;
		}
		
		public function get framerate() : Number
		{
			return Math.round(1 / _frameTime);
		}
		
		
		/**
		 * if set to True motion will loop at end
		 */
		public function get motionLoop():Boolean
		{
			return _motionLoop;
		}
		public function set motionLoop(value:Boolean):void
		{
			_motionLoop = value;
		}
		
		
		
		
		public function toStr() : String
		{
			return _rootBone.structureToString();
		}
		
		public function get nbFrames():uint
		{
			return _nbFrames;
		}
		
		public function get bones():Vector.<BvhBone>
		{
			return _bones;
		}
		
		
		/**
		 * Parse the bvh file string
		 * then call the gotoFrame method
		 */
		public function parse(__str : String) : void
		{
			_src = __str;
			_bones = new Vector.<BvhBone>();
			_parse();
		}
		
		
		/**
		 * go to the frame at __index, update the bones position and rotation
		 */
		public function gotoFrame(__index : uint) : void
		{
			if(!_motionLoop)
			{
				if(__index >= _nbFrames)
					_currentFrame = _nbFrames-1;
				else
					_currentFrame = __index;
			}else{
				while (__index >= _nbFrames)
					__index -= _nbFrames;			
				_currentFrame = __index;
			}
			_updateFrame();
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function _updateFrame():void
		{
			
			var frame : Vector.<Number> = _frames[_currentFrame];
			
			var count : uint = 0;
			for each (var n : Number in frame)
			{				
				var bone : BvhBone = _getBoneInFrameAt(count);				
				var prop : String = _getBonePropInFrameAt(count);
				
				if(bone)
					bone[prop] = n;	
				
				count++;
			}			
		}		
		
		private function _getBonePropInFrameAt(n:Number):String
		{
			var c : uint = 0;			
			for each (var bone : BvhBone in _bones)
			{
				if (c + bone.nbChannels > n)
				{
					n -= c;
					return bone.channels[n];
				}else{
					c += bone.nbChannels;	
				}
			}
			return null;
		}
		
		private function _getBoneInFrameAt(n:Number):BvhBone
		{
			var c : uint = 0;			
			for each (var bone : BvhBone in _bones)
			{
				c += bone.nbChannels;
				if ( c > n )
					return bone;
			}
			return null;
		}		
		
		
		private function _parse():void
		{
			var linesStr : Array = _src.split("\n");
			
			// liste de BvhLines
			_lines = new Vector.<BvhLine>();			
			for each (var lineStr : String in linesStr)
			_lines.push(new BvhLine(lineStr));
			
			// creation des bones				
			_currentLine = 1;
			_rootBone = _parseBone();
			
			// parsing
			_parseFrames();
			
		}		
		
		private function _parseFrames():void
		{
			for (var currentLine : uint = 0; currentLine < _lines.length; currentLine++)
				if(_lines[currentLine].lineType == BvhParser.MOTION)
					break;
			
			currentLine++;
			_nbFrames = _lines[currentLine].nbFrames;
			currentLine++;
			_frameTime = _lines[currentLine].frameTime;
			currentLine++;
			_frames = new Vector.<Vector.<Number>>();
			for (var frameLine : int = 0; frameLine < _nbFrames; frameLine++)
			{
				_frames.push(_lines[currentLine].frames);
				currentLine++;
			}
			
			
		}
		
		private function _parseBone() : BvhBone
		{
			
			var bone : BvhBone = new BvhBone( _currentBone );
			
			_bones.push(bone);
			
			bone.name = _lines[_currentLine].boneName;
			
			// +2 OFFSET
			_currentLine++;
			_currentLine++;
			bone.offsetX = _lines[_currentLine].offsetX;
			bone.offsetY = _lines[_currentLine].offsetY;
			bone.offsetZ = _lines[_currentLine].offsetZ;
			
			// +3 CHANNELS
			_currentLine++;
			bone.nbChannels = _lines[_currentLine].nbChannels;
			bone.channels = _lines[_currentLine].channelsProps
			
			// +4 JOINT or End Site or }
			_currentLine++;
			while(_currentLine < _lines.length)
			{
				switch (_lines[_currentLine].lineType)
				{
					case BvhParser.BONE:
						var child : BvhBone = _parseBone();
						child.parent = bone;
						bone.children.push(child);
						break;
					case BvhParser.END_SITE:
						_currentLine++;
						_currentLine++;
						bone.endSite = true;
						bone.endOffsetX = _lines[_currentLine].offsetX;
						bone.endOffsetY = _lines[_currentLine].offsetY;
						bone.endOffsetZ = _lines[_currentLine].offsetZ;
						_currentLine++;
						_currentLine++;
						return bone;
						break;
					case BvhParser.BRACE_CLOSED:
						return bone;
						break;
				}
				_currentLine++;
			}
			
			// normalement on passe jamais ici
			trace("[BvhParser] warning ! should never never never pass here :(", bone.name);
			return bone;
			
			
		}		
		
		
	}
}








import org.rkn14.bvh.BvhParser;


internal class BvhLine
{
	
	
	
	
	private var _lineStr : String;
	
	private var _lineType : String;
	private var _boneType : String;
	
	private var _boneName : String;
	private var _offsetX : Number;
	private var _offsetY : Number;
	private var _offsetZ : Number;
	private var _nbChannels : uint;
	private var _channelsProps : Vector.<String>;
	private var _nbFrames : uint;
	private var _frameTime : Number;
	private var _frames : Vector.<Number>;
	
	
	
	
	
	
	
	public function toString() : String
	{
		return _lineStr;
	}
	
	
	private function _parse(__lineStr:String):void
	{
		_lineStr = __lineStr;
		_lineStr = _lineStr.replace("\t", "");
		_lineStr = _lineStr.replace("\n", "");
		_lineStr = _lineStr.replace("\r", "");			
		while (_lineStr.charAt(0) == String.fromCharCode(9) || _lineStr.charAt(0) == " ")
			_lineStr = _lineStr.substring(1, _lineStr.length);
		
		var words : Array = _lineStr.split(" ");
		
		_lineType = _parseLineType(words);
		
		switch (_lineType)
		{
			case BvhParser.HIERARCHY:
				
				break;
			case BvhParser.BONE:
				_boneType = (words[0] == "ROOT") ? BvhParser.BONE_TYPE_ROOT : BvhParser.BONE_TYPE_JOINT;
				_boneName = words[1];
				break;
			case BvhParser.OFFSET:
				_offsetX = Number(words[1]);
				_offsetY = Number(words[2]);
				_offsetZ = Number(words[3]);
				break;
			case BvhParser.CHANNELS:
				_nbChannels = Number(words[1]);
				_channelsProps = new Vector.<String>();
				for (var i:int = 0; i < _nbChannels; i++)
					_channelsProps.push(words[i+2]);
				break;
			
			case BvhParser.FRAMES:
				_nbFrames = Number(words[1]);
				break;
			case BvhParser.FRAME_TIME:
				_frameTime = Number(words[2]);
				break;
			case BvhParser.FRAME:
				_frames = new Vector.<Number>();
				for each (var word : String in words)
				_frames.push(Number(word));
				break;
			
			case BvhParser.END_SITE:
			case BvhParser.BRACE_OPEN:
			case BvhParser.BRACE_CLOSED:
			case BvhParser.MOTION:
				
				
				break;
		}
		
		
	}		
	
	private function _parseLineType(__words:Array):String
	{
		
		switch (__words[0])
		{
			case "HIERARCHY":
				return BvhParser.HIERARCHY;
				break;
			case "ROOT":
			case "JOINT":
				return BvhParser.BONE;
				break;
			case "{":
				return BvhParser.BRACE_OPEN;
				break;
			case "}":
				return BvhParser.BRACE_CLOSED;
				break;
			case "OFFSET":
				return BvhParser.OFFSET;
				break;
			case "CHANNELS":
				return BvhParser.CHANNELS;
				break;
			case "End":
				return BvhParser.END_SITE;
				break;
			case "MOTION":
				return BvhParser.MOTION;
				break;
			case "Frames:":
				return BvhParser.FRAMES;
				break;
			case "Frame":
				return BvhParser.FRAME_TIME;
				break;
		}
		
		// else
		if(!isNaN(Number(__words[0])))
			return BvhParser.FRAME;
		
		return null;
	}		
	
	
	
	
	
	
	
	
	
	public function BvhLine(__lineStr : String)
	{
		_parse(__lineStr);
	}
	
	public function get frames():Vector.<Number>
	{
		return _frames;
	}
	
	public function get frameTime():Number
	{
		return _frameTime;
	}
	
	public function get nbFrames():uint
	{
		return _nbFrames;
	}
	
	public function get channelsProps():Vector.<String>
	{
		return _channelsProps;
	}
	
	public function get nbChannels():uint
	{
		return _nbChannels;
	}
	
	public function get offsetZ():Number
	{
		return _offsetZ;
	}
	
	public function get offsetY():Number
	{
		return _offsetY;
	}
	
	public function get offsetX():Number
	{
		return _offsetX;
	}
	
	public function get boneName():String
	{
		return _boneName;
	}
	
	public function get boneType():String
	{
		return _boneType;
	}
	
	public function get lineType():String
	{
		return _lineType;
	}
	
}

