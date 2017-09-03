#cs
	Function: farmForever
	Calls farmAstromonMain with config settings

	Author: Shimizoki (2017)
#ce
Func farmForever()	
	setLog("~~~Starting 'Farm Forever' script~~~", 2)
	farmForeverMain()
	setLog("~~~Finished 'Farm Forever' script~~~", 2)
EndFunc   ;==>farmForever


#cs
	Function: farmForeverMain
	Farm a type of astromon in story mode.

	Author: Shimizoki (2017)
#ce
Func farmForeverMain()
		
	While True

		antiStuck("map")
		If _Sleep(100) Then ExitLoop
		
		Local $location = getLocation()
		Switch $location
			; This case is used to trigger the "astromon-full" popup, or re-enter farm Astromon if it glitched out.
			Case "battle-end"
				clickWhile($battle_coorRestart, "battle-end", 30, 1000)
				If _Sleep(1000) Then ExitLoop
				
			; This case is used to trigger the "astromon-full" popup, or re-enter farm Astromon if it glitched out.
			Case "map-battle"
				clickWhile($map_coorBattle, "map-battle", 30, 1000)
				If _Sleep(1000) Then ExitLoop
					
			; If you are out of gold, navigate to golems	
			Case "buy-gold"
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				navigate("map", "golem-dungeons")
				
			; If your inventory is full, convert them to gems
			Case "map-astromon-full"
				navigate("village","monsters")
			
			; We should never ge stuck in an unknown location
			Case "unknown"
				clickPoint($game_coorTap)
				clickPoint(findImage("misc-close", 30)) ;to close any windows open
				ExitLoop
			
			; If you are in golems, farm them
			Case "golem-dungeons"
				farmGolem()
			
			; If on this screen, we should evolve some mons
			Case "monsters"
				setLog("~~~Starting 'Farm Gem' script~~~", 2)
				If Not farmGemMain(IniRead($botConfigDir, "Farm Gem", "monster", Null), 1, IniRead($botConfigDir, "Farm Gem", "gems-to-farm", Null), IniRead($botConfigDir, "Farm Gem", "refill-max", Null), 0) Then
					navigate("map", "golem-dungeons")
				Else
					navigate("map")
				EndIf
			
			; If you are unsure where to start, farm astromon
			Case Else
				farmAstromon()
				
		EndSwitch
	WEnd
	
	Return
EndFunc   ;==>farmForeverMain
