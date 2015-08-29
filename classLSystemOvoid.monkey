Strict

Import mojo
Import classLSystem
Import classLSystemSegmentOvoid
Import classLSystemState
Import monkey.math

Class LSystemOvoid Extends LSystem
	Field radX:Float
	Field radY:Float
	Field warpRadii:Bool

	Method New()
		Create()
	End
	
	Method Create:Void()
		Create(0.0)
	End Method

	Method Create:Void(_startx:Float)
		Create(_startx, 0.0)
	End Method
	
	Method Create:Void(_startx:Float, _starty:Float)
		Create(_startx, _starty, -90.0)
	End Method
	
	Method Create:Void(_startx:Float, _starty:Float, _startAngle:Float)
		Create(_startx, _starty, _startAngle, 40.0)
	End Method
	
	Method Create:Void(_startx:Float, _starty:Float, _startAngle:Float, _segmentLength:Float)
		Create(_startx, _starty, _startAngle, _segmentLength, 2)
	End Method
	
	' RadX and radY are the x- and y-radius of the oval used to draw each segment of the curve.
	' warpRadii tells the LSystem executor whether (True) or not (False) to stretch the oval based on the current angle.
	Method Create:Void(_startx:Float, _starty:Float, _startAngle:Float, _segmentLength:Float, _iterations:Int)
		Super.Create(_startx, _starty, _startAngle, _segmentLength, _iterations)
		radX = segmentLength
		radY = segmentLength
		warpRadii = False
		'Note: Question: Should I store calculated value (modified by warpRadii,
		' for example), or should I store the raw value, and calculate 
		' manipulations on retrieval?
		startingSegment = New LSystemSegmentOvoid(x, y, False, angle, RadX, RadY, rgb[0 .. 3])
	End Method
	
	Method RadX:Void(_value:Float) Property
		radX = _value
	End

	'Note: Feature - Make warpRadii more flexible. Instead of hardcoding a limit
	' of 1/2 segmentLength for the maximum radius, and radX/radY for the minimum
	' radius, let users decide how much warp to allow in each direction.
	Method RadX:Float() Property
		If (warpRadii)
			Return math.Max(radX, math.Abs( (segmentLength / 2) * math.Sin(angle)))
		EndIf
		Return radX
	End
				
	Method RadY:Void(_value:Float) Property
		radY = _value
	End
			
	Method RadY:Float() Property
		If (warpRadii)
			Return math.Max(radY, math.Abs( (segmentLength / 2) * math.Cos(angle)))
		EndIf
		Return radY
	End
				
	' Call to advance the L-System to the next step
	Method Iterate:Void()
		' I had some other stuff going on in here. We can probably just
		' remove this overriding method, now, but I am leaving it in case
		' I want to put back any of the logic I previously had in here.
		Super.Iterate()
	End Method

	
	' Ugh, I'd been avoiding overriding anything I don't absolutely have to,
	' but it was getting to be a hassle dealing with an array full of segments
	' created by the Super class. LSystem uses the base segment class, and
	' we're playing with ovoids, around here.
	Method ProcessDrawRules:Void(_rule:String)
		Local tmpSegment:LSystemSegmentOvoid = New LSystemSegmentOvoid()
		tmpSegment.x = x
		tmpSegment.y = y
		tmpSegment.angle = angle Mod 360
		tmpSegment.visible = drawRules.Get(_rule)
		tmpSegment.rgb = rgb[0 .. 3]
		tmpSegment.radX = RadX
		tmpSegment.radY = RadY
		x = x - (segmentLength * math.Sin(angle))
		y = y - (segmentLength * math.Cos(angle))
		bounds.X = x
		bounds.Y = y
		segments[segmentInsertIndex] = tmpSegment
		segmentInsertIndex += 1
	End
	
	Method Draw:Void()
		Local target:Int = segmentInsertIndex
		If (chunkSize > 0 And segmentStackPosition < segmentInsertIndex)
			target = math.Min(target, segmentStackPosition + chunkSize)
		EndIf
		For Local i:Int = 0 To target - 1
			Local segment:LSystemSegment = segments[i]
			If (segment.visible)
				SetColor(segment.rgb[0], segment.rgb[1], segment.rgb[2])
				DrawOval(segment.x, segment.y, LSystemSegmentOvoid(segment).radX, LSystemSegmentOvoid(segment).radY)
			EndIf
		Next
		segmentStackPosition += chunkSize
	End Method

	Method PushState:Void()
		stateStack.Push(New LSystemState(x, y, angle, rgb))
	End
			
	Method PopState:Void(_x:Bool, _y:Bool, _angle:Bool, _rgb:Bool)
		previousStatePop = stateStack.Pop()
		If (_x)
			x = previousStatePop.x
		EndIf
		If (_y)
			y = previousStatePop.y
		EndIf
		If (_angle)
			angle = previousStatePop.angle
		EndIf
		If (_rgb)
			rgb = previousStatePop.rgb
		EndIf
	End
			
End Class
