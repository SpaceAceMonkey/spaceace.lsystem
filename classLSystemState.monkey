Import mojo

Class LSystemState
	
	Field x:Float
	Field y:Float
	Field angle:Float
	Field angleModifier:Float
	Field segmentLength:Float
	Field rgb:Float[3]
	Field rgbModifiers:Float[3]
	
	Method New(_x:Float, _y:Float, _angle:Float, _rgb:Float[])
		x = _x
		y = _y
		angle = _angle
		rgb = _rgb
	End Method
End Class

