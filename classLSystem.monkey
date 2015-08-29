Strict

Import mojo
Import classLSystemSegment
Import classLSystemState
Import classBounds

'Note: Question: Why bother storing invisible segments?
' Is there ever going to be a time where someone will want
' to turn invisible segments into visible ones? Not storing
' them at all would reduce the size of the segments stack.
' Is there enough benefit there to worry about?

'Note: Optimization: Scoping is a mess. Make Private those
' things that should require accessors.

Class LSystem
	'
	' Scoping and accessors are a bit of a mess, at the moment. In general,
	' you should probably use the accessor methods I've provided, as many
	' of them perform fairly critical tasks. I name accessors the same way
	' I name fields, but with a capitalized first letter. So, field "x" is
	' accessed by method "X()" or property "X"
	'
	' Length of each line segment in the L-System
	Field segmentLength:Float = 10.0
	' How many iterations of the L-System to execute
	Field iterations:Int = 2

	' Rules
	' A "rule" consists of a single letter or symbol that tells the L-System what action to take.
	' For example, it is common for the letter "F" to be used to represent the command to "draw a 
	' line segment." It is also common for "+" to mean "turn left," and "-" to mean "turn right."
	'
	' [, ], (, ), and ! are reserved for internal use. See ProcessRules() for details.
	' I dont feel like writing try/catch blocks for this, right now. If you assign these symbols
	' to draw/turn/color rules, silly things might happen.
	'
	' When assigning a single rule to more than one function, actions are processed in this
	' order:
	' Color commands
	' Turning commands
	' Drawing commands
	'
	' StringMap mapping rules to their translations
	Field ruleMap:StringMap<String>
	' Contains the seed string that is used to generate the rules string.
	Field axiom:String
	' String containing the actual rules to be used for creating the system. This
	' variable is modified on each iteration of the system.
	Field rules:String
	
	' Pretty self-explanatory, I think.
	Field x:Float = 0.0
	Field y:Float = 0.0
	Field angle:Float = 0.0
	Field currentIteration:Int = 0

	' Added to the rules before the current iteration is executed
	Field preIterate:String = ""
	' Added to the rules after the current iteration is executed
	Field postIterate:String = ""

	' This is used to easily flip the sign of the angle. Note that this does not
	' necessarily reverse the direction of drawing, as +x degrees and -x degrees 
	' usually won't be on exact opposite sides of a 360 degree circle.
	Field angleSign:Int = 1
	
	' Maps single-letter rules to the "draw" function.
	Field drawRules:StringMap<Bool>
	' Maps single-letter rules to the "turn" function.
	Field turnRules:StringMap<Float>
	' Maps single-letter rules to the color-manipulation function.
	Field colorRules:StringMap<Float[] >
	
	' Contains red, green, and blue values for drawing the L-System line segments.
	' Index 0 = red, index 1 = green, index 2 = blue
	Field rgb:Float[3]
	' Defines the minimum value for each of the indexes in rgb. These default to 0, 0, 0.
	Field rgbMins:Float[3]
	' Defines the maximum value for each of the indexes in rgb. These default to 255, 255, 255.
	Field rgbMaxes:Float[3]
		
	' Holds the segment objects used for storing pieces of the curve.
	'Note: Question: Is an array the way to go, here?
	' I've been through Stack and List, already, and both have upsides
	' and downsides. Extensive benchmarking suggests this is the right
	' solution, especially since I will be editing the data once it is
	' in the array.
	Field segments:LSystemSegment[]
	' This goes with segments to track the index of the last draw rule
	' inserted into the array. We'll use this to fake pushing values
	' onto the array.
	Field segmentInsertIndex:Int
	
	' Stores the starting parameters for the L-System
	Field startingSegment:LSystemSegment
	
	' Draw the curve in "chunks" (True) or one segment at a time (False)
	Field chunkSize:Int
	
	' Z-index for sorting the draw order of curves. This has no built-in use
	' inside the LSystem class. You will have to implement it from wherever
	' are calling the Draw() method.
	Field zIndex:Int
	
	Field stateStack:Stack<LSystemState>
	Field previousStatePop:LSystemState
	Field segmentStackPosition:Int = 0
	Field bounds:Bounds
	Field debugDrawing:Bool
	
	Field dummy:LSystemSegment[]
				
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
	
	Method Create:Void(_startx:Float, _starty:Float, _startAngle:Float, _segmentLength:Float, _iterations:Int)
		chunkSize = 0
		rules = axiom
		x = _startx
		y = _starty
		angle = _startAngle
		segmentLength = _segmentLength
		iterations = _iterations
		ruleMap = New StringMap<String>
		drawRules = New StringMap<Bool>
		turnRules = New StringMap<Float>
		colorRules = New StringMap<Float[] >
		rgb =[0.0, 0.0, 0.0]
		rgbMins =[0.0, 0.0, 0.0]
		rgbMaxes =[255.0, 255.0, 255.0]
		startingSegment = New LSystemSegment(x, y, False, angle, rgb[0 .. 3])
		stateStack = New Stack<LSystemState>
		bounds = New Bounds(x, x, y, y)
		debugDrawing = False
		zIndex = 0
	End Method

	' This is a little sloppy, but it works when you want to set a new starting point
	' without creating a new object. This code does no sanity checks, so be sure
	' startingSegment exists before calling this method.
	Method StorestartingSegment:Void()
		startingSegment.x = x
		startingSegment.y = y
		startingSegment.angle = angle
		startingSegment.rgb = rgb[0 .. 3]
	End
	
	#rem
		The xxxTranslationRules methods manipulate the rules for mapping single-letter inputs to
		their desired outputs.
	#END
	Method ClearTranslationRules:Void()
		ruleMap.Clear()
	End

	Method RemoveTranslationRule:Void(_rule:String)
		If (ruleMap.Contains(_rule))
			ruleMap.Remove(_rule)
		EndIf
	End

	' Maps single characters to their transforms.
	' Example: AddTranslationRule("a", "a+b+b+a")
	' The above usage causes the letter "a" in the rule string to be replaced with "a+b+b+a" on each
	' iteration of the L-System.
	Method AddTranslationRule:Void(_rule:String, _translation:String)
		If Not (ruleMap.Contains(_rule))
			ruleMap.Add(_rule, _translation)
		Else
			UpdateTranslationRule(_rule, _translation)
		EndIf
	End
	
	Method UpdateTranslationRule:Void(_rule:String, _translation:String)
		ruleMap.Set(_rule, _translation)
	End

	#rem
		The xxxDrawRules methods manipulate the rules for mapping single-letter inputs to
		drawing functions.
	#END
	Method ClearDrawRules:Void()
		drawRules.Clear()
	End

	Method RemoveDrawRule:Void(_rule:String)
		If (drawRules.Contains(_rule))
			drawRules.Remove(_rule)
		EndIf
	End

	' Add a rule to tell the system to move the pen. A value of "true" attached to the rule will
	' cause a line segment to be drawn. A value of "false" attached to the rule will cause the
	' pen to move without drawing a line segment.
	'
	' Examples:
	' AddDrawRule("a", false)
	' AddDrawRule("f", true)
	'
	' If you set the rules as above, an "a" in the rule string will cause the pen to move without
	' drawing, while "f" will create a line segment.
	Method AddDrawRule:Void(_rule:String, _draw:Bool)
		If Not (drawRules.Contains(_rule))
			drawRules.Add(_rule, _draw)
		Else
			UpdateDrawRule(_rule, _draw)
		EndIf
	End
	
	Method UpdateDrawRule:Void(_rule:String, _draw:Bool)
		drawRules.Set(_rule, _draw)
	End

	#rem
		The xxxTurnRules methods manipulate the rules for mapping single-letter inputs to
		turning functions.
	#END
	Method ClearTurnRules:Void()
		turnRules.Clear()
	End

	Method RemoveTurnRule:Void(_rule:String)
		If (turnRules.Contains(_rule))
			turnRules.Remove(_rule)
		EndIf
	End
		
	' Add a rule mapping that tells the L-System to change the current drawing angle.
	'
	' Examples:
	' AddTurnRule("+", 90)
	' AddTurnRule("-", -90)
	'
	' Using the above mappings, a "+" in the rule string will turn the current drawing angle by 90 degrees 
	' positive. A "-" in the rule string will rotate the current drawing angle by 90 degrees negative.
	Method AddTurnRule:Void(_rule:String, _angle:Float)
		If Not (turnRules.Contains(_rule))
			turnRules.Add(_rule, _angle)
		Else
			UpdateTurnRule(_rule, _angle)
		EndIf
	End
	
	Method UpdateTurnRule:Void(_rule:String, _angle:Float)
		turnRules.Set(_rule, _angle)
	End

	#rem
		The xxxTurnRules methods manipulate the rules for mapping single-letter inputs to
		color functions.
	#END
	Method ClearColorRules:Void()
		colorRules.Clear()
	End

	Method RemoveColorRule:Void(_rule:String)
		If (colorRules.Contains(_rule))
			colorRules.Remove(_rule)
		EndIf
	End
		
	' Add a rule to change the red, green, and blue color values.
	'
	' Examples:
	' AddColorRule("#", [0.0, 1.0, -0.5])
	'
	' The above rule mapping will cause the green value for the current line segment to be increates by 1.0
	' when a "#" is encountered in the rule string. At the same time, the blue value for the current segment
	' will be reduced by 0.5.
	Method AddColorRule:Void(_rule:String, _modifiers:Float[])
		If Not (colorRules.Contains(_rule))
			colorRules.Add(_rule, _modifiers)
		Else
			UpdateColorRule(_rule, _modifiers)
		Print colorRules.Get(_rule)[0] + ", " + colorRules.Get(_rule)[1] + ", " + colorRules.Get(_rule)[2]
		EndIf
	End
	
	Method UpdateColorRule:Void(_rule:String, _modifiers:Float[])
		colorRules.Set(_rule, _modifiers)
	End

	' Call to advance the L-System to the next step
	Method Iterate:Void()
		If (currentIteration < iterations)
			' Restore the L-System's starting parameters so that each iteration begins 
			' with the same conditions.
			x = startingSegment.x
			y = startingSegment.y
			angle = startingSegment.angle
			rgb = startingSegment.rgb[0 .. 3]
			bounds.x1 = startingSegment.x
			bounds.x2 = startingSegment.x
			bounds.y1 = startingSegment.y
			bounds.y2 = startingSegment.y
			bounds.dirty = False
			bounds.complete = False

			rules = preIterate + rules
			Local tempRules:String = ""
			For Local s:String = EachIn(rules.Split(""))
				If (ruleMap.Contains(s))
					tempRules += ruleMap.Get(s)
				Else
					tempRules += s
				End If
			End For
			rules = tempRules
			'
			'Note: Optimization: Latest testing shows method overhead may
			' be miniscule (7ms per 1,000,000 calls.) Investigate further.
			'
			'
			' This used to happen at the same time as the rule translations,
			' but that always left us one iteration behind. Looping through
			' the string once for replacements, then again for processing,
			' really bugs me, but the alternative is tons of slicing and
			' splicing of the string in the For loop, above. Another possible
			' solution would be maintaining an index of our position in
			' tempRules, and processing everything added during the last trip 
			' through the For loop. However, this is a good excuse to lose the
			' calls to ProcessRule(), as mentioned, below.
			'
			' Now that this has been broken out of the For loop, I am changing
			' ProcessRule() to ProcessRules(), because there's no longer any
			' point in eating the overhead for potentially hundreds of thousands
			' of method calls, when we can just loop through the rule string in
			' a single call of ProcessRules().
			' 
			' This is not ideal, since it requires subclasses to override the
			' entire rule processing facility if they want to change something,
			' but I have made the system extremely flexible, and it is entirely
			' reasonable to assume that most people using this code will never 
			' have a compelling reason to modify the core of ProcessRules(). Still,
			' I feel  like this is throwing away a tiny bit of the modularity I 
			' have been striving for in designing this code.
			'
			' Since we switched from a Stack to just using the array, directly, we
			' need to make sure the array can hold all the rules. The segments
			' array will only hold draw rules, but draw rules will usually make up
			' the majority of the rules string, so we'll just make the array big
			' enough to hold the entire rules string.
			segments = New LSystemSegment[rules.Length()]
			' Track our position in the segments array
			segmentInsertIndex = 0
			' Apply postIterate rules.
			rules += postIterate

			ProcessRules(rules)

			currentIteration += 1

		Else If Not (bounds.complete)
			bounds.complete = True
		End If
	End Method

	' This is mostly for creating the entire curve in order to calculate
	' its bounds.
	Method DryRun:Void()
		Local sign:Int = angleSign
		currentIteration = 0
		While (currentIteration < iterations)
			Iterate()
		Wend
		currentIteration = 0
		segments =[]
		rules = axiom
		x = startingSegment.x
		y = startingSegment.y
		angle = startingSegment.angle
		rgb = startingSegment.rgb[0 .. 3]
		angleSign = sign
		bounds.complete = True
	End
	
	Method ProcessRules:Void(_rules:String)
		For Local rule:String = EachIn(_rules.Split(""))
			Select rule
				Case "!"
					angleSign = -angleSign
				' Store current x, y, angle, and rgb 
				Case "[", "("
					PushState()
				' Restore x, y, angle, and rgb from last save
				Case "]"
					PopState(True, True, True, True)
				' Restore only the rgb values
				Case ")"
					PopState(False, False, False, True)
				Default
					If (colorRules.Contains(rule))
						ProcessColorRules(rule)
					EndIf
					
					If (turnRules.Contains(rule))
						ProcessTurnRules(rule)
					EndIf
					
					If (drawRules.Contains(rule))
						ProcessDrawRules(rule)
					EndIf
			End Select
		End For
	End

	' These are so I can call bits and pieces of processing from subclasses,
	' rather than duplicate code. Hopefully we're not taking much of a
	' performance hit by splitting these out into methods.
	Method ProcessColorRules:Void(_rule:String)
		Local rgbModifiers:Float[] = colorRules.Get(_rule)
		rgb[0] += rgbModifiers[0]
		rgb[1] += rgbModifiers[1]
		rgb[2] += rgbModifiers[2]
		rgb[0] = math.Max(rgbMins[0], rgb[0] Mod rgbMaxes[0])
		rgb[1] = math.Max(rgbMins[1], rgb[1] Mod rgbMaxes[1])
		rgb[2] = math.Max(rgbMins[2], rgb[2] Mod rgbMaxes[2])
	End
	Method ProcessTurnRules:Void(_rule:String)
		angle += turnRules.Get(_rule) * angleSign
	End
	Method ProcessDrawRules:Void(_rule:String)
		Local tmpSegment:LSystemSegment = New LSystemSegment()
		tmpSegment.x = x
		tmpSegment.y = y
		tmpSegment.angle = angle Mod 360
		tmpSegment.visible = drawRules.Get(_rule)
		tmpSegment.rgb = rgb[0 .. 3]
		x = x - (segmentLength * math.Sin(angle))
		y = y - (segmentLength * math.Cos(angle))
		bounds.X = x
		bounds.Y = y
		segments[segmentInsertIndex] = tmpSegment
		segmentInsertIndex += 1
	End
	
	
	Method Axiom:Void(_value:String) Property
		axiom = _value
		If (rules = "")
			rules = axiom
		EndIf
	End
		
	Method Draw:Void()
		' If chunkSize is less than or equal to 0, all available segments 
		' will be drawn on each Draw() call. Otherwise, up to chunkSize
		' segments will be drawn on each call. A chunkSize of 1 effectively
		' means "draw every segment one at a time," while a value of 10 
		' batches up to 10 segments per draw.
		'
		' Remember, we are using segmentInsertIndex to track the number of
		' rules in the stack. The length of the segments array is not a
		' reliable indicator of the actual number of elements. This is
		' annoyingly inelegant, but extensive benchmarking suggests a pretty
		' big performance hit when using other collections, such as Stacks.
		Local target:Int = segmentInsertIndex
		If (chunkSize > 0 And segmentStackPosition < segmentInsertIndex)
			target = math.Min(target, segmentStackPosition + chunkSize)
		EndIf
		'Note: Question: Performance hit on ToArray() vs Stack?
		' Got rid of Stack<LSystemSegment> for other reasons.
		' Not thrilled about having to convert to an array
		' for indexing purposes. Look into this.
		For Local i:Int = 0 To target - 1
			Local segment:LSystemSegment = segments[i]
			'Note: Question: Why bother storing invisible segments - case study.
			If (segment.visible)
				SetColor(segment.rgb[0], segment.rgb[1], segment.rgb[2])
				DrawLine(segment.x, segment.y, segment.x - (segmentLength * math.Sin(segment.angle)), segment.y - (segmentLength * math.Cos(segment.angle)))
			EndIf
		Next
		If (debugDrawing)
			SetColor(0, 255, 0)
			DrawLine(bounds.x1, bounds.y1, bounds.x2, bounds.y1)
			DrawLine(bounds.x2, bounds.y1, bounds.x2, bounds.y2)
			DrawLine(bounds.x1, bounds.y2, bounds.x2, bounds.y2)
			DrawLine(bounds.x1, bounds.y1, bounds.x1, bounds.y2)
		EndIf
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
			
	' These properties update the startingSegment when altering their values.
	' This is important if you want to make a permanent change to the curve's
	' state which will be retained when the curve is redrawn.
	'
	' These accessors also update the bounds object when necessary.
	'
	' Accessors are not necessary for retrieving values, but I don't like to
	' mix-and-match access methods for a single field.
	Method X:Void(_value:Float) Property
		If Not (bounds.dirty)
			bounds.x2 -= (x - _value)
			bounds.x1 -= (x - _value)
		EndIf
		x = _value
		startingSegment.x = x
	End
	Method X:Float() Property
		Return x
	End
	Method Y:Void(_value:Float) Property
		If Not (bounds.dirty)
			bounds.y2 -= (y - _value)
			bounds.y1 -= (y - _value)
		EndIf
		y = _value
		startingSegment.y = y
	End
	Method Y:Float() Property
		Return y
	End
	Method Angle:Void(_value:Float) Property
		angle = _value
		startingSegment.angle = angle
	End
	Method Angle:Float() Property
		Return angle
	End
	Method Visible:Void(_value:Bool) Property
		visible = _value
		startingSegment.visible = visible
	End
	Method Visible:Bool() Property
		Return visible
	End
	Method Rgb:Void(_value:Float[]) Property
		For Local i:Int = 0 To math.Min(_value.Length() -1, 2)
			rgb[i] = _value[i]
			startingSegment.rgb[i] = rgb[i]
		Next
	End
	Method Rgb:Float[] () Property
		Return rgb
	End
	Method RgbMins:Void(_value:Float[]) Property
		For Local i:Int = 0 To math.Min(_value.Length() -1, 2)
			rgbMins[i] = _value[i]
			rgb[i] = math.Max(rgb[i], rgbMins[i])
			startingSegment.rgb[i] = math.Max(startingSegment.rgb[i], rgbMins[i])
		Next
	End
	Method RgbMins:Float[] () Property
		Return rgbMins
	End
	Method RgbMaxes:Void(_value:Float[]) Property
		For Local i:Int = 0 To math.Min(_value.Length() -1, 2)
			rgbMaxes[i] = _value[i]
			rgb[i] = math.Min(rgb[i], rgbMaxes[i])
			startingSegment.rgb[i] = math.Min(startingSegment.rgb[i], rgbMaxes[i])
		Next
	End
	Method RgbMaxes:Float[] () Property
		Return rgbMaxes
	End
	
	' Positioning functions. If the complete flag on the Bounds object
	' is not set to True, a DryRun() is executed before any positioning
	' is attempted.
	Method PositionCurve:LSystem(_pos:String)
		' In most cases, processing the rules is not a significant
		' time sink. I am changing this method so it calculates the
		' size and position of the curve on ever call unless I find
		' a compelling reason to put it back the way it was.
		'If not (bounds.complete)
		'	DryRun()
		'EndIf
		DryRun()
		
		Select _pos.ToLower()
			Case "left"
				X -= bounds.x1
			Case "top"
				Y -= bounds.y1
			Case "centerx"
				X -= (bounds.MidPoint[0] - DeviceWidth() / 2.0)
			Case "right"
				X += (DeviceWidth() -bounds.x2)
			Case "centery"
				Y -= (bounds.MidPoint[1] - DeviceHeight() / 2.0)
			Case "bottom"
				Y += (DeviceHeight() -bounds.y2)
			Case "fit"
				' Call this before calling any other positioning commands.
				'Note: Feature: Add flags so fit automatically adjusts the
				' curve to remain positioned as specified by the last
				' position adjustment.
				'
				'Note: Bug: Most systems are fitted properly into the viewing
				' area. Others, such as 
				'
				' curve.Axiom = "X"
				' curve.AddTranslationRule("X", "[F]+[F]+[F]+[F]+[F]+[F]+[F]+FFX")
				' curve.AddDrawRule("F", True)
				' curve.AddTurnRule("+", -45.0)
				' curve.AddTurnRule("-", 45.0)
				'
				' are not.
				' Huh, the above curve starts fitting, again, at six iterations.

				segmentLength /= math.Min(bounds.Height / DeviceHeight(), bounds.Width / DeviceWidth())
		End
		Return Self
	End
	' Aliases for the positioning command, above. These are just convenient
	' short-hand for chaining together multiple calls.
	Method PCtr:LSystem()
		PositionCurve("centerx")
		Return PositionCurve("centery")
	End
	Method PCtrX:LSystem()
		Return PositionCurve("centerx")
	End
	Method PCtrY:LSystem()
		Return PositionCurve("centery")
	End
	Method PLft:LSystem()
		Return PositionCurve("left")
	End
	Method PRt:LSystem()
		Return PositionCurve("right")
	End
	Method PTop:LSystem()
		Return PositionCurve("top")
	End
	Method PBtm:LSystem()
		Return PositionCurve("bottom")
	End
	Method PFit:LSystem()
		Return PositionCurve("fit")
	End
End Class
