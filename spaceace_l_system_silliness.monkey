Strict

Import mojo
Import classLSystem
Import classLSystemLibrary
Import classLSystemOvoid

Function Main:Int()
	' Just to make it easy to do things like divide the segment length by the size of the canvas.

'	#GLFW_WINDOW_WIDTH=400
'	#GLFW_WINDOW_HEIGHT=400
'	SetDeviceWindow(400, 400, 0)
	#GLFW_WINDOW_WIDTH=180
	#GLFW_WINDOW_HEIGHT=180
	SetDeviceWindow(180, 180, 0)
	
	Local generator:LSystemGenerator = New LSystemGenerator()
	Local curve:LSystem = New LSystem()

	#rem
	' Peano-in-Carpet
	' Add curve from the library, then modify it.
	generator.AddCurve("peano-gosper curve", "ovoid")
	generator.curves.Last().segmentLength = DeviceWidth() / 200.0
	' DryRun() creates the entire curve and measures it's size. The bounding
	' box coordinates are stored in a Bounds object attached to the LSystem
	' object. The curve is not drawn during this process, but the curve is
	' re-measured every time it is drawn.
	'
	' Make sure all important metrics (x, y, segmentLength, etc) are set before
	' calling DryRun().
	generator.curves.Last().DryRun()
	generator.curves.Last().chunkSize = 10
	' Colors and color rules are set in the library, but let's override them.
	generator.curves.Last().rgbMaxes =[255.0, 128.0, 128.0]
	generator.curves.Last().rgbMins =[128.0, 32.0, 32.0]
	generator.curves.Last().AddColorRule("X",[0.25, 0.125, 0.125])
	generator.curves.Last().AddColorRule("F",[0.5, 0.25, 0.25])
	' Use the Bounds data to center the curve in the drawing area.
	generator.curves.Last().X -= (generator.curves.Last().bounds.MidPoint[0] - DeviceWidth() / 2)
	generator.curves.Last().Y -= (generator.curves.Last().bounds.MidPoint[1] - DeviceHeight() / 2)
	If (LSystemOvoid(generator.curves.Last()))
		LSystemOvoid(generator.curves.Last()).radX = generator.curves.Last().segmentLength / 3.0
		LSystemOvoid(generator.curves.Last()).radY = generator.curves.Last().segmentLength / 3.0
	EndIf

	
	' Create a curve, in this case by checking it out from the Library,
	' then add it to the generator.
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "sierpinski carpet")
	curve.Angle = -135.0
	curve.segmentLength = DeviceWidth() / 60.0
	curve.DryRun()
	curve.chunkSize = 20
	generator.AddCurve(curve)
	generator.curves.Last().X -= (generator.curves.Last().bounds.MidPoint[0] - DeviceWidth() / 2)
	generator.curves.Last().Y -= (generator.curves.Last().bounds.MidPoint[1] - DeviceHeight() / 2)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
#END


