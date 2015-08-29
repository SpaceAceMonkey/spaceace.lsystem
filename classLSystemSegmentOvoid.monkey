Import classLSystemSegment

Class LSystemSegmentOvoid Extends LSystemSegment
	Field radX:Float
	Field radY:Float
	
	Method New(_x:Float, _y:Float, _visible:Bool, _angle:Float, _radX:Float, _radY:Float, _rgb:Float[])
		Super.New(_x, _y, _visible, _angle, _rgb)
		radX = _radX
		radY = _radY
	End
End