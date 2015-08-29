Strict

Import monkey.math

Class Bounds
	Field x1:Float
	Field x2:Float
	Field y1:Float
	Field y2:Float
	' This flag tells us whether this object has been initialized with real values.
	' "Real" in this case means "using New(Float, Float, Float, Float)." We can't
	' stop someone from using garbage values when creating the Bounds object, but
	' this is sufficient for our purposes.
	Field dirty:Bool
	' Dirty tells us if _something_ has been set. Complete is only set to True
	' when a DryRun() has been executed, or the entire curve has been iterated
	' through. Well, that's how it is in my code. Be careful if you change that.
	Field complete:Bool
	
	Method New()
		dirty = True
		complete = False
	End
	
	Method New(_x1:Float, _y1:Float, _x2:Float, _y2:Float)
		x1 = _x1
		x2 = _x2
		y1 = _y1
		y2 = _y2
	End
	
	' This is why the dirty flag exists. Imagine x1 were left uninitialized (0), 
	' but the curve contains no segments with an x under 0. In that case, the
	' curve's x would never be less than x1, so x1 would never be set to the actual
	' value of a segment's x-coordinate.
	'
	' If this object is dirty, we store the first value we receive, otherwise, we
	' use the normal criteria.
	Method X:Void(_value:Float) Property
		If Not (dirty)
			x1 = math.Min(x1, _value)
			x2 = math.Max(x2, _value)
		Else
			x1 = _value
			x2 = _value
			dirty = False
		EndIf
	End
	Method Y:Void(_value:Float) Property
		If Not (dirty)
			y1 = math.Min(y1, _value)
			y2 = math.Max(y2, _value)
		Else
			y1 = _value
			y2 = _value
			dirty = False
		End
	End
	Method Width:Float() Property
		Return math.Abs(x1 - x2)
	End
	Method Height:Float() Property
		Return math.Abs(y1 - y2)
	End
	Method MidPoint:Float[] () Property
		Local midpoint:Float[2]
		midpoint[0] = x1 + Width() / 2.0
		midpoint[1] = y1 + Height() / 2.0
		
		Return midpoint
	End
End