#rem
	' Four corners
	' Top-left Sierpinski gasket
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "non-intersecting Sierpinski gasket")
	curve.chunkSize = 12
	curve.segmentLength = DeviceHeight() / 160.0
	curve.Angle = -45.0
	curve.PTop().PLft()
	curve.rgbMaxes =[192.0, 255.0, 255.0]
	curve.rgbMins =[96.0, 128.0, 128.0]
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	' Top-right Sierpinski gasket
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "non-intersecting Sierpinski gasket")
	curve.chunkSize = 12
	curve.segmentLength = DeviceHeight() / 160.0
	curve.Angle = -135.0
	curve.PTop().PRt()
	curve.rgbMaxes =[192.0, 255.0, 255.0]
	curve.rgbMins =[96.0, 128.0, 128.0]
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	' Bottom-left Sierpinski gasket
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "non-intersecting Sierpinski gasket")
	curve.chunkSize = 12
	curve.segmentLength = DeviceHeight() / 160.0
	curve.Angle = 45.0
	curve.PBtm().PLft()
	curve.rgbMaxes =[192.0, 255.0, 255.0]
	curve.rgbMins =[96.0, 128.0, 128.0]
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	' Bottom-right Sierpinski gasket
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "non-intersecting Sierpinski gasket")
	curve.chunkSize = 12
	curve.segmentLength = DeviceHeight() / 160.0
	curve.Angle = 135.0
	curve.PBtm().PRt()
	curve.RgbMaxes =[192.0, 255.0, 255.0]
	curve.RgbMins =[96.0, 128.0, 128.0]
	Print curve.rgb[0]
	Print curve.rgb[1]
	Print curve.rgb[2]
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	' Drop-shadow Sierpinski curve
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "sierpinski curve")
	curve.chunkSize = 20
	curve.segmentLength = DeviceHeight() / 80.0
	curve.Angle = -90.0
	curve.PCtr()
	curve.X += 1
	curve.Y += 1
	curve.Rgb =[255.0, 255.0, 255.0]
	curve.colorRules.Clear()
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	' Colored Sierpinski curve
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "sierpinski curve")
	curve.chunkSize = 20
	curve.segmentLength = DeviceHeight() / 80.0
	curve.Angle = -90.0
	curve.PCtr()
	curve.rgbMaxes =[255.0, 192.0, 255.0]
	curve.rgbMins =[96.0, 128.0, 128.0]
	curve.AddColorRule("X",[0.5, 0.1, 0.1])
	curve.AddColorRule("F",[0.25, 0.0, 0.0])
	generator.AddCurve(curve)
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
#END

	#rem
	' MultiPentaplexity
	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.X = curve.X - 4
	curve.Y = curve.Y - 4
	curve.chunkSize = 0
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
	curve.AddColorRule("F",[0.4, 0.0, 0.0])
	curve.AddColorRule("G",[1.0, 0.0, 0.0])
	curve.rgbMins =[0.0, 0.0, 0.0]
	curve.rgbMaxes =[160.0, 128.0, 128.0]

	generator.AddCurve(curve)

	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.X = curve.X + 4
	curve.Y = curve.Y + 4
	curve.chunkSize = 0
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
	curve.AddColorRule("F",[0.4, 0.0, 0.0])
	curve.AddColorRule("G",[1.0, 0.0, 0.0])
	curve.rgbMins =[0.0, 0.0, 0.0]
	curve.rgbMaxes =[128.0, 160.0, 128.0]

	generator.AddCurve(curve)

	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.Y = curve.Y + 8
	curve.chunkSize = 0
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
	curve.AddColorRule("F",[0.4, 0.0, 0.0])
	curve.AddColorRule("G",[1.0, 0.0, 0.0])
	curve.rgbMins =[0.0, 0.0, 0.0]
	curve.rgbMaxes =[128.0, 128.0, 160.0]

	generator.AddCurve(curve)

	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.X = curve.X - 4
	curve.Y = curve.Y + 4
	curve.chunkSize = 0
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
	curve.AddColorRule("F",[0.4, 0.0, 0.0])
	curve.AddColorRule("G",[1.0, 0.0, 0.0])
	curve.rgbMins =[0.0, 0.0, 0.0]
	curve.rgbMaxes =[192.0, 192.0, 192.0]

	generator.AddCurve(curve)

	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.X = curve.X - 8
	curve.chunkSize = 12
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
	curve.AddColorRule("F",[0.4, 0.0, 0.0])
	curve.AddColorRule("G",[1.0, 0.0, 0.0])
	curve.rgbMins =[0.0, 0.0, 0.0]
	curve.rgbMaxes =[192.0, 224.0, 192.0]

	generator.AddCurve(curve)
	#end

	#rem
	' Pentaplexity
	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.chunkSize = 4
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 3.0
		LSystemOvoid(curve).radY = 3.0
	EndIf
		curve.AddColorRule("F",[0.4, 0.0, 0.0])
		curve.AddColorRule("G",[1.0, 0.0, 0.0])
		curve.rgbMins =[0.0, 0.0, 0.0]
		curve.rgbMaxes =[160.0, 192.0, 160.0]

	generator.AddCurve(curve)

	' Pentaplexity
	curve = New LSystemOvoid()
	curve = generator.library.CheckOut(curve, "pentaplexity")
	curve.Angle = -90.0
	curve.PCtr()
	curve.chunkSize = 4
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 1.0
		LSystemOvoid(curve).radY = 8.0
	EndIf
	generator.AddCurve(curve)

	' Accidental Nazi
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "accidental nazi")
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 1.0
		LSystemOvoid(curve).radY = 8.0
	EndIf
	generator.AddCurve(curve)

	' Dragon curve
	curve = New LSystem()
	curve = generator.library.CheckOut(curve, "dragon curve")
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 1.0
		LSystemOvoid(curve).radY = 8.0
	EndIf
	curve.PCtr()
	generator.AddCurve(curve)

	' "Blank" curve, made to order.
	' F[F[+F][-F]]F
	curve = New LSystem()
	curve.Axiom = "X"
	' Denser
'	curve.AddTranslationRule("X", "F[+[+[+[+[+[+X]X]X]X]X]X][-[-[-[-[-[-X]X]X]X]X]X]X")
	' Sparser
	curve.AddTranslationRule("X", "F[++[++[++X]X]X][--[--[--X]X]X]X")
	curve.AddTranslationRule("F", "FG")
	curve.AddTranslationRule("G", "H")
	curve.AddTranslationRule("H", "F")
	curve.AddDrawRule("F", True)
	curve.AddTurnRule("+", -10.0)
	curve.AddTurnRule("-", 10.0)
	curve.Angle = 0.0
	curve.segmentLength = DeviceHeight() / 20
	curve.iterations = 4
	curve.PFit()
	curve.Rgb([255.0, 255.0, 255.0])
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	generator.AddCurve(curve)
#end

