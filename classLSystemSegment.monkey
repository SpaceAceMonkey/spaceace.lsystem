Class LSystemSegment
	Field x:Float
	Field y:Float
	Field visible:Bool
	Field angle:Float
	Field rgb:Float[]
	
	Method New(_x:Float, _y:Float, _visible:Bool, _angle:Float, _rgb:Float[])
		x = _x
		y = _y
		visible = _visible
		angle = _angle
		rgb = _rgb
	End
	
	Method Clone:LSystemSegment()
		Local clone:LSystemSegment = New LSystemSegment()
		clone.x = x
		clone.y = y
		clone.visible = visible
		clone.angle = angle
		clone.rgb = rgb[0 .. 3]
		
		Return clone
	End
End