
Func farmStarstone()
	Local $level = IniRead($botConfigDir, "Farm Starstone", "level", 10)
	Local $maxGemRefill = IniRead($botConfigDir, "Farm Starstone", "refill-gems", 500)
	Local $high = IniRead($botConfigDir, "Farm Starstone", "high", 20)
	Local $mid = IniRead($botConfigDir, "Farm Starstone", "mid", 0)
	Local $low = IniRead($botConfigDir, "Farm Starstone", "low", 0)

	setLog("~~~Starting 'Farm Starstone' script~~~", 2)
	farmStarstoneMain($level, $maxGemRefill, $high, $mid, $low)
	setLog("~~~Finished 'Farm Starstone' script~~~", 2)
EndFunc   ;==>farmStarStone

Func farmStarstoneMain($level, $maxGemRefill, $high, $mid = 0, $low = 0)
	$globalScriptTimer = TimerInit()

	;setting variables
	Local $gemsUsed = 0
	Local $totHigh = $high
	Local $totMid = $mid
	Local $totLow = $low
	Local $totEgg = 0
	
	_setStarstoneDisplay($high, $totHigh, $mid, $totMid, $low, $totLow, $totEgg)
	
	Local $arrayEllipse[3] = [".", "..", "..."]
	setLogReplace("Enter stone dungeon, waiting...")

	;select level [incomplete]
	Local $tempCounter = 0
	Local $tempTimer = TimerInit()
	While checkLocations("battle,battle-auto") = ""
		If TimerDiff($tempTimer) > 300000 Then ;5 minutes
			setLog("Could not detect battle for 5 minutes, stopping script.", 2)
			Return False
		EndIf

		setLogReplace("Enter stone dungeon, waiting" & $arrayEllipse[$tempCounter])
		$tempCounter += 1
		If $tempCounter > 2 Then $tempCounter = 0

		If _Sleep(1000) Then Return False
		_setStarstoneDisplay($high, $totHigh, $mid, $totMid, $low, $totLow, $totEgg)
	WEnd

	setLog("Battle detected, beginning to farm stones.")
	;grind for starstone
	While (($high > 0) Or ($mid > 0) Or ($low > 0))
		_setStarstoneDisplay($high, $totHigh, $mid, $totMid, $low, $totLow, $totEgg)
	
		Local $currLocation = getLocation()

		antiStuck("map")
		Switch getLocation()
			Case "battle"
				clickPoint($battle_coorAuto)
				
			Case "battle-end"
				If (($high > 0) Or ($mid > 0) Or ($low > 0)) Then
					If clickUntil($battle_coorRestart, "unknown,refill", 30, 1000) = True Then
						If getLocation() = "refill" Then ContinueCase
					EndIf
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					If setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "battle-end-exp", "battle-sell", "battle-sell-item"
				clickUntil("193,255", "battle-sell-item", 500, 100)
				If _Sleep(10) Then ExitLoop

				Local $stoneInfo = getStone()
				If IsArray($stoneInfo) Then
					If Not($stoneInfo[0] = "EGG") Then
						Switch $stoneInfo[1]
							Case "LOW"
								$low -= $stoneInfo[2]
							Case "MID"
								$mid -= $stoneInfo[2]
							Case "HIGH"
								$high -= $stoneInfo[2]
						EndSwitch
					Else
						$totEgg += 1
					EndIf
				EndIf
				
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
				
			Case "battle-boss"
				waitLocation("battle-auto", 5000)
				clickPoint("406, 209")
					
			Case "pause"
				clickPoint($battle_coorContinue)
				
			Case "map"
				Return farmStarstoneMain($level, $refillGems, $high, $mid, $low)
				
		EndSwitch
	WEnd

	_setStarstoneDisplay($high, $totHigh, $mid, $totMid, $low, $totLow, $totEgg)
	Return True
EndFunc

Func _setStarstoneDisplay($high, $totHigh, $mid, $totMid, $low, $totLow, $totEgg)
	setList("High Stones: " & $totHigh-$high  & "/" & $totHigh & "|Mid Stones: " & $totMid-$mid  & "/" & $totMid & "|Low Stones: " & $totLow-$low  & "/" & $totLow & "|Eggs: " & $totEgg)
EndFunc
