Strict

Import classLSystem
Import classMapCloner

Class LSystemLibrary
	Field system:LSystem
	Field Library:StringMap<LSystem>
	
	Method New()
		Library = New StringMap<LSystem>
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Non-intersecting Sierpinski gasket
		system = New LSystem()
		system.Create(0, DeviceHeight() -1)
		' These are the translation rules. Whenever a "b" is encountered in the rule string, it will be
		' replaced by "b#-a#-b#." Any "b" in the rule string will be replaced by "a+b+a." Read on for more
		' information on what these symbols mean.
		system.AddTranslationRule("a", "b#-a#-b#")
		system.AddTranslationRule("b", "a+b+a")
		' In the original code, I had extended the LSystem class and overridden the Iterate() method to
		' flip the angleSign after each iteration. The reason for this is that the non-intersecting 
		' Sierpinski gasket changes orientation on each iteration. In order to keep it facing the
		' right way, the angle needs to be reversed after each iteration. In order to keep the code
		' short and simple for posting on the Monkey-X forums, I've used this little bit of trickery
		' rather than using an extended class.
		'
		' Anything in postIterate is added to the rules after each iteration. The "!" symbol is a built-in
		' command that tells the LSystem to flip the sign of the angle currently being used to draw line
		' segments. By putting "!" into the postIterate field, we are effectively flipping the angleSign
		' value once per iteration. However, we only want one "!" in the entire rule string, at the very end.
		' So, we also add a translation rule that tells the rule parser to replace "!" with an empty string.
		' The overall effect is that the angleSign gets reversed, then the "!" gets removed from the rule string,
		' and a new "!" is added to the end. This gives us the once-per-draw flipping effect we want.
'		system.AddTranslationRule("!", "G!")
		system.AddTranslationRule("G", "H")
		system.AddTranslationRule("H", "!H")