#rem
	' "Blank" curve, made to order.
	curve = New LSystem()
	curve.Axiom = "X"
	curve.AddTranslationRule("X", "[F]+[F]+[F]+[F]+[F]+[F]+[F]+FFX")
	curve.AddDrawRule("F", True)
	curve.AddTurnRule("+", -45.0)
	curve.AddTurnRule("-", 45.0)
	curve.Angle = 0.0
	curve.segmentLength = DeviceHeight() / 20
	curve.iterations = 4
	curve.PFit()
	curve.Rgb([255.0, 255.0, 255.0])
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	generator.AddCurve(curve)

	' Box
	curve = New LSystemOvoid()
	curve.Axiom = "F+F+F+F"
	curve.AddTranslationRule("F", "FF+F++F+F")
	curve.AddDrawRule("F", True)
	curve.AddTurnRule("+", -90.0)
	curve.AddTurnRule("-", 90.0)
	curve.Angle = 45.0
	curve.segmentLength = DeviceHeight() / 420.0
	curve.iterations = 5
	curve.PFit()
	curve.Rgb([255.0, 255.0, 224.0])
	curve.AddColorRule("F",[1.0, 0.5, 0.1])
	curve.AddColorRule("+",[-0.5, -0.2, 0.1])
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	curve.chunkSize = 2048
	generator.AddCurve(curve)

	
	' Wheat
	curve = New LSystem()
	curve.Axiom = "F"
	curve.AddTranslationRule("F", "FF-[F+F+F]+[+F-F-F]")
	curve.AddDrawRule("F", True)
	curve.AddTurnRule("+", -22.0)
	curve.AddTurnRule("-", 20.0)
	curve.Angle = 45.0
	curve.segmentLength = DeviceHeight() / 40.0
	curve.iterations = 5
	curve.PFit()
	curve.Rgb([255.0, 255.0, 224.0])
	curve.AddColorRule("F",[1.0, 0.5, 0.1])
	curve.AddColorRule("+",[-0.5, -0.2, 0.1])
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2.0
		LSystemOvoid(curve).radY = 2.0
	EndIf
	curve.chunkSize = 512
	generator.AddCurve(curve)
	#end

	' Sapling
	curve = New LSystemOvoid()
	curve.Axiom = "G"
	curve.AddTranslationRule("F", "FF")
	curve.AddTranslationRule("G", "F[+G][-G]FG")
	curve.AddDrawRule("F", True)
	curve.AddDrawRule("G", False)
	curve.AddTurnRule("+", -25.7)
	curve.AddTurnRule("-", 25.7)
	curve.Angle = 0.0
	curve.segmentLength = DeviceHeight() / 260.0
	curve.iterations = 7
'	curve.PFit()
	curve.Rgb([16.0, 48.0, 8.0])
	curve.AddColorRule("F",[0.1, 0.5, 0.1])
	curve.AddColorRule("G",[0.0, 0.1, -0.05])
	curve.AddColorRule("+",[-0.1, -0.1, 0.05])
	curve.rgbMaxes =[128.0, 255.0, 160.0]
	curve.PCtr()
	If (LSystemOvoid(curve))
		LSystemOvoid(curve).radX = 2
		LSystemOvoid(curve).radY = 1.5
	EndIf
	curve.chunkSize = 4
	generator.AddCurve(curve)
	
	



	
	Return 0
End

Class LSystemGenerator Extends App
	Field updateRate:Int
	Field library:LSystemLibrary
	Field curves:List<LSystem>

	Method New()
		library = New LSystemLibrary()
		curves = New List<LSystem>
		updateRate = 0
	End Method
		
	Method AddCurve:Void(_curve:String)
		AddCurve(_curve, "")
	End

	Method AddCurve:Void(_curve:String, _type:String)
		Local system:LSystem
		Select _type
			Case "ovoid"
			system = New LSystemOvoid()
			Default
			system = New LSystem()
		End
		system = library.CheckOut(system, _curve)
		' The Create() method of LSystemOvoid objects automatically takes a guess at sizing
		' the ellipses it uses to draw the curve. However, if you do not provide a segmentLength
		' in the Create() call, that guess is based on the default segmentLength. That guess may 
		' be the wrong size for your purposes. The x radius (radX) and y radius (radY) of the 
		' ellipses can be changed, as below.
		If (LSystemOvoid(system))
			LSystemOvoid(system).radX = system.segmentLength / 2.0
			LSystemOvoid(system).radY = system.segmentLength / 2.0
		EndIf
		AddCurve(system)
	End

	Method AddCurve:Void(_system:LSystem)
		If (_system <> Null)
			curves.AddLast(_system)
		EndIf
	End
		
	Method OnCreate:Int()
		SetUpdateRate(updateRate)
		Return 1
	End Method


	Method OnUpdate:Int()
		For Local system:LSystem = EachIn(curves)
			system.Iterate()
		Next
		Return 1
	End Method
	
	Method OnRender:Int()
		Cls(238, 238, 238)
		For Local system:LSystem = EachIn(curves)
			system.Draw()
		Next
		Return 0
	End Method
End Class