'		system.postIterate = "!"
'		system.preIterate = "!"
		' Tell the L-System to draw when it encounters an "a" or a "b" in the rule string.
		system.AddDrawRule("a", True)
		system.AddDrawRule("b", True)
		' Tell the L-System to turn by -60.0 degrees when it encounters a "+" in the rule string.
		system.AddTurnRule("+", -60.0)
		' Tell the L-System to turn by 60.0 degrees when it encounters a "-" in the rule string.
		system.AddTurnRule("-", 60.0)
		' Add a rule to modify the drawing color whenever a "#" is encountered in the rule string. In this case,
		' we are telling the system to increase red by 0.5, green by 1.0, and blue by .75 each time a "#" is
		' processed.
		system.AddColorRule("#",[0.75, 0.25, 0.75])
		' Set the maximum red value for any line segment to 128.0. Set the maximum green and blue values to 
		' 255.0 each.
		system.RgbMaxes =[192.0, 255.0, 255.0]
		' Set the minimum color values for red, green, and blue. Both this call and the one
		' above are using accessors rather than directly modifying the rgb arrays. The
		' accessors do helpful things like make sure the current RGB values obey the minimum
		' and maximum values as you set them.
		system.RgbMins =[32.0, 64.0, 64.0]
		' Every L-System needs a starting point, otherwise there's nothing for the translation rules to do.
		' The axiom is the entry point for the entire process.
		system.Axiom = "a!"
		system.segmentLength = DeviceHeight() / 65.0
		system.iterations = 7
		' If you change properties such as the x and y coordinates, or the angle, and you want those changes
		' to be stored as the starting point for iterating the L-System, call this method after you make
		' your changes. Be sure you've called Create() or otherwise insitialized the startingSegment member of
		' you LSystem object, first.
		system.StorestartingSegment()
		Library.Add("non-intersecting sierpinski gasket", system)

		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Sierpinski carpet
		system = New LSystem()
		system.Create(0, DeviceHeight() / 2)
		' Spaces and unknown symbols are ignored
		' Symbols are case-sensitive
		system.AddTranslationRule("F", "F + F - F            -      FF - F - F - f           F")
		system.AddTranslationRule("f", "fff")
		system.AddDrawRule("F", True)
		system.AddDrawRule("f", False)
		system.AddTurnRule("+", -90.0)
		system.AddTurnRule("-", 90.0)
		system.Axiom = "F"
		system.AddColorRule("F",[4.0, 2.0, 1.0])
		system.rgbMaxes =[255.0, 255.0, 128.0]
		system.angle = -90
		' We did not specify a segmentLength when we called Create(), but we set it, here.
		' However, if you are drawing this curve using an LSystemOvoid object, this can
		' mean trouble. See the comments, below, for more information.
		system.segmentLength = DeviceHeight() / 80.0
		system.iterations = 4
		system.StorestartingSegment()
		Library.Add("sierpinski carpet", system)

		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Capillary system
		system = New LSystem()
		system.Create(DeviceWidth() / 2, DeviceHeight() -1)
		system.AddTranslationRule("0", "#1#[$+0$]$-%0%")
		system.AddTranslationRule("1", "#1#1#")
		system.AddDrawRule("0", True)
		system.AddDrawRule("1", True)
		system.AddTurnRule("+", -45.0)
		system.AddTurnRule("-", 45.0)
		' The #, $, and % symbols are not included in the Draw Rules, so they will
		' not cause any line segments to be drawn. Rather, those symbols are meant
		' to control the colors of the system. So, we add them to the Color Rules.
		system.AddColorRule("#",[1.0, 2.0, 8.0])
		system.AddColorRule("$",[2.0, 4.0, 2.0])
		system.AddColorRule("%",[1.0, 1.0, 1.0])
		system.rgbMaxes =[192.0, 192.0, 128.0]
		system.Axiom = "0"
		system.angle = 0
		system.segmentLength = DeviceHeight() / 58.5
		system.iterations = 6
		system.StorestartingSegment()
		Library.Add("capillary system", system)
		
						
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Dragon curve
		system = New LSystem()
		system.Create(DeviceWidth() / 3.75, DeviceHeight() / 1.75)
		system.AddTranslationRule("a", "a+b+")
		system.AddTranslationRule("b", "-a-b")
		system.AddDrawRule("a", True)
		system.AddDrawRule("b", True)
		system.AddTurnRule("+", -90.0)
		system.AddTurnRule("-", 90.0)
		#rem
			This is an alternate way to draw the Dragon Curve. I am
			not giving this its own library entry because, unlike 
			Sierpinskis A and B, there is no real difference between
			the final curves generated by the different rule sets.
			
			This method uses 65,533 segments for a 14-iteration curve. 
			The one defined, above, uses 49,150 segments to produce the
			same (or a very similar) curve.

			system.AddTranslationRule("a", "-a++b")
			system.AddTranslationRule("b", "a--b+")
			system.AddTurnRule("+", -45.0)
			system.AddTurnRule("-", 45.0)
		#END
		' Here we see how you can "double-up" on rules. Now, the symbol "a" will both draw a line segment
		' and change the rgb values.
		system.AddColorRule("a",[1.0, 0.0, 0.0])
		system.rgbMaxes =[255.0, 255.0, 255.0]
		system.Axiom = "a"
		' Start off with pen lines facing to the right
		system.angle = -90
		system.segmentLength = 4.4
		system.iterations = 13
		system.StorestartingSegment()
		Library.Add("dragon curve", system)

		
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'			Hilbert curve
		system = New LSystem()
		system.Create(0, 0)
		system.AddTranslationRule("L", "+RF-LFL-FR+")
		system.AddTranslationRule("R", "-LF+RFR+FL-")
		system.AddDrawRule("F", True)
		system.AddTurnRule("+", -90.0)
		system.AddTurnRule("-", 90.0)
		system.AddColorRule("L",[0.5, 0.5, 0.0])
		system.AddColorRule("F",[0.0, 0.0, 1.0])
		system.rgbMaxes =[128.0, 255.0, 128.0]
		system.Axiom = "L"
		system.angle = -90
		system.segmentLength = DeviceHeight() / 30
		system.iterations = 5
		' Draw each segment individually. This lets you watch the curve grow
		' instead of having it appear in chunks.
		system.chunkSize = False
		' Increase the updating speed because we are going to require a lot more draw
		' calls to complete the figure now that chunkSize is set to false.
		system.StorestartingSegment()
		Library.Add("hilbert curve", system)

		
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Pino-Grigio curve
		'	Ha ! Just kidding. Peano-Gosper curve
		system = New LSystem()
		system.Create(DeviceWidth() / 1.60, 0)
		system.AddTranslationRule("X", "X+YF++YF-FX--FXFX-YF+")
		system.AddTranslationRule("Y", "-FX+YFYF++YF+FX--FX-Y")
		system.AddDrawRule("F", True)
		system.AddTurnRule("+", -60.0)
		system.AddTurnRule("-", 60.0)
		' The axiom can be a single symbol, or a string of symbols. The axiom can contain
		' any symbols used by any of the rules you define.
		system.Axiom = "FX"
		system.AddColorRule("X",[4.0, 2.0, 1.0])
		system.AddColorRule("F",[4.0, 2.0, 1.0])
		system.rgbMaxes =[255.0, 255.0, 128.0]
		system.angle = -90
		system.segmentLength = DeviceHeight() / 60.0
		system.iterations = 4
		system.StorestartingSegment()
		Library.Add("peano-gosper curve", system)
				
		
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		'	Sierpinski curve
		system = New LSystem()
		system.Create(DeviceWidth() / 2, 0)
		system.AddTranslationRule("X", "XF-F+F-XF+F+XF-F+F-X")
		system.AddDrawRule("F", True)
		system.AddDrawRule("X", True)
		system.AddTurnRule("+", -90.0)
		system.AddTurnRule("-", 90.0)
		' The axiom can be a single symbol, or a string of symbols. The axiom can contain
		' any symbols used by any of the rules you define.
		' The axiom, or starting point, can be a complex string
		system.Axiom = "F+XF+F+XF"
		system.AddColorRule("X",[0.5, 0.4, 0.3])
		system.AddColorRule("F",[0.3, 0.2, 0.1])
		system.rgbMins =[32.0, 32.0, 48.0]
		system.rgbMaxes =[192.0, 192.0, 128.0]
		system.angle = -90
		system.segmentLength = DeviceHeight() / 77.0
		system.iterations = 4
		system.StorestartingSegment()
		Library.Add("sierpinski curve", system)


		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		' Pentaplexity
		system = New LSystem()
		system.Create(DeviceWidth() / 2, 0)
		system.AddTranslationRule("F", "F++F++F|F-F++FG")
		system.AddDrawRule("F", True)
		system.AddTurnRule("+", -36.0)
		system.AddTurnRule("-", 36.0)
		system.AddTurnRule("|", 180.0)
		system.Axiom = "F++F++F++F++F"
		system.AddColorRule("F",[0.6, 0.6, 0.6])
		system.AddColorRule("G",[6.0, 1.0, 2.0])
		system.rgbMins =[64.0, 64.0, 96.0]
		system.rgbMaxes =[192.0, 192.0, 128.0]
		system.angle = -90
		system.segmentLength = DeviceHeight() / 30.0
		system.Rgb =[255.0, 255.0, 255.0]
		system.chunkSize = 4
		system.iterations = 3
'		system.StorestartingSegment()
		Library.Add("pentaplexity", system)

		
		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
		' Accidental Nazi
		system = New LSystem()
		system.Create(0, 0)
		system.AddTranslationRule("F", "FFF+FF+F+F-F-FF+F+FFF")
		system.AddDrawRule("F", True)
		system.AddDrawRule("G", False)
		system.AddTurnRule("+", -90.0)
		system.AddTurnRule("-", 90.0)
		system.AddTurnRule("|", 180.0)
		system.Axiom = "F"
		system.rgbMins =[64.0, 64.0, 96.0]
		system.rgbMaxes =[192.0, 192.0, 128.0]
		system.angle = -90.0
		system.segmentLength = DeviceHeight() / 50.0
		system.Rgb =[255.0, 255.0, 255.0]
		system.chunkSize = 1
		system.iterations = 2
		system.StorestartingSegment()
		Library.Add("accidental nazi", system)
		

		'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	End
	
	Method CheckOut:LSystem(_system:LSystem, _curve:String)
		If (_curve = "")
			Return Null
		End
		
		
		If (Library.Contains(_curve.ToLower()))
			Local mc:MapCloner<StringMap<String>> = New MapCloner<StringMap<String>>()
			Local tmp:LSystem = New LSystem()
			tmp = Library.Get(_curve.ToLower())
			_system.segmentLength = tmp.segmentLength
			_system.iterations = tmp.iterations
			_system.ruleMap = MapCloner<StringMap<String>>.Clone(tmp.ruleMap)
			_system.axiom = tmp.axiom
			_system.rules = tmp.rules
			_system.x = tmp.x
			_system.y = tmp.y
			_system.angle = tmp.angle
			_system.preIterate = tmp.preIterate
			_system.postIterate = tmp.postIterate
			_system.angleSign = tmp.angleSign
			_system.drawRules = MapCloner<StringMap<Bool>>.Clone(tmp.drawRules)
			_system.turnRules = MapCloner<StringMap<Float>>.Clone(tmp.turnRules)
			_system.colorRules = MapCloner<StringMap<Float[] > >.Clone(tmp.colorRules)
			_system.rgb = tmp.rgb[0..3]
			_system.rgbMins = tmp.rgbMins[0 .. 3]
			_system.rgbMaxes = tmp.rgbMaxes[0 .. 3]
			_system.startingSegment = tmp.startingSegment.Clone()
			_system.chunkSize = tmp.chunkSize

			tmp = Null
			Return _system
		EndIf

		Return Null
	End
